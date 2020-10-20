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

provider "google" {
  version = "~> 3.19"
}

provider "google-beta" {
  version = "~> 3.19"
}

locals {
  # Exporters paths
  exporters_path_pipeline = "../../slos/exporters_pipeline.yaml"
  exporters_vars_pipeline = {
    PROJECT_ID                  = var.project_id
    STACKDRIVER_HOST_PROJECT_ID = var.backends.stackdriver.host_project_id
    PROMETHEUS_PUSH_URL         = var.backends.prometheus.push_url
    DATADOG_API_KEY             = var.backends.datadog.api_key
    DATADOG_APP_KEY             = var.backends.datadog.app_key
    DYNATRACE_API_TOKEN         = var.backends.dynatrace.api_token
    DYNATRACE_API_URL           = var.backends.dynatrace.api_url
    BIGQUERY_PROJECT_ID         = var.backends.bigquery.project_id
    BIGQUERY_TABLE_ID           = var.backends.bigquery.table_id
    BIGQUERY_DATASET_ID         = var.backends.bigquery.dataset_id
  }
  exporters_path_slo = "../../slos/exporters_slo.yaml"
  exporters_vars_slo = {
    PROJECT_ID        = var.project_id
    PUBSUB_TOPIC_NAME = module.slo-pipeline.pubsub_topic_name
  }

  # Error budget policy paths
  error_budget_policy_path     = "../../slos/error_budget_policy.yaml"
  error_budget_policy_path_ssm = "../../slos/error_budget_policy_ssm.yaml"

  # SLO config paths
  slo_configs_paths_ob   = fileset(path.module, "../../slos/online-boutique/slo_*.yaml")
  slo_configs_paths_prom = fileset(path.module, "../../slos/flask-app-prometheus/slo_*.yaml")
  slo_configs_paths_dd   = fileset(path.module, "../../slos/flask-app-datadog/slo_*.yaml")
  slo_configs_paths_gen  = fileset(path.module, "../../slos/slo-generator/slo_*.yaml")
  slo_configs_vars = {
    PROJECT_ID                   = var.project_id
    STACKDRIVER_HOST_PROJECT_ID  = var.backends.stackdriver.host_project_id
    PROMETHEUS_URL               = var.backends.prometheus.url
    DATADOG_API_KEY              = var.backends.datadog.api_key
    DATADOG_APP_KEY              = var.backends.datadog.app_key
    DATADOG_SLO_ID               = var.backends.datadog.slo_id
    DYNATRACE_API_TOKEN          = var.backends.dynatrace.api_token
    DYNATRACE_API_URL            = var.backends.dynatrace.api_url
    ONLINE_BOUTIQUE_PROJECT_ID   = var.apps.online_boutique.project_id
    ONLINE_BOUTIQUE_LOCATION     = var.apps.online_boutique.location
    ONLINE_BOUTIQUE_CLUSTER_NAME = var.apps.online_boutique.cluster_name
    ONLINE_BOUTIQUE_NAMESPACE    = var.apps.online_boutique.namespace
  }
}

#-----------------------------#
# Shared SLOs service account #
#-----------------------------#
resource "google_service_account" "slo" {
  project    = var.project_id
  account_id = var.service_account_name
}

#----------------------------#
# Shared SLOs storage bucket #
#----------------------------#
resource "google_storage_bucket" "slos" {
  project                     = var.project_id
  location                    = "EU"
  name                        = var.bucket_name
  uniform_bucket_level_access = true
}

#---------------------#
# Shared SLO pipeline #
#---------------------#
module "slo-pipeline" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-slo.git//modules/slo-pipeline?ref=slo-generator-v1.3.0-new"
  # source                = "../../../../../terraform/modules/terraform-google-slo//modules/slo-pipeline"
  # source                = "terraform-google-modules/slo/google//modules/slo-pipeline"
  # version               = "0.2.2"
  project_id            = var.project_id
  region                = var.region
  exporters_path        = local.exporters_path_pipeline
  exporters_vars        = local.exporters_vars_pipeline
  slo_generator_version = var.slo_generator_version
  dataset_create        = false
  pubsub_topic_name     = "slo-generator-export"
}

