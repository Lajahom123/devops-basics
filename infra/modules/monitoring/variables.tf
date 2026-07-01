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

variable "kubernetes_namespace" {
  description = "Kubernetes namespace monitored by Container Insights alerts."
  type        = string
  default     = "devops-tracker"
}

variable "enable_high_latency_alert" {
  description = "Create the high request latency scheduled query alert."
  type        = bool
  default     = true
}

variable "high_latency_threshold_ms" {
  description = "Average request duration threshold in milliseconds."
  type        = number
  default     = 1000
}

variable "enable_pod_restart_alert" {
  description = "Create the pod/container restart scheduled query alert."
  type        = bool
  default     = true
}

variable "pod_restart_threshold" {
  description = "Total container restart count threshold within the alert window."
  type        = number
  default     = 0
}

variable "enable_failed_pod_alert" {
  description = "Create the failed Kubernetes pod scheduled query alert."
  type        = bool
  default     = true
}
