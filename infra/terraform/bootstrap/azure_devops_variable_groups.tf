#############################
# Azure DevOps Variable Group
# Used for Key Vault Linked Variable Group for bootstrap
#############################

# Create VG with Key Vault
resource "azuredevops_variable_group" "adobootstrapvg" {
  project_id   = azuredevops_project.project.id
  name         = "${var.prefix}-${var.environment}-ado-bootstrap-vg"
  description  = "Azure DevOps Variable Group linked to Azure Key Vault used for bootstrapping an environment"
  allow_access = false # should only be used by the environment stand up pipeline

  key_vault {
    name                = azurerm_key_vault.keyvault.name
    service_endpoint_id = azuredevops_serviceendpoint_azurerm.endpointazure.id
  }

  # Link Secret from Azure Key Vault into Azure DevOps Variable Group
  # Note that key vault secrets must match the name (and key vault secrets don't allow underscores)
  variable {
    name = "omopPassword"
  }

  variable {
    name = "bootstrapAdminObjectId"
  }

  variable {
    name = "spServiceConnectionObjectId"
  }

  variable {
    name = "vmssManagedIdentityObjectId"
  }

  depends_on = [
    azurerm_key_vault.keyvault,
    azurerm_key_vault_secret.omopPassword,
    azurerm_key_vault_secret.bootstrapAdminObjectId,
    azurerm_key_vault_secret.spServiceConnectionObjectId,
    azurerm_key_vault_secret.vmssManagedIdentityObjectId,
    azuredevops_serviceendpoint_azurerm.endpointazure
  ]
}

# Authorize the VG for the Environment Pipeline
resource "azuredevops_resource_authorization" "adobootstrapvgauth" {
  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_variable_group.adobootstrapvg.id
  definition_id = azuredevops_build_definition.environmentpipeline.id
  authorized    = true
  type          = "variablegroup"
}

#############################
# Azure DevOps Variable Group
# Settings for bootstrap
#############################

# Create VG for bootstrap settings without Key Vault
resource "azuredevops_variable_group" "adobootstrapsettingsvg" {
  project_id   = azuredevops_project.project.id
  name         = "${var.prefix}-${var.environment}-ado-bootstrap-settings-vg"
  description  = "Azure DevOps Variable Group without KV used for bootstrapping an environment"
  allow_access = false # should only be used by the environment stand up pipeline

  /* Add in environment configuration settings */
  variable {
    name  = "prefix"
    value = var.prefix
  }

  variable {
    name  = "environment"
    value = var.environment
  }

  variable {
    name  = "location"
    value = var.location
  }

  variable {
    name  = "cdr_vocab_container_name"
    value = var.cdr_vocab_container_name
  }

  variable {
    name  = "omop_db_size"
    value = var.omop_db_size
  }

  variable {
    name  = "omop_db_sku"
    value = var.omop_db_sku
  }

  variable {
    name  = "acr_sku_edition"
    value = var.acr_sku_edition
  }

  variable {
    name  = "asp_kind_edition"
    value = var.asp_kind_edition
  }

  variable {
    name  = "asp_sku_tier"
    value = var.asp_sku_tier
  }

  variable {
    name  = "asp_sku_size"
    value = var.asp_sku_size
  }

  # Pass along the Azure AD Group to add to Azure SQL as AAD administrator
  variable {
    name  = "aad_admin_object_id"
    value = azuread_group.dbadminsaadgroup.object_id
  }

  variable {
    name  = "aad_admin_login_name"
    value = azuread_group.dbadminsaadgroup.display_name
  }

  # Pass along the Azure AD Group for Directory Readers to add in Azure SQL Server Managed Identity access
  variable {
    name  = "aad_directory_readers_object_id"
    value = azuread_group.directoryreadersaadgroup.object_id
  }

  variable {
    name  = "aad_directory_readers_login_name"
    value = azuread_group.directoryreadersaadgroup.display_name
  }

  /* Add in Service Connection information */
  variable {
    name  = "azure_service_connection_name"
    value = azuredevops_serviceendpoint_azurerm.endpointazure.service_endpoint_name
  }

  /* Add in Azure DevOps Agent Pool VMSS Name */
  variable {
    name  = "ado_agent_pool_vmss_name"
    value = azurerm_linux_virtual_machine_scale_set.vmss.name
  }

  # This is the name of the Azure DevOps Agent Pool which will use the Azure VMSS
  # TODO: revisit naming
  variable {
    name  = "adoVMSSBuildAgentPoolName"
    value = "${azurerm_linux_virtual_machine_scale_set.vmss.name}-pool"
  }

  /* Add in Terraform Configuration for Environment Pipeline */
  variable {
    name  = "tf_storage_resource_group"
    value = azurerm_resource_group.adobootstrap.name
  }

  variable {
    name  = "tf_storage_region"
    value = var.location
  }

  variable {
    name  = "tf_storage_account_name"
    value = azurerm_storage_account.tfstatesa.name
  }

  variable {
    name  = "tf_storage_container_name"
    value = azurerm_storage_container.tfstatecontainer.name
  }

  variable {
    name  = "tf_state_filename"
    value = "terraform.tfstate"
  }

  # enable clean up option for your environment pipeline
  # Set to '0' for not enabled
  # Set to '1' for enabled
  variable {
    name  = "enable_cleanup"
    value = "0"
  }

  variable {
    name  = "tf_plan_environment"
    value = module.azure_devops_environment_tf_plan.azure_devops_environment_name
  }

  variable {
    name  = "tf_approval_environment"
    value = module.azure_devops_environment_tf_apply.azure_devops_environment_name
  }

  depends_on = [
    azuredevops_serviceendpoint_azurerm.endpointazure,
    azurerm_resource_group.adobootstrap,
    azuread_group.dbadminsaadgroup,
    azurerm_storage_account.tfstatesa,
    azurerm_storage_container.tfstatecontainer,
    module.azure_devops_environment_tf_plan,
    module.azure_devops_environment_tf_apply
  ]
}

