variable "prefix" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "resource_group_name" {
  description = "Name of the resource group in which the resources will be created"
  default     = "myResourceGroup"
}

variable "location" {
  default     = "westus3"
  description = "Location where resources will be created"
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(any)
  default     = {}
}

variable "admin_user_jumpbox" {
  description = "User name to use as the admin account on the Azure VM Jumpbox"
  default     = "azureuser"
}

variable "admin_password_jumpbox" {
  description = "Default password for admin account for the Azure VM Jumpbox"
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Default password for admin account"
}

variable "omop_password" {
  description = "password for azure sql admin account"
  sensitive   = true
}

variable "ado_org_service_url" {
  description = "Azure DevOps Organization URL e.g. https://dev.azure.com/my-org"
}

variable "ado_project_name" {
  description = "Azure DevOps Project Name e.g. https://dev.azure.com/my-org/my-project"
}

variable "ado_repo_name" {
  description = "Azure DevOps Repo Name e.g. https://dev.azure.com/my-org/my-project/_git/my-repo"
}

variable "ado_pat" {
  description = "Azure DevOps PAT"
  sensitive   = true
}

variable "azure_subscription_name" {
  description = "This is your Azure Subscription Name for your Azure Service Connection"
}

variable "environment_pipeline_path" {
  description = "Azure DevOps Environment Pipeline path e.g. /pipelines/environments/TF-OMOP.yaml"
}

variable "vocabulary_build_pipeline_path" {
  description = "Azure DevOps Vocabulary Build Pipeline path e.g. /pipelines/vocabulary_build_pipeline.yaml"
}

variable "vocabulary_release_pipeline_path" {
  description = "Azure DevOps Vocabulary Release Pipeline path e.g. /pipelines/vocabulary_release_pipeline.yaml"
}

variable "broadsea_build_pipeline_path" {
  description = "Azure DevOps Broadsea Build Pipeline path e.g. /pipelines/broadsea_build_pipeline.yaml"
}

variable "broadsea_release_pipeline_path" {
  description = "Azure DevOps Broadsea Release Pipeline path e.g. /pipelines/broadsea_release_pipeline.yaml"
}

variable "cdr_vocab_container_name" {
  description = "The name of the blob container in the CDR storage account that will be used for vocabulary file uploads."
  default     = "vocabularies"
}

variable "cdr_vocab_version" {
  description = "The path in the vocabulary blob container in the CDR storage account that will be used for vocabulary file uploads.  E.g. if the vocabulries are stored under /vocabularies/19-AUG-2021 you should specify 19-AUG-2021."
  default     = "19-AUG-2021"
}

variable "data_source_vocabulary_name" {
  description = "The Data Source name in Azure SQL for mapping the vocabulary from Azure Blob Storage.  E.g. DSVocabularyBlobStorage"
  default     = "DSVocabularyBlobStorage"
}

variable "omop_db_size" {
  type    = string
  default = 20 # max size gb
}

variable "omop_db_sku" {
  type = string
  # default = "BC_Gen5_10"
  default = "GP_Gen5_2"
}

/* ACR */
variable "acr_sku_edition" {}


/* Application Service Plan */
variable "asp_kind_edition" {}
variable "asp_sku_tier" {}
variable "asp_sku_size" {}