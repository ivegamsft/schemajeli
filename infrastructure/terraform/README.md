# SchemaJeli Infrastructure as Code (IaC)

This directory contains the Terraform configuration for deploying SchemaJeli on Azure. The infrastructure is organized into reusable modules for easy management and scalability.

## Architecture Overview

The infrastructure consists of 7 core modules:

```
┌─────────────────────────────────────────────────────────┐
│                   Resource Group                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐  │
│  │  Networking  │  │  App Service │  │   Storage   │  │
│  │   (VNet)     │  │   (Backend)  │  │  (Uploads)  │  │
│  └──────┬───────┘  └──────┬───────┘  └─────┬───────┘  │
│         │                 │                │          │
│  ┌──────▼────────────────▼───┐  ┌────────▼────────┐  │
│  │   Static Web App (Frontend) │  │  Key Vault      │  │
│  └─────────────────────────────┘  │  (Secrets)      │  │
│                                    └─────┬──────────┘  │
│  ┌──────────────┐  ┌──────────────┐     │             │
│  │   Database   │  │  Monitoring  │─────┘             │
│  │ (PostgreSQL) │  │(App Insights)│                    │
│  └──────────────┘  └──────────────┘                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Modules

#### 1. Networking (`modules/networking/`)
- **Purpose**: Virtual network infrastructure with proper subnet delegation and security policies
- **Resources**:
  - Virtual Network (10.0.0.0/16)
  - App Service subnet (10.0.1.0/24) with App Service delegation
  - Database subnet (10.0.2.0/24) with PostgreSQL delegation
  - Network Security Groups with HTTP/HTTPS and PostgreSQL rules
  - Service endpoints for Storage and Key Vault
- **Outputs**: VNet ID, Subnet IDs, NSG IDs

#### 2. App Service (`modules/app-service/`)
- **Purpose**: Backend API hosting with staging slots for blue-green deployment
- **Resources**:
  - App Service Plan (Linux)
  - Backend Web App (Node.js 18-LTS)
  - Staging slot for production
  - Managed identity for secure Azure service access
- **Configuration**:
  - Environment-specific app settings
  - Database connection strings
  - Application Insights integration
  - CORS configuration
- **Outputs**: App Service ID, hostname, principal ID (for RBAC)

#### 3. Static Web App (`modules/static-web-app/`)
- **Purpose**: Frontend React/Vite application hosting
- **Resources**:
  - Azure Static Web App
  - Optional custom domain binding
  - Environment variables for API URL
- **Outputs**: Site ID, domain name, API key

#### 4. Database (`modules/database/`)
- **Purpose**: PostgreSQL Flexible Server with security and HA features
- **Resources**:
  - PostgreSQL Flexible Server (default v15)
  - Private DNS Zone for network isolation
  - Firewall rules (Azure services + optional dev access)
  - Server configuration (max_connections, logging)
  - Zone redundancy for production
- **Security**:
  - TLS 1.2+ enforcement
  - SSL enforcement
  - Private DNS isolation
  - VNet integration
- **Outputs**: Server FQDN, admin credentials, connection string

#### 5. Key Vault (`modules/key-vault/`)
- **Purpose**: Centralized secrets management
- **Resources**:
  - Azure Key Vault
  - Access policies for Terraform and App Service
  - Secrets storage (database connection, JWT secret)
- **Features**:
  - Soft delete enabled
  - Production purge protection
  - Managed identity RBAC
- **Outputs**: Key Vault URI, secret IDs

#### 6. Monitoring (`modules/monitoring/`)
- **Purpose**: Observability and alerting
- **Resources**:
  - Log Analytics Workspace
  - Application Insights
  - Action Group for email alerts
  - Metric alerts (error rate, response time)
- **Alerts Configured**:
  - High error rate: >10 failures in 5 minutes (Severity 2)
  - High response time: >5 seconds average (Severity 3)
- **Outputs**: App Insights connection string, instrumentation key

#### 7. Storage (`modules/storage/`)
- **Purpose**: Blob storage for application data
- **Resources**:
  - Storage Account (GRS replication)
  - Blob containers (uploads, exports, backups)
  - SAS token for app access
  - RBAC role assignment for managed identity
- **Features**:
  - HTTPS-only enforcement
  - TLS 1.2+ minimum
  - Managed identity integration
- **Outputs**: Connection string, SAS token, container names

## Deployment Guide

### Prerequisites

1. **Azure Subscription**: You need an active Azure subscription
2. **Terraform**: Version 1.5.0 or higher
3. **Azure CLI**: For authentication (`az login`)
4. **Credentials**: Ensure you're authenticated to Azure

```bash
# Check Terraform version
terraform version

# Authenticate to Azure
az login
az account show
```

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/schemajeli.git
   cd schemajeli/infrastructure/terraform
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```
   
   This will:
   - Download required providers (azurerm, random)
   - Initialize the backend (local by default)
   - Create `.terraform/` directory

