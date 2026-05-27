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

variable "location" {
  description = "Azure region."
  type        = string
  default     = "switzerlandnorth"
}

variable "owner_email" {
  description = "Project owner."
  type        = string
}

variable "web_app_name" {
  description = "Globally unique Azure Web App name."
  type        = string
}

variable "app_service_sku" {
  description = "App Service plan SKU. Use Basic or higher for VNet integration."
  type        = string
  default     = "B1"
}

# Docker

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

# Postgre

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

variable "postgres_admin_password" {
  description = "PostgreSQL administrator password. Kept only as a bootstrap/fallback credential while password auth remains enabled."
  type        = string
  sensitive   = true
}

variable "postgres_entra_admin_principal_name" {
  type        = string
  description = "Display name or UPN of the Microsoft Entra administrator for PostgreSQL."
}

# Alers

variable "alert_evaluation_frequency" {
  type    = string
  default = "PT5M"
}

variable "alert_window_duration" {
  type    = string
  default = "PT5M"
}

# Github runner

variable "github_runner_admin_username" {
  type        = string
  description = "Admin username for the GitHub runner VM."
  default     = "azureuser"
}

variable "github_runner_admin_ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key used for runner VM access."
  default     = "path/to/public/key"
}