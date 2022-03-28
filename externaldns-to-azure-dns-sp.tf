
resource "random_id" "current" {
  byte_length = 8
  prefix      = "ExternalDnsTf"
}

# Create Azure AD App.
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "sp_externaldns_connect_to_dns_zone" {
  display_name = random_id.current.hex
  owners       = [data.azuread_client_config.current.object_id]

}

# Create Service Principal associated with the Azure AD App
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal
resource "azuread_service_principal" "sp_externaldns_connect_to_dns_zone" {
  application_id               = azuread_application.sp_externaldns_connect_to_dns_zone.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

# Create Service Principal password
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password
resource "azuread_application_password" "sp_externaldns_connect_to_dns_zone" {
  application_object_id = azuread_application.sp_externaldns_connect_to_dns_zone.object_id
}

# Create role assignment for service principal
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "sp_externaldns_connect_to_dns_zone" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "DNS Zone Contributor"

  # When assigning to a SP, use the object_id, not the appId
  # see: https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli
  principal_id = azuread_service_principal.sp_externaldns_connect_to_dns_zone.object_id
}
