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
  # Exporters (common)
  exporters = yamldecode(templatefile("../../slos/exporters.yaml",
    {
      STACKDRIVER_HOST_PROJECT_ID = var.backends.stackdriver.host_project_id
      PROJECT_ID                  = var.project_id
      PUBSUB_TOPIC_NAME           = module.slo-pipeline.pubsub_topic_name
  }))

  # Error budget policy (common)
  error_budget_policy = yamldecode(file("../../slos/error_budget_policy.yaml"))

  # SLO configs
  slo_configs = [
    for file in fileset(path.module, "../../slos/**/slo_*.yaml") :
    merge(yamldecode(templatefile(file,
      {
        DATADOG_API_KEY             = var.backends.datadog.api_key
        DATADOG_APP_KEY             = var.backends.datadog.app_key
        DATADOG_SLO_ID              = var.backends.datadog.slo_id
        PROMETHEUS_URL              = var.backends.prometheus.url
        PROJECT_ID                  = var.project_id
        STACKDRIVER_HOST_PROJECT_ID = var.backends.stackdriver.host_project_id
      })), {
      exporters = local.exporters.slo
    })
  ]
  slo_configs_map = {
    for config in local.slo_configs :
    "${config.service_name}-${config.feature_name}-${config.slo_name}" => config
  }
}

module "slo-pipeline" {
  source                = "terraform-google-modules/slo/google//modules/slo-pipeline"
  project_id            = var.project_id
  region                = var.region
  exporters             = local.exporters.pipeline
  slo_generator_version = var.slo_generator_version
}

module "slos" {
  for_each                   = local.slo_configs_map
  source                     = "terraform-google-modules/slo/google//modules/slo"
  schedule                   = var.schedule
  region                     = var.region
  project_id                 = var.project_id
  labels                     = var.labels
  config                     = each.value
  error_budget_policy        = local.error_budget_policy
  service_account_email      = var.service_account_email
  use_custom_service_account = true
  slo_generator_version      = var.slo_generator_version
}
