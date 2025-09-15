# PokeData Infrastructure Deployment Guide

## Quick Start Deployment

This guide will help you deploy the PokeData infrastructure from scratch.

## Prerequisites Checklist

- [ ] Azure subscription with appropriate permissions
- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] Terraform >= 1.9.0 installed
- [ ] GitHub personal access token (PAT) with repo permissions
- [ ] Valid email address for API Management

## Step 1: Deploy State Storage (5 minutes)

First, we need to create the storage account for Terraform state management:

```bash
# Navigate to state storage directory
cd state-storage

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Create the storage account
terraform apply -auto-approve

# IMPORTANT: Note the storage account name!
terraform output storage_account_name
# Example output: tfstate123abc
```

Save this storage account name - you'll need it in Step 2.

## Step 2: Configure Dev Environment (2 minutes)

```bash
# Navigate to dev environment
cd ../environments/dev

# Create your variables file from the example
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your actual values:
```hcl
# Required changes:
github_token         = "ghp_your_actual_github_token_here"
apim_publisher_email = "your-actual-email@example.com"
owner               = "Your Name"
```

## Step 3: Configure Backend (2 minutes)

Edit `environments/dev/backend.tf`:

1. Comment out the local backend block (lines 14-17)
2. Uncomment the azurerm backend block (lines 5-12)
3. Replace `tfstate<random>` with your actual storage account name from Step 1

Example:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "pokedata-terraform-state-rg"
    storage_account_name = "tfstate123abc"  # Your actual name here
    container_name       = "tfstate-dev"
    key                  = "dev.terraform.tfstate"
  }
}
```

## Step 4: Deploy Dev Environment (15-20 minutes)

```bash
# Initialize with the new backend
terraform init

# You'll be prompted to migrate state from local to remote - type 'yes'

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
# Type 'yes' when prompted
```

## Step 5: Verify Deployment

After successful deployment, get your resource URLs:

```bash
# Get all outputs
terraform output

# Get specific URLs
terraform output static_web_app_url
terraform output function_app_url
terraform output api_management_gateway_url
```

## Validation Checklist

- [ ] Static Web App URL loads in browser
- [ ] Function App URL responds (may show default Azure page)
- [ ] API Management developer portal accessible
- [ ] All resources visible in Azure Portal

## Common Issues & Solutions

### Issue: GitHub Token Error
**Solution**: Ensure your GitHub PAT has these permissions:
- repo (all)
- workflow
- write:packages (optional)

### Issue: Storage Account Name Already Exists
**Solution**: The random suffix should prevent this, but if it happens:
1. Delete the failed resources: `terraform destroy`
2. Run `terraform apply` again (will generate new random suffix)

### Issue: Terraform Init Fails
**Solution**: Check Azure authentication:
```bash
az account show
az account set --subscription "your-subscription-id"
```

### Issue: API Management Takes Forever
**Solution**: API Management can take 30-45 minutes to deploy. This is normal for the first deployment.

## Cost Estimates

Dev environment with minimal usage:
- Cosmos DB (Serverless): ~$5/month
- Function App (Consumption): ~$0-5/month
- Static Web App (Free): $0
- API Management (Consumption): ~$5/month
- Storage Account (State): ~$1/month
- **Total: ~$15-20/month**

## Clean Up Resources

To destroy all resources and stop billing:

```bash
# Destroy dev environment
cd environments/dev
terraform destroy
# Type 'yes' when prompted

# Optionally destroy state storage (careful!)
cd ../../state-storage
terraform destroy
# Type 'yes' when prompted
```

## Next Steps After Deployment

1. **Test the Application**
   - Deploy application code to Function App
   - Push frontend code to GitHub repository
   - Configure API endpoints

2. **Set Up CI/CD**
   - Create Azure DevOps project
   - Configure service connections
   - Create pipeline from template

3. **Add Monitoring**
   - Configure Application Insights dashboards
   - Set up alerts for errors
   - Create custom metrics

4. **Security Hardening**
   - Enable Azure Key Vault
   - Configure managed identities
   - Set up network restrictions

## Support Resources

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Static Web Apps Docs](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [Azure Functions Docs](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Azure Cosmos DB Docs](https://docs.microsoft.com/en-us/azure/cosmos-db/)

## Troubleshooting Commands

```bash
# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Format check
terraform fmt -check

# Show current state
terraform state list

# Refresh state
terraform refresh

# Get detailed logs
TF_LOG=DEBUG terraform apply
```

## Portfolio Showcase Tips

When demonstrating this project:

1. **Show the Code Structure**: Highlight the modular design
2. **Explain State Management**: Discuss remote state benefits
3. **Demonstrate Environment Separation**: Show how dev/staging/prod differ
4. **Highlight Security**: No secrets in code, managed identities
5. **Discuss Cost Optimization**: Environment-specific SKUs
6. **Show Documentation**: Professional READMEs and guides

## Questions?

This deployment creates a complete, production-ready infrastructure showcasing:
- ✅ Infrastructure as Code best practices
- ✅ State management
- ✅ Environment separation
- ✅ Security considerations
- ✅ Cost optimization
- ✅ Professional documentation

Perfect for your DevOps portfolio! 🚀
