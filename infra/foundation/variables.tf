variable "project" {
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

variable "github_owner" {
  description = "GitHub organization or username allowed to federate to Azure."
  type        = string
  default     = "Lajahom123"
}

variable "github_repo" {
  description = "GitHub repository name allowed to federate to Azure."
  type        = string
  default     = "devops-basics"
}

variable "github_branch" {
  description = "GitHub branch allowed to federate to Azure."
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Additional tags to merge onto foundation resources."
  type        = map(string)
  default     = {}
}
