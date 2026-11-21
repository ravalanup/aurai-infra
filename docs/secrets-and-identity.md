# Secrets and identity

## Principles
- No secret values in Git, Helm values (outside local development), Terraform code or Terraform state.
- Secret values live in AWS Secrets Manager and reach pods through the External Secrets Operator.
- Pods authenticate to AWS through IAM roles for service accounts (IRSA), not static keys.

## Where secrets come from

| Secret | Created by | Value set by | Consumed by |
|---|---|---|---|
| Database master credentials | RDS (generated, managed by AWS) | AWS | Keycloak (through External Secrets), administrators |
| `aurai-<env>/keycloak/admin` | Terraform (container only) | Operator, once | Keycloak |
| `aurai-<env>/litellm/master-key` | Terraform (container only) | Operator, once | `aurai-gateway` |
| `aurai-<env>/langfuse/api-keys` | Terraform (container only) | `aurai-eval-governance` bootstrap | Tracing exporters |
| `aurai-<env>/qdrant/api-key` | Terraform (container only) | Operator, once | Knowledge and agent services |

Set a value without putting it in a file:
```bash
aws secretsmanager put-secret-value \
  --secret-id aurai-dev/keycloak/admin \
  --secret-string '{"username":"admin","password":"<generated>"}'
```

## External Secrets Operator
Install the operator in the `external-secrets` namespace with a service account named `external-secrets`, annotated with the role ARN from `terraform output external_secrets_role_arn`. The chart then creates a `ClusterSecretStore` and one `ExternalSecret` per entry in `externalSecrets.secrets`. The template uses the `external-secrets.io/v1` API; check it against the operator version you install.

The IAM role can read only secrets named `aurai-<env>/*` and the generated database secret.

## Identity with Keycloak
- Keycloak is the OIDC provider for the workspace, the gateway admin interface and internal tools.
- Local: `start-dev` mode with an embedded database. Data is lost when the pod restarts.
- AWS: production mode, PostgreSQL on RDS, TLS terminated at the load balancer, proxy headers enabled.
- Realms, clients and roles are defined as code in `aurai-workspace` and `aurai-eval-governance` so each repository owns the clients it needs.

### Keycloak high availability
The chart runs a single Keycloak replica. Running several requires distributed caching (a Kubernetes-aware cache stack) and a headless service for node discovery. Treat this as production work to add.

## Rotation
- Database master password: rotation is handled by Secrets Manager for the generated secret.
- Other secrets: rotate by writing a new value to Secrets Manager; External Secrets syncs within the refresh interval (1 hour by default); restart consumers that read the value at start-up.
