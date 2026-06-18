variable "resource_group_name" {
  description = "Resource group where private DNS zones are created."
  type        = string
}

variable "vnet_id" {
  description = "Virtual network ID linked to the private DNS zones."
  type        = string
}

variable "zones" {
  description = "Private DNS zones keyed by logical name."
  type = map(object({
    name                 = string
    virtual_network_link = string
    registration_enabled = optional(bool, false)
  }))
}

variable "tags" {
  description = "Tags applied to DNS zones and links."
  type        = map(string)
  default     = {}
}
