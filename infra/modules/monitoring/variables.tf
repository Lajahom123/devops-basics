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

variable "tags" {
  description = "Tags applied to monitoring resources."
  type        = map(string)
  default     = {}
}

variable "owner_email" {
  description = "Email address for alert notifications."
  type        = string
}

variable "alert_evaluation_frequency" {
  description = "How often the alert rule is evaluated (ISO 8601 duration, e.g. PT5M)."
  type        = string
  default     = "PT5M"
}

variable "alert_window_duration" {
  description = "Period of time data is collected for each evaluation (ISO 8601 duration, e.g. PT15M)."
  type        = string
  default     = "PT15M"
}
