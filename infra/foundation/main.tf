data "azurerm_client_config" "current" {}

resource "random_string" "foundation_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "platform" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source = "../modules/network"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  project             = var.project
  environment         = var.environment
  vnet_name           = local.vnet_name
  address_space       = ["10.20.0.0/16"]
  subnets             = local.subnets
  tags                = local.common_tags
}

module "private_dns" {
  source = "../modules/private-dns"

  resource_group_name = azurerm_resource_group.platform.name
  vnet_id             = module.network.vnet_id
  zones               = local.private_dns_zones
  tags                = local.common_tags
}

module "monitoring" {
  source = "../modules/monitoring"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  tags                = local.common_tags
}

module "acr" {
  source = "../modules/acr"

  name                = local.acr_name
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  sku                 = "Basic"
}

module "managed_identities" {
  source = "../modules/managed-identities"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  name_prefix         = local.name_prefix
  tags                = local.common_tags
}

module "key_vault" {
  source = "../modules/key-vault"

  name                = local.key_vault_name
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = local.common_tags
}

module "github_oidc" {
  source = "../modules/github-oidc"

  name                = "github-${var.github_branch}"
  resource_group_name = azurerm_resource_group.platform.name
  parent_identity_id  = module.managed_identities.identities.github_actions_deploy.resource_id
  subject             = local.github_deploy_subject
}
