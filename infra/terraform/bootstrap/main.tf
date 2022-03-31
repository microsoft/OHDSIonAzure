terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    # Using 0.1.8 provider for variable groups until fix is pushed for
    # https://github.com/microsoft/terraform-provider-azuredevops/issues/541
    azuredevops = {
      source = "microsoft/azuredevops"
      #   version = ">=0.2.0"
      version = "~>0.1.8"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url       = var.ado_org_service_url
  personal_access_token = var.ado_pat
}

data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "adobootstrap" {
  name     = "${var.prefix}-${var.environment}-ado-bootstrap-omop-rg"
  location = var.location
  tags     = var.tags
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

#############################
# Azure DevOps Settings
# Used for SP Service connection
#############################

# You can also use terraform import azuredevops_project.project "OHDSIonAzure"
resource "azuredevops_project" "project" {
  name = "OHDSIonAzure"
  lifecycle {
    ignore_changes = [
      # Ignore changes to visibility and work_item_template to support importing existing projects
      # Given that a project now exists, either imported into terraform state or created by terraform,
      # we don't care for the configuration of visibility and work_item_template against the existing resource
      visibility,
      work_item_template,
    ]
  }
  #   name       = "${var.prefix}-${var.environment}-OHDSIonAzure"
  #   description        = "AzDevOps OHDSI on Azure bootstrap project"
  #   visibility         = "private"
  #   version_control    = "Git"
  #   work_item_template = "Agile"
}

# resource "azuredevops_git_repository" "repo" {
#   project_id = azuredevops_project.project.id
#   name       = "Sample Empty Git Repository"

#   initialization {
#     init_type = "Clean"
#   }
# }

# you can import the repo 
# terraform import azuredevops_git_repository.repo projectName/repoName
# e.g. terraform import azuredevops_git_repository.repo OHDSIonAzure/OHDSIonAzure
resource "azuredevops_git_repository" "repo" {
  project_id = azuredevops_project.project.id
  name       = "OHDSIonAzure"
  initialization {
    init_type = "Uninitialized"
  }
  # Use Terraform import instead, otherwise this resource will destroy the existing repository.
  lifecycle {
    ignore_changes = [
      # Ignore changes to initialization to support importing existing repositories
      # Given that a repo now exists, either imported into terraform state or created by terraform,
      # we don't care for the configuration of initialization against the existing resource
      initialization,
    ]
  }
  #   name       = "Sample Import an Existing Repository"
  #   initialization {
  #     init_type             = "Import"
  #     source_type           = "Git"
  #     source_url            = "${var.ado_org_service_url}/${var.ado_project_name}/_git/${var.ado_repo_name}"
  #     service_connection_id = azuredevops_serviceendpoint_generic_git.serviceendpoint.id
  #   }
}

#############################
# Azure DevOps Environment
# Used for TF Environment plan and apply
#############################

module "azure_devops_environment_tf_plan" {
  source              = "../modules/azure_devops_environment"
  environment_name    = "${var.prefix}-${var.environment}-omop-tf-plan-environment"
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_id      = azuredevops_project.project.id
}

module "azure_devops_environment_tf_apply" {
  source              = "../modules/azure_devops_environment"
  environment_name    = "${var.prefix}-${var.environment}-omop-tf-apply-environment"
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_id      = azuredevops_project.project.id
}

#############################
# Azure Service Principal
# Used for SP Service connection
#############################

resource "azuread_application" "spomop" {
  display_name = "sp-for-${var.prefix}-${var.environment}-omop-service-connection"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "spomop" {
  application_id = azuread_application.spomop.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "spomop" {
  service_principal_id = azuread_service_principal.spomop.id
}

resource "azurerm_role_assignment" "main" {
  principal_id         = azuread_service_principal.spomop.id
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Owner"
}

#############################
# Azure Key Vault
# Used for Key Vault Linked Variable Group for Bootstrap
#############################

resource "azurerm_key_vault" "keyvault" {
  name                        = "${var.prefix}-${var.environment}-omop-kv"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.adobootstrap.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy = [
    {
      tenant_id      = data.azurerm_client_config.current.tenant_id
      object_id      = data.azurerm_client_config.current.object_id
      application_id = null

      secret_permissions = [
        "Backup",
        "Get",
        "List",
        "Purge",
        "Recover",
        "Restore",
        "Set",
        "Delete",
      ]
      certificate_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
      ]
      key_permissions = [
        "Get",
        "List",
        "Update",
        "Restore",
        "Backup",
        "Recover",
        "Delete",
        "Import",
        "Create",
      ]
      storage_permissions = [
      ]
    },
    ## Grant SP permissions
    {
      tenant_id      = data.azurerm_client_config.current.tenant_id
      object_id      = azuread_service_principal.spomop.object_id
      application_id = null
      secret_permissions = [
        "Get",
        "List",
      ]
      certificate_permissions = [
      ]
      key_permissions = [
      ]
      storage_permissions = [
      ]
    }
  ]
}

## Create secrets
# Note that key vault secrets must match the name (and key vault secrets don't allow underscores)
resource "azurerm_key_vault_secret" "omopPassword" {
  key_vault_id = azurerm_key_vault.keyvault.id
  name         = "omopPassword"
  value        = var.omop_password
}

# this is assumed to be the bootstrap administrator id
resource "azurerm_key_vault_secret" "bootstrapAdminObjectId" {
  key_vault_id = azurerm_key_vault.keyvault.id
  name         = "bootstrapAdminObjectId"
  value        = data.azuread_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "spServiceConnectionObjectId" {
  key_vault_id = azurerm_key_vault.keyvault.id
  name         = "spServiceConnectionObjectId"
  value        = azuread_service_principal.spomop.id
}

resource "azurerm_key_vault_secret" "vmssManagedIdentityObjectId" {
  key_vault_id = azurerm_key_vault.keyvault.id
  name         = "vmssManagedIdentityObjectId"
  value        = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
}

#############################
# Azure Service Connection
#############################

## Create Service Connection
resource "azuredevops_serviceendpoint_azurerm" "endpointazure" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "sp-${var.prefix}-${var.environment}-omop-service-connection"
  credentials {
    serviceprincipalid  = azuread_service_principal.spomop.application_id
    serviceprincipalkey = azuread_service_principal_password.spomop.value
  }
  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = data.azurerm_client_config.current.subscription_id
  azurerm_subscription_name = var.azure_subscription_name
}

## grant permission to SC
resource "azuredevops_resource_authorization" "auth" {
  project_id  = azuredevops_project.project.id
  resource_id = azuredevops_serviceendpoint_azurerm.endpointazure.id
  authorized  = true
}

#############################
# Azure DevOps Variable Group
# Used for Key Vault Linked Variable Group for bootstrap
#############################

# Create VG with Key Vault
resource "azuredevops_variable_group" "adobootstrapvg" {
  project_id   = azuredevops_project.project.id
  name         = "ado-${var.prefix}-${var.environment}-omop-bootstrap-vg"
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
  name         = "ado-${var.prefix}-${var.environment}-omop-bootstrap-settings-vg"
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

  variable {
    name  = "enable_cleanup"
    value = "false"
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
  name         = "${var.prefix}-${var.environment}-omop-env-vg"
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

  variable {
    name  = "vocabularyBuildPipelineId"
    value = azuredevops_build_definition.vocabularybuildpipeline.id
  }

  variable {
    name  = "vocabularyBuildPipelineName"
    value = azuredevops_build_definition.vocabularybuildpipeline.name
  }

  variable {
    name  = "vocabularyReleasePipelineName"
    value = azuredevops_build_definition.vocabularyreleasepipeline.name
  }

  variable {
    name  = "broadseaBuildPipelineName"
    value = azuredevops_build_definition.broadseabuildpipeline.name
  }

  variable {
    name  = "broadseaReleasePipelineName"
    value = azuredevops_build_definition.broadseareleasepipeline.name
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
}

# Authorize the VG for the Application Pipelines
# You may need to comment this out for a first time run
resource "azuredevops_resource_authorization" "adoenvvgauth" {
  for_each = toset([
    azuredevops_build_definition.vocabularybuildpipeline.id,
    azuredevops_build_definition.vocabularyreleasepipeline.id,
    azuredevops_build_definition.broadseabuildpipeline.id,
  azuredevops_build_definition.broadseareleasepipeline.id])
  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_variable_group.adoenvvg.id
  definition_id = each.key
  authorized    = true
  type          = "variablegroup"
}

#############################
# Import Azure DevOps Build Pipelines
# Environment Pipeline
#############################
resource "azuredevops_build_definition" "environmentpipeline" {
  project_id = azuredevops_project.project.id
  name       = "TF OMOP Environment Pipeline"
  path       = "\\OHDSIOnAzure\\Terraform"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.environment_pipeline_path
  }

  variable_groups = [
    azuredevops_variable_group.adobootstrapvg.id,
    azuredevops_variable_group.adobootstrapsettingsvg.id
  ]
}

#############################
# Import Azure DevOps Build Pipelines
# Vocabulary Build Pipeline
#############################
resource "azuredevops_build_definition" "vocabularybuildpipeline" {
  project_id = azuredevops_project.project.id
  name       = "Vocabulary Build Pipeline"
  path       = "\\OHDSIOnAzure\\Vocabulary"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.vocabulary_build_pipeline_path
  }
}

#############################
# Import Azure DevOps Build Pipelines
# Vocabulary Release Pipeline
#############################
resource "azuredevops_build_definition" "vocabularyreleasepipeline" {
  project_id = azuredevops_project.project.id
  name       = "Vocabulary Release Pipeline"
  path       = "\\OHDSIOnAzure\\Vocabulary"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.vocabulary_release_pipeline_path
  }
}

#############################
# Import Azure DevOps Build Pipelines
# Broadsea Build Pipeline
#############################
resource "azuredevops_build_definition" "broadseabuildpipeline" {
  project_id = azuredevops_project.project.id
  name       = "Broadsea Build Pipeline"
  path       = "\\OHDSIOnAzure\\Broadsea"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.broadsea_build_pipeline_path
  }
}

