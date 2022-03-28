/*resource "kubernetes_secret" "azure_config_file" {
  metadata {
    name = var.azure_config_file
  }

  data = { "azure.json" = jsonencode({
    tenantId        = data.azurerm_subscription.current.tenant_id
    subscriptionId  = data.azurerm_subscription.current.subscription_id
    resourceGroup   = data.azurerm_resource_group.rg.name
    aadClientId     = azuread_application.sp_externaldns_connect_to_dns_zone.application_id
    aadClientSecret = azuread_application_password.sp_externaldns_connect_to_dns_zone.value
    })

  }
}*/
