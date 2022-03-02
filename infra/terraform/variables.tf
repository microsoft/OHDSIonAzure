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
}

variable "source_source_daimon_path" {
  type = string
  default = "../sql/source_source_daimon.sql"
}

locals {
  source-source-daimon = <<-EOT
  -- OHDSI CDM source
  INSERT INTO webapi.source( source_id, source_name, source_key, source_connection, source_dialect)
  VALUES (1, 'OHDSI CDM V5 Database', 'OHDSI-CDMV5',
    'jdbc:sqlserver://${var.prefix}-${var.environment}-omop-sql-server.database.windows.net:1433;database=${var.prefix}_${var.environment}_omop_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;Authentication=ActiveDirectoryMsi', 'sql server');

  -- CDM daimon
  INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (1, 1, 0, 'dbo', 2);

  -- VOCABULARY daimon
  INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (2, 1, 1, 'dbo', 2);

  -- RESULTS daimon
  INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (3, 1, 2, 'webapi', 2);

  -- EVIDENCE daimon
  INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (4, 1, 3, 'webapi', 2);

  EOT
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
  default = "yradsmikham/ohdsi-webapi-and-webtools"
}

# TODO: this should come from ACR
variable "broadsea_image_tag" {
  description = "Docker image tag for OHDSI - Broadsea (Atlas and WebAPI)"
  default = "latest"
}

variable "webtools_image" {
  description = "Docker image for OHDSI - Webtools (Achilles)"
  default = "ohdsi/broadsea-methodslibrary"
}

variable "webtools_image_tag" {
  description = "Docker image tag for OHDSI - Webtools (Achilles)"
  default = "latest"
}

variable "webtools_user" {
  description = "Achilles user"
  default = "ohdsi"
}

variable "webtools_password" {
  description = "Achilles password"
  default = "ohdsi"
}

variable "cdr_vocab_container_name" {
  description = "The name of the blob container in the CDR storage account that will be used for vocabulary file uploads."
  default     = "vocabularies"
}

/* Application Service Plan */
variable "asp_kind_edition" {}
variable "asp_sku_tier" {}
variable "asp_sku_size" {}
