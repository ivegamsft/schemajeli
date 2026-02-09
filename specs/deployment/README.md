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

## Performance & Capacity

> **Clarified 2026-02-08:** Expected concurrent user load and autoscaling parameters.

- **Target load**: Up to 50 concurrent users (internal team/department schema documentation tool)
- **Autoscaling**: Not required for initial deployment; the fixed App Service Plan SKUs are sufficient
- **Response time targets**: Simple queries <100ms p95, complex searches <500ms p95 (per constitution)
- **Database connections**: 100 max connections is adequate for the expected load

## CI/CD Pipeline

> **Clarified 2026-02-08:** Deployment automation and promotion strategy.

### GitHub Actions Workflows
- **CI (on every PR)**: lint → build → unit tests → coverage check (≥70%)
- **CD to Dev**: Auto-deploy on merge to `main` branch
- **CD to Staging**: Manual trigger or auto-deploy on release candidate tag (`rc-*`)
- **CD to Prod**: Manual trigger with required approval from at least 1 maintainer

### Deployment Method
- Backend: Docker container image pushed to Azure Container Registry, deployed to App Service
- Frontend: Built static assets deployed to Azure Static Web App
- Database migrations: Run via `prisma migrate deploy` as a pre-deployment step in the pipeline

### Approval Gates
- Staging → Prod promotion requires passing E2E tests in staging environment
- GitHub Environment protection rules enforce required reviewers for `production` environment

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
AZURE_TENANT_ID=<tenant-id>
AZURE_CLIENT_ID=<backend-app-registration-id>
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

### Alert Thresholds & Escalation

> **Clarified 2026-02-08:** Specific alert thresholds and escalation procedures.

- **Response time**: Alert when p95 response time exceeds 500ms for 5 consecutive minutes
- **Error rate**: Alert when HTTP 5xx rate exceeds 5% of total requests over a 10-minute window
- **CPU/Memory**: Alert when App Service CPU > 80% or memory > 85% sustained for 10 minutes
- **Database**: Alert when connection pool usage exceeds 80% or query time p95 > 1s
- **Availability**: Alert when health check endpoint fails 3 consecutive probes (2-minute interval)
- **Escalation**: Alerts sent to engineering team via email and Teams channel; no on-call rotation required for an internal tool — issues addressed during business hours (next business day SLA)

### Azure Monitor
- Resource metrics
- Alert rules
- Log Analytics workspace
- Diagnostic settings

## Disaster Recovery

### Recovery Objectives

> **Clarified 2026-02-08:** RTO/RPO targets for production environment.

- **Recovery Time Objective (RTO)**: 4 hours — system must be restored within 4 hours of an outage
- **Recovery Point Objective (RPO)**: 1 hour — maximum acceptable data loss is 1 hour of transactions
- These targets align with an important internal tool that does not require near-immediate recovery but should not remain down for an entire business day

### Backup Strategy
- PostgreSQL automated backups (7-35 days retention)
- Storage Account geo-redundant replication (GRS)
- App Service deployment slots for zero-downtime updates

### Recovery Procedures
- Database restore from Point-In-Time Recovery (PITR)
- Terraform state stored in Azure Storage with versioning

### Rollback Strategy

> **Clarified 2026-02-08:** Rollback procedures and triggers.

- **App Service deployment slots**: Use staging slot for blue-green deployments; swap slots for zero-downtime rollback
- **Automatic rollback trigger**: If the health check endpoint (`/api/v1/health`) fails 3 consecutive times within 5 minutes after a slot swap, auto-swap back to the previous slot
- **Manual rollback**: Swap deployment slots back via Azure Portal or `az webapp deployment slot swap --action reset`
- **Database rollback**: Prisma migrations are forward-only; breaking schema changes require a new corrective migration rather than rollback
- **Database migration failure handling**: If `prisma migrate deploy` fails during the pre-deployment step, the pipeline must halt and NOT proceed with slot swap; the failed migration should be investigated manually, and a corrective migration applied before retrying deployment
- **Concurrent deployment protection**: GitHub Actions concurrency groups (`concurrency: deploy-${{ env.ENVIRONMENT }}`) ensure only one deployment runs per environment at a time; queued deployments are cancelled in favor of the latest
- **Infrastructure rollback**: Revert Terraform to previous state file version in Azure Storage and re-apply

## Cost Management

> **Clarified 2026-02-08:** Budget limits, cost alerts, and resource tagging strategy.

- **Monthly budget target**: ~$150–$250/month for dev/staging; ~$300–$500/month for production (small internal tool scale)
- **Cost alerts**: Configure Azure Cost Management alerts at 75%, 90%, and 100% of monthly budget
- **Resource tagging**: All resources tagged with `project: schemajeli`, `environment: dev|staging|prod`, `cost_center: engineering`, `managed_by: terraform`
- **Cost optimization**: Use B-series (burstable) SKUs for dev/staging; review resource utilization monthly and right-size as needed
- **Unused resource cleanup**: Review and remove orphaned resources (disks, IPs, old container images) quarterly

## Security Considerations

- TLS/HTTPS for all communications
- Managed identities for service authentication
- RBAC for resource access control
- Network isolation via Virtual Networks
- Secrets rotation policy
- Regular security updates

### Security Auditing & Incident Response

> **Clarified 2026-02-08:** Security testing and incident response procedures.

- **Dependency scanning**: Enable GitHub Dependabot for automated vulnerability alerts and PRs on both backend and frontend
- **Static analysis**: ESLint security plugin (`eslint-plugin-security`) runs in CI pipeline
- **Penetration testing**: Not required for initial launch; reassess after 6 months or when handling sensitive data beyond schema metadata
- **Incident response**: Security issues reported via GitHub Security Advisories; engineering team triages within 1 business day; critical vulnerabilities (CVSS ≥ 9.0) patched within 48 hours
- **Access review**: Review Azure RBAC assignments and Entra ID group memberships quarterly

### Secrets Rotation Policy

> **Clarified 2026-02-08:** Rotation schedules and procedures.

- **Azure Entra ID client secrets**: 90-day rotation; alert 14 days before expiry via Azure Monitor
- **Database passwords**: Prefer managed identity authentication (passwordless) where supported; otherwise 90-day rotation
- **Key Vault secrets**: Enable soft-delete and purge protection in production; configure expiry notifications
- **API keys / third-party tokens**: Rotate per provider guidance, minimum every 180 days

## Related Documentation

- [AZURE_SETUP.md](../../AZURE_SETUP.md) - Azure Entra ID setup guide
- [AZURE_MIGRATION_STATUS.md](../../AZURE_MIGRATION_STATUS.md) - Entra ID migration progress
- [Terraform Code](../../infrastructure/terraform/)
