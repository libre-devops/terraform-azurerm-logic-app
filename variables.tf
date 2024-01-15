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
