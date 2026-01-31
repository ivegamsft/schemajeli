terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58"
    }
  }
}

# Data source for current client config
data "azurerm_client_config" "current" {}

# PostgreSQL Flexible Server
# Note: Using public network access with firewall rules for now
# Private DNS zone validation has known issues in azurerm, using public with restricted access instead
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.project_name}-${var.environment}-postgres"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.admin_username
  administrator_password = var.admin_password  # Must be provided from Key Vault
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  version                = var.postgres_version
  backup_retention_days  = var.backup_retention_days

  public_network_access_enabled = true

  # Enable Azure AD authentication for RBAC-based access
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled          = true  # Allow password auth as fallback
    tenant_id                      = data.azurerm_client_config.current.tenant_id
  }

  zone = var.environment == "prod" ? "1" : null

  tags = var.tags
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Firewall rule for local development (dev only)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_local" {
  count            = var.environment == "dev" && var.allow_local_dev ? 1 : 0
  name             = "AllowLocalDev"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# Firewall rule for Azure services
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  count            = var.allow_azure_services ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# RBAC Configuration for App Service identity to access PostgreSQL
# Note: Azure AD authentication is enabled on the PostgreSQL server
# App Service can authenticate using its managed identity without requiring a password
# The actual role assignment will be managed through Azure AD roles on the database

# Database configuration parameters
resource "azurerm_postgresql_flexible_server_configuration" "max_connections" {
  name      = "max_connections"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = var.max_connections
}

resource "azurerm_postgresql_flexible_server_configuration" "log_statement" {
  name      = "log_statement"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "all"
}
