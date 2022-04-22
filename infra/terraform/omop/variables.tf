variable "tags" {
  description = "Tags used for the resources created"
  type        = map(any)
  default     = {}
}

variable "prefix" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "westus3"
}

### Filled in through Azure Key Vault from bootstrap VG ###
variable "omop_password" {
  type      = string
  sensitive = true
}

### Filled in through Azure Key Vault from bootstrap VG ###
variable "bootstrap_admin_object_id" {
  type      = string
  sensitive = true
}

### Filled in through Azure Key Vault from bootstrap VG ###
variable "sp_service_connection_object_id" {
  type      = string
  sensitive = true
}

### Filled in through Azure Key Vault from bootstrap VG ###
variable "vmss_managed_identity_object_id" {
  type      = string
  sensitive = true
}

### Filled in through bootstrap settings VG
variable "ado_agent_pool_vmss_name" {
  type = string
}
/* AD Auth Creds */
variable "aad_admin_login_name" {}
variable "aad_admin_object_id" {}
variable "aad_directory_readers_login_name" {}
variable "aad_directory_readers_object_id" {}

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

# TODO: this should come from ACR
variable "broadsea_image" {
  description = "Docker image for OHDSI - Broadsea (Atlas and WebAPI)"
  default     = "broadsea-webtools"
}

# TODO: this should come from ACR
variable "broadsea_image_tag" {
  description = "Docker image tag for OHDSI - Broadsea (Atlas and WebAPI)"
  default     = "latest"
}

variable "cdr_vocab_container_name" {
  description = "The name of the blob container in the CDR storage account that will be used for vocabulary file uploads."
  default     = "vocabularies"
}

variable "tf_storage_resource_group" {
  description = "The bootstrap resource group name"
}

variable tf_backend_storage_account {
  description = "Storage Account name for backend Terraform state file"
}

variable "tf_backend_container" {
  description = "Storage Account Container name for backend Terraform state file"
}

variable "tf_state_filename" {
  description = "The name of the tf state file"
}

/* Application Service Plan */
variable "asp_kind_edition" {}
variable "asp_sku_tier" {}
variable "asp_sku_size" {}
