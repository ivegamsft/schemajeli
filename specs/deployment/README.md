# Deployment & Infrastructure Specifications

Infrastructure as Code, deployment procedures, and configuration management.

## Infrastructure as Code (Terraform)

All infrastructure is managed via Terraform with the following structure:

```
infrastructure/terraform/
├── main.tf                 # Main configuration and module calls
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── locals.tf               # Local values
├── terraform.tfvars        # Variable values
├── modules/
│   ├── app-service/        # Backend API deployment
│   ├── app-configuration/  # Azure App Configuration
│   ├── database/           # PostgreSQL Flexible Server
│   ├── key-vault/          # Azure Key Vault
│   ├── networking/         # VNet, subnets, NSGs
│   ├── storage/            # Blob storage for uploads
│   ├── monitoring/         # Application Insights
│   └── static-web-app/     # Frontend SPA deployment
```

## Deployment Architecture

### Development Environment
- Local development with Docker Compose
- PostgreSQL local container
- Node.js backends/frontends running locally

### Azure Staging/Production
- App Service Plan (Linux)
- Backend Linux Web App
- Frontend Static Web App
- PostgreSQL Flexible Server
- Storage Account
- Key Vault
- App Configuration
- Application Insights
- Virtual Network with private endpoints

## Infrastructure Variables

### Core Configuration
```terraform
project_name = "schemajeli"
environment = "dev" | "staging" | "prod"
location = "eastus"
cost_center = "engineering"
```

### App Service
```terraform
app_service_sku = "B2" (dev), "B3" (staging), "P1v2" (prod)
cors_allowed_origins = ["http://localhost:5173"]
```

### Database
```terraform
postgres_version = "15"
db_sku = "Standard_B1ms"
db_storage_mb = 32768 (32GB minimum)
db_backup_days = 7
db_max_connections = 100
```

### Storage
```terraform
storage_account_tier = "Standard"
storage_account_replication = "GRS"
```

### App Configuration
```terraform
app_configuration_sku = "standard"
purge_protection_enabled = false
```

## Deployment Steps

### 1. Terraform Init
```bash
cd infrastructure/terraform
terraform init -backend-config="key=schemajeli.tfstate"
```

### 2. Terraform Plan
```bash
terraform plan -var-file=environments/dev.tfvars -out=plan.tfplan
```

### 3. Terraform Apply
```bash
terraform apply plan.tfplan
```

### 4. Post-Deployment Configuration
- Set environment variables in App Service
- Configure database backups
- Enable monitoring and alerts
- Configure custom domains (if prod)

## Azure Resources

### Compute
- App Service Plan (Linux)
- Backend Web App (Node.js 18 LTS)
- Frontend Static Web App (React SPA)

### Data
- PostgreSQL Flexible Server (v15)
- Storage Account (Blob containers)

### Security
- Key Vault (Secrets, certificates)
- Managed Identities (System-assigned)

### Networking
- Virtual Network (10.0.0.0/16)
- App Subnet (10.0.1.0/24)
- Database Subnet (10.0.2.0/24)
- Network Security Groups

### Management
- App Configuration
- Application Insights
- Monitor (Alerts, Metrics)

## Environment Configuration

### Development (.env)
```env
AZURE_TENANT_ID=62837751-4e48-4d06-8bcb-57be1a669b78
AZURE_CLIENT_ID=b521d5cf-a911-4ea4-bba6-109a1fcb9fe9
AZURE_CLIENT_SECRET=<secret>
DATABASE_URL=postgresql://user:pass@localhost:5432/schemajeli
RBAC_MOCK_ROLES=Viewer
```

### Production
- All secrets stored in Azure Key Vault
- Referenced via Key Vault references in App Service
- RBAC groups configured in Entra ID
- HTTPS enforced
- Custom domain configured

## Monitoring & Logging

### Application Insights
- Request metrics
- Performance counters
- Exception tracking
- Dependency monitoring
- Availability tests

### Azure Monitor
- Resource metrics
- Alert rules
- Log Analytics workspace
- Diagnostic settings

## Disaster Recovery

### Backup Strategy
- PostgreSQL automated backups (7-35 days retention)
- Storage Account geo-redundant replication (GRS)
- App Service deployment slots for zero-downtime updates

### Recovery Procedures
- Database restore from Point-In-Time Recovery (PITR)
- Terraform state stored in Azure Storage with versioning

## Security Considerations

- TLS/HTTPS for all communications
- Managed identities for service authentication
- RBAC for resource access control
- Network isolation via Virtual Networks
- Secrets rotation policy
- Regular security updates

## Related Documentation

- [AZURE_SETUP.md](../../AZURE_SETUP.md) - Azure Entra ID setup guide
- [AZURE_MIGRATION_STATUS.md](../../AZURE_MIGRATION_STATUS.md) - Entra ID migration progress
- [Terraform Code](../../infrastructure/terraform/)
