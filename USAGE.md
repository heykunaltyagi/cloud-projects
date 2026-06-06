# Using Cloud Projects Modules

This guide explains how to use the shared Terraform modules from the `cloud-projects` repository to provision infrastructure on Azure.

## Overview

The `cloud-projects` monorepo contains **reusable Terraform modules** that centralize common infrastructure patterns. These modules are available for consumption by multiple projects.

### Available Modules

| Module | Purpose |
|--------|----------|
| `azure_key_vault` | Azure Key Vault with rotation-ready keys and policies |
| `azure_function_app` | Azure Function App with storage, identity, and Event Hub for rotation logic |
| `azure_event_grid` | Event Grid resources and subscriptions for Key Vault events |
| `azure_event_grid` | Event Grid resources and subscriptions for Key Vault events |
| `azure_monitoring` | Azure Monitor action groups and failure alerts |

## Prerequisites

| Requirement | Details |
|-------------|----------|
| **Terraform** | >= 1.0 |
| **Azure CLI** | Configured with appropriate credentials |
| **Azure Subscription** | With permissions to create resources |
| **Git** | (Optional) For cloning the repository |

## Usage Options

### Option 1: Use Shared Modules from GitHub

Reference modules directly from the GitHub repository. This approach is best for external projects that want to consume the modules without maintaining a local copy.
Example from keyvault module.

```hcl
# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.50"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-myapp-${var.environment}"
  location = var.location
}

module "key_vault" {
  source = "git::https://github.com/heykunaltyagi/cloud-projects.git//infrastructure-modules/modules/azure_key_vault"

  environment         = var.environment
  location        = var.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

```

### Option 2: Use Local Modules

If you clone the repository locally, reference modules using relative paths. This is useful for development or when you want to customize modules.

```bash
# Project structure
my-cloud-project/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── versions.tf
└── ../cloud-projects/          # sibling repository
    └── infrastructure-modules/
        └── modules/
```

Then in `main.tf`:

```hcl
module "key_vault" {
  source = "../../cloud-projects/infrastructure-modules/modules/azure_key_vault"

  environment         = var.environment
  location        = var.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}
```

### Option 3: Use the Complete Project

Example : Clone and deploy the entire `azure-key-vault-rotation` project with all components pre-configured.

```bash
git clone https://github.com/heykunaltyagi/cloud-projects.git
cd cloud-projects/projects/azure-key-vault-rotation/terraform

# Review the environment variables
cat environments/dev.tfvars

# Plan deployment
terraform plan -var-file=environments/dev.tfvars

# Apply
terraform apply -var-file=environments/dev.tfvars
```

## Module Reference

**Location:** `infrastructure-modules/modules/`

## Deployment Steps

1. **Prepare your configuration files**
   ```bash
   mkdir -p terraform/environments
   touch terraform/main.tf
   touch terraform/variables.tf
   touch terraform/versions.tf
   touch terraform/environments/dev.tfvars
   ```

2. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

3. **Validate configuration**
   ```bash
   terraform validate
   terraform fmt -recursive
   ```

4. **Plan deployment**
   ```bash
   terraform plan -var-file=environments/dev.tfvars
   ```

5. **Review and apply**
   ```bash
   terraform apply -var-file=environments/dev.tfvars
   ```

6. **Verify deployment**
   ```bash
   terraform output
   ```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Use environment variables files** | Keep `dev.tfvars`, `staging.tfvars`, and `prod.tfvars` separate for different environments. |
| **Store secrets securely** | Use Azure Key Vault or environment variables for sensitive values. Never commit them to Git. |
| **State file management** | Store Terraform state in Azure Storage or a remote backend, not locally. |
| **Test in dev first** | Always test changes in a dev environment before applying to production. |
| **Review plans before applying** | Use `terraform plan` to review changes before execution. |
| **Version control** | Commit your Terraform code (not state files) to Git. |

## Support

For issues, questions, or contributions:

1. Check existing [issues](https://github.com/heykunaltyagi/cloud-projects/issues)
2. Review the [contributing guide](https://github.com/heykunaltyagi/cloud-projects/blob/main/CONTRIBUTING.md)
3. Open a new issue with details about your use case
