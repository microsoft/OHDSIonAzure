provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# Define azurerm backend, Azure DevOps will fill in other required details
terraform {
  #backend "azurerm" {}
  # Uncomment to include your backend state for first time run
  backend "azurerm" {
       resource_group_name  = var.tf_storage_resource_group
       storage_account_name = var.tf_backend_storage_account
       container_name       = var.tf_backend_container
       key                  = var.tf_state_filename
  }
  required_version = "~> 1.1.4"

  required_providers {
    azurerm = {
      version = "~> 2.90.0"
      source  = "hashicorp/azurerm"
    }
  }
}

data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "omop_rg" {
  name     = "${var.prefix}-${var.environment}-omop-rg"
  location = var.location

  tags = var.tags
}

#############################
# AZURE KEY VAULT
#############################
# example KV in case you'd like to add sensitive values, and can uncomment for reference.

# resource "azurerm_key_vault" "app_service_settings" {
#   name                       = "${var.prefix}-${var.environment}-omop-kv"
#   location                   = azurerm_resource_group.omop_rg.location
#   resource_group_name        = azurerm_resource_group.omop_rg.name
#   tenant_id                  = data.azurerm_client_config.current.tenant_id
#   sku_name                   = "premium"
#   soft_delete_retention_days = 7

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     key_permissions = [
#       "create",
#       "get",
#       "list",
#     ]

#     secret_permissions = [
#       "list",
#       "set",
#       "get",
#       "delete",
#       "purge",
#       "recover",
#     ]
#   }
# }

# # example secret
# resource "azurerm_key_vault_secret" "url" {
#   name         = "datasource-url"
#   value        = "jdbc:sqlserver://${var.prefix}-${var.environment}-omop-sql-server.database.windows.net:1433;database=${var.prefix}_${var.environment}_omop_db"
#   key_vault_id = azurerm_key_vault.app_service_settings.id
# }

# # example key vault access policy
# resource "azurerm_key_vault_access_policy" "app_service_kv" {
#   key_vault_id = azurerm_key_vault.app_service_settings.id
#   tenant_id    = azurerm_app_service.omop_broadsea.identity[0].tenant_id
#   object_id    = azurerm_app_service.omop_broadsea.identity[0].principal_id

#   key_permissions = [
#     "Get",
#   ]

#   secret_permissions = [
#     "Get",
#   ]
# }

#############################
# AZURE STORAGE
#############################

resource "azurerm_storage_account" "omop_sa" {
  name                     = "${var.prefix}${var.environment}omopsa"
  resource_group_name      = azurerm_resource_group.omop_rg.name
  location                 = azurerm_resource_group.omop_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "vocabularies" {
  name                  = var.cdr_vocab_container_name
  storage_account_name  = azurerm_storage_account.omop_sa.name
  container_access_type = "private"
}

#############################
# AZURE SQL
#############################

resource "azurerm_mssql_server" "omop_sql_server" {
  name                         = "${var.prefix}-${var.environment}-omop-sql-server"
  resource_group_name          = azurerm_resource_group.omop_rg.name
  location                     = azurerm_resource_group.omop_rg.location
  version                      = "12.0"
  administrator_login          = "omop_admin"
  administrator_login_password = var.omop_password
  minimum_tls_version          = "1.2"
  tags = {
    environment = var.environment
  }

  # https://registry.terraform.io/providers/hashicorp/azurerm/2.90.0/docs/resources/mssql_server#azuread_administrator
  # Cover this with az cli call?
  azuread_administrator {
    login_username = var.aad_admin_login_name
    object_id      = var.aad_admin_object_id
  }
  # you can access the principal_id e.g. azurerm_mssql_server.omop_sql_server.identity[0].principal_id
  # and the tenant_id with azurerm_mssql_server.omop_sql_server.identity[0].tenant_id
  identity {
    type = "SystemAssigned"
  }
}

# Assign Storage Blob Data Reader to Azure SQL MI
resource "azurerm_role_assignment" "azure_sql_managed_identity_to_azure_storage" {
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_storage_account.omop_sa.id
  principal_id         = azurerm_mssql_server.omop_sql_server.identity[0].principal_id
}

# TODO: This is open networking, and should be updated per the security requirements in your environment.
resource "azurerm_sql_firewall_rule" "open_firewall" {
  name                = "SQLFirewallRule1"
  resource_group_name = azurerm_resource_group.omop_rg.name
  server_name         = azurerm_mssql_server.omop_sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_sql_firewall_rule" "allow_azure_services" {
  name                = "SQLFirewallRule2"
  resource_group_name = azurerm_resource_group.omop_rg.name
  server_name         = azurerm_mssql_server.omop_sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mssql_database" "OHDSI-CDMV5" {
  name         = "${var.prefix}_${var.environment}_omop_db"
  server_id    = azurerm_mssql_server.omop_sql_server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = var.omop_db_size
  sku_name     = var.omop_db_sku
  # zone_redundant = true
}

#############################
# CONTAINER REGISTRY
#############################

resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}${var.environment}acr"
  resource_group_name = "${var.prefix}-${var.environment}-omop-rg"
  location            = var.location
  sku                 = var.acr_sku_edition
  admin_enabled       = false
}

