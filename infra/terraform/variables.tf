variable "tags" {
  description = "Tags used for the resources created"
  type        = map(any)
  default     = {}
}

variable "prefix" {
  type = string
}

variable "environment" {
  type = string
  default = "dev"
}

variable "location" {
  type = string
  default = "westus3"
}

variable "omop_password" {
  type = string
  sensitive = true
}

/* AD Auth Creds */
variable "ad_admin_login_name" {}
variable "ad_admin_object_id" {}

variable "omop_db_size" {
  type = string
  default = 20 # max size gb
}

variable "omop_db_sku" {
  type = string
  # default = "BC_Gen5_10"
  default = "GP_Gen5_2"
}

variable log_file {
  description = "Log file name to create with the seeding results."
  default     = "db-init.log"
}

/* ACR */
variable "acr_sku_edition" {}

# variable "acr_sp_key" {
#   description = "Docker Server Registry Password (SP) used for App Service"
#   type        = string
#   sensitive   = true
# }

# variable "acr_sp_clientid" {
#   description = "Docker Server Registry Client ID (SP) used for App Service"
#   type        = string
# }

# variable "acr_sp_objectid" {
#   description = "Docker Server Registry Client ID (SP) used for App Service"
#   type        = string
# }

# TODO: this should come from ACR
variable "broadsea_image" {
  description = "Docker image for OHDSI - Broadsea (Atlas and WebAPI)"
  default = "broadsea-webtools"
}

# TODO: this should come from ACR
variable "broadsea_image_tag" {
  description = "Docker image tag for OHDSI - Broadsea (Atlas and WebAPI)"
  default = "latest"
}

variable "cdr_vocab_container_name" {
  description = "The name of the blob container in the CDR storage account that will be used for vocabulary file uploads."
  default     = "vocabularies"
}

/* Application Service Plan */
variable "asp_kind_edition" {}
variable "asp_sku_tier" {}
variable "asp_sku_size" {}
