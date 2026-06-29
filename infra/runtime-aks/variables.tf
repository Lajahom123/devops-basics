variable "postgres_server_name" {
  description = "PostgreSQL Flexible Server name. Defaults to a name derived from the platform suffix."
  type        = string
  default     = null
}

variable "postgres_database_name" {
  description = "Application database name."
  type        = string
  default     = "devops_tracker"
}

variable "postgres_administrator_login" {
  description = "PostgreSQL administrator login used for bootstrap access."
  type        = string
  default     = "devopsadmin"
}

variable "postgres_administrator_password" {
  description = "PostgreSQL administrator password used for bootstrap access."
  type        = string
  sensitive   = true
}

variable "postgres_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16"
}

variable "postgres_sku_name" {
  description = "Azure PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage in MB."
  type        = number
  default     = 32768
}

variable "postgres_zone" {
  description = "Availability zone for PostgreSQL Flexible Server."
  type        = string
  default     = "1"
}

variable "postgres_backup_retention_days" {
  description = "Backup retention in days."
  type        = number
  default     = 7
}

variable "postgres_geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backups are enabled for PostgreSQL."
  type        = bool
  default     = false
}

variable "postgres_maintenance_day_of_week" {
  description = "Day of week for the PostgreSQL maintenance window. Sunday is 0."
  type        = number
  default     = 0
}

variable "postgres_maintenance_start_hour" {
  description = "Start hour for the PostgreSQL maintenance window."
  type        = number
  default     = 2
}

variable "postgres_maintenance_start_minute" {
  description = "Start minute for the PostgreSQL maintenance window."
  type        = number
  default     = 0
}

variable "postgres_entra_administrator_object_id" {
  description = "Object ID of the Microsoft Entra administrator for PostgreSQL. Defaults to the current Azure caller."
  type        = string
  default     = null
}

variable "postgres_entra_administrator_principal_name" {
  description = "Display name or UPN of the Microsoft Entra administrator for PostgreSQL. Defaults to the administrator object ID when unset."
  type        = string
  default     = null
}

variable "postgres_entra_administrator_principal_type" {
  description = "Principal type of the Microsoft Entra administrator for PostgreSQL."
  type        = string
  default     = "User"
}

variable "postgres_app_entra_principal_name" {
  description = "Microsoft Entra principal name to create in PostgreSQL with pgaadauth_create_principal. Defaults to the AKS workload identity name."
  type        = string
  default     = null
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster. Defaults to a name derived from the platform suffix."
  type        = string
  default     = null
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster. Defaults to a name derived from the platform suffix."
  type        = string
  default     = null
}

variable "aks_node_count" {
  description = "Initial number of nodes in the AKS default system node pool."
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  description = "VM size for the AKS default system node pool."
  type        = string
  default     = "Standard_B2s_v2"
}
