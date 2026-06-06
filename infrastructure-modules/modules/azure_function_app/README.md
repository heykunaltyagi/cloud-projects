# Azure Function App module

Reusable Terraform module for the Azure Function App and Event Hub resources.

## Inputs

- `environment`
- `azure_region`
- `resource_group_name`
- `location`
- `key_vault_id`
- `key_vault_name`
- `cosmos_db_connection_string`
- `cosmos_db_database_name`
- `cosmos_db_container_name`
- `dry_run_rotation`

## Outputs

- `function_id`
- `function_app_principal_id`
- `storage_account_id`
- `eventhub_id`
- `eventhub_name`
- `eventhub_connection_string`


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
| [azurerm_app_service_plan.function_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan) | resource |
| [azurerm_eventhub.rotation_audit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.analytics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_function_app.key_rotation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app) | resource |
| [azurerm_key_vault_access_policy.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_storage_account.function_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_user_assigned_identity.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.func_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.storage_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | n/a | `string` | n/a | yes |
| <a name="input_cosmos_db_connection_string"></a> [cosmos\_db\_connection\_string](#input\_cosmos\_db\_connection\_string) | n/a | `string` | n/a | yes |
| <a name="input_cosmos_db_container_name"></a> [cosmos\_db\_container\_name](#input\_cosmos\_db\_container\_name) | n/a | `string` | n/a | yes |
| <a name="input_cosmos_db_database_name"></a> [cosmos\_db\_database\_name](#input\_cosmos\_db\_database\_name) | n/a | `string` | n/a | yes |
| <a name="input_dry_run_rotation"></a> [dry\_run\_rotation](#input\_dry\_run\_rotation) | n/a | `bool` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | n/a | `string` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_eventhub_connection_string"></a> [eventhub\_connection\_string](#output\_eventhub\_connection\_string) | n/a |
| <a name="output_eventhub_id"></a> [eventhub\_id](#output\_eventhub\_id) | n/a |
| <a name="output_eventhub_name"></a> [eventhub\_name](#output\_eventhub\_name) | n/a |
| <a name="output_function_app_principal_id"></a> [function\_app\_principal\_id](#output\_function\_app\_principal\_id) | n/a |
| <a name="output_function_id"></a> [function\_id](#output\_function\_id) | n/a |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
<!-- END_TF_DOCS -->