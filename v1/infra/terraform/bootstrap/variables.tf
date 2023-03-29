variable "prefix" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
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
  sensitive   = true
}

variable "admin_password_jumpbox" {
  description = "Default password for admin account for the Azure VM Jumpbox"
  sensitive   = true
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "azureuser"
  sensitive   = true
}

variable "admin_password" {
  description = "Default password for admin account"
  sensitive   = true
}

variable "omop_password" {
  description = "password for azure sql admin account"
  sensitive   = true
}

variable "client_object_id" {
  description = "Logged in User / Service Principal Object Id"
  sensitive   = true
  default     = null
}

variable "ado_org_service_url" {
  description = "Azure DevOps Organization URL e.g. https://dev.azure.com/my-org"
  sensitive   = true
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

variable "ado_linux_vmss_agent_pool_settings" {
  description = "Azure DevOps Linux VMSS Agent Pool Settings"
  type = object({
    max_capacity           = number # VMSS Max Capacity
    desired_size           = number # VMSS desired size
    desired_idle           = number # VMSS desired idle
    time_to_live_minutes   = number # VMSS time to live in minutes
    recycle_after_each_use = bool   # VMSS recycle after each use
    ostype                 = string # VMSS ostype e.g. linux
  })

  default = {
    max_capacity           = 2
    desired_size           = 1
    desired_idle           = 1
    time_to_live_minutes   = 30
    recycle_after_each_use = false
    ostype                 = "linux"
  }
}

variable "ado_windows_vmss_agent_pool_settings" {
  description = "Azure DevOps Windows VMSS Agent Pool Settings"
  type = object({
    max_capacity           = number # VMSS Max Capacity
    desired_size           = number # VMSS desired size
    desired_idle           = number # VMSS desired idle
    time_to_live_minutes   = number # VMSS time to live in minutes
    recycle_after_each_use = bool   # VMSS recycle after each use
    ostype                 = string # VMSS ostype e.g. windows
  })

  default = {
    max_capacity           = 2
    desired_size           = 1
    desired_idle           = 1
    time_to_live_minutes   = 30
    recycle_after_each_use = false
    ostype                 = "windows"
  }
}

variable "azure_subscription_name" {
  description = "This is your Azure Subscription Name for your Azure Service Connection"
  sensitive   = true
}

variable "tf_apply_environment_pipeline_path" {
  description = "Azure DevOps Environment Pipeline path e.g. /pipelines/environments/omop-terraform-apply.yaml"
}

variable "tf_destroy_environment_pipeline_path" {
  description = "Azure DevOps Environment Pipeline path e.g. /pipelines/environments/omop-terraform-destroy.yaml"
}

variable "tf_apply_environment_pipeline_name" {
  default     = "TF Apply OMOP Environment Pipeline"
  description = "Terraform Apply Environment Build Pipeline Name"
}

variable "tf_destroy_environment_pipeline_name" {
  default     = "TF Destroy OMOP Environment Pipeline"
  description = "Terraform Destroy Environment Build Pipeline Name"
}

variable "vocabulary_build_pipeline_name" {
  default     = "Vocabulary Build Pipeline"
  description = "Vocabulary Build Pipeline Name"
}

variable "vocabulary_release_pipeline_name" {
  default     = "Vocabulary Release Pipeline"
  description = "Vocabulary Release Pipeline Name"
}

variable "broadsea_build_pipeline_name" {
  default     = "Broadsea Build Pipeline"
  description = "Broadsea Build Pipeline Name"
}

variable "broadsea_release_pipeline_name" {
  default     = "Broadsea Release Pipeline"
  description = "Broadsea Release Pipeline Name"
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

/* Azure VMSS Settings */
variable "azure_vmss_sku" {
  type        = string
  description = "Azure VMSS SKU"
  default     = "Standard_D4s_v3"
}
variable "azure_vmss_instances" {
  type        = number
  description = "Number of Azure VMSS Instances"
  default     = 2
}

variable "azure_vmss_source_image_publisher" {
  type        = string
  description = "Azure VMSS Source Image Publisher"
  default     = "Canonical"
}
variable "azure_vmss_source_image_offer" {
  type        = string
  description = "Azure VMSS Source Image Offer"
  default     = "0001-com-ubuntu-server-focal"
}
variable "azure_vmss_source_image_sku" {
  type        = string
  description = "Azure VMSS Source Image SKU"
  default     = "20_04-lts"
}
variable "azure_vmss_source_image_version" {
  type        = string
  description = "Azure VMSS Source Image Version"
  default     = "latest"
}

/* Azure Windows VMSS Settings */
variable "azure_windows_vmss_sku" {
  type        = string
  description = "Azure VMSS SKU"
  default     = "Standard_D4s_v3"
}
variable "azure_windows_vmss_instances" {
  type        = number
  description = "Number of Azure VMSS Instances"
  default     = 1
}

variable "azure_windows_vmss_source_image_publisher" {
  type        = string
  description = "Azure VMSS Source Image Publisher"
  default     = "MicrosoftWindowsServer"
}
variable "azure_windows_vmss_source_image_offer" {
  type        = string
  description = "Azure VMSS Source Image Offer"
  default     = "WindowsServer"
}
variable "azure_windows_vmss_source_image_sku" {
  type        = string
  description = "Azure VMSS Source Image SKU"
  default     = "2019-Datacenter"
}
variable "azure_windows_vmss_source_image_version" {
  type        = string
  description = "Azure VMSS Source Image Version"
  default     = "latest"
}

/* ACR */
variable "acr_sku_edition" {}

/* Application Service Plan */
variable "asp_kind_edition" {}
variable "asp_sku_tier" {}
variable "asp_sku_size" {}
