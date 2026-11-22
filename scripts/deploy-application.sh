
#!/usr/bin/env bash
set -Eeuo pipefail

# L00205530 - Automated Kubernetes Application Deployment

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="${NAMESPACE:-default}"
DEPLOYMENT="l00205530-flask"
SERVICE="l00205530-flask-service"
TIMEOUT="${TIMEOUT:-180s}"

echo "========================================"
echo "L00205530 - Flask Kubernetes Deployment"
echo "========================================"

# Verify required tools.
for command in kubectl; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $command"
        exit 1
    fi
done

# Verify Kubernetes connectivity.
echo "[1/6] Checking Kubernetes connectivity..."
kubectl cluster-info >/dev/null

# Validate deployment manifests before applying.
echo "[2/6] Validating Kubernetes manifests..."
kubectl apply \
    --dry-run=server \
    -n "$NAMESPACE" \
    -f "$ROOT_DIR/k8s/"

# Deploy application resources.
echo "[3/6] Applying Kubernetes manifests..."
kubectl apply \
    -n "$NAMESPACE" \
    -f "$ROOT_DIR/k8s/"

# Wait for the deployment to become available.
echo "[4/6] Waiting for application rollout..."
kubectl rollout status \
    deployment/"$DEPLOYMENT" \
    -n "$NAMESPACE" \
    --timeout="$TIMEOUT"

# Verify replica availability.
echo "[5/6] Verifying application replicas..."

DESIRED=$(kubectl get deployment "$DEPLOYMENT" \
    -n "$NAMESPACE" \
    -o jsonpath='{.spec.replicas}')

READY=$(kubectl get deployment "$DEPLOYMENT" \
    -n "$NAMESPACE" \
    -o jsonpath='{.status.readyReplicas}')

READY="${READY:-0}"

if [[ "$DESIRED" != "$READY" ]]; then
    echo "ERROR: Expected $DESIRED replicas, found $READY ready."
    exit 1
fi

# Verify service and report deployment status.
echo "[6/6] Verifying service and displaying resources..."

kubectl get service "$SERVICE" -n "$NAMESPACE"

kubectl get deployment "$DEPLOYMENT" \
    -n "$NAMESPACE" \
    -o wide

kubectl get pods \
    -n "$NAMESPACE" \
    -l app=l00205530-flask

echo
echo "Deployed container image:"
kubectl get deployment "$DEPLOYMENT" \
    -n "$NAMESPACE" \
    -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

echo
echo "SUCCESS: Flask deployment is available."

