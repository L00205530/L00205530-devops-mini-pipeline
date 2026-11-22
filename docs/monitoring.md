# L00205530 — Monitoring Implementation

## Overview

This project implements application monitoring for a containerized Flask application deployed to Kubernetes.

The monitoring stack consists of:

- **Prometheus:** Collects application metrics using Kubernetes pod discovery.
- **Grafana:** Visualizes application availability, throughput, HTTP errors, and latency.
- **Kubernetes:** Runs two Flask replicas and the monitoring components.
- **Helm:** Manages monitoring deployments.
- **Git:** Version-controls monitoring configuration and dashboards.

## Architecture

```text
Flask Replica 1 ──┐
                  ├──> Prometheus ──> Grafana
Flask Replica 2 ──┘
     /metrics          Scraping       Dashboards
```

Prometheus discovers Flask pods using Kubernetes metadata and scrapes their `/metrics` endpoints every 15 seconds.

Grafana connects to Prometheus using the internal Kubernetes service address:

`http://prometheus-server.monitoring.svc.cluster.local`

## Monitoring Dashboard

The dashboard is named **L00205530 - DevOps Monitoring**.

It contains four panels:

| Panel | Purpose |
|---|---|
| Available Flask Replicas | Counts healthy Prometheus scrape targets |
| HTTP Requests per Second | Measures application request throughput |
| HTTP 5xx Error Rate | Shows the percentage of server-error responses |
| P95 HTTP Response Latency | Estimates the 95th percentile of request duration |

Dashboard definitions are stored in `monitoring/grafana/dashboards/devops-monitoring.json`.

## Deployment

Prerequisites:

- Kubernetes cluster
- Helm
- kubectl
- Flask application deployed to Kubernetes
- Grafana administrator Secret named `grafana-admin` in the `monitoring` namespace

Create the namespace and administrator Secret before the initial deployment.

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

read -rsp "Grafana admin password: " GRAFANA_PASSWORD
echo

kubectl create secret generic grafana-admin \
  --namespace monitoring \
  --from-literal=admin-user=admin \
  --from-literal=admin-password="$GRAFANA_PASSWORD"

unset GRAFANA_PASSWORD
```

Deploy monitoring:

```bash
./scripts/deploy-monitoring.sh
```

The script installs Prometheus and Grafana using pinned Helm chart versions and provisions the dashboard through a Kubernetes ConfigMap.

## Verification

```bash
helm list -n monitoring
kubectl get pods -n monitoring
kubectl get deployment l00205530-flask
kubectl get configmap l00205530-grafana-dashboards -n monitoring
```

Access Grafana:

```bash
kubectl port-forward -n monitoring service/grafana 3000:80
```

Open `http://localhost:3000`.

In Grafana Explore, use:

```promql
up{job="l00205530-flask"}
```

A healthy deployment with two replicas should return two series with value `1`.

## Security and Operational Considerations

- Grafana administrator credentials are stored in a Kubernetes Secret, not in Git.
- Monitoring services use internal Kubernetes ClusterIP networking.
- Grafana dashboards and data sources are provisioned through version-controlled configuration.
- Prometheus and Grafana persistence are disabled for this local development environment.
- Historical Prometheus data may be lost when its storage is recreated.
- For production, persistent storage, access controls, TLS, alerting, and appropriate resource planning would be required.

## Validation Results — 22 November 2026

- Flask deployment: 2/2 replicas available.
- Flask pods: both Running, zero restarts.
- Prometheus Helm release: deployed, revision 5.
- Grafana Helm release: deployed, revision 5.
- Grafana dashboard: provisioned successfully.
- HTTP 5xx panel: verified displaying zero when no error series exists.
- Automated monitoring deployment: completed successfully.

## Prometheus Alerting and Kubernetes Logging

### Alerting Implementation

Prometheus alert rules are defined declaratively in `monitoring/prometheus/values.yaml` and deployed through the existing Helm-based monitoring automation.

Two alert rules are configured:

| Alert | Trigger | Duration |
|---|---|---|
| FlaskReplicaAvailabilityLow | Fewer than two successfully scraped Flask replicas | 2 minutes |
| FlaskHighHTTPErrorRate | HTTP 5xx error rate above 5%, with sufficient traffic | 5 minutes |

Prometheus evaluates these rules every 15 seconds.

### Availability Alert Validation

The availability alert was tested by temporarily scaling the Flask Kubernetes Deployment from two replicas to one.

The following command was used:

```bash
kubectl scale deployment/l00205530-flask --replicas=1
```

Prometheus detected the reduction in available targets and transitioned the availability alert from INACTIVE to PENDING.

After the configured two-minute duration, the alert transitioned to FIRING.

The original deployment configuration was restored using:

```bash
kubectl scale deployment/l00205530-flask --replicas=2
kubectl rollout status deployment/l00205530-flask
./scripts/deploy-application.sh
```

Following recovery, Prometheus returned the alert to INACTIVE.

This demonstrates that the monitoring configuration detects reduced application availability and recognizes recovery.

The HTTP 5xx alert was configured and loaded successfully, but a simulated high-error-rate test has not yet been performed.

### Application Logging

The Flask application produces HTTP access logs through its Gunicorn server.

Application logs are available through Kubernetes:

```bash
kubectl logs deployment/l00205530-flask \
  --all-pods=true \
  --all-containers=true \
  --tail=20 \
  --prefix=true
```

The logs contain timestamps, pod identifiers, HTTP request methods, request paths, and response status codes.

Logging was verified for Kubernetes `/health` probes and Prometheus `/metrics` requests, both returning HTTP 200 responses.

### Limitations

Alertmanager is disabled in this local monitoring environment. Prometheus evaluates and displays alerts, but external notifications are not configured.

Application logging is available through Kubernetes but is not forwarded to a centralized logging platform.

Prometheus and Grafana persistence are disabled, so monitoring history may be lost if their storage is recreated.

## Conclusion

The implementation demonstrates application instrumentation, Kubernetes-based service discovery, centralized metrics collection, dashboard provisioning as code, and reproducible infrastructure deployment using Helm.
