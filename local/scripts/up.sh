#!/usr/bin/env bash
# Creates the local kind cluster and installs the aurai-platform chart.
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-aurai}"
NAMESPACE="${NAMESPACE:-aurai-system}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for tool in docker kind kubectl helm; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing required tool: $tool (see docs/local-development.md)" >&2; exit 1; }
done

docker info >/dev/null 2>&1 || { echo "Docker is not running." >&2; exit 1; }

if ! kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  echo "Creating kind cluster '$CLUSTER_NAME'..."
  kind create cluster --name "$CLUSTER_NAME" --config "$ROOT/local/kind-config.yaml"
else
  echo "kind cluster '$CLUSTER_NAME' already exists."
fi

kubectl config use-context "kind-$CLUSTER_NAME" >/dev/null

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace "$NAMESPACE" pod-security.kubernetes.io/enforce=baseline --overwrite >/dev/null

echo "Installing aurai-platform..."
helm upgrade --install aurai-platform "$ROOT/charts/aurai-platform" \
  --namespace "$NAMESPACE" \
  --values "$ROOT/charts/aurai-platform/values-local.yaml" \
  --wait --timeout 10m

echo
echo "Done. Next: make port-forward  (Keycloak http://localhost:8080)"