#############################
# Import Azure DevOps Build Pipelines
# Broadsea Release Pipeline
#############################
resource "azuredevops_build_definition" "broadseareleasepipeline" {
  project_id = azuredevops_project.project.id
  name       = "Broadsea Release Pipeline"
  path       = "\\OHDSIOnAzure\\Broadsea"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.broadsea_release_pipeline_path
  }
}

#############################
# Azure Storage
# Used for bootstrap TF State
#############################

resource "azurerm_storage_account" "tfstatesa" {
  name                     = "${var.prefix}${var.environment}tfstatesa"
  resource_group_name      = azurerm_resource_group.adobootstrap.name
  location                 = azurerm_resource_group.adobootstrap.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = var.tags
}

resource "azurerm_storage_container" "tfstatecontainer" {
  name                  = "${var.prefix}-${var.environment}-statefile-container"
  storage_account_name  = azurerm_storage_account.tfstatesa.name
  container_access_type = "private"
}

#############################
# Azure Virtual Network
#############################

resource "azurerm_virtual_network" "vmss" {
  name                = "${var.prefix}-${var.environment}-vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name
  tags                = var.tags
}

resource "azurerm_subnet" "vmss" {
  name                 = "${var.prefix}-${var.environment}-vmss-subnet"
  resource_group_name  = azurerm_resource_group.adobootstrap.name
  virtual_network_name = azurerm_virtual_network.vmss.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vmss" {
  name                = "${var.prefix}-${var.environment}-vmss-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = random_string.fqdn.result
  tags                = var.tags
}

