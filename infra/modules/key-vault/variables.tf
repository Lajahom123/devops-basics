variable "name" {
  description = "Globally unique Key Vault name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the vault is created."
  type        = string
}

variable "location" {
  description = "Azure region for the vault."
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID."
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU name."
  type        = string
}

variable "tags" {
  description = "Tags applied to the vault."
  type        = map(string)
  default     = {}
}
