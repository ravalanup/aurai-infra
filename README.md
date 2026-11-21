# aurai-infra

Infrastructure foundation for **Aurai**, the enterprise AI platform for Amazing-Enterprise (a fictional company; all data is synthetic). This repository provisions the cluster and shared services that every other `aurai-*` repository deploys onto.

Product context, requirements and decisions live in [`aurai-docs`](https://github.com/ravalanup/aurai-docs) (see ADR 0006: Kubernetes and Terraform deployment).

## What it provides

| Area | Contents |
|---|---|
| **Local cluster** | kind cluster config and PowerShell / shell scripts to start, inspect and stop it |
| **Shared services (Helm)** | PostgreSQL, Redis, Qdrant, Keycloak, OpenTelemetry collector, namespaces, network policies, optional ingress and External Secrets wiring |
| **AWS (Terraform)** | VPC, EKS, RDS PostgreSQL, ElastiCache Redis, Secrets Manager, ECR, IAM roles for service accounts; `dev`, `staging` and `prod` environments |
| **CI** | Helm lint and schema validation, Terraform format / validate / tflint, Checkov, Trivy and Gitleaks scans |

Service-specific charts and configuration (LiteLLM, Open WebUI, agents, connectors) live in their own repositories.

## Repository layout

```text
.
├── charts/aurai-platform/        # Umbrella chart for shared services
│   ├── templates/
│   ├── values.yaml               # defaults
│   ├── values-local.yaml         # kind
│   ├── values-aws.yaml           # shared AWS settings
│   └── values-{dev,staging,prod}.yaml
├── local/
│   ├── kind-config.yaml
│   └── scripts/                  # up / down / status / port-forward (.ps1 and .sh)
├── terraform/
│   ├── bootstrap/                # one-time S3 state bucket
│   ├── modules/platform/         # wraps community modules (vpc, eks, rds, iam)
│   └── environments/{dev,staging,prod}/
├── docs/
├── .github/workflows/
└── Makefile
```

## Quick start (local)

Prerequisites: Docker Desktop, [kind](https://kind.sigs.k8s.io/), kubectl and Helm. Details in [docs/local-development.md](docs/local-development.md).

```powershell
# Windows PowerShell
.\local\scripts\up.ps1
.\local\scripts\port-forward.ps1     # Keycloak at http://localhost:8080
.\local\scripts\down.ps1             # delete the cluster
```

```bash
# macOS, Linux or WSL
make up
make port-forward
make down
```

The local admin passwords in `values-local.yaml` are for development only and protect nothing real.

## AWS

Terraform builds the same shape in each environment at different sizes. See [docs/environments.md](docs/environments.md) for the differences and [docs/runbook.md](docs/runbook.md) for the deployment sequence. Nothing in this repository applies infrastructure automatically; CI validates and scans only.

## Documentation

- [Architecture](docs/architecture.md)
- [Local development](docs/local-development.md)
- [Environments](docs/environments.md)
- [Secrets and identity](docs/secrets-and-identity.md)
- [Runbook](docs/runbook.md)

## Status

Prototype-scale foundation using production patterns. What a real enterprise rollout would add is listed in [docs/environments.md](docs/environments.md#not-covered-here).

## License

MIT. See [LICENSE](LICENSE).
