# Secret containers only. Values are written out of band (console, CLI or the owning service's bootstrap job)
# so they never enter Terraform state.

locals {
  secret_names = [
    "keycloak/admin",
    "litellm/master-key",
    "langfuse/api-keys",
    "qdrant/api-key",
  ]
}

resource "aws_secretsmanager_secret" "platform" {
  for_each = toset(local.secret_names)

  name                    = "${local.name}/${each.value}"
  description             = "Aurai ${var.environment}: ${each.value}"
  recovery_window_in_days = var.environment == "prod" ? 30 : 7

  tags = local.tags
}
