#############################
# Azure DevOps Settings
# Used for SP Service connection
#############################

# You can also use terraform import azuredevops_project.project "OHDSIonAzure"
resource "azuredevops_project" "project" {
  # name = "OHDSIonAzure"
  name               = "${var.prefix}-${var.environment}-OHDSIonAzure"
  description        = "AzDevOps OHDSI on Azure bootstrap project"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  lifecycle {
    prevent_destroy = true # prevent destroying the project
    ignore_changes = [
      # Ignore changes to visibility and work_item_template to support importing existing projects
      # Given that a project now exists, either imported into terraform state or created by terraform,
      # we don't care for the configuration of visibility and work_item_template against the existing resource
      visibility,
      work_item_template,
    ]
  }
}

# you can import the repo
# terraform import azuredevops_git_repository.repo projectName/repoName
# e.g. terraform import azuredevops_git_repository.repo OHDSIonAzure/OHDSIonAzure
resource "azuredevops_git_repository" "repo" {
  project_id = azuredevops_project.project.id
  name       = "OHDSIonAzure" # keep this if you are just importing an existing repository according to the name
  # name       = "${var.prefix}-${var.environment}-OHDSIonAzure" # you have an option to rename the repository

  # Comment this out if you want to make a new repo
  # initialization {
  #   init_type = "Uninitialized"
  # }
  # Use Terraform import instead, otherwise this resource will destroy the existing repository.
  lifecycle {
    prevent_destroy = true # prevent destroying the repo
    ignore_changes = [
      # Ignore changes to initialization to support importing existing repositories
      # Given that a repo now exists, either imported into terraform state or created by terraform,
      # we don't care for the configuration of initialization against the existing resource
      initialization, # comment this out if you are making a new repo (and want to import from an existing repository)
    ]
  }

  ## Uncomment this section to import the contents of another git repo into this repo
  initialization {
    init_type   = "Import"
    source_type = "Git"
    # you can import from an existing ADO repository
    # source_url            = "${var.ado_org_service_url}/${var.ado_project_name}/_git/${var.ado_repo_name}" # you can import from an existing ADO repository
    # service_connection_id = azuredevops_serviceendpoint_generic_git.serviceendpoint.id

    # You can import from a public repository
    source_url = "https://github.com/microsoft/OHDSIonAzure.git"
  }
}

# Include if you want to import from an existing repository using a service endpoint to authenticate to the repo
resource "azuredevops_serviceendpoint_generic_git" "serviceendpoint" {
  project_id            = azuredevops_project.project.id
  repository_url        = "${var.ado_org_service_url}/${var.ado_project_name}/_git/${var.ado_repo_name}"
  username              = ""
  password              = var.ado_pat
  service_endpoint_name = "${var.prefix}-${var.environment} Sample Generic Git"
  description           = "Managed by Terraform"
}

#############################
# Azure DevOps Agent Pool
#############################

module "azure_devops_elastic_pool_linux_vmss_pool" {
  source                          = "../modules/azure_devops_elastic_pool/v0"
  ado_agent_pool_name             = "${var.prefix}-${var.environment}-ado-build-linux-vmss-agent-pool"
  ado_org_service_url             = var.ado_org_service_url
  ado_pat                         = var.ado_pat
  ado_project_id                  = azuredevops_project.project.id
  ado_vmss_resource_id            = azurerm_linux_virtual_machine_scale_set.vmss.id
  ado_service_endpoint_id         = azuredevops_serviceendpoint_azurerm.endpointazure.id
  ado_vmss_max_capacity           = var.ado_linux_vmss_agent_pool_settings.max_capacity
  ado_vmss_desired_size           = var.ado_linux_vmss_agent_pool_settings.desired_size
  ado_vmss_desired_idle           = var.ado_linux_vmss_agent_pool_settings.desired_idle
  ado_vmss_time_to_live_minutes   = var.ado_linux_vmss_agent_pool_settings.time_to_live_minutes
  ado_vmss_recycle_after_each_use = var.ado_linux_vmss_agent_pool_settings.recycle_after_each_use
  ado_vmss_os_type                = var.ado_linux_vmss_agent_pool_settings.ostype

  depends_on = [
    azurerm_linux_virtual_machine_scale_set.vmss,
    azuredevops_serviceendpoint_azurerm.endpointazure
  ]
}

