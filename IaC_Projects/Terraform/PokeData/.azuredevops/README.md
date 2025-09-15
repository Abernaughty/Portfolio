# Azure DevOps CI/CD Pipeline for PokeData Infrastructure

## Overview

This directory contains a production-ready Azure DevOps CI/CD pipeline for deploying PokeData infrastructure using Terraform. The pipeline demonstrates enterprise-grade DevOps practices including:

- 🔄 Multi-stage deployments
- 🔒 Security scanning with tfsec and Checkov
- ✅ Infrastructure validation and testing
- 📊 Comprehensive artifact management
- 📧 Email notifications
- 🏷️ Git tagging for deployments
- 🔍 Post-deployment verification

## Pipeline Architecture

```
┌─────────────┐     ┌──────────┐     ┌────────┐     ┌────────┐     ┌──────┐
│  Validate   │────▶│   Plan   │────▶│ Deploy │────▶│  Test  │────▶│Notify│
└─────────────┘     └──────────┘     └────────┘     └────────┘     └──────┘
      │                   │                │              │
      ├─ Format           ├─ Init         ├─ Apply       ├─ Verify
      ├─ Validate         ├─ Plan         ├─ Tag         └─ Smoke Tests
      └─ Security Scan    └─ Artifacts    └─ Outputs
```

## Prerequisites

### 1. Azure DevOps Setup

1. **Organization**: `maber-devops`
2. **Project**: `PCPC`
3. **Repository**: Connected to GitHub

### 2. Service Connections Required

#### Azure Service Connection
Create a service principal and configure in Azure DevOps:

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "sp-azdo-pokedata" \
  --role Contributor \
  --scopes /subscriptions/{subscription-id}

# Save the output:
# - appId (Client ID)
# - password (Client Secret)  
# - tenant (Tenant ID)
```

In Azure DevOps:
1. Go to Project Settings → Service connections
2. New service connection → Azure Resource Manager
3. Service principal (manual)
4. Name: `Azure-Service-Connection`
5. Enter the credentials from above

#### GitHub Service Connection (Optional for PR comments)
1. Project Settings → Service connections
2. New service connection → GitHub
3. Authorize with your GitHub account
4. Name: `GitHub-Service-Connection`

### 3. Variable Groups

Create these variable groups in Azure DevOps Library:

#### terraform-common
```yaml
ARM_TENANT_ID: {your-tenant-id}
ARM_SUBSCRIPTION_ID: {your-subscription-id}
```

#### terraform-dev
```yaml
ARM_CLIENT_ID: {service-principal-app-id}
ARM_CLIENT_SECRET: {service-principal-password} # Mark as secret
```

### 4. Remote State Configuration

The pipeline uses remote state stored in Azure Storage:
- **Storage Account**: `tfstateyul4ts`
- **Container**: `tfstate`
- **Key**: `pokedata/dev.tfstate`

Ensure the service principal has access to this storage account.

## Pipeline Configuration

### Triggers

- **Main branch**: Automatic deployment to dev environment
- **Pull Requests**: Validation and plan only (no deployment)
- **Path filters**: Excludes markdown and memory-bank files

### Stages

#### 1. Validate & Scan
- Terraform format check
- Terraform validate
- tfsec security scanning
- Checkov compliance scanning

#### 2. Plan
- Generates Terraform plan
- Saves plan as artifact
- Posts summary to PR (if applicable)

#### 3. Deploy (main branch only)
- Downloads saved plan
- Applies infrastructure changes
- Tags deployment in Git
- Generates deployment summary

#### 4. Test
- Verifies all resources exist
- Tests connectivity
- Validates resource states

#### 5. Notify
- Sends email to mike@maber.io
- Includes pipeline status and links

## Setting Up the Pipeline

### Step 1: Push Pipeline Files to Repository

```bash
git add .azuredevops/
git commit -m "Add Azure DevOps CI/CD pipeline"
git push origin main
```

### Step 2: Create Pipeline in Azure DevOps

1. Navigate to Pipelines → New Pipeline
2. Select "GitHub (YAML)"
3. Select your repository
4. Select "Existing Azure Pipelines YAML file"
5. Path: `/IaC_Projects/Terraform/PokeData/.azuredevops/azure-pipelines.yml`
6. Review and Run

### Step 3: Configure Environments (Optional)

For production deployments with approval gates:

1. Pipelines → Environments
2. New environment → "dev"
3. Add approvals and checks as needed

## Pipeline Features

### Security Scanning

The pipeline includes two security scanners:

- **tfsec**: Terraform-specific security scanner
- **Checkov**: General infrastructure-as-code scanner

Results are published as build artifacts for review.

### Artifact Management

The pipeline creates several artifacts:

- `terraform-plan`: The actual Terraform plan file
- `plan-output-dev`: Human-readable plan output
- `plan-json-dev`: JSON format for parsing
- `security-scan-results`: tfsec results
- `compliance-scan-results`: Checkov results
- `deployment-summary-dev`: Post-deployment summary

### Git Tagging

Successful deployments are automatically tagged:
- Format: `{environment}-{build-number}`
- Example: `dev-20250109.1`

### Infrastructure Tests

Post-deployment tests verify:
- Resource group exists
- Cosmos DB is accessible
- Function App is running
- Static Web App responds
- API Management is provisioned
- Application Insights is configured

## Customization

### Adding Environments

To add staging or production:

1. Copy `environments/dev/` to `environments/staging/`
2. Update variables in `terraform.tfvars`
3. Create new variable group `terraform-staging`
4. Update pipeline to include staging stage

### Modifying Notifications

Edit the notification stage in `azure-pipelines.yml`:
- Change email recipient
- Add Teams/Slack notifications
- Customize message format

### Adding More Tests

Extend `infrastructure-tests.yml`:
- Add performance tests
- Include security validation
- Test specific endpoints

## Troubleshooting

### Common Issues

1. **Service Connection Not Found**
   - Ensure service connection name matches exactly
   - Verify permissions on the service connection

2. **State Lock Issues**
   - Check if another pipeline is running
   - Manually break lock if needed: `terraform force-unlock {lock-id}`

3. **Permission Denied**
   - Verify service principal has Contributor role
   - Check resource group permissions

4. **Pipeline Fails at Plan**
   - Review terraform validate output
   - Check for missing variables
   - Ensure backend is accessible

### Debug Mode

Enable debug logging:
1. Run pipeline with variables
2. Add: `system.debug: true`

## Best Practices

1. **Always Review Plans**: Never auto-approve production deployments
2. **Use PR Validation**: Test changes in PR before merging
3. **Monitor Costs**: Review plan outputs for cost implications
4. **Regular Updates**: Keep Terraform and providers updated
5. **Security First**: Address security scan findings promptly

## Support

- **Pipeline Issues**: Check Azure DevOps logs
- **Terraform Issues**: Review plan output artifacts
- **Infrastructure Issues**: Check Azure Portal and logs
- **Notifications**: mike@maber.io

## Next Steps

1. ✅ Configure service connections
2. ✅ Create variable groups
3. ✅ Run initial pipeline
4. ⏳ Add staging environment
5. ⏳ Implement Terratest
6. ⏳ Add cost estimation
7. ⏳ Create dashboard

## License

This pipeline configuration is part of the PokeData portfolio project.

---

**Created by**: Azure Pipeline Automation
**Last Updated**: January 2025
**Version**: 1.0.0