# Authorize the VG for the Environment Pipeline
resource "azuredevops_resource_authorization" "adobootstrapsettingsvgauth" {
  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_variable_group.adobootstrapsettingsvg.id
  definition_id = azuredevops_build_definition.environmentpipeline.id
  authorized    = true
  type          = "variablegroup"
}

#############################
# Azure DevOps Variable Group
# Used to hold environment settings
# This will be filled in as a first pass, but should be updated to reflect the settings
# in the environment (e.g. from /terraform/omop/main.tf)
#############################

resource "azuredevops_variable_group" "adoenvvg" {
  project_id   = azuredevops_project.project.id
  name         = "${var.prefix}-${var.environment}-omop-environment-settings-vg"
  description  = "Azure Variable Group for Azure DevOps OMOP Environment Settings"
  allow_access = false

  variable {
    name  = "prefix"
    value = var.prefix
  }

  variable {
    name  = "environment"
    value = var.environment
  }

  variable {
    name  = "serviceConnection"
    value = azuredevops_serviceendpoint_azurerm.endpointazure.service_endpoint_name
  }

  # enable clean up option for your pipeline
  # Set to '0' for not enabled
  # Set to '1' for enabled
  variable {
    name  = "enableCleanup"
    value = "0"
  }

  # This is the Azure VMSS used for the Azure DevOps Build Agent Pool
  variable {
    name  = "adoAgentPoolVMSSName"
    value = azurerm_linux_virtual_machine_scale_set.vmss.name
  }

  # This is the name of the Azure DevOps Agent Pool which will use the Azure VMSS
  variable {
    name  = "adoVMSSBuildAgentPoolName"
    value = "${azurerm_linux_virtual_machine_scale_set.vmss.name}-pool"
  }

  /* Add in Azure DevOps Agent Pool Windows VMSS Name */
  variable {
    name  = "adoAgentPoolWindowsVMSSName"
    value = azurerm_windows_virtual_machine_scale_set.vmss.name
  }

  # This is the name of the Azure DevOps Agent Pool which will use the Azure Windows VMSS
  variable {
    name  = "adoWindowsVMSSBuildAgentPoolName"
    value = "${azurerm_windows_virtual_machine_scale_set.vmss.name}-pool"
  }

  # This is the Azure DevOps project name for your pipelines (e.g. https://dev.azure.com/<my-organization>/<my-project>)
  variable {
    name  = "projectName"
    value = azuredevops_project.project.name
  }

  variable {
    name  = "vocabularyBuildPipelineName"
    value = var.vocabulary_build_pipeline_name
  }

  variable {
    name  = "vocabularyReleasePipelineName"
    value = var.vocabulary_release_pipeline_name
  }

  variable {
    name  = "broadseaBuildPipelineName"
    value = var.broadsea_build_pipeline_name
  }

  variable {
    name  = "broadseaReleasePipelineName"
    value = var.broadsea_release_pipeline_name
  }

  variable {
    name  = "vocabulary_build_environment"
    value = module.azure_devops_environment_vocabulary_build.azure_devops_environment_name
  }

  variable {
    name  = "vocabulary_release_environment"
    value = module.azure_devops_environment_vocabulary_release.azure_devops_environment_name
  }

  variable {
    name  = "broadsea_build_environment"
    value = module.azure_devops_environment_broadsea_build.azure_devops_environment_name
  }

  variable {
    name  = "broadsea_release_environment"
    value = module.azure_devops_environment_broadsea_release.azure_devops_environment_name
  }

  variable {
    name  = "containerRegistry"
    value = "${var.prefix}${var.environment}acr"
  }

  variable {
    name  = "appSvcRg"
    value = "${var.prefix}-${var.environment}-omop-rg"
  }

  variable {
    name  = "appSvcName"
    value = "${var.prefix}-${var.environment}-omop-broadsea"
  }

  variable {
    name  = "sqlServerName"
    value = "${var.prefix}-${var.environment}-omop-sql-server"
  }

  variable {
    name  = "sqlServerDbName"
    value = "${var.prefix}_${var.environment}_omop_db"
  }

  # this should be filled in through either through the environment (e.g. from /terraform/omop/main.tf)
  # or you can override it manually
  # This is a combination of the /container/vocabularyVersion which represents which vocabulary to use
  # from the environment storage account
  variable {
    name  = "vocabulariesContainerPath"
    value = "${var.cdr_vocab_container_name}/${var.cdr_vocab_version}"
  }

  variable {
    name  = "vocabularyVersion"
    value = var.cdr_vocab_version
  }

  variable {
    name  = "dSVocabularyBlobStorageName"
    value = var.data_source_vocabulary_name
  }

  variable {
    name  = "storageAccount"
    value = "${var.prefix}${var.environment}omopsa"
  }

  variable {
    name  = "webapiSources"
    value = "https://${var.prefix}-${var.environment}-omop-broadsea.azurewebsites.net/WebAPI/source"
  }

  variable {
    name  = "cdmVersion"
    value = "5.3.1"
  }

  variable {
    name  = "cdmSchema"
    value = "dbo"
  }

  variable {
    name  = "syntheaSchema"
    value = "synthea"
  }

  variable {
    name  = "syntheaVersion"
    value = "2.7.0"
  }

  variable {
    name  = "vocabSchema"
    value = "dbo"
  }

  variable {
    name  = "resultsSchema"
    value = "webapi"
  }

  variable {
    name  = "resultsSchema"
    value = "2.7.0"
  }

  depends_on = [
    azuredevops_project.project,
    module.azure_devops_environment_vocabulary_build,
    module.azure_devops_environment_vocabulary_release,
    module.azure_devops_environment_broadsea_build,
    module.azure_devops_environment_broadsea_release
  ]
}

# Authorize the VG for the Application Pipelines
# You may need to comment this out for a first time run
resource "azuredevops_resource_authorization" "adoenvvgauthvocabularybuild" {
  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_variable_group.adoenvvg.id
  definition_id = azuredevops_build_definition.vocabularybuildpipeline.id
  authorized    = true
  type          = "variablegroup"
}

resource "azuredevops_resource_authorization" "adoenvvgauthvocabularyrelease" {
  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_variable_group.adoenvvg.id
  definition_id = azuredevops_build_definition.vocabularyreleasepipeline.id
  authorized    = true
  type          = "variablegroup"
}

resource "azuredevops_resource_authorization" "adoenvvgauthbroadseabuild" {
  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_variable_group.adoenvvg.id
  definition_id = azuredevops_build_definition.broadseabuildpipeline.id
  authorized    = true
  type          = "variablegroup"
}

resource "azuredevops_resource_authorization" "adoenvvgauthbroadsearelease" {
  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_variable_group.adoenvvg.id
  definition_id = azuredevops_build_definition.broadseareleasepipeline.id
  authorized    = true
  type          = "variablegroup"
}