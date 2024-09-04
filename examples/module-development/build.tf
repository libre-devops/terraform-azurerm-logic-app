module "rg" {
  source = "libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}

locals {
  vnet_address_space = "10.0.0.0/16"
}



module "subnet_calculator" {
  source = "github.com/libre-devops/terraform-null-subnet-calculator"

  base_cidr    = local.vnet_address_space
  subnet_sizes = [24]
}

module "network" {
  source = "registry.terraform.io/libre-devops/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name          = "vnet-${var.short}-${var.loc}-${var.env}-01"
  vnet_location      = module.rg.rg_location
  vnet_address_space = module.subnet_calculator.base_cidr_set

  subnets = {
    for i, name in module.subnet_calculator.subnet_names :
    name => {
      address_prefixes  = toset([module.subnet_calculator.subnet_ranges[i]])
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = [
        {
          type = "Microsoft.Web/serverFarms"
        }
      ]
    }
  }
}


resource "azurerm_user_assigned_identity" "uid" {
  name                = "uid-${var.short}-${var.loc}-${var.env}-01"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  tags                = module.rg.rg_tags
}

locals {
  now                 = timestamp()
  seven_days_from_now = timeadd(timestamp(), "168h")
}

module "sa" {
  source = "libre-devops/storage-account/azurerm"
  storage_accounts = [
    {
      name     = "sa${var.short}${var.loc}${var.env}01"
      rg_name  = module.rg.rg_name
      location = module.rg.rg_location
      tags     = module.rg.rg_tags

      identity_type              = "UserAssigned"
      identity_ids               = [azurerm_user_assigned_identity.uid.id]
      shared_access_keys_enabled = true

      network_rules = {
        bypass                     = ["AzureServices"]
        default_action             = "Allow"
        ip_rules                   = [chomp(data.http.client_ip.response_body)]
        virtual_network_subnet_ids = [module.network.subnets_ids[module.subnet_calculator.subnet_names[0]]]
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
      os_type                    = "Windows"
      sku_name                   = "WS1"
      storage_account_name       = module.sa.storage_account_names["sa${var.short}${var.loc}${var.env}01"]
      storage_account_access_key = module.sa.primary_access_keys["sa${var.short}${var.loc}${var.env}01"]
      use_extension_bundle       = true
      bundle_version             = "2.*"
      version                    = "~4"
      enabled                    = true
      identity_type              = "UserAssigned"
      identity_ids               = [azurerm_user_assigned_identity.uid.id]
      virtual_network_subnet_id  = module.network.subnets_ids[module.subnet_calculator.subnet_names[0]]
      app_settings = {
        "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
      }
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