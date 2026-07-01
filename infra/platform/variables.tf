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
