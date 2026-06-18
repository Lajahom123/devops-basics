variable "project" {
  description = "Project name used in application display names."
  type        = string
}

variable "environment" {
  description = "Environment name used in application display names."
  type        = string
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

variable "create_dev_operator" {
  description = "Whether to create the dev operations OIDC application."
  type        = bool
  default     = false
}
