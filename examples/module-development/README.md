```hcl
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
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.0.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_logic_apps"></a> [logic\_apps](#module\_logic\_apps) | ../../ | n/a |
| <a name="module_network"></a> [network](#module\_network) | registry.terraform.io/libre-devops/network/azurerm | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | libre-devops/rg/azurerm | n/a |
| <a name="module_sa"></a> [sa](#module\_sa) | libre-devops/storage-account/azurerm | n/a |
| <a name="module_subnet_calculator"></a> [subnet\_calculator](#module\_subnet\_calculator) | github.com/libre-devops/terraform-null-subnet-calculator | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_user_assigned_identity.uid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [http_http.client_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Regions"></a> [Regions](#input\_Regions) | Converts shorthand name to longhand name via lookup on map list | `map(string)` | <pre>{<br>  "eus": "East US",<br>  "euw": "West Europe",<br>  "uks": "UK South",<br>  "ukw": "UK West"<br>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | The env variable, for example - prd for production. normally passed via TF\_VAR. | `string` | `"prd"` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | The loc variable, for the shorthand location, e.g. uks for UK South.  Normally passed via TF\_VAR. | `string` | `"uks"` | no |
| <a name="input_short"></a> [short](#input\_short) | The shorthand name of to be used in the build, e.g. cscot for CyberScot.  Normally passed via TF\_VAR. | `string` | `"cscot"` | no |
| <a name="input_static_tags"></a> [static\_tags](#input\_static\_tags) | The tags variable | `map(string)` | <pre>{<br>  "Contact": "info@cyber.scot",<br>  "CostCentre": "671888",<br>  "ManagedBy": "Terraform"<br>}</pre> | no |

## Outputs

No outputs.