#----------------------#
# Online Boutique SLOs #
#----------------------#
module "slos-online-boutique" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-slo.git//modules/slo?ref=slo-generator-v1.3.0-new"
  #source                     = "../../../../../terraform/modules/terraform-google-slo//modules/slo"
  # source                     = "terraform-google-modules/slo/google//modules/slo"
  # version                    = "0.2.2"
  for_each                   = local.slo_configs_paths_ob
  schedule                   = var.schedule
  region                     = var.region
  project_id                 = var.project_id
  labels                     = var.labels
  config_path                = each.value
  config_vars                = local.slo_configs_vars
  exporters_path             = local.exporters_path_slo
  exporters_vars             = local.exporters_vars_slo
  error_budget_policy_path   = local.error_budget_policy_path_ssm
  service_account_email      = google_service_account.slo.email
  use_custom_service_account = true
  slo_generator_version      = var.slo_generator_version
  config_bucket              = google_storage_bucket.slos.name
}

#------------------------#
# Flask App Datadog SLOs #
#------------------------#
module "slos-flask-app-datadog" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-slo.git//modules/slo?ref=slo-generator-v1.3.0-new"
  #source                     = "../../../../../terraform/modules/terraform-google-slo//modules/slo"
  # source                     = "terraform-google-modules/slo/google//modules/slo"
  # version                    = "0.2.2"
  for_each                   = local.slo_configs_paths_dd
  schedule                   = var.schedule
  region                     = var.region
  project_id                 = var.project_id
  labels                     = var.labels
  config_path                = each.value
  config_vars                = local.slo_configs_vars
  exporters_path             = local.exporters_path_slo
  exporters_vars             = local.exporters_vars_slo
  error_budget_policy_path   = local.error_budget_policy_path
  service_account_email      = google_service_account.slo.email
  use_custom_service_account = true
  slo_generator_version      = var.slo_generator_version
  config_bucket              = google_storage_bucket.slos.name
}

#---------------------------#
# Flask App Prometheus SLOs #
#---------------------------#
module "slos-flask-app-prometheus" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-slo.git//modules/slo?ref=slo-generator-v1.3.0-new"
  #source                     = "../../../../../terraform/modules/terraform-google-slo//modules/slo"
  # source                     = "terraform-google-modules/slo/google//modules/slo"
  # version                    = "0.2.2"
  for_each                   = local.slo_configs_paths_prom
  schedule                   = var.schedule
  region                     = var.region
  project_id                 = var.project_id
  labels                     = var.labels
  config_path                = each.value
  config_vars                = local.slo_configs_vars
  exporters_path             = local.exporters_path_slo
  exporters_vars             = local.exporters_vars_slo
  error_budget_policy_path   = local.error_budget_policy_path
  service_account_email      = google_service_account.slo.email
  use_custom_service_account = true
  slo_generator_version      = var.slo_generator_version
  config_bucket              = google_storage_bucket.slos.name
}

#--------------------#
# SLO Generator SLOs #
#--------------------#
module "slos-generator" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-slo.git//modules/slo?ref=slo-generator-v1.3.0-new"
  #source                     = "../../../../../terraform/modules/terraform-google-slo//modules/slo"
  # source                     = "terraform-google-modules/slo/google//modules/slo"
  # version                    = "0.2.2"
  for_each                   = local.slo_configs_paths_gen
  schedule                   = var.schedule
  region                     = var.region
  project_id                 = var.project_id
  labels                     = var.labels
  config_path                = each.value
  config_vars                = local.slo_configs_vars
  exporters_path             = local.exporters_path_slo
  exporters_vars             = local.exporters_vars_slo
  error_budget_policy_path   = local.error_budget_policy_path
  service_account_email      = google_service_account.slo.email
  use_custom_service_account = true
  slo_generator_version      = var.slo_generator_version
  config_bucket              = google_storage_bucket.slos.name
}
