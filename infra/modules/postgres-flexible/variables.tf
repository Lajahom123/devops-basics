variable "name" {
  description = "PostgreSQL Flexible Server name."
  type        = string
}

variable "location" {
  description = "Azure region for the PostgreSQL Flexible Server."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where PostgreSQL resources are created."
  type        = string
}

variable "administrator_login" {
  description = "PostgreSQL administrator login used for bootstrap access."
  type        = string
}

variable "administrator_password" {
  description = "PostgreSQL administrator password used for bootstrap access. Supply through a sensitive Terraform variable or TF_VAR environment variable; do not commit it."
  type        = string
  sensitive   = true
}

variable "postgres_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "sku_name" {
  description = "Azure PostgreSQL Flexible Server SKU."
  type        = string
}

variable "storage_mb" {
  description = "PostgreSQL storage size in MB."
  type        = number
}

variable "zone" {
  description = "Availability zone for the PostgreSQL Flexible Server."
  type        = string
  default     = "1"
}

variable "backup_retention_days" {
  description = "Backup retention in days."
  type        = number
}

variable "geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backups are enabled."
  type        = bool
  default     = false
}

variable "maintenance_day_of_week" {
  description = "Day of week for the maintenance window. Sunday is 0."
  type        = number
  default     = 0
}

variable "maintenance_start_hour" {
  description = "Start hour for the maintenance window."
  type        = number
  default     = 2
}

variable "maintenance_start_minute" {
  description = "Start minute for the maintenance window."
  type        = number
  default     = 0
}

variable "delegated_subnet_id" {
  description = "Delegated subnet ID for private PostgreSQL access."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.postgres.database.azure.com."
  type        = string
}

variable "database_name" {
  description = "Application database name."
  type        = string
}

variable "entra_administrator_object_id" {
  description = "Required object ID of the dedicated Microsoft Entra administrator identity or group for PostgreSQL. Use a service account or security group, not the identity of the person running Terraform."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.entra_administrator_object_id))
    error_message = "entra_administrator_object_id must be a valid Microsoft Entra object ID (UUID)."
  }
}

variable "entra_administrator_principal_name" {
  description = "Required display name or UPN of the dedicated Microsoft Entra administrator identity or group for PostgreSQL. Must match the principal identified by entra_administrator_object_id; do not use the Terraform caller's identity."
  type        = string

  validation {
    condition     = trimspace(var.entra_administrator_principal_name) != ""
    error_message = "entra_administrator_principal_name is required and must not be blank."
  }
}

variable "entra_administrator_principal_type" {
  description = "Principal type of the Microsoft Entra administrator for PostgreSQL."
  type        = string
  default     = "User"
}

variable "tags" {
  description = "Tags applied to PostgreSQL resources."
  type        = map(string)
  default     = {}
}
