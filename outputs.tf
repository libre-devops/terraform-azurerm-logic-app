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
