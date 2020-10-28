project_id = "<GCP_PROJECT_ID>"

region = "<GCP_REGION>"

bucket_name = "<GCS_BUCKET_NAME>"

pubsub_topic_name = "<PIPELINE_PUBSUB_TOPIC_NAME>"

service_account_name = "<SLO_SERVICE_ACCOUNT_NAME>"

slo_generator_version = "1.3.2"

schedule = "*/2 * * * *"

backends = {
  datadog = {
    api_key = "<DATADOG_API_KEY>"
    app_key = "<DATADOG_APP_KEY>"
    slo_id  = "<DATADOG_SLO_ID>"
  }
  dynatrace = {
    api_token = "DATADOG_API_TOKEN"
    api_url   = "DATADOG_API_URL"
  }
  prometheus = {
    url      = "<PROMETHEUS_URL>"
    push_url = "<PROMETHEUS_PUSH_URL>"
  }
  stackdriver = {
    host_project_id = "<STACKDRIVER_HOST_PROJECT_ID>"
  }
  bigquery = {
    project_id = "<BIGQUERY_PROJECT_ID>"
    dataset_id = "<BIGQUERY_DATASET_ID>"
    table_id   = "<BIGQUERY_TABLE_ID>"
  }
}

apps = {
  online_boutique = {
    project_id   = "<ONLINE_BOUTIQUE_PROJECT_ID>"
    location     = "<ONLINE_BOUTIQUE_CLUSTER_LOCATION>"
    cluster_name = "<ONLINE_BOUTIQUE_CLUSTER_NAME>"
    namespace    = "default"
  }
}
