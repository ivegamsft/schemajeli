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

variable "sku_tier" {
  description = "Static Web App SKU tier"
  type        = string
  default     = "Standard"
}

variable "sku_size" {
  description = "Static Web App SKU size"
  type        = string
  default     = "Standard"
}

variable "api_url" {
  description = "Backend API URL"
  type        = string
}

variable "custom_domain" {
  description = "Custom domain name (optional)"
  type        = string
  default     = null
}

variable "additional_app_settings" {
  description = "Additional app settings"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
