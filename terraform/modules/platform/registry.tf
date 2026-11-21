locals {
  repositories = [
    "aurai-gateway",
    "aurai-workspace",
    "aurai-knowledge-rag",
    "aurai-mcp-connectors",
    "aurai-agent-runtime",
    "aurai-eval-governance",
  ]
}

resource "aws_ecr_repository" "service" {
  for_each = toset(local.repositories)

  name                 = "${local.name}/${each.value}"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.environment != "prod"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "service" {
  for_each   = aws_ecr_repository.service
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the most recent 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = { type = "expire" }
      }
    ]
  })
}
