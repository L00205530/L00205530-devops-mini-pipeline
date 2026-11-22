
#!/usr/bin/env bash
set -euo pipefail

# L00205530 - Deploy Prometheus and Grafana monitoring

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

NAMESPACE="monitoring"

echo "Creating monitoring namespace..."
kubectl create namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Checking Grafana administrator Secret..."
if ! kubectl get secret grafana-admin -n "$NAMESPACE" >/dev/null 2>&1; then
  echo "ERROR: grafana-admin Secret is missing."
  echo "Create the Secret before deploying Grafana."
  exit 1
fi

echo "Adding Helm repositories..."
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts \
  --force-update

helm repo add grafana-community \
  https://grafana-community.github.io/helm-charts \
  --force-update

helm repo update

echo "Creating Grafana dashboard ConfigMap..."
kubectl create configmap l00205530-grafana-dashboards \
  --namespace "$NAMESPACE" \
  --from-file=devops-monitoring.json=monitoring/grafana/dashboards/devops-monitoring.json \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying Prometheus..."
helm upgrade --install prometheus \
  prometheus-community/prometheus \
  --version 29.48.0 \
  --namespace "$NAMESPACE" \
  --values monitoring/prometheus/values.yaml \
  --wait --timeout 5m

echo "Deploying Grafana..."
helm upgrade --install grafana \
  grafana-community/grafana \
  --version 14.5.0 \
  --namespace "$NAMESPACE" \
  --values monitoring/grafana/values.yaml \
  --wait --timeout 5m

echo "Monitoring deployment completed."
kubectl get pods -n "$NAMESPACE"