#############################
# Azure Virtual Machine Scale Set (VMSS)
# This will be used for the Azure DevOps agent pool
# Note that linking the VMSS to Azure DevOps as an agent pool in TF is still a TODO
# https://github.com/microsoft/terraform-provider-azuredevops/issues/204
# And revisit setting up elastic pools https://github.com/microsoft/terraform-provider-azuredevops/issues/368
#############################

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.prefix}-${var.environment}-ado-build-linux-vmss-agent"
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name
  upgrade_mode        = "Manual"
  admin_username      = var.admin_user
  admin_password      = var.admin_password

  custom_data                     = base64encode(file("adobuilder.conf"))
  disable_password_authentication = false
  sku                             = var.azure_vmss_sku
  instances                       = var.azure_vmss_instances
  overprovision                   = false
  single_placement_group          = false
  platform_fault_domain_count     = 1

  source_image_reference {
    publisher = var.azure_vmss_source_image_publisher
    offer     = var.azure_vmss_source_image_offer
    sku       = var.azure_vmss_source_image_sku
    version   = var.azure_vmss_source_image_version
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name      = "IPConfiguration"
      subnet_id = azurerm_subnet.vmss.id
      primary   = true
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # ignore changes to tags for Azure DevOps
      tags["__AzureDevOpsElasticPool"],
      tags["__AzureDevOpsElasticPoolTimeStamp"],
    ]
  }
}

