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

variable "app_service_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B2"
}

variable "database_host" {
  description = "PostgreSQL server FQDN"
  type        = string
  sensitive   = true
}

variable "database_user" {
  description = "PostgreSQL admin username"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "schemajeli"
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  sensitive   = true
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins"
  type        = list(string)
  default     = ["*"]
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
