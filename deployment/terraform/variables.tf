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

variable "project_id" {
  description = "Project id"
}

variable "bucket_name" {
  description = "Bucket name for SLO configs"
}

variable "pubsub_topic_name" {
  description = "SLO Pipeline pubsub topic name"
  default     = "slo-generator-export"
}

variable "slo_generator_version" {
  description = "SLO Generator version"
}

variable "apps" {
  description = "Apps variables"
  type        = map
}

variable "backends" {
  description = "Backends options"
  type        = map
}

variable "schedule" {
  description = "Cron-like Cloud Scheduler schedule"
  default     = "* * * * */1"
}

variable "region" {
  description = "Region"
  default     = "us-east1"
}

variable "labels" {
  description = "Project labels"
  default     = {}
}

variable "service_account_name" {
  description = "Service account email"
  type        = string
}
