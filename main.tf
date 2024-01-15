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
