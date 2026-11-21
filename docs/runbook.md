# Runbook

## Deploying a new AWS environment

### 1. Create the state bucket (once per account)
```bash
cd terraform/bootstrap
terraform init
terraform apply -var="bucket_name=aurai-terraform-state-<account-id>"
```
Then replace `REPLACE-aurai-terraform-state` in each `terraform/environments/*/backend.tf` with that bucket name.

### 2. Apply infrastructure
```bash
cd terraform/environments/dev
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```
Before the first plan, replace the placeholder API CIDR (`203.0.113.0/24`) in dev and staging with your own address range. Production uses a private API endpoint, so run from a host inside the VPC.

### 3. Connect to the cluster
```bash
aws eks update-kubeconfig --name aurai-dev --region us-east-1
```

### 4. Install cluster prerequisites
Install the following (not managed in this repository): the AWS Load Balancer Controller, and the External Secrets Operator with the role from `terraform output external_secrets_role_arn`.

### 5. Set secret values
See [secrets-and-identity.md](secrets-and-identity.md).

### 6. Fill in Helm values
Take values from `terraform output`:
- `db_endpoint` → `keycloak.database.host`
- `db_master_secret_arn` → `remoteKey` for the `keycloak-db` ExternalSecret
- `vpc_cidr` → `networkPolicies.allowedIngressCIDRs`
- Hostnames and certificate ARN → `keycloak.hostname`, `ingress.host`, ingress annotations

Create the Keycloak database in RDS once (`CREATE DATABASE keycloak;`) using the master credentials.

### 7. Install the chart
```bash
kubectl create namespace aurai-system
kubectl label namespace aurai-system pod-security.kubernetes.io/enforce=baseline
helm upgrade --install aurai-platform charts/aurai-platform \
  --namespace aurai-system \
  -f charts/aurai-platform/values-aws.yaml \
  -f charts/aurai-platform/values-dev.yaml \
  --wait --timeout 10m
```

## Routine operations

| Task | Command |
|---|---|
| Check platform health | `kubectl get pods -n aurai-system` |
| View Keycloak logs | `kubectl logs -n aurai-system deploy/keycloak` |
| Check Qdrant volume usage | `kubectl exec -n aurai-system statefulset/qdrant -- df -h /qdrant/storage` |
| Expand Qdrant volume | Edit the PVC size (gp3 supports expansion), then confirm the filesystem resized |
| Roll the collector after config changes | Automatic: the pod restarts when the config checksum changes |
| Review Terraform drift | `terraform plan` in the environment folder |

## Incident quick reference

| Symptom | First checks | Action |
|---|---|---|
| Services cannot reach Postgres or Redis | Security groups, subnet routes, secret values | Confirm node security group is allowed on 5432 / 6379; verify credentials |
| Keycloak login failing | Keycloak logs, RDS health, ingress | Restart the deployment after fixing DB connectivity |
| Qdrant slow or out of space | PVC usage, memory | Expand the volume; raise memory limits |
| No traces arriving | Collector pod, exporter errors | Check `kubectl logs deploy/otel-collector`; confirm exporters in config |
| Terraform lock error | Another run in progress | Wait; remove a stale `.tflock` object only after confirming no run is active |

## Destroying a non-production environment
```bash
cd terraform/environments/dev
terraform destroy
```
Production and staging have deletion protection on the database; disable it deliberately before destroying.

## Cost control
- Destroy dev when not in use.
- Dev uses spot nodes and a single NAT gateway.
- Review NAT, EKS control plane, RDS and ElastiCache charges first; they run continuously.
