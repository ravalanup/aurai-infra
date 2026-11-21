#!/usr/bin/env bash
# Forwards the platform services to localhost until Ctrl+C.
# Keycloak 8080, Qdrant 6333, Postgres 5432, Redis 6379, OTLP 4317/4318.
set -euo pipefail

NAMESPACE="${NAMESPACE:-aurai-system}"

pids=()
cleanup() { kill "${pids[@]}" 2>/dev/null || true; }
trap cleanup EXIT INT TERM

kubectl port-forward -n "$NAMESPACE" svc/keycloak 8080:8080 &
pids+=($!)
kubectl port-forward -n "$NAMESPACE" svc/qdrant 6333:6333 6334:6334 &
pids+=($!)
kubectl port-forward -n "$NAMESPACE" svc/postgres 5432:5432 &
pids+=($!)
kubectl port-forward -n "$NAMESPACE" svc/redis 6379:6379 &
pids+=($!)
kubectl port-forward -n "$NAMESPACE" svc/otel-collector 4317:4317 4318:4318 &
pids+=($!)

echo "Port-forwarding started. Press Ctrl+C to stop."
wait
