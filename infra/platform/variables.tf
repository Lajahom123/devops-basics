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
  default     = "master"
}

variable "tags" {
  description = "Additional tags to merge onto platform resources."
  type        = map(string)
  default     = {}
}

variable "owner_email" {
  description = "Email address for alert notifications."
  type        = string
}

variable "alert_evaluation_frequency" {
  description = "How often alert rules are evaluated (ISO 8601 duration, e.g. PT5M)."
  type        = string
  default     = "PT5M"
}

variable "alert_window_duration" {
  description = "Period of time data is collected for each alert evaluation (ISO 8601 duration, e.g. PT15M)."
  type        = string
  default     = "PT15M"
}
