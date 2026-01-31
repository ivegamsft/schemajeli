terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
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

# Static Web App for Frontend
resource "azurerm_static_site" "frontend" {
  name                = "${var.project_name}-${var.environment}-frontend-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size

  app_settings = merge(
    {
      "VITE_API_URL" = var.api_url
      "VITE_ENV"     = var.environment
    },
    var.additional_app_settings
  )

  tags = var.tags
}

# Custom domain binding (optional)
resource "azurerm_static_site_custom_domain" "frontend" {
  count           = var.custom_domain != null ? 1 : 0
  static_site_id  = azurerm_static_site.frontend.id
  domain_name     = var.custom_domain
  validation_type = "cname-delegation"
}
