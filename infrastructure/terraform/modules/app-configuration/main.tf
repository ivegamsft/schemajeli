terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_app_configuration" "main" {
  name                = "${var.project_name}-${var.environment}-appcfg-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku = var.app_configuration_sku

  purge_protection_enabled = var.purge_protection_enabled

  tags = var.tags
}
