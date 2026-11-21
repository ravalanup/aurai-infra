#!/usr/bin/env bash
# Deletes the local kind cluster (and all data in it).
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-aurai}"
kind delete cluster --name "$CLUSTER_NAME"
