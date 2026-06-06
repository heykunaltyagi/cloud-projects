# Infrastructure Modules

This folder houses shared Terraform modules for the `cloud-projects` monorepo.

Shared modules are consumed by individual project roots, such as `projects/azure-key-vault-rotation/terraform`.

## Current shared modules

- `azure_key_vault/`
  - Deploys Azure Key Vault and an application key for rotation.
- `azure_function_app/`
  - Deploys a function app, storage account, identity, and Event Hub for rotation logic.
- `azure_event_grid/`
  - Deploys Event Grid resources and subscriptions for key vault events.
- `azure_monitoring/`
  - Deploys Azure Monitor action group and function failure alerts.

## Purpose

This directory centralizes reusable Terraform module code so multiple projects can share the same implementation patterns and reduce duplication.

## Usage

In a consuming project, point your module source to the shared module path:

```hcl
module "key_vault" {
  source = "../../infrastructure-modules/modules/azure_key_vault"
  environment = var.environment
  location = var.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id = data.azurerm_client_config.current.tenant_id
}
```

## Adding new shared modules

1. Create a new directory under `infrastructure-modules/modules/`.
2. Add `main.tf`, `variables.tf`, and `outputs.tf` as needed.
3. Keep module inputs/outputs explicit and reusable.
4. Update this README with the new module description.

## Notes

- Shared modules should avoid project-specific hardcoding.
- Keep module interfaces stable to minimize changes in consuming projects.
- Use relative paths from consuming projects until a remote module registry or git source is adopted.