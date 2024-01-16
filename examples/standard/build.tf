module "rg" {
  source = "cyber-scot/rg/azurerm"

  name     = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}

module "network" {
  source = "cyber-scot/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name          = "vnet-${var.short}-${var.loc}-${var.env}-01"
  vnet_location      = module.rg.rg_location
  vnet_address_space = ["10.0.0.0/16"]

  subnets = {
    "sn1-${module.network.vnet_name}" = {
      address_prefixes  = ["10.0.0.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
  }
}

resource "azurerm_user_assigned_identity" "uid" {
  name                = "uid-${var.short}-${var.loc}-${var.env}-01"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  tags                = module.rg.rg_tags
}

module "sa" {
  source = "cyber-scot/storage-account/azurerm"
  storage_accounts = [
    {
      name     = "sa${var.short}${var.loc}${var.env}01"
      rg_name  = module.rg.rg_name
      location = module.rg.rg_location
      tags     = module.rg.rg_tags

      identity_type             = "SystemAssigned, UserAssigned"
      identity_ids              = [azurerm_user_assigned_identity.uid.id]
      shared_access_key_enabled = true

      network_rules = {
        bypass                     = ["AzureServices"]
        default_action             = "Deny"
        ip_rules                   = [chomp(data.http.client_ip.response_body)]
        virtual_network_subnet_ids = [module.network.subnets_ids["sn1-${module.network.vnet_name}"]]
      }
    },
  ]
}


module "logic_apps" {
  source = "../../"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  logic_apps = [
    {
      name                       = "logic-${var.short}-${var.loc}-${var.env}-01"
      app_service_plan_name      = "asp-logic-${var.short}-${var.loc}-${var.env}-01"
      os_type                    = "Linux"
      sku_name                   = "Y1"
      storage_account_name       = module.sa.storage_account_names["sa${var.short}${var.loc}${var.env}01"]
      storage_account_access_key = module.sa.primary_access_keys["sa${var.short}${var.loc}${var.env}01"]
      use_extension_bundle       = true
      bundle_version             = "2.*"
      enabled                    = true
      identity_type              = "SystemAssigned, UserAssigned"
      identity_ids               = [azurerm_user_assigned_identity.uid.id]
      virtual_network_subnet_id  = module.network.subnets_ids["sn1-${module.network.vnet_name}"]
      site_config = {
        ftps_state                = "AllAllowed"
        http2_enabled             = true
        min_tls_version           = "1.2"
        dotnet_framework_version  = "v6.0"
        use_32_bit_worker_process = false
        websockets_enabled        = true
      }
    },
  ]
}
