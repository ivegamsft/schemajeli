# SchemaJeli Infrastructure - Quick Reference Guide

## 🚀 Quick Deploy Commands

### Development Environment
```bash
cd infrastructure/terraform
terraform init
terraform plan -var-file="terraform.dev.tfvars"
terraform apply -var-file="terraform.dev.tfvars"
```

### Staging Environment
```bash
terraform plan -var-file="terraform.staging.tfvars"
terraform apply -var-file="terraform.staging.tfvars"
```

### Production Environment
```bash
export TF_VAR_db_admin_password="YourSecurePassword123!"
export TF_VAR_jwt_secret="YourJWTSecretMin32Chars1234567890"
terraform plan -var-file="terraform.prod.tfvars"
terraform apply -var-file="terraform.prod.tfvars"
```

---

## 📋 Module Structure

| Module | Purpose | Key Resources |
|--------|---------|---|
| **networking** | VNet infrastructure | VNet, Subnets, NSGs |
| **app-service** | Backend API hosting | App Service Plan, Web App, Slot |
| **static-web-app** | Frontend hosting | Static Web App, Custom Domain |
| **database** | PostgreSQL database | Flexible Server, Private DNS |
| **key-vault** | Secrets management | Key Vault, Access Policies |
| **monitoring** | Observability | App Insights, Log Analytics, Alerts |
| **storage** | Blob storage | Storage Account, Containers, SAS |

---

## 🔑 Important Output Values

Get outputs after deployment:
```bash
terraform output

# Specific outputs:
terraform output backend_app_url
terraform output frontend_url
terraform output database_server_fqdn
terraform output key_vault_uri
```

---

## 🔐 Secrets Management

All secrets stored in Azure Key Vault. Access via:
```bash
# Get Key Vault name
vault_name=$(terraform output key_vault_name)

# List secrets
az keyvault secret list --vault-name $vault_name

# View specific secret
az keyvault secret show --vault-name $vault_name --name database-connection-string
```

---

## 📊 Resource Limits by Environment

| Resource | Dev | Staging | Prod |
|----------|-----|---------|------|
| App Service SKU | B2 | S2 | P1v2 |
| Database SKU | B1ms | B2s | B4ms |
| Storage Replication | LRS | GRS | GRS |
| Backup Retention | 7 days | 14 days | 30 days |
| Max DB Connections | 50 | 100 | 500 |

---

## 🔄 Common Operations

### Scale App Service
```bash
terraform apply \
  -var-file="terraform.prod.tfvars" \
  -var="app_service_sku=P2v2"
```

### Increase Database Storage
```bash
terraform apply \
  -var-file="terraform.prod.tfvars" \
  -var="db_storage_mb=65536"
```

### Update JWT Secret
```bash
# Generate new secret
openssl rand -base64 32

# Apply with new secret
terraform apply \
  -var-file="terraform.prod.tfvars" \
  -var="jwt_secret=<new-secret>"
```

### Destroy Environment (WARNING: Data Loss!)
```bash
terraform destroy -var-file="terraform.dev.tfvars"
```

### Destroy Specific Module
```bash
terraform destroy -var-file="terraform.dev.tfvars" -target=module.storage
```

---

## 📊 Monitoring & Alerts

### Application Insights Dashboard
1. Go to Azure Portal
2. Navigate to Application Insights resource
3. View metrics, logs, and performance data

### Set Alert Recipients
Update in `terraform.{env}.tfvars`:
```hcl
alert_email_addresses = [
  "ops-team@company.com",
  "incident-response@company.com"
]
```

### Alert Thresholds
- **Error Rate**: >10 failures in 5 minutes (Severity 2)
- **Response Time**: >5 seconds average (Severity 3)

---

## 🔍 Validation Commands

```bash
# Check syntax
terraform validate

# Format check
terraform fmt -check -recursive .

# Create plan file
terraform plan -var-file="terraform.dev.tfvars" -out=tfplan

# Show plan
terraform show tfplan

# Estimate costs
terraform plan -var-file="terraform.prod.tfvars" | grep azure
```

---

## 🐛 Troubleshooting

### Provider Authentication
```bash
az login
az account show
```

### Check Deployment Status
```bash
terraform state list
terraform state show module.database.azurerm_postgresql_flexible_server.main
```

### View Recent Logs
```bash
# App Service logs
az webapp log tail --name <app-name> --resource-group <rg-name>

# Application Insights
az monitor app-insights component show --app <insights-name>
```

