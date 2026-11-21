output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block (use for networkPolicies.allowedIngressCIDRs in the Helm values)."
  value       = var.vpc_cidr
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "db_endpoint" {
  description = "RDS endpoint address (use for keycloak.database.host in the Helm values)."
  value       = module.db.db_instance_address
}

output "db_master_secret_arn" {
  description = "Secrets Manager ARN holding the generated database master credentials."
  value       = module.db.db_instance_master_user_secret_arn
}

output "redis_primary_endpoint" {
  description = "ElastiCache primary endpoint."
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "external_secrets_role_arn" {
  description = "IAM role for the External Secrets Operator service account."
  value       = module.external_secrets_irsa.iam_role_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URLs by service."
  value       = { for k, r in aws_ecr_repository.service : k => r.repository_url }
}

output "secret_arns" {
  description = "Secrets Manager secret ARNs (containers only; set values out of band)."
  value       = { for k, s in aws_secretsmanager_secret.platform : k => s.arn }
}
