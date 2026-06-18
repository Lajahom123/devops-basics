variable "name" {
  description = "Globally unique Azure Container Registry name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the registry is created."
  type        = string
}

variable "location" {
  description = "Azure region for the registry."
  type        = string
}

variable "sku" {
  description = "Azure Container Registry SKU."
  type        = string
}