### Database Connectivity
```bash
# Get connection string
psql -h <server-fqdn> -U <admin> -d <dbname>

# Test connection
psql -h $(terraform output database_server_fqdn) -U schemajeli_admin -d schemajeli_dev
```

---

## 📁 File Locations

```
f:\Git\SchemaJeli\
├── infrastructure/
│   └── terraform/
│       ├── main.tf                      # Root orchestration
│       ├── variables.tf                 # Root variables
│       ├── outputs.tf                   # Root outputs
│       ├── terraform.dev.tfvars         # Dev config
│       ├── terraform.staging.tfvars     # Staging config
│       ├── terraform.prod.tfvars        # Prod config
│       ├── README.md                    # Full documentation
│       └── modules/
│           ├── networking/              # VNet infrastructure
│           ├── app-service/             # Backend hosting
│           ├── static-web-app/          # Frontend hosting
│           ├── database/                # PostgreSQL
│           ├── key-vault/               # Secrets
│           ├── monitoring/              # Observability
│           └── storage/                 # Blob storage
└── INFRASTRUCTURE_REFACTORING_SUMMARY.md # This architecture guide
```

---

## 🚨 Critical Values Don't Share

⚠️ **NEVER commit these to version control:**
- `db_admin_password`
- `jwt_secret`
- Connection strings
- Access keys
- SSH keys

Use environment variables or Azure Key Vault instead!

---

## 🔄 Release Checklist

### Before Deploying to Production

- [ ] Run `terraform plan` and review output
- [ ] Verify all variables are correct
- [ ] Check Secret values in Key Vault
- [ ] Validate backup retention settings
- [ ] Confirm alert email recipients
- [ ] Review VNet CIDR ranges don't conflict
- [ ] Check database is accessible
- [ ] Verify app service environment variables
- [ ] Test static web app deployment
- [ ] Validate monitoring and alerts work

### After Deployment

- [ ] Access backend API URL
- [ ] Access frontend URL
- [ ] Check Application Insights for errors
- [ ] Verify database backups started
- [ ] Test file uploads/downloads
- [ ] Check alert emails deliver
- [ ] Review Key Vault access logs
- [ ] Update DNS records (if custom domain)

---

## 📞 Support Contacts

### Issues
- See `infrastructure/terraform/README.md` for comprehensive troubleshooting
- Check Azure Portal resource health status
- Review Application Insights for error logs

### Documentation
- Full guide: `infrastructure/terraform/README.md`
- Architecture: `INFRASTRUCTURE_REFACTORING_SUMMARY.md`
- Code comments in module files

---

## 📈 Performance Monitoring

### Key Metrics to Monitor
- **Response Time**: Target <2 seconds
- **Error Rate**: Target <1% of requests
- **Database Connections**: Ensure under max_connections
- **Storage Usage**: Monitor growth rate
- **Backup Status**: Ensure daily backups succeed

### Cost Monitoring
- Review Azure bill monthly
- Check quota usage
- Monitor unused resources
- Analyze spending trends
- Use Azure Cost Analysis tool

---

## 🔒 Security Reminders

1. **Never commit secrets** to git
2. **Use Key Vault** for all credentials
3. **Enable logging** on all resources
4. **Review access** monthly
5. **Rotate secrets** periodically
6. **Validate CORS** settings
7. **Check firewall** rules
8. **Monitor NSGs** for changes

---

## 💡 Tips & Tricks

### View All Resources
```bash
terraform state list | sort
```

### Find Specific Resource
```bash
terraform state show module.app_service.azurerm_linux_web_app.backend
```

### Show Only Changes
```bash
terraform plan -var-file="terraform.prod.tfvars" | grep -E "^(  [+-]|  ~)"
```

### Backup Current State
```bash
cp terraform.tfstate terraform.tfstate.backup.$(date +%s)
```

### View Outputs as JSON
```bash
terraform output -json | jq .
```

---

## 📚 Learning Resources

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Architecture Best Practices](https://docs.microsoft.com/en-us/azure/architecture/)
- [PostgreSQL on Azure](https://docs.microsoft.com/en-us/azure/postgresql/)
- [App Service Best Practices](https://docs.microsoft.com/en-us/azure/app-service/app-service-best-practices)

---

**Last Updated**: January 31, 2026  
**Version**: 1.0  
**Status**: ✅ Production Ready
