# Remote state in S3 with native locking (Terraform 1.10+).
# Create the bucket first with terraform/bootstrap, then replace the bucket name below.
terraform {
  backend "s3" {
    bucket       = "REPLACE-aurai-terraform-state"
    key          = "aurai-infra/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
