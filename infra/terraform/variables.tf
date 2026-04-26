variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "devops-tracker"
}

variable "env" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
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
  description = "App Service plan SKU."
  type        = string
  default     = "F1"
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

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}