#############################
# APP SERVICE
#############################

# This creates the plan that the service use
resource "azurerm_app_service_plan" "omop_asp" {
  name                = "${var.prefix}-${var.environment}-omop-asp"
  location            = azurerm_resource_group.omop_rg.location
  resource_group_name = azurerm_resource_group.omop_rg.name
  kind                = var.asp_kind_edition
  reserved            = true

  sku {
    tier = var.asp_sku_tier
    size = var.asp_sku_size
  }
}

# This creates the Broadsea app service definition
resource "azurerm_app_service" "omop_broadsea" {
  name                = "${var.prefix}-${var.environment}-omop-broadsea"
  location            = azurerm_resource_group.omop_rg.location
  resource_group_name = azurerm_resource_group.omop_rg.name
  app_service_plan_id = azurerm_app_service_plan.omop_asp.id

  site_config {
    app_command_line                     = ""
    linux_fx_version                     = "DOCKER|${azurerm_container_registry.acr.name}.azurecr.io/${var.broadsea_image}:${var.broadsea_image_tag}" # could be handled through pipeline instead
    always_on                            = true
    acr_use_managed_identity_credentials = true # Connect ACR with MI
  }

  app_settings = {
    "WEBAPI_RELEASE"                                 = "2.9.0"
    "WEBAPI_WAR"                                     = "WebAPI-2.9.0.war"
    "WEBSITES_PORT"                                  = "8080"
    "WEBSITES_CONTAINER_START_TIME_LIMIT"            = "1800"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"            = "false"
    "WEBSITE_HTTPLOGGING_RETENTION_DAYS"             = "7"
    "WEBAPI_SOURCES"                                 = "https://${var.prefix}-${var.environment}-omop-broadsea.azurewebsites.net/WebAPI/source"
    "WEBAPI_URL"                                     = "https://${var.prefix}-${var.environment}-omop-broadsea.azurewebsites.net/WebAPI"
    "env"                                            = "webapi-mssql"
    "security_origin"                                = "*"
    "datasource.driverClassName"                     = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
    "datasource.url"                                 = "jdbc:sqlserver://${azurerm_mssql_server.omop_sql_server.name}.database.windows.net:1433;database=${azurerm_mssql_database.OHDSI-CDMV5.name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;Authentication=ActiveDirectoryMsi"
    "datasource.cdm.schema"                          = "cdm"
    "datasource.ohdsi.schema"                        = "webapi"
    "datasource.username"                            = ""
    "datasource.password"                            = ""
    "spring.jpa.properties.hibernate.default_schema" = "webapi"
    "spring.jpa.properties.hibernate.dialect"        = "org.hibernate.dialect.SQLServer2012Dialect"
    "spring.batch.repository.tableprefix"            = "${azurerm_mssql_database.OHDSI-CDMV5.name}.webapi.BATCH_"
    "flyway.datasource.driverClassName"              = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
    "flyway.datasource.url"                          = "jdbc:sqlserver://${azurerm_mssql_server.omop_sql_server.name}.database.windows.net:1433;database=${azurerm_mssql_database.OHDSI-CDMV5.name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;Authentication=ActiveDirectoryMsi"
    "flyway.schemas"                                 = "webapi"
    "flyway.placeholders.ohdsiSchema"                = "webapi"
    "flyway.datasource.username"                     = ""
    "flyway.datasource.password"                     = ""
    "flyway.locations"                               = "classpath:db/migration/sqlserver"
  }

  identity {
    type = "SystemAssigned"
  }

  connection_string {
    name  = "ConnectionStrings:Default"
    type  = "SQLServer" # check if this shuld be SQLServer
    value = "jdbc:sqlserver://${azurerm_mssql_server.omop_sql_server.name}.database.windows.net:1433;database=${azurerm_mssql_database.OHDSI-CDMV5.name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;Authentication=ActiveDirectoryMsi"
  }
}

# Assign App Service MI ACR Pull
resource "azurerm_role_assignment" "app_service_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_app_service.omop_broadsea.identity[0].principal_id
}
