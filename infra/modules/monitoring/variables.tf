variable "name_prefix" {
  description = "Name prefix for monitoring resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where monitoring resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for monitoring resources."
  type        = string
}

variable "retention_in_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "create_application_insights" {
  description = "Whether to create Application Insights."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to monitoring resources."
  type        = map(string)
  default     = {}
}
