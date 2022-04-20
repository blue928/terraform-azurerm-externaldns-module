variable "tags" {
  description = "Tags to be passed to created instances"
  default     = {}
}

/*variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "azure_client_id" {
  description = "The App ID for your Service Principal/Managed Identity"
  type        = string
}

variable "azure_client_secret" {
  description = "The password/secret for your Service Principal/Managed Identity"
}

variable "azure_subscription_id" {
  description = "The Subscription ID for your Azure Resource group"
  type        = string
}
*/

variable "externaldns_domain" {
  description = "the DNS Zone to to register for external DNS"
  type        = string
}

variable "externaldns_namespace" {
  description = "The namespace to deploy the external DNS kubernetes object"
  default     = "externaldns"
}

variable "chart_version" {
  description = "The version of External DNS to install"
  default     = "6.2.4"
}

variable "azure_secret_name" {
  description = "The name of the Azure Secret containing the Azure AD credentials"
  type        = string
  default     = "azure.json"
  
}