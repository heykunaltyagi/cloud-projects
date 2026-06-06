# Azure Key Vault Automated Key Rotation

**A production-ready, event-driven key rotation system for Azure.**

## What This Is

A complete implementation of automated key rotation for Azure Key Vault using:
- **Terraform** - Infrastructure-as-code for Azure resources
- **Python** - Serverless rotation logic in Azure Functions
- **Event Grid** - Event-driven trigger when keys near expiry
- **Event Hub** - Audit logging
- **Monitoring** - Alerts for function failures

## Project layout

```
azure-key-vault-rotation/
├── terraform/
│   ├── main.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── data.tf
│   ├── environments/
│   └── modules/             # local modules removed where shared modules are used
├── function_app/
├── tests/
└── docs/
```

## Use the Complete Project

Clone and deploy the entire `azure-key-vault-rotation` project with all components pre-configured.

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

## Key features

- ✅ Automatic key rotation for Azure Key Vault
- ✅ Event-driven architecture with Azure Event Grid
- ✅ Audit log streaming to Azure Event Hub
- ✅ Monitoring and alerting via Azure Monitor
- ✅ Shared Terraform modules under `infrastructure-modules/`

## Shared module usage

This project now consumes shared infrastructure modules from `infrastructure-modules/`.

```hcl
module "key_vault" {
  source = "../../infrastructure-modules/modules/azure_key_vault"
  environment = var.environment
}

module "function_app" {
  source = "../../infrastructure-modules/modules/azure_function_app"
  environment = var.environment
}

module "event_grid" {
  source = "../../infrastructure-modules/modules/azure_event_grid"
  environment = var.environment
}

module "monitoring" {
  source = "../../infrastructure-modules/modules/azure_monitoring"
  environment = var.environment
}
```

## Notes

- Terraform provider and version settings are now in `versions.tf`.
- Data sources are centralized in `data.tf`.
- Variable definitions are kept in `variables.tf`.
- Local module folders have been removed in favor of shared modules in the monorepo.
