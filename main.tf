# This module requires information from the currently existing Azure environment.

# A resource group needs to already exist before this module will work correctly.
data azurerm_resource_group "rg" {
  name = var.resource_group_name
}

# Current subscription information
data "azurerm_subscription" "current" {}

# Current client configuration information
data "azuread_client_config" "current" {}

# This module automatically creates a service principal and role assignment
# so that Externaldns can interact with Azure DNS. Consequently, Helm has to
# wait until this resource has been created. See file: external-dns-to-azure-dns-sp.tf
# for those details.

# External DNS Deployment using Helm
resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://charts.bitnami.com"
  chart            = "external-dns"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  set {
    name  = "provider"
    value = "azure"
  }

  set {
    name  = "azure.resourceGroup"
    value = data.azurerm_resource_group.rg.name
  }

  set {
    name  = "azure.tenantId"
    value = data.azurerm_subscription.current.tenant_id
  }

  set {
    name  = "azure.subscriptionId"
    value = data.azurerm_subscription.current.subscription_id
  }

  set {
    name  = "azure.aadClientId"
    value = azuread_application.sp_externaldns_connect_to_dns_zone.application_id
  }

  set {
    name  = "azure.aadClientSecret"
    value = azuread_application_password.sp_externaldns_connect_to_dns_zone.value
  }

  # TODO Use dynamic block to set domain names
  set {
    name  = "domainFilters[0]"
    value = var.domain_name
  }

  depends_on = [var.module_depends_on]
}