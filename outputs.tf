output "display_name" {
  value = azuread_service_principal.sp_externaldns_connect_to_dns_zone.display_name
}

output "client_id" {
  value = azuread_application.sp_externaldns_connect_to_dns_zone.application_id
}

output "client_secret" {
  value     = azuread_application_password.sp_externaldns_connect_to_dns_zone.value
  sensitive = true
}
output "object_id" {
  value = azuread_service_principal.sp_externaldns_connect_to_dns_zone.object_id
}