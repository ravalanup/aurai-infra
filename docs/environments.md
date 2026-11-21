# Environments

Local, dev, staging and prod share one shape. They differ in size, resilience and protection.

| Setting | Local (kind) | Dev | Staging | Prod |
|---|---|---|---|---|
| VPC CIDR | n/a | 10.10.0.0/16 | 10.20.0.0/16 | 10.30.0.0/16 |
| Availability zones | n/a | 2 | 3 | 3 |
| NAT gateways | n/a | 1 shared | 1 shared | 1 per zone |
| VPC flow logs | n/a | off | on | on |
| EKS API endpoint | n/a | public, restricted CIDR | public, restricted CIDR | private only |
| Nodes | 1 worker | 1 to 3, spot, m6i.large | 2 to 4, on-demand, m6i.large | 3 to 9, on-demand, m6i.xlarge |
| PostgreSQL | in-cluster | db.t4g.medium, single zone, 3-day backups | db.t4g.large, single zone, 7-day backups | db.r6g.large, multi-zone, 14-day backups |
| Redis | in-cluster | cache.t4g.small, 1 node | cache.t4g.small, 2 nodes | cache.r6g.large, 2 nodes with failover |
| Deletion protection | n/a | off | on | on |
| ECR force delete | n/a | allowed | allowed | blocked |
| Qdrant volume | 10 Gi | 20 Gi | 50 Gi | 200 Gi |

The VPC CIDRs in the Terraform environments must match the `networkPolicies.allowedIngressCIDRs` in the Helm values files.

## Promotion
Changes move dev, then staging, then prod. A change that touches both Terraform and Helm values is applied in this order: Terraform, then the chart. Production changes require a reviewed plan.

## Not covered here
This repository is a prototype-scale foundation. A real enterprise rollout would add:
- multiple AWS accounts with organization guardrails, and a landing zone
- keycloak high availability (distributed cache) and a managed identity provider integration
- autoscaling add-ons (cluster autoscaler or Karpenter), the AWS Load Balancer Controller and the External Secrets Operator managed as code
- backup and restore drills, cross-region disaster recovery
- policy enforcement (Kyverno or Gatekeeper), runtime security, image signing
- cost allocation, budgets and alarms
- centralized logging and metrics (CloudWatch, Prometheus, Grafana)
- third-party penetration testing and compliance evidence
