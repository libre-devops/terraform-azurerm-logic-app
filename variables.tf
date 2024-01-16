variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "logic_apps" {
  description = "The logic app blocks"
  default     = null
  type = list(object({
    name                         = string
    app_service_plan_name        = optional(string)
    os_type                      = string
    sku_name                     = string
    app_service_environment_id   = optional(string, null)
    maximum_elastic_worker_count = optional(number, null)
    worker_count                 = optional(number, null)
    per_site_scaling_enabled     = optional(bool, null)
    zone_balancing_enabled       = optional(bool, null)
    storage_account_name         = string
    storage_account_access_key   = optional(string)
    use_extension_bundle         = optional(bool)
    bundle_version               = optional(string)
    client_affinity_enabled      = optional(bool)
    client_certificate_mode      = optional(string)
    enabled                      = optional(bool)
    https_only                   = optional(bool, true)
    version                      = optional(string)
    virtual_network_subnet_id    = optional(string)
    identity_type                = optional(string)
    identity_ids                 = optional(list(string))
    app_settings                 = optional(map(string))

    connection_string = optional(object({
      name  = string
      type  = string
      value = string
    }))

    site_config = optional(object({
      always_on                        = optional(bool)
      app_scale_limit                  = optional(number)
      dotnet_framework_version         = optional(string)
      elastic_instance_minimum         = optional(number)
      ftps_state                       = optional(string)
      health_check_path                = optional(string)
      http2_enabled                    = optional(bool, false)
      scm_use_main_ip_restriction      = optional(bool, false)
      scm_min_tls_version              = optional(string, "1.2")
      scm_type                         = optional(string)
      linux_fx_version                 = optional(string)
      min_tls_version                  = optional(string, "1.2")
      pre_warmed_instance_count        = optional(number)
      public_network_enabled           = optional(bool, false)
      runtime_scale_monitoring_enabled = optional(bool, false)
      use_32_bit_worker_process        = optional(bool)
      vnet_route_all_enabled           = optional(bool)
      websocket_enabled                = optional(bool)

      ip_restriction = optional(list(object({
        name                      = optional(string)
        ip_address                = optional(string)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        priority                  = optional(number)
        action                    = optional(string)
        headers = optional(object({
          x_azure_fdid      = optional(string)
          x_fd_health_probe = optional(string)
          x_forwarded_for   = optional(string)
          x_forwarded_host  = optional(string)
        }))
      })))

      scm_ip_restriction = optional(list(object({
        name                      = optional(string)
        ip_address                = optional(string)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        priority                  = optional(number)
        action                    = optional(string)
        headers = optional(object({
          x_azure_fdid      = optional(string)
          x_fd_health_probe = optional(string)
          x_forwarded_for   = optional(string)
          x_forwarded_host  = optional(string)
        }))
      })))

      cors = optional(object({
        allowed_origins     = optional(set(string))
        support_credentials = optional(bool)
      }))
    }))
  }))
}

variable "name" {
  type        = string
  description = "The name of the VNet gateway"
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
}
