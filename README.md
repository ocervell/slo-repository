# SLO Repository Sample

This repository is an example SLO repository, i.e the repository where all your
SLOs will be stored.

The `slos/` folder contains folders that each map to one application:

* `custom-example/`: Test SLOs for custom backends.
* `datadog-example/`: Test SLOs for Datadog backend.
* `prometheus-flask-app/`: SLOs for Flask app instrumented with Prometheus
SDK (see [app code](https://github.com/ocervell/gunicorn-opentelemetry-poc/tree/prometheus))
* `slo-generator/`: SLOs for slo-generator deployment on Cloud Functions.

The `deployment/` folder contains different deployment methods:
* `k8s`: Deploy `slo-generator` on Kubernetes.
* `terraform`: Deploy `slo-generator` using the [terraform-google-slo](https://github.com/terraform-google-modules/terraform-google-slo) modules (Cloud Scheduler + Cloud Functions + PubSub).
