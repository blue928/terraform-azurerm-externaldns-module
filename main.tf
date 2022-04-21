terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      #version = ">= 1.7.0"
    }
  }
}
# This module requires information from the currently existing Azure environment.

# A resource group needs to already exist before this module will work correctly.
data "azurerm_resource_group" "rg" {
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

resource "kubernetes_namespace_v1" "externaldns_ns" {
  metadata {
    annotations = {}
    labels      = {}
    name        = var.externaldns_namespace
  }
}

# External DNS Deployment using Helm
resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  version          = var.chart_version
  namespace        = kubernetes_namespace_v1.externaldns_ns.metadata.name
  timeout = 1200

  # be sure all set values are of type string per this bug
  # https://github.com/hashicorp/terraform-provider-helm/issues/476
  set {
    name  = "provider"
    value = "azure"
  }

  set {
    name = "azure.secretName"
    value = "${var.azure_secret_name}"
  }

  set {
    name  = "azure.resourceGroup"
    value = "${data.azurerm_resource_group.rg.name}"
  }

  set {
    name  = "azure.tenantId"
    value = "${data.azurerm_subscription.current.tenant_id}"
  }

  set {
    name  = "azure.subscriptionId"
    value = "${data.azurerm_subscription.current.subscription_id}"
  }

  set {
    name  = "azure.aadClientId"
    value = "${azuread_application.sp_externaldns_connect_to_dns_zone.application_id}"
  }

  set {
    name  = "azure.aadClientSecret"
    value = "${azuread_application_password.sp_externaldns_connect_to_dns_zone.value}"
  }

  /* TODO create a Service Principal module that can feed this data in automatically.
  set {
    name  = "azure.tenantId"
    value = var.azure_tenant_id
  }

  set {
    name  = "azure.subscriptionId"
    value = var.azure_subscription_id
  }

  set {
    name  = "azure.aadClientId"
    value = var.azure_client_id
  }

  set {
    name  = "azure.aadClientSecret"
    value = var.azure_client_secret
  }*/
  

  # TODO Use dynamic block to set domain names
  set {
    name  = "domainFilters[0]"
    value = "${var.externaldns_domain}"
  }

}