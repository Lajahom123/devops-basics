data "azurerm_client_config" "current" {}

locals {
  entra_administrator_object_id      = coalesce(var.entra_administrator_object_id, data.azurerm_client_config.current.object_id)
  entra_administrator_principal_name = coalesce(var.entra_administrator_principal_name, local.entra_administrator_object_id)
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  version = var.postgres_version

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false

  sku_name   = var.sku_name
  storage_mb = var.storage_mb
  zone       = var.zone

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  maintenance_window {
    day_of_week  = var.maintenance_day_of_week
    start_hour   = var.maintenance_start_hour
    start_minute = var.maintenance_start_minute
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "de_DE.utf8"
}

resource "azurerm_postgresql_flexible_server_configuration" "require_secure_transport" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "ON"
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "main" {
  server_name         = azurerm_postgresql_flexible_server.main.name
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  object_id      = local.entra_administrator_object_id
  principal_name = local.entra_administrator_principal_name
  principal_type = var.entra_administrator_principal_type
}