3. **Select Environment**:
   Choose between dev, staging, or production:
   ```bash
   # Development
   terraform plan -var-file="terraform.dev.tfvars"
   terraform apply -var-file="terraform.dev.tfvars"

   # Staging
   terraform plan -var-file="terraform.staging.tfvars"
   terraform apply -var-file="terraform.staging.tfvars"

   # Production
   terraform plan -var-file="terraform.prod.tfvars"
   terraform apply -var-file="terraform.prod.tfvars"
   ```

### Deployment Workflow

#### Step 1: Format and Validate
```bash
# Format Terraform files to standard
terraform fmt -recursive

# Validate configuration syntax
terraform validate
```

#### Step 2: Plan Changes
```bash
# Preview what will be created
terraform plan -var-file="terraform.dev.tfvars" -out=tfplan
```

#### Step 3: Review Plan
```bash
# Show human-readable plan
terraform show tfplan

# Or save to JSON for programmatic review
terraform show -json tfplan > plan.json
```

#### Step 4: Apply Configuration
```bash
# Apply with saved plan
terraform apply tfplan

# Or directly (will prompt for confirmation)
terraform apply -var-file="terraform.dev.tfvars"
```

#### Step 5: Verify Deployment
```bash
# Get outputs
terraform output

# View specific outputs
terraform output backend_app_url
terraform output frontend_url
terraform output database_server_fqdn
```

### Variables Configuration

#### Required Variables
- **environment**: Must be set to "dev", "staging", or "prod"
- **db_admin_password**: PostgreSQL admin password (min 8 characters)
- **jwt_secret**: JWT signing secret (min 32 characters)

#### Using tfvars Files
```bash
# Development (B2 SKU, LRS storage, 7-day backups)
terraform apply -var-file="terraform.dev.tfvars"

# Staging (S2 SKU, GRS storage, 14-day backups)
terraform apply -var-file="terraform.staging.tfvars"

# Production (P1v2 SKU, GRS storage, 30-day backups, zone redundancy)
terraform apply -var-file="terraform.prod.tfvars"
```

#### Overriding Variables via CLI
```bash
# Override specific variables
terraform apply \
  -var-file="terraform.dev.tfvars" \
  -var="db_backup_days=14" \
  -var="alert_email_addresses=[\"ops@company.com\"]"
```

#### Environment Variables
```bash
# Set sensitive values via environment
export TF_VAR_db_admin_password="YourSecurePassword123!"
export TF_VAR_jwt_secret="YourJWTSecretMin32Chars1234567890"

terraform apply -var-file="terraform.dev.tfvars"
```

## Environment Configuration

### Development (`terraform.dev.tfvars`)
- **Purpose**: Local development and testing
- **Compute**: B2 App Service (affordable)
- **Database**: Standard_B1ms (minimal)
- **Storage**: LRS (local redundancy)
- **Backups**: 7 days retention
- **Cost**: ~$50-80/month
- **SKU Strategy**: Minimal for cost savings

### Staging (`terraform.staging.tfvars`)
- **Purpose**: Production-like testing before release
- **Compute**: S2 App Service (production-like)
- **Database**: Standard_B2s (medium capacity)
- **Storage**: GRS (geo-redundancy)
- **Backups**: 14 days retention
- **Cost**: ~$200-300/month
- **SKU Strategy**: Balance between cost and production readiness

### Production (`terraform.prod.tfvars`)
- **Purpose**: Live application serving users
- **Compute**: P1v2 App Service (high availability)
- **Database**: Standard_B4ms (production capacity)
- **Storage**: GRS (geo-redundancy)
- **Backups**: 30 days retention + zone redundancy
- **Cost**: ~$400-600/month
- **SKU Strategy**: High availability, compliance, disaster recovery

## Common Operations

### View Current State
```bash
# Get all outputs
terraform output

# Get specific output
terraform output backend_app_url

# Get as JSON
terraform output -json
```

### Scale Resources

#### Increase App Service SKU
```bash
# Update variables
terraform apply \
  -var-file="terraform.dev.tfvars" \
  -var="app_service_sku=B3"
```

#### Increase Database Storage
```bash
terraform apply \
  -var-file="terraform.dev.tfvars" \
  -var="db_storage_mb=65536"
```

### Destroy Infrastructure

#### Destroy specific environment
```bash
# Warning: This will DELETE all resources!
terraform destroy -var-file="terraform.dev.tfvars"
```

#### Destroy specific resources
```bash
# Only destroy the storage account
terraform destroy \
  -var-file="terraform.dev.tfvars" \
  -target=module.storage
```

### Manage Secrets

#### View stored secrets (for reference only)
```bash
# This will show Key Vault name
terraform output key_vault_name

# Access secrets via Azure CLI
az keyvault secret list --vault-name <vault-name>
az keyvault secret show --vault-name <vault-name> --name database-connection-string
```

#### Update JWT Secret
```bash
# Generate new secret
openssl rand -base64 32

# Update variable
terraform apply \
  -var-file="terraform.dev.tfvars" \
  -var="jwt_secret=<new-secret>"
```

