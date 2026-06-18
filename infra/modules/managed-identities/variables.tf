variable "resource_group_name" {
  description = "Resource group where identities are created."
  type        = string
}

variable "location" {
  description = "Azure region for identities."
  type        = string
}

variable "identities" {
  description = "User-assigned identities keyed by logical name."
  type = map(object({
    name = string
  }))
}

variable "tags" {
  description = "Tags applied to identities."
  type        = map(string)
  default     = {}
}
