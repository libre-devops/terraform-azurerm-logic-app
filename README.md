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
  tags                       = var.tags
  app_service_plan_id        = azurerm_service_plan.service_plan[each.key].id
  storage_account_name       = each.value.storage_account_name
  storage_account_access_key = each.value.storage_account_access_key
  use_extension_bundle       = each.value.use_extension_bundle != null ? each.value.use_extension_bundle : null
  bundle_version             = each.value.use_extension_bundle != null ? each.value.bundle_version : null
  client_affinity_enabled    = each.value.client_affinity_enabled != null ? each.value.client_affinity_enabled : null
  client_certificate_mode    = each.value.client_certificate_mode != null ? each.value.client_certificate_mode : null
  enabled                    = each.value.enabled != null ? each.value.enabled : true
  https_only                 = each.value.https_only != null ? each.value.https_only : true
  version                    = each.value.version != null ? each.value.version : null
  virtual_network_subnet_id  = each.value.virtual_network_subnet_id != null ? each.value.virtual_network_subnet_id : null
  app_settings               = each.value.app_settings != null ? each.value.app_settings : null

  dynamic "connection_string" {
    for_each = each.value.connection_string != null ? [each.value.connection_string] : []
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "site_config" {
    for_each = each.value.site_config != null ? [each.value.site_config] : []
    content {
      always_on                 = site_config.value.always_on != null ? site_config.value.always_on : null
      app_scale_limit           = site_config.value.app_scale_limit != null ? site_config.value.app_scale_limit : null
      elastic_instance_minimum  = site_config.value.elastic_instance_minimum != null ? site_config.value.elastic_instance_minimum : null
      ftps_state                = site_config.value.ftps_state != null ? site_config.value.ftps_state : null
      health_check_path         = site_config.value.health_check_path != null ? site_config.value.health_check_path : null
      http2_enabled             = site_config.value.http2_enabled != null ? site_config.value.http2_enabled : null
      ip_restriction            = site_config.value.ip_restriction != null ? site_config.value.ip_restriction : null
      min_tls_version           = site_config.value.min_tls_version != null ? site_config.value.min_tls_version : null
      dotnet_framework_version  = site_config.value.dotnet_framework_version != null ? site_config.value.dotnet_framework_version : null
      scm_type                  = site_config.value.scm_type != null ? site_config.value.scm_type : null
      use_32_bit_worker_process = site_config.value.use_32_bit_worker_process != null ? site_config.value.use_32_bit_worker_process : null
      websockets_enabled        = site_config.value.websockets_enabled != null ? site_config.value.websockets_enabled : null

      dynamic "ip_restriction" {
        for_each = site_config.value.ip_restriction != null ? [site_config.value.ip_restriction] : []
        content {
          name                      = ip_restriction.value.name
          ip_address                = ip_restriction.value.ip_address
          virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
          priority                  = ip_restriction.value.priority
          action                    = ip_restriction.value.action

          dynamic "headers" {
            for_each = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []
            content {
              x_azure_fdid      = headers.value.x_azure_fdid
              x_fd_health_probe = headers.value.x_fd_health_probe
              x_forwarded_for   = headers.value.x_forwarded_for
              x_forwarded_host  = headers.value.x_forwarded_host
            }
          }

        }
      }

      dynamic "scm_ip_restriction" {
        for_each = site_config.value.scm_ip_restriction != null ? [site_config.value.scm_ip_restriction] : []
        content {
          name                      = scm_ip_restriction.value.name
          ip_address                = scm_ip_restriction.value.ip_address
          virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
          priority                  = scm_ip_restriction.value.priority
          action                    = scm_ip_restriction.value.action

          dynamic "headers" {
            for_each = scm_ip_restriction.value.headers != null ? [scm_ip_restriction.value.headers] : []
            content {
              x_azure_fdid      = headers.value.x_azure_fdid
              x_fd_health_probe = headers.value.x_fd_health_probe
              x_forwarded_for   = headers.value.x_forwarded_for
              x_forwarded_host  = headers.value.x_forwarded_host
            }
          }

        }
      }

      dynamic "cors" {
        for_each = site_config.value.cors != null ? [site_config.value.cors] : []
        content {
          allowed_origins     = cors.value.allowed_origins
          support_credentials = cors.value.support_credentials != null ? cors.value.support_credentials : null
        }
      }
    }
  }

  dynamic "identity" {
    for_each = each.value.identity_type == "SystemAssigned" ? [each.value.identity_type] : []
    content {
      type = each.value.identity_type
    }
  }

  dynamic "identity" {
    for_each = each.value.identity_type == "SystemAssigned, UserAssigned" ? [each.value.identity_type] : []
    content {
      type         = each.value.identity_type
      identity_ids = try(each.value.identity_ids, [])
    }
  }


  dynamic "identity" {
    for_each = each.value.identity_type == "UserAssigned" ? [each.value.identity_type] : []
    content {
      type         = each.value.identity_type
      identity_ids = length(try(each.value.identity_ids, [])) > 0 ? each.value.identity_ids : []
    }
  }
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
| <a name="input_logic_apps"></a> [logic\_apps](#input\_logic\_apps) | The logic app blocks | <pre>list(object({<br>    name                         = string<br>    app_service_plan_name        = optional(string)<br>    os_type                      = string<br>    sku_name                     = string<br>    app_service_environment_id   = optional(string, null)<br>    maximum_elastic_worker_count = optional(number, null)<br>    worker_count                 = optional(number, null)<br>    per_site_scaling_enabled     = optional(bool, null)<br>    zone_balancing_enabled       = optional(bool, null)<br>    storage_account_name         = string<br>    storage_account_access_key   = optional(string)<br>    use_extension_bundle         = optional(bool)<br>    bundle_version               = optional(string)<br>    client_affinity_enabled      = optional(bool)<br>    client_certificate_mode      = optional(string)<br>    enabled                      = optional(bool)<br>    https_only                   = optional(bool, true)<br>    version                      = optional(string)<br>    virtual_network_subnet_id    = optional(string)<br>    identity_type                = optional(string)<br>    identity_ids                 = optional(list(string))<br>    app_settings                 = optional(map(string))<br><br>    connection_string = optional(object({<br>      name  = string<br>      type  = string<br>      value = string<br>    }))<br><br>    site_config = optional(object({<br>      always_on                        = optional(bool)<br>      app_scale_limit                  = optional(number)<br>      dotnet_framework_version         = optional(string)<br>      elastic_instance_minimum         = optional(number)<br>      ftps_state                       = optional(string)<br>      health_check_path                = optional(string)<br>      http2_enabled                    = optional(bool, false)<br>      scm_use_main_ip_restriction      = optional(bool, false)<br>      scm_min_tls_version              = optional(string, "1.2")<br>      scm_type                         = optional(string)<br>      linux_fx_version                 = optional(string)<br>      min_tls_version                  = optional(string, "1.2")<br>      pre_warmed_instance_count        = optional(number)<br>      public_network_enabled           = optional(bool, false)<br>      runtime_scale_monitoring_enabled = optional(bool, false)<br>      use_32_bit_worker_process        = optional(bool)<br>      vnet_route_all_enabled           = optional(bool)<br>      websocket_enabled                = optional(bool)<br><br>      ip_restriction = optional(list(object({<br>        name                      = optional(string)<br>        ip_address                = optional(string)<br>        service_tag               = optional(string)<br>        virtual_network_subnet_id = optional(string)<br>        priority                  = optional(number)<br>        action                    = optional(string)<br>        headers = optional(object({<br>          x_azure_fdid      = optional(string)<br>          x_fd_health_probe = optional(string)<br>          x_forwarded_for   = optional(string)<br>          x_forwarded_host  = optional(string)<br>        }))<br>      })))<br><br>      scm_ip_restriction = optional(list(object({<br>        name                      = optional(string)<br>        ip_address                = optional(string)<br>        service_tag               = optional(string)<br>        virtual_network_subnet_id = optional(string)<br>        priority                  = optional(number)<br>        action                    = optional(string)<br>        headers = optional(object({<br>          x_azure_fdid      = optional(string)<br>          x_fd_health_probe = optional(string)<br>          x_forwarded_for   = optional(string)<br>          x_forwarded_host  = optional(string)<br>        }))<br>      })))<br><br>      cors = optional(object({<br>        allowed_origins     = optional(set(string))<br>        support_credentials = optional(bool)<br>      }))<br>    }))<br>  }))</pre> | `null` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_plan_ids"></a> [service\_plan\_ids](#output\_service\_plan\_ids) | The IDs of the service plans |
| <a name="output_service_plan_kinds"></a> [service\_plan\_kinds](#output\_service\_plan\_kinds) | The kinds of the service plans |
| <a name="output_service_plan_names"></a> [service\_plan\_names](#output\_service\_plan\_names) | The names of the service plans |
| <a name="output_service_plan_reserved"></a> [service\_plan\_reserved](#output\_service\_plan\_reserved) | The reserved property of the service plans |
