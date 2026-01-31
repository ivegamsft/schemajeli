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

variable "soft_delete_retention_days" {
  description = "Key Vault soft delete retention days"
  type        = number
  default     = 7
}

variable "database_connection_string" {
  description = "Database connection string"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}

variable "app_service_principal_id" {
  description = "App Service managed identity principal ID"
  type        = string
  default     = null
}

variable "additional_secrets" {
  description = "Additional secrets to store"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
