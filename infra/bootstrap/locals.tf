locals {
  resource_group_name = "rg-${var.project_name}-${var.environment}-tfstate"
  name_prefix         = var.project_name

  common_tags = {
    Owner = var.owner_email
  }
}