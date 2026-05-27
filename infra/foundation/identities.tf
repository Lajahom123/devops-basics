resource "azurerm_user_assigned_identity" "web_app" {
  name                = "id-${local.name_prefix}-webapp"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location
  tags                = local.common_tags
}

resource "azurerm_user_assigned_identity" "migration_job" {
  name                = "id-${local.name_prefix}-migration-job"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location
  tags                = local.common_tags
}

resource "azurerm_user_assigned_identity" "github_runner" {
  name                = "id-${local.name_prefix}-github-runner"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
}