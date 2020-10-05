# SLO Repository

This repository is an example SLO repository for `slo-generator`, i.e the repository where all your
SLOs will be stored.

The `slos/` folder contains examples for real-world applications:

* `providers/`:
  * `gcp`: GCP SLOs.
  
* `apps/`:
  * `custom-example/`: Test SLOs for custom backends.
  * `flask-app-prometheus/`: SLOs for Flask app instrumented with Prometheus
SDK (see [app code](https://github.com/ocervell/gunicorn-opentelemetry-poc/tree/arch/prometheus))
  * `flask-app-datadog/`: SLOs for Flask app instrumented with Datadog
SDK (see [app code](https://github.com/ocervell/gunicorn-opentelemetry-poc/tree/feature/datadog))
  * `slo-generator/`: SLOs for slo-generator deployment on Cloud Functions.
  * `datadog-example/`: Test SLOs for Datadog backend.
  
The `deployment/` folder contains different deployment methods:
* `k8s`: Deploy `slo-generator` on Kubernetes.
* `terraform`: Deploy `slo-generator` using the [terraform-google-slo](https://github.com/terraform-google-modules/terraform-google-slo) modules (Cloud Scheduler + Cloud Functions + PubSub).
