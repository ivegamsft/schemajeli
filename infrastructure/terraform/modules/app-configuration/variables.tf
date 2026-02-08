variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "app_configuration_sku" {
  description = "App Configuration SKU (free or standard)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["free", "standard"], var.app_configuration_sku)
    error_message = "App Configuration SKU must be free or standard."
  }
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