#############################
# Azure Windows Virtual Machine Scale Set (VMSS)
# This will be used for the Azure DevOps agent pool
# Note that linking the Windows VMSS to Azure DevOps as an agent pool in TF is still a TODO
# https://github.com/microsoft/terraform-provider-azuredevops/issues/204
# And revisit setting up elastic pools https://github.com/microsoft/terraform-provider-azuredevops/issues/368
#############################

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                 = "${var.prefix}-${var.environment}-ado-build-windows-vmss-agent"
  computer_name_prefix = "ado-build" # 9 character limit for prefix
  location             = var.location
  resource_group_name  = azurerm_resource_group.adobootstrap.name
  upgrade_mode         = "Manual"
  admin_username       = var.admin_user
  admin_password       = var.admin_password

  # Copy in script data
  custom_data = base64encode(file("scripts/build-agent-dependencies.ps1"))

  sku                         = var.azure_windows_vmss_sku
  instances                   = var.azure_windows_vmss_instances
  overprovision               = false
  single_placement_group      = false
  platform_fault_domain_count = 1

  source_image_reference {
    publisher = var.azure_windows_vmss_source_image_publisher
    offer     = var.azure_windows_vmss_source_image_offer
    sku       = var.azure_windows_vmss_source_image_sku
    version   = var.azure_windows_vmss_source_image_version
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name      = "IPConfiguration"
      subnet_id = azurerm_subnet.vmss.id
      primary   = true
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # ignore changes to tags for Azure DevOps
      tags["__AzureDevOpsElasticPool"],
      tags["__AzureDevOpsElasticPoolTimeStamp"],
    ]
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "script_build_agent_dependencies" {
  name                         = "${var.prefix}-${var.environment}-build-agent-dependencies"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Compute"
  type                         = "CustomScriptExtension"
  type_handler_version         = "1.10"

  # run custom script
  settings = jsonencode(
    {
      "commandToExecute" : "powershell.exe -ExecutionPolicy Unrestricted -Command \"Copy-Item C:/AzureData/CustomData.bin ./build-agent-dependencies.ps1 -Force; ./build-agent-dependencies.ps1 *> C:/WindowsAzure/Logs/build-agent-dependencies.log\""
  })
}


#############################
# Jumpbox Settings
#############################

