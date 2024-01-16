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
