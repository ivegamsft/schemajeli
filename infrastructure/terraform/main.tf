# SchemaJeli Infrastructure - Main Configuration
# Modular Terraform for Azure deployment

terraform {
  required_version = ">= 1.5.0"

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

  # Uncomment and update the backend block below to use Azure Storage for remote state
  # This is recommended for production teams
  # backend "azurerm" {
  #   resource_group_name  = "schemajeli-terraform-rg"
  #   storage_account_name = "schemajeli tfstate"
  #   container_name       = "tfstate"
  #   key                  = "schemajeli.terraform.tfstate"
  # }

  # Using local backend by default. To migrate to Azure backend:
  # 1. Create resource group and storage account
  # 2. Uncomment azurerm backend block above
  # 3. Run: terraform init
}

provider "azurerm" {
  skip_provider_registration = true
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = local.common_tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  log_analytics_sku     = var.log_analytics_sku
  retention_in_days     = var.log_retention_days
  alert_email_addresses = var.alert_email_addresses

  tags = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.networking.database_subnet_id
  vnet_id             = module.networking.vnet_id

  admin_username        = var.db_admin_username
  admin_password        = var.db_admin_password
  database_name         = var.db_name
  postgres_version      = var.postgres_version
  sku_name              = var.db_sku
  storage_mb            = var.db_storage_mb
  backup_retention_days = var.db_backup_days
  max_connections       = var.db_max_connections
  allow_local_dev       = var.environment == "dev"
  allow_azure_services  = true

  tags = local.common_tags

  depends_on = [module.networking]
}

# Key Vault Module
module "key_vault" {
  source = "./modules/key-vault"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  database_connection_string = module.database.connection_string
  jwt_secret                 = var.jwt_secret
  app_service_principal_id   = var.app_service_principal_id

  additional_secrets = var.additional_secrets

  tags = local.common_tags

  depends_on = [module.database]
}

# App Service Module
module "app_service" {
  source = "./modules/app-service"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  app_service_sku = var.app_service_sku

  database_host     = module.database.server_fqdn
  database_user     = module.database.admin_username
  database_password = module.database.admin_password
  database_name     = module.database.database_name

  jwt_secret = var.jwt_secret

  app_insights_connection_string = module.monitoring.application_insights_connection_string

  cors_allowed_origins = var.cors_allowed_origins
  additional_app_settings = merge(
    {
      "STORAGE_CONNECTION_STRING" = "" # Will be added after storage module is created
      "STORAGE_ACCOUNT_NAME"      = "" # Will be added after storage module is created
    },
    var.additional_app_settings
  )

  tags = local.common_tags

  depends_on = [module.database, module.monitoring, module.key_vault]
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  app_service_principal_id = null # Will be set via separate RBAC assignment

  tags = local.common_tags

  depends_on = [module.app_service]
}

# Assign storage RBAC role to App Service after storage exists
resource "azurerm_role_assignment" "app_service_storage" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.app_service.principal_id
}

# Static Web App Module (Frontend)
module "static_web_app" {
  source = "./modules/static-web-app"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  sku_tier = var.static_app_sku_tier
  sku_size = var.static_app_sku_size

  api_url       = "https://${module.app_service.backend_default_hostname}"
  custom_domain = var.frontend_custom_domain

  additional_app_settings = var.frontend_app_settings

  tags = local.common_tags
}

# Local variables
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
  }
}