resource "azurerm_public_ip" "jumpbox" {
  name                = "${var.prefix}-${var.environment}-jumpbox-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name
  allocation_method   = "Static"
  domain_name_label   = "${random_string.fqdn.result}-ssh"
  tags                = var.tags
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "${var.prefix}-${var.environment}-jumpbox-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.adobootstrap.name

  ip_configuration {
    name                          = "${var.prefix}-${var.environment}-IPConfiguration"
    subnet_id                     = azurerm_subnet.vmss.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }

  tags = var.tags
}

#############################
# Azure VM
# This is a jumpbox for testing VMSS instances
# You can either use an Azure Linux VM or an Azure Windows VM as your jumpbox
#############################

## Uncomment if you prefer to use an Azure Linux VM for your jumpbox
# resource "azurerm_virtual_machine" "jumpbox" {
#   name                  = "${var.prefix}-${var.environment}-jumpbox"
#   location              = var.location
#   resource_group_name   = azurerm_resource_group.adobootstrap.name
#   network_interface_ids = [azurerm_network_interface.jumpbox.id]
#   vm_size               = "Standard_DS1_v2"

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

#   storage_os_disk {
#     name              = "${var.prefix}-${var.environment}-jumpbox-osdisk"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }

#   os_profile {
#     computer_name  = "${var.prefix}-${var.environment}-jumpbox"
#     admin_username = var.admin_user_jumpbox
#     admin_password = var.admin_password_jumpbox
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   tags = var.tags
# }

## Uncomment if you prefer to use an Azure Windows VM for your jumpbox
resource "azurerm_windows_virtual_machine" "jumpbox-windows" {
  name                = "${var.prefix}${var.environment}jump" # 15 character limit
  resource_group_name = azurerm_resource_group.adobootstrap.name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_user_jumpbox
  admin_password      = var.admin_password_jumpbox
  network_interface_ids = [
    azurerm_network_interface.jumpbox.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Windows Server 2019 includes Open SSH
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

#############################
# Azure AD Group for Azure SQL Admins
# This will hold the current admin user, the SP used for the Service Connection, and the Azure VMSS
# In the corresponding omop environment (/terraform/omop/output.tf), you should also have your administrator
# complete adding the Azure App Service to this group through Azure CLI
#############################

resource "azuread_group" "dbadminsaadgroup" {
  display_name  = "${var.prefix}-${var.environment}-omop-sql-server-admins"
  mail_nickname = "${var.prefix}-${var.environment}-omop-sql-server-admins"
  owners = toset([
    data.azuread_client_config.current.object_id,
  ])
  security_enabled = true

  # uncomment this if you have AAD premium enabled in your Azure subscription
  # https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept
  # assignable_to_role = true

  members = toset([
    data.azuread_client_config.current.object_id,
    azuread_service_principal.spomop.id,
    azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
  ])
}

# This AAD Group is for Directory Readers.  You can add in the Azure SQL Server Managed Identity as a separate step.
# https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group
resource "azuread_group" "directoryreadersaadgroup" {
  display_name  = "${var.prefix}-${var.environment}-omop-sql-server-directory-readers"
  mail_nickname = "${var.prefix}-${var.environment}-omop-sql-server-directory-readers"
  owners = toset([
    data.azuread_client_config.current.object_id,
  ])
  security_enabled = true

  # You need AAD premium enabled in your Azure subscription to assign a role to the group
  # https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept
  assignable_to_role = true

  members = toset([
    data.azuread_client_config.current.object_id,
  ])
}

#############################
# Uncomment the following section if you have AAD premium enabled in your Azure subscription
# The following section will allow you to assign Directory Reader to your Azure AD group
# https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept
# Look to add in Directory Reader to your Azure AD Group: https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial#assign-directory-readers-permission-to-the-sql-logical-server-identity
#############################

# resource "azuread_directory_role" "directoryreaders" {
#   display_name = "Directory Readers"
# }

# resource "azuread_directory_role_member" "directoryreadersmember" {
#   role_object_id   = azuread_directory_role.directoryreaders.object_id
#   member_object_id = azuread_group.directoryreadersaadgroup.object_id
# }