# Azure Cosmos DB module

Reusable Terraform module for Cosmos DB rotation history storage.

## Inputs

- `environment`
- `azure_region`
- `resource_group_name`
- `location`

## Outputs

- `cosmos_connection_string`
- `cosmos_database_name`
- `cosmos_container_name`

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_cosmosdb_account.rotation_history](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_sql_container.rotation_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container) | resource |
| [azurerm_cosmosdb_sql_database.rotation_history](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |
| [random_string.cosmos_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cosmos_connection_string"></a> [cosmos\_connection\_string](#output\_cosmos\_connection\_string) | n/a |
| <a name="output_cosmos_container_name"></a> [cosmos\_container\_name](#output\_cosmos\_container\_name) | n/a |
| <a name="output_cosmos_database_name"></a> [cosmos\_database\_name](#output\_cosmos\_database\_name) | n/a |
<!-- END_TF_DOCS -->