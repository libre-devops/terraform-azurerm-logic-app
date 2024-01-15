```hcl
resource "azurerm_service_plan" "service_plan" {
  for_each                     = { for app in var.logic_apps : app.name => app if app.app_service_plan_name != null }
  name                         = each.value.app_service_plan_name != null ? each.value.app_service_plan_name : "asp-${each.value.name}"
  resource_group_name          = var.rg_name
  location                     = var.location
  os_type                      = each.value.os_type != null ? each.value.os_type : "Linux"
  sku_name                     = each.value.sku_name
  app_service_environment_id   = each.value.app_service_environment_id != null ? each.value.app_service_environment_id : null
  maximum_elastic_worker_count = each.value.maximum_elastic_worker_count != null ? each.value.maximum_elastic_worker_count : null
  worker_count                 = each.value.worker_count != null ? each.value.worker_count : null
  per_site_scaling             = each.value.per_site_scaling_enabled != null ? each.value.per_site_scaling_enabled : null
  zone_balancing_enabled       = each.value.zone_balancing_enabled != null ? each.value.zone_balancing_enabled : null
  tags                         = var.tags
}

resource "azurerm_logic_app_standard" "this" {
  for_each = { for app in var.logic_apps : app.name => app if app.app_service_plan_name != null }

  name                       = each.value.name
  location                   = var.location
  resource_group_name        = var.rg_name
  app_service_plan_id        = azurerm_service_plan.service_plan[each.key].id
  storage_account_name       = each.value.storage_account_name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_logic_app_standard.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_standard) | resource |
| [azurerm_service_plan.service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_logic_apps"></a> [logic\_apps](#input\_logic\_apps) | The logic app blocks | <pre>list(object({<br>    name                         = string<br>    app_service_plan_name        = optional(string)<br>    os_type                      = string<br>    sku_name                     = string<br>    app_service_environment_id   = optional(string, null)<br>    maximum_elastic_worker_count = optional(number, null)<br>    worker_count                 = optional(number, null)<br>    per_site_scaling_enabled     = optional(bool, null)<br>    zone_balancing_enabled       = optional(bool, null)<br>    storage_account_name         = string<br>  }))</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the VNet gateway | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_plan_ids"></a> [service\_plan\_ids](#output\_service\_plan\_ids) | The IDs of the service plans |
| <a name="output_service_plan_kinds"></a> [service\_plan\_kinds](#output\_service\_plan\_kinds) | The kinds of the service plans |
| <a name="output_service_plan_names"></a> [service\_plan\_names](#output\_service\_plan\_names) | The names of the service plans |
| <a name="output_service_plan_reserved"></a> [service\_plan\_reserved](#output\_service\_plan\_reserved) | The reserved property of the service plans |
