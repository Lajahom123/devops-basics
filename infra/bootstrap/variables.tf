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
  default     = "swedencentral"
}

variable "owner_email" {
  description = "Project owner."
  type        = string
}

variable "storage_account_name" {
  type    = string
  default = "stdevopstrackerswedenct"
}

variable "container_name" {
  type    = string
  default = "tfstate"
}