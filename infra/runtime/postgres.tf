resource "azurerm_postgresql_flexible_server" "main" {
  name                = var.postgres_server_name
  resource_group_name = data.azurerm_resource_group.foundation.name
  location            = var.location

  version = var.postgres_version

  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password

  delegated_subnet_id           = data.azurerm_subnet.postgres.id
  private_dns_zone_id           = data.azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false

  sku_name   = var.postgres_sku_name
  storage_mb = var.postgres_storage_mb

  backup_retention_days        = var.postgres_backup_retention_days
  geo_redundant_backup_enabled = var.postgres_geo_redundant_backup_enabled

  zone = var.postgres_zone

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  maintenance_window {
    day_of_week  = var.postgres_maintenance_day_of_week
    start_hour   = var.postgres_maintenance_start_hour
    start_minute = var.postgres_maintenance_start_minute
  }

  tags = {
    environment = var.environment
    owner       = var.owner_email
    project     = var.project_name
  }
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.postgres_database_name
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
  resource_group_name = data.azurerm_resource_group.foundation.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  object_id = data.azurerm_client_config.current.object_id
  # TODO: change me to principal_name = var.postgres_entra_admin_principal_name
  principal_name = data.azurerm_client_config.current.object_id
  principal_type = "User"
}