## Monitoring & Troubleshooting

### Check Deployment Status
```bash
# View most recent changes
terraform show

# Check specific resource
terraform state show module.app_service.azurerm_linux_web_app.backend

# List all managed resources
terraform state list
```

### Application Insights

View monitoring data:
```bash
# Get App Insights connection string from outputs
terraform output app_insights_connection_string

# Query logs in Azure Portal
# Home > Application Insights > <resource> > Logs
```

### Common Issues

#### Backend App Not Starting
1. Check Application Insights logs
2. Verify database connection string in Key Vault
3. Check App Service app settings
4. Review deployment slot logs

#### Database Connection Failures
1. Verify firewall rules allow your IP (dev) or Azure services (prod)
2. Check database credentials in Key Vault
3. Verify DNS resolution to database FQDN
4. Check NSG rules on database subnet

#### Static Web App Not Serving Frontend
1. Verify build succeeded in Static Web App deployment
2. Check custom domain DNS settings (if using custom domain)
3. Review API URL configuration in app settings
4. Check CORS configuration in backend

## State Management

### Local State (Default)
```bash
# State stored in terraform.tfstate
# Not recommended for production teams
# Risk: Accidental deletion or merge conflicts
```

### Remote State (Production)

To use Azure Storage backend:

```hcl
# In main.tf, update backend block:
backend "azurerm" {
  resource_group_name  = "schemajeli-terraform-rg"
  storage_account_name = "schemajeli tfstate"
  container_name       = "tfstate"
  key                  = "schemajeli.terraform.tfstate"
}
```

Create backend resources:
```bash
# Create resource group
az group create -n schemajeli-terraform-rg -l eastus

# Create storage account
az storage account create \
  -n schemajeli tfstate \
  -g schemajeli-terraform-rg \
  -l eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  -n tfstate \
  --account-name schemajeli tfstate

# Reinitialize backend
terraform init
```

### Lock/Unlock State
```bash
# List locks
terraform force-unlock <LOCK_ID>

# Note: Use with caution - only when necessary
```

## Security Best Practices

### 1. Secret Management
- ✅ Store sensitive values in Key Vault
- ✅ Use managed identities for Azure service authentication
- ✅ Rotate secrets regularly
- ❌ Never commit passwords to version control

### 2. Network Security
- ✅ Use VNets with proper subnet segmentation
- ✅ Implement NSGs with least-privilege rules
- ✅ Use private DNS for database isolation
- ✅ Enable service endpoints for Azure services

### 3. Access Control
- ✅ Use managed identities for app authentication
- ✅ Enable RBAC for Azure resources
- ✅ Restrict Key Vault access policies
- ✅ Audit all administrative access

### 4. Monitoring & Logging
- ✅ Enable Application Insights
- ✅ Configure Log Analytics retention
- ✅ Set up email alerts for critical issues
- ✅ Review logs regularly

### 5. Infrastructure Code
- ✅ Version control all Terraform files
- ✅ Use code reviews for infrastructure changes
- ✅ Validate and format all configurations
- ✅ Plan before applying changes

## Maintenance

### Regular Tasks

#### Weekly
- Review Application Insights for errors
- Check alert emails
- Monitor resource costs

#### Monthly
- Update Terraform provider versions
- Review and rotate credentials
- Analyze performance metrics

#### Quarterly
- Upgrade PostgreSQL version (when available)
- Review and optimize SKUs
- Conduct disaster recovery drill

### Backup & Recovery

#### Database Backups
- Automated daily backups to geo-redundant storage
- Retention: 7 days (dev), 14 days (staging), 30 days (prod)
- Recovery Point Objective (RPO): 1 day

#### Application Recovery
- App Service staging slot enables blue-green deployment
- Static Web App automatic deployments
- Infrastructure can be re-created from Terraform state

## Cost Optimization

### Current Estimates

| Environment | App Service | Database | Storage | Monitoring | Monthly |
|-------------|------------|----------|---------|-----------|---------|
| Dev         | $15        | $20      | $5      | $10       | ~$50    |
| Staging     | $75        | $50      | $10     | $20       | ~$155   |
| Production  | $150       | $100     | $20     | $25       | ~$295   |

### Optimization Tips
- Use Free tier for Static Web App in dev
- Use B-series VMs for non-critical environments
- Enable auto-shutdown for non-production resources
- Review and remove unused resources monthly

## Support & Documentation

### References
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Architecture Best Practices](https://docs.microsoft.com/en-us/azure/architecture/)
- [PostgreSQL on Azure Documentation](https://docs.microsoft.com/en-us/azure/postgresql/)

### Getting Help
1. Check logs: `terraform state list` and `terraform show`
2. Review Azure Portal for resource details
3. Check Application Insights for runtime errors
4. Consult team documentation

---

**Last Updated**: 2024
**Terraform Version**: 1.5.0+
**Azure Provider Version**: 3.80.0+
