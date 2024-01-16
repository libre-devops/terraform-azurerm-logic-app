output "logic_app_custom_domain_verification_ids" {
  description = "Custom domain verification IDs for the Logic Apps"
  value       = { for k, v in azurerm_logic_app_standard.this : k => v.custom_domain_verification_id }
}

output "logic_app_default_hostnames" {
  description = "The default hostnames of the Logic Apps"
  value       = { for k, v in azurerm_logic_app_standard.this : k => v.default_hostname }
}

output "logic_app_identities" {
  description = "Managed Service Identity information for the Logic Apps"
  value       = { for k, v in azurerm_logic_app_standard.this : k => v.identity }
}

output "logic_app_ids" {
  description = "The IDs of the Logic Apps"
  value       = { for k, v in azurerm_logic_app_standard.this : k => v.id }
}

output "logic_app_kinds" {
  description = "The kinds of the Logic Apps"
  value       = { for k, v in azurerm_logic_app_standard.this : k => v.kind }
}

output "logic_app_outbound_ip_addresses" {
  description = "Comma-separated list of outbound IP addresses for the Logic Apps"
  value       = { for k, v in azurerm_logic_app_standard.this : k => v.outbound_ip_addresses }
}

output "logic_app_possible_outbound_ip_addresses" {
  description = "Comma-separated list of possible outbound IP addresses for the Logic Apps"
  value       = { for k, v in azurerm_logic_app_standard.this : k => v.possible_outbound_ip_addresses }
}

output "logic_app_site_credentials" {
  description = "Site-level credentials for publishing to the Logic Apps"
  value       = { for k, v in azurerm_logic_app_standard.this : k => v.site_credential }
}

output "logic_app_tenant_ids" {
  description = "Tenant IDs for the Service Principal associated with the MSI of the Logic Apps"
  value       = { for k, v in azurerm_logic_app_standard.this : k => v.identity.0.tenant_id }
}

output "service_plan_ids" {
  description = "The IDs of the service plans"
  value       = { for k, v in azurerm_service_plan.service_plan : k => v.id }
}

output "service_plan_kinds" {
  description = "The kinds of the service plans"
  value       = { for k, v in azurerm_service_plan.service_plan : k => v.kind }
}

output "service_plan_names" {
  description = "The names of the service plans"
  value       = { for k, v in azurerm_service_plan.service_plan : k => v.name }
}

output "service_plan_reserved" {
  description = "The reserved property of the service plans"
  value       = { for k, v in azurerm_service_plan.service_plan : k => v.reserved }
}
