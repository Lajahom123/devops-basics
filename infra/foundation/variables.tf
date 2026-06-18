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
  default     = "switzerlandnorth"
}

variable "tags" {
  description = "Additional tags to merge onto foundation resources."
  type        = map(string)
  default     = {}
}
