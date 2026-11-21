terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.73"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "aurai"
      Environment = "staging"
      ManagedBy   = "terraform"
    }
  }
}

module "platform" {
  source = "../../modules/platform"

  environment = "staging"
  region      = "us-east-1"

  # Network: production-shaped, but one NAT gateway to control cost.
  vpc_cidr           = "10.20.0.0/16"
  az_count           = 3
  single_nat_gateway = true
  enable_flow_logs   = true

  # EKS: public API endpoint limited to your own address. Replace the documentation range below.
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["203.0.113.0/24"]
  node_instance_types                  = ["m6i.large"]
  node_capacity_type                   = "ON_DEMAND"
  node_min_size                        = 2
  node_max_size                        = 4
  node_desired_size                    = 3

  # Data stores: mirror production settings at lower size.
  db_instance_class        = "db.t4g.large"
  db_allocated_storage     = 50
  db_max_allocated_storage = 200
  db_multi_az              = false
  db_backup_retention_days = 7
  cache_node_type          = "cache.t4g.small"
  cache_num_nodes          = 2
  deletion_protection      = true
}

output "cluster_name" {
  value = module.platform.cluster_name
}

output "vpc_cidr" {
  value = module.platform.vpc_cidr
}

output "db_endpoint" {
  value = module.platform.db_endpoint
}

output "db_master_secret_arn" {
  value = module.platform.db_master_secret_arn
}

output "redis_primary_endpoint" {
  value = module.platform.redis_primary_endpoint
}

output "external_secrets_role_arn" {
  value = module.platform.external_secrets_role_arn
}

output "ecr_repository_urls" {
  value = module.platform.ecr_repository_urls
}
