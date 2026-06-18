variable "resource_group_name" {
  description = "Resource group where identities are created."
  type        = string
}

variable "location" {
  description = "Azure region for identities."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for managed identity names."
  type        = string
}

variable "tags" {
  description = "Tags applied to identities."
  type        = map(string)
  default     = {}
}
