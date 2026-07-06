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

variable "postgres_admin_member_object_id" {
  description = "Object ID of the general admin or service principal added to devops-tracker-postgres-admins."
  type        = string

  validation {
    condition = (
      var.postgres_admin_member_object_id == null ||
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.postgres_admin_member_object_id))
    )
    error_message = "postgres_admin_member_object_id must be a valid Microsoft Entra object ID (UUID)."
  }
}
