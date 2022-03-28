variable "azure_config_file" {
  type = string
  default = "azure-config-file"
  description = "Name of the Azure config file"
}

variable "resource_group_name" {
  description = "The name of the existing resource group where the AKS Cluster server resides"
  type        = string
}
