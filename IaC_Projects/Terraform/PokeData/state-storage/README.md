# Terraform State Storage Setup

This directory contains the bootstrap configuration for setting up Azure Storage to manage Terraform state files for the PokeData project.

## Purpose

This is a **one-time setup** that creates:
- A dedicated resource group for state management
- An Azure Storage Account with versioning enabled
- Separate containers for each environment (dev, staging, prod)
- Security configurations including TLS 1.2 and blob versioning

## Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.9.0
- Appropriate Azure permissions to create resources

## Initial Setup

1. **Navigate to this directory:**
   ```bash
   cd state-storage
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review the plan:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

5. **Save the outputs:**
   ```bash
   terraform output -json > state-config.json
   ```

## Important Outputs

After successful deployment, note these values:
- `storage_account_name`: Use in backend configurations
- `resource_group_name`: Reference in backend configurations
- `primary_access_key`: Store securely for backend authentication

## Backend Configuration

After creating the state storage, configure each environment's backend:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "pokedata-terraform-state-rg"
    storage_account_name = "<output from terraform>"
    container_name       = "tfstate-dev"  # or tfstate-staging, tfstate-prod
    key                  = "terraform.tfstate"
  }
}
```

## Security Considerations

- The storage account has public access enabled by default for initial setup
- For production, consider:
  - Restricting network access to specific IPs
  - Using Private Endpoints
  - Enabling Azure AD authentication instead of access keys
  - Implementing additional encryption

## State Management Best Practices

1. **Never delete this storage account** - it contains all state history
2. **Enable additional backups** for production state files
3. **Use state locking** (enabled by default with Azure backend)
4. **Regularly review state file versions** for audit purposes
5. **Implement RBAC** for team access control

## Maintenance

- Blob versioning is enabled with 30-day retention
- Container soft delete is enabled with 7-day retention
- Review storage costs monthly (typically minimal for state files)

## Troubleshooting

If you encounter issues:

1. **Authentication errors:**
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

2. **Storage account name conflicts:**
   - The random suffix should prevent this
   - If needed, modify the `random_string` resource

3. **Access key issues:**
   ```bash
   terraform output primary_access_key
   ```

## Cost Estimation

- Storage Account: ~$0.05/GB/month
- Transaction costs: Minimal for state operations
- Total estimated cost: < $5/month

## Next Steps

After creating the state storage:
1. Configure backend in each environment
2. Migrate existing local state (if any)
3. Set up CI/CD pipeline with backend configuration
4. Document access keys in secure location (e.g., Azure Key Vault)

## Clean Up (Warning!)

⚠️ **Only run if you want to destroy all state management:**
```bash
terraform destroy
```

This will permanently delete all state files and history!
