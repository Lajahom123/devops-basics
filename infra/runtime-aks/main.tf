resource "azurerm_resource_group" "runtime" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

module "postgres" {
  source = "../modules/postgres-flexible"

  name                = local.postgres_server_name
  location            = local.location
  resource_group_name = azurerm_resource_group.runtime.name

  administrator_login    = var.postgres_administrator_login
  administrator_password = var.postgres_administrator_password

  postgres_version      = var.postgres_version
  sku_name              = var.postgres_sku_name
  storage_mb            = var.postgres_storage_mb
  zone                  = var.postgres_zone
  backup_retention_days = var.postgres_backup_retention_days

  geo_redundant_backup_enabled = var.postgres_geo_redundant_backup_enabled
  maintenance_day_of_week      = var.postgres_maintenance_day_of_week
  maintenance_start_hour       = var.postgres_maintenance_start_hour
  maintenance_start_minute     = var.postgres_maintenance_start_minute

  delegated_subnet_id = local.postgres_subnet_id
  private_dns_zone_id = local.foundation.postgres_private_dns_zone_id
  database_name       = var.postgres_database_name
  tags                = local.tags

  entra_administrator_object_id      = var.postgres_entra_administrator_object_id
  entra_administrator_principal_name = var.postgres_entra_administrator_principal_name
  entra_administrator_principal_type = var.postgres_entra_administrator_principal_type
}

module "aks" {
  source = "../modules/aks"

  name                = local.aks_cluster_name
  resource_group_name = azurerm_resource_group.runtime.name
  location            = local.location
  dns_prefix          = local.aks_dns_prefix
  subnet_id           = local.aks_subnet_id

  identity_ids               = [local.aks_identity.resource_id]
  node_count                 = var.aks_node_count
  node_vm_size               = var.aks_node_vm_size
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tags                       = local.tags

  depends_on = [
    azurerm_role_assignment.aks_control_plane_network_contributor_on_aks_subnet,
  ]
}

resource "azurerm_role_assignment" "aks_control_plane_network_contributor_on_aks_subnet" {
  scope                = local.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = local.aks_identity.principal_id
}