module "azure_devops_elastic_pool_windows_vmss_pool" {
  source                          = "../modules/azure_devops_elastic_pool/v0"
  ado_agent_pool_name             = "${var.prefix}-${var.environment}-ado-build-windows-vmss-agent-pool"
  ado_org_service_url             = var.ado_org_service_url
  ado_pat                         = var.ado_pat
  ado_project_id                  = azuredevops_project.project.id
  ado_vmss_resource_id            = azurerm_windows_virtual_machine_scale_set.vmss.id
  ado_service_endpoint_id         = azuredevops_serviceendpoint_azurerm.endpointazure.id
  ado_vmss_max_capacity           = var.ado_windows_vmss_agent_pool_settings.max_capacity
  ado_vmss_desired_size           = var.ado_windows_vmss_agent_pool_settings.desired_size
  ado_vmss_desired_idle           = var.ado_windows_vmss_agent_pool_settings.desired_idle
  ado_vmss_time_to_live_minutes   = var.ado_windows_vmss_agent_pool_settings.time_to_live_minutes
  ado_vmss_recycle_after_each_use = var.ado_windows_vmss_agent_pool_settings.recycle_after_each_use
  ado_vmss_os_type                = var.ado_windows_vmss_agent_pool_settings.ostype

  depends_on = [
    azurerm_windows_virtual_machine_scale_set.vmss,
    azuredevops_serviceendpoint_azurerm.endpointazure
  ]
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

module "azure_devops_environment_vocabulary_build" {
  source              = "../modules/azure_devops_environment"
  environment_name    = "${var.prefix}-${var.environment}-omop-vocabulary-build-environment"
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_id      = azuredevops_project.project.id
}

module "azure_devops_environment_vocabulary_release" {
  source              = "../modules/azure_devops_environment"
  environment_name    = "${var.prefix}-${var.environment}-omop-vocabulary-release-environment"
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_id      = azuredevops_project.project.id
}

module "azure_devops_environment_broadsea_build" {
  source              = "../modules/azure_devops_environment"
  environment_name    = "${var.prefix}-${var.environment}-omop-broadsea-build-environment"
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_id      = azuredevops_project.project.id
}

module "azure_devops_environment_broadsea_release" {
  source              = "../modules/azure_devops_environment"
  environment_name    = "${var.prefix}-${var.environment}-omop-broadsea-release-environment"
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_id      = azuredevops_project.project.id
}

module "azure_devops_environment_tf_plan_pipeline_assignment" {
  source              = "../modules/azure_devops_environment_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_environment_id  = module.azure_devops_environment_tf_plan.azure_devops_environment_id
  ado_pipeline_id     = azuredevops_build_definition.tfapplyenvironmentpipeline.id
}

module "azure_devops_environment_tf_apply_pipeline_assignment" {
  source              = "../modules/azure_devops_environment_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_environment_id  = module.azure_devops_environment_tf_apply.azure_devops_environment_id
  ado_pipeline_id     = azuredevops_build_definition.tfapplyenvironmentpipeline.id
}

module "azure_devops_environment_tf_destroy_pipeline_assignment" {
  source              = "../modules/azure_devops_environment_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  # Should the ado_environment_id be something else?
  ado_environment_id = module.azure_devops_environment_tf_apply.azure_devops_environment_id
  ado_pipeline_id    = azuredevops_build_definition.tfdestroyenvironmentpipeline.id
}

module "azure_devops_environment_vocabulary_build_pipeline_assignment" {
  source              = "../modules/azure_devops_environment_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_environment_id  = module.azure_devops_environment_vocabulary_build.azure_devops_environment_id
  ado_pipeline_id     = azuredevops_build_definition.vocabularybuildpipeline.id
}

module "azure_devops_environment_vocabulary_release_pipeline_assignment" {
  source              = "../modules/azure_devops_environment_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_environment_id  = module.azure_devops_environment_vocabulary_release.azure_devops_environment_id
  ado_pipeline_id     = azuredevops_build_definition.vocabularyreleasepipeline.id
}

module "azure_devops_environment_broadsea_build_pipeline_assignment" {
  source              = "../modules/azure_devops_environment_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_environment_id  = module.azure_devops_environment_broadsea_build.azure_devops_environment_id
  ado_pipeline_id     = azuredevops_build_definition.broadseabuildpipeline.id
}

module "azure_devops_environment_broadsea_release_pipeline_assignment" {
  source              = "../modules/azure_devops_environment_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_environment_id  = module.azure_devops_environment_broadsea_release.azure_devops_environment_id
  ado_pipeline_id     = azuredevops_build_definition.broadseareleasepipeline.id
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
# Azure DevOps Extensions
#############################

resource "null_resource" "install_tf_ext" {
  provisioner "local-exec" {
    command = "./scripts/install_azdo_ext.sh"
  }
}
