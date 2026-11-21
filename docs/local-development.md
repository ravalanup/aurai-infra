# Local development

## Prerequisites
| Tool | Purpose | Notes |
|---|---|---|
| Docker Desktop | Runs the kind nodes | Allocate at least 6 GB RAM and 4 CPUs |
| kind | Local Kubernetes | https://kind.sigs.k8s.io/ |
| kubectl | Cluster access | Match the Kubernetes minor version where possible |
| Helm 3 | Installs the chart | https://helm.sh/ |
| PowerShell 5.1+ or Bash | Scripts | `make` is optional on Windows |

Install on Windows with winget or Chocolatey, for example `winget install Kubernetes.kind Kubernetes.kubectl Helm.Helm`.

## Start
```powershell
.\local\scripts\up.ps1
```
This creates a two-node kind cluster named `aurai`, creates the `aurai-system` namespace with Pod Security labels, and installs the chart with `values-local.yaml`. First start downloads images and can take several minutes.

## Reach the services
```powershell
.\local\scripts\port-forward.ps1
```
| Service | Address |
|---|---|
| Keycloak | http://localhost:8080 (admin user `admin`, password from `values-local.yaml`) |
| Qdrant | http://localhost:6333/dashboard |
| Postgres | `localhost:5432` (database `aurai`, user `aurai`) |
| Redis | `localhost:6379` |
| OTLP | `localhost:4317` (gRPC), `localhost:4318` (HTTP) |

## Inspect
```powershell
.\local\scripts\status.ps1
kubectl logs -n aurai-system statefulset/postgres
```

## Stop and reset
```powershell
.\local\scripts\down.ps1
```
This deletes the cluster and all its data.

## Validating changes
```bash
make lint            # helm lint for local, dev, staging, prod
make template ENV=prod
make tf-validate ENV=dev
```
CI runs the same checks on every pull request.

## Troubleshooting
| Symptom | Likely cause | Fix |
|---|---|---|
| `up.ps1` stops with "Docker is not running" | Docker Desktop not started | Start it and retry |
| Pods stay Pending | Not enough Docker memory | Raise Docker Desktop resources |
| Keycloak not ready for several minutes | First start imports the realm and builds caches | Wait; check `kubectl logs -n aurai-system deploy/keycloak` |
| Port-forward exits immediately | Local port already in use | Stop the other process or change the port mapping |
| Images fail to pull | Network or registry rate limit | Retry; pre-pull with `docker pull` |
