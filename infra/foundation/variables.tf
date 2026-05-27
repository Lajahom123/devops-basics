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

variable "resource_group_name" {
  description = "Persistent resource group name for all project resources."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the application virtual network."
  type        = string
  default     = "10.20.0.0/16"
}

variable "app_service_subnet_address_prefix" {
  description = "Subnet delegated to App Service regional VNet integration."
  type        = string
  default     = "10.20.1.0/24"
}

variable "postgres_subnet_address_prefix" {
  description = "Subnet delegated to Azure Database for PostgreSQL Flexible Server."
  type        = string
  default     = "10.20.2.0/24"
}

variable "admin_subnet_address_prefix" {
  description = "Subnet reserved for private administrative access patterns such as jump hosts."
  type        = string
  default     = "10.20.3.0/24"
}

variable "container_apps_subnet_address_prefix" {
  description = "Subnet delegated to container apps."
  type        = string
  default     = "10.20.4.0/24"
}

variable "private_endpoints_subnet_address_prefix" {
  description = "Subnet delegated to private endpoints."
  type        = string
  default     = "10.20.5.0/24"
}

variable "github_runner_subnet_address_prefix" {
  description = "Subnet delegated to Github runners."
  type        = string
  default     = "10.20.6.0/24"
}

variable "github_owner" {
  description = "GitHub organization or username."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to federate to Azure."
  type        = string
  default     = "master"
}
