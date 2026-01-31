terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

# Random password for PostgreSQL
resource "random_password" "postgres" {
  length  = 32
  special = true
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.project_name}-${var.environment}-postgres"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.admin_username
  administrator_password = var.admin_password != "" ? var.admin_password : random_password.postgres.result
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  version                = var.postgres_version
  backup_retention_days  = var.backup_retention_days

  delegated_subnet_id = var.subnet_id

  zone = var.environment == "prod" ? "1" : null

  depends_on = []

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
