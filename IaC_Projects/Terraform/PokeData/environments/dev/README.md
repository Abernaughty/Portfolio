# PokeData Development Environment

This directory contains the Terraform configuration for deploying the PokeData application to the development environment.

## Architecture

The dev environment deploys the following Azure resources:
- **Resource Group**: Container for all resources
- **Cosmos DB**: Serverless NoSQL database for Pokemon card data
- **Function App**: .NET 8 serverless API (Consumption plan)
- **Static Web App**: React frontend (Free tier)
- **API Management**: API gateway (Consumption tier)
- **Application Insights**: Monitoring and telemetry

## Prerequisites

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Terraform**: Version >= 1.9.0
3. **Azure CLI**: Authenticated (`az login`)
4. **GitHub Token**: Personal access token with repo permissions (for Static Web App)
5. **State Storage**: Complete the state-storage setup first

## Setup Instructions

### 1. Create State Storage (One-time)

```bash
cd ../../state-storage
terraform init
terraform apply
# Note the storage account name from the output
```

### 2. Configure Backend

After creating state storage, update `backend.tf`:
1. Comment out the local backend block
2. Uncomment the azurerm backend block
3. Replace `tfstate<random>` with your actual storage account name

### 3. Configure Variables

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
# REQUIRED: github_token, apim_publisher_email
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Save outputs for reference
terraform output -json > outputs.json
```

## Module Configuration

This environment uses the following module configurations:

| Module | Configuration | Rationale |
|--------|--------------|-----------|
| Cosmos DB | Serverless | Cost-effective for dev workloads |
| Function App | Consumption Plan | Pay-per-execution model |
| Static Web App | Free Tier | Sufficient for development |
| API Management | Consumption Tier | Low-cost API gateway |

## Cost Optimization

The dev environment is optimized for minimal costs:
- **Serverless/Consumption tiers**: Pay only for actual usage
- **No VNet integration**: Reduces networking costs
- **Minimal backup retention**: 7 days only
- **No auto-scaling**: Manual scaling sufficient for dev

Estimated monthly cost: **< $50** (with minimal usage)

## Environment Variables

You can also use environment variables instead of terraform.tfvars:

```bash
export TF_VAR_repository_token="your-github-pat"
export TF_VAR_apim_publisher_email="your-email@example.com"
```

## Accessing Resources

After deployment, access your resources:

1. **Static Web App**: 
   ```bash
   terraform output static_web_app_url
   ```

2. **Function App API**:
   ```bash
   terraform output function_app_url
   ```

3. **API Management Portal**:
   ```bash
   terraform output api_management_developer_portal_url
   ```

4. **Application Insights**:
   - Portal: Azure Portal > Resource Group > Application Insights
   - Instrumentation Key: `terraform output -raw function_app_instrumentation_key`

## Testing the Deployment

1. **Verify Static Web App**:
   - Navigate to the URL
   - Should see the React application

2. **Test Function App**:
   ```bash
   curl https://<function-app-name>.azurewebsites.net/api/health
   ```

3. **Check API Management**:
   - Access developer portal
   - Test API endpoints

4. **Monitor with App Insights**:
   - Check Live Metrics
   - Review logs and traces

## Troubleshooting

### Common Issues

1. **GitHub Token Error**:
   - Ensure token has `repo` and `workflow` permissions
   - Token must not be expired

2. **Deployment Failures**:
   ```bash
   # Check detailed logs
   terraform apply -auto-approve 2>&1 | tee deploy.log
   ```

3. **State Lock Issues**:
   ```bash
   # Force unlock if needed (use with caution)
   terraform force-unlock <lock-id>
   ```

4. **Resource Already Exists**:
   ```bash
   # Import existing resource
   terraform import module.cosmos_db.azurerm_cosmosdb_account.this <resource-id>
   ```

## Clean Up

To destroy the dev environment:

```bash
# Review what will be destroyed
terraform plan -destroy

# Destroy resources
terraform destroy

# Confirm by typing 'yes'
```

⚠️ **Warning**: This will delete all resources and data!

## CI/CD Integration

This configuration is designed to work with CI/CD pipelines:

### Azure DevOps
```yaml
- task: TerraformTaskV2@2
  inputs:
    provider: 'azurerm'
    command: 'apply'
    workingDirectory: 'environments/dev'
    environmentServiceNameAzureRM: 'Azure-Service-Connection'
```

### GitHub Actions
```yaml
- name: Terraform Apply
  run: |
    terraform init
    terraform apply -auto-approve
  working-directory: environments/dev
```

## Security Considerations

1. **Secrets Management**:
   - Never commit terraform.tfvars with real values
   - Use Azure Key Vault for production secrets
   - Rotate GitHub tokens regularly

2. **Access Control**:
   - Dev environment has relaxed security
   - No private endpoints to reduce complexity
   - CORS configured for localhost testing

3. **Data Protection**:
   - Backup enabled (7-day retention)
   - Soft delete enabled on Cosmos DB
   - TLS 1.2 minimum for all services

## Next Steps

After successful deployment:

1. **Configure Application Code**:
   - Update connection strings in app
   - Deploy code to Function App
   - Push frontend to GitHub

2. **Set Up Monitoring**:
   - Create custom dashboards
   - Configure alerts
   - Set up log queries

3. **Prepare for Staging**:
   - Document any dev-specific configurations
   - Note performance baselines
   - Create runbook for promotion

## Support

For issues or questions:
1. Check the [main README](../../README.md)
2. Review module documentation in `modules/`
3. Check Azure Portal for resource-specific logs
4. Use `terraform console` for debugging

## Version History

- v1.0.0 - Initial dev environment setup
- Terraform: >= 1.9.0
- Azure Provider: ~> 4.40.0
