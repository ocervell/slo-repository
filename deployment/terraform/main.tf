/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  config        = yamldecode(file("../../slos/config.yaml"))
  config_export = yamldecode(file("../../slos/config_export.yaml"))
  slo_configs   = [
    for cfg in fileset(path.module, "../../slos/**/slo_*.yaml") :
    yamldecode(file(cfg))
  ]
}

# Uncomment for shared scheduler setup
#resource "google_cloud_scheduler_job" "scheduler" {
#  project  = var.project_id
#  region   = var.region
#  schedule = "* * * * *"
#  name     = "every-1-minute"
#  http_target {
#    oidc_token {
#      service_account_email = module.slo-generator.service_account_email
#      audience              = module.slo-generator.service_url
#    }
#    http_method = "POST"
#    uri         = "${module.slo-generator.service_url}/?batch=true"
#    body        = base64encode(join(";", [for config in local.slo_configs : "gs://${module.slo-generator.bucket_name}/slos/${config.metadata.name}.yaml"]))
#  }
#}

module "slo-generator" {
  source                = "git::https://github.com/terraform-google-modules/terraform-google-slo//modules/slo-generator?ref=slo-generator-v2"
  project_id            = var.project_id
  region                = var.region
  slo_generator_version = var.slo_generator_version
  config                = local.config
  slo_configs           = local.slo_configs
  # create_cloud_schedulers = false # uncommented for shared scheduler setup
  annotations           = {
    "autoscaling.knative.dev/minScale" = "1"
    "autoscaling.knative.dev/maxScale" = "10"
  }
  concurrency           = 1000
  env                   = {
    ENV                          = terraform.workspace
    PROJECT_ID                   = var.project_id
    DYNATRACE_API_URL            = var.backends.dynatrace.api_url
    ONLINE_BOUTIQUE_PROJECT_ID   = var.apps.online_boutique.project_id
    ONLINE_BOUTIQUE_LOCATION     = var.apps.online_boutique.location
    ONLINE_BOUTIQUE_CLUSTER_NAME = var.apps.online_boutique.cluster_name
    ONLINE_BOUTIQUE_NAMESPACE    = var.apps.online_boutique.namespace
    STACKDRIVER_HOST_PROJECT_ID  = var.backends.stackdriver.host_project_id
    PROMETHEUS_URL               = var.backends.prometheus.url
    SERVICE_URL                  = module.slo-pipeline.service_url
    DATADOG_SLO_ID               = var.backends.datadog.slo_id
  }
  secrets               = {
    DATADOG_API_KEY              = var.backends.datadog.api_key
    DATADOG_APP_KEY              = var.backends.datadog.app_key
    DYNATRACE_API_TOKEN          = var.backends.dynatrace.api_token
  }
}

resource "google_project_iam_member" "metric-viewer" {
  project = var.backends.stackdriver.host_project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${module.slo-generator.service_account_email}"
}

resource "google_project_iam_member" "slo-creator" {
  project = var.apps.online_boutique.project_id
  role    = "roles/monitoring.servicesEditor"
  member  = "serviceAccount:${module.slo-generator.service_account_email}"
}

module "slo-pipeline" {
  source                = "git::https://github.com/terraform-google-modules/terraform-google-slo//modules/slo-generator?ref=slo-generator-v2"
  service_name          = "slo-generator-export"
  project_id            = var.project_id
  region                = var.region
  slo_generator_version = var.slo_generator_version
  config                = local.config_export
  target                = "run_export"
  signature_type        = "cloudevent"
  env                   = {
    BIGQUERY_PROJECT_ID         = var.backends.bigquery.project_id
    BIGQUERY_DATASET_ID         = var.backends.bigquery.dataset_id
    BIGQUERY_TABLE_ID           = var.backends.bigquery.table_id
    STACKDRIVER_HOST_PROJECT_ID = var.backends.stackdriver.host_project_id
  }
  authorized_members = [
    "serviceAccount:${module.slo-generator.service_account_email}"
  ]
}

resource "google_project_iam_member" "metric-writer" {
  project = var.backends.stackdriver.host_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${module.slo-pipeline.service_account_email}"
}

resource "google_project_iam_member" "bq-data-editor" {
  project = var.backends.stackdriver.host_project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${module.slo-pipeline.service_account_email}"
}
