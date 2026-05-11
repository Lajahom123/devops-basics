variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "devops-tracker"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Persistent foundation resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "switzerlandnorth"
}

variable "owner_email" {
  description = "Project owner."
  type        = string
}

variable "vnet_name" {
  description = "Foundation virtual network name."
  type        = string
  default     = "vnet-devops-tracker"
}

variable "app_service_subnet_name" {
  description = "Foundation subnet used for App Service VNet integration."
  type        = string
  default     = "snet-web-egress"
}

variable "postgres_subnet_name" {
  description = "Foundation subnet delegated to PostgreSQL Flexible Server."
  type        = string
  default     = "snet-postgres"
}

variable "postgres_private_dns_zone_name" {
  description = "Foundation private DNS zone name for PostgreSQL."
  type        = string
  default     = "private.postgres.database.azure.com"
}

variable "web_app_identity_name" {
  description = "Foundation user-assigned managed identity used by the Web App."
  type        = string
  default     = "id-devops-tracker-webapp"
}

variable "github_actions_principal_id" {
  description = "Object ID / principal ID of the GitHub Actions service principal from foundation."
  type        = string
}

variable "web_app_name" {
  description = "Globally unique Azure Web App name."
  type        = string
}

variable "acr_name" {
  description = "Globally unique Azure Container Registry name. Only letters and numbers."
  type        = string
}

variable "app_service_sku" {
  description = "App Service plan SKU. Use Basic or higher for VNet integration."
  type        = string
  default     = "B1"
}

variable "docker_image_name" {
  description = "Docker image name and tag inside ACR."
  type        = string
  default     = "devops-tracker:latest"
}

variable "container_port" {
  description = "Port exposed by the Docker container."
  type        = string
  default     = "3000"
}

variable "key_vault_name" {
  description = "Globally unique Key Vault name. Leave null to derive one from the project."
  type        = string
  default     = null
}

variable "postgres_server_name" {
  description = "Globally unique Azure PostgreSQL Flexible Server name."
  type        = string
}

variable "postgres_database_name" {
  description = "Application database name."
  type        = string
  default     = "devops_tracker"
}

variable "postgres_admin_username" {
  description = "PostgreSQL administrator username."
  type        = string
  default     = "devopsadmin"
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
  description = "Azure PostgreSQL storage in MB."
  type        = number
  default     = 32768
}

variable "postgres_backup_retention_days" {
  description = "Backup retention in days."
  type        = number
  default     = 7
}

variable "postgres_zone" {
  type    = string
  default = "1"
}

variable "postgres_geo_redundant_backup_enabled" {
  type    = bool
  default = false
}

variable "postgres_maintenance_day_of_week" {
  type    = number
  default = 0
}

variable "postgres_maintenance_start_hour" {
  type    = number
  default = 2
}

variable "postgres_maintenance_start_minute" {
  type    = number
  default = 0
}

variable "postgres_standby_zone" {
  type    = string
  default = "2"
}
