terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "aurai"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}

module "platform" {
  source = "../../modules/platform"

  environment = "prod"
  region      = "us-east-1"

  # Network: three zones, one NAT gateway per zone, flow logs on.
  vpc_cidr           = "10.30.0.0/16"
  az_count           = 3
  single_nat_gateway = false
  enable_flow_logs   = true

  # EKS: private API endpoint only. Reach it through a VPN, bastion or CI runner inside the VPC.
  cluster_endpoint_public_access = false
  node_instance_types            = ["m6i.xlarge"]
  node_capacity_type             = "ON_DEMAND"
  node_min_size                  = 3
  node_max_size                  = 9
  node_desired_size              = 3

  # Data stores: multi-zone database, longer backups, deletion protection, replicated cache.
  db_instance_class        = "db.r6g.large"
  db_allocated_storage     = 100
  db_max_allocated_storage = 500
  db_multi_az              = true
  db_backup_retention_days = 14
  cache_node_type          = "cache.r6g.large"
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
