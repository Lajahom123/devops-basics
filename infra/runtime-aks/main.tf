module "postgres" {
  source = "../modules/postgres-flexible"

  name                = local.postgres_server_name
  location            = local.location
  resource_group_name = local.resource_group_name

  administrator_login    = var.postgres_administrator_login
  administrator_password = var.postgres_administrator_password

  postgres_version      = var.postgres_version
  sku_name              = var.postgres_sku_name
  storage_mb            = var.postgres_storage_mb
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
