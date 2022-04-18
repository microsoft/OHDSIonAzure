#############################
# Import Azure DevOps Build Pipelines
# Environment Pipeline
#############################
resource "azuredevops_build_definition" "environmentpipeline" {
  project_id = azuredevops_project.project.id
  name       = var.tf_environment_build_pipeline_name
  path       = "\\OHDSIOnAzure\\${var.prefix}-${var.environment}\\Terraform"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.environment_pipeline_path
  }

  # map variable groups to pipeline
  variable_groups = [
    azuredevops_variable_group.adobootstrapvg.id,
    azuredevops_variable_group.adobootstrapsettingsvg.id
  ]
}

module "azure_devops_elastic_pool_for_environment_pipeline_assignment" {
  source              = "../modules/azure_devops_elastic_pool_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_queue_id        = module.azure_devops_elastic_pool_linux_vmss_pool.vmssAgentQueueId
  ado_pipeline_id     = azuredevops_build_definition.environmentpipeline.id

  depends_on = [
    module.azure_devops_elastic_pool_linux_vmss_pool,
    azuredevops_build_definition.environmentpipeline
  ]
}

#############################
# Import Azure DevOps Build Pipelines
# Vocabulary Build Pipeline
#############################
resource "azuredevops_build_definition" "vocabularybuildpipeline" {
  project_id = azuredevops_project.project.id
  name       = var.vocabulary_build_pipeline_name
  path       = "\\OHDSIOnAzure\\${var.prefix}-${var.environment}\\Vocabulary"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.vocabulary_build_pipeline_path
  }

  # map variable groups to pipeline
  variable_groups = [
    azuredevops_variable_group.adoenvvg.id
  ]
}

module "azure_devops_elastic_pool_for_vocabulary_build_pipeline_assignment" {
  source              = "../modules/azure_devops_elastic_pool_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_queue_id        = module.azure_devops_elastic_pool_windows_vmss_pool.vmssAgentQueueId
  ado_pipeline_id     = azuredevops_build_definition.vocabularybuildpipeline.id

  depends_on = [
    module.azure_devops_elastic_pool_windows_vmss_pool,
    azuredevops_build_definition.vocabularybuildpipeline
  ]
}


#############################
# Import Azure DevOps Build Pipelines
# Vocabulary Release Pipeline
#############################
resource "azuredevops_build_definition" "vocabularyreleasepipeline" {
  project_id = azuredevops_project.project.id
  name       = var.vocabulary_release_pipeline_name
  path       = "\\OHDSIOnAzure\\${var.prefix}-${var.environment}\\Vocabulary"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.vocabulary_release_pipeline_path
  }

  # map variable groups to pipeline
  variable_groups = [
    azuredevops_variable_group.adoenvvg.id
  ]

  variable {
    name = "vocabularyBuildPipelineId"
    value = azuredevops_build_definition.vocabularybuildpipeline.id
  }

  depends_on = [
    azuredevops_build_definition.vocabularybuildpipeline
  ]
}

module "azure_devops_elastic_pool_for_vocabulary_release_pipeline_assignment" {
  source              = "../modules/azure_devops_elastic_pool_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_queue_id        = module.azure_devops_elastic_pool_linux_vmss_pool.vmssAgentQueueId
  ado_pipeline_id     = azuredevops_build_definition.vocabularyreleasepipeline.id

  depends_on = [
    module.azure_devops_elastic_pool_linux_vmss_pool,
    azuredevops_build_definition.vocabularyreleasepipeline
  ]
}

#############################
# Import Azure DevOps Build Pipelines
# Broadsea Build Pipeline
#############################
resource "azuredevops_build_definition" "broadseabuildpipeline" {
  project_id = azuredevops_project.project.id
  name       = var.broadsea_build_pipeline_name
  path       = "\\OHDSIOnAzure\\${var.prefix}-${var.environment}\\Broadsea"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.broadsea_build_pipeline_path
  }

  # map variable groups to pipeline
  variable_groups = [
    azuredevops_variable_group.adoenvvg.id
  ]
}

module "azure_devops_elastic_pool_for_broadsea_build_pipeline_assignment" {
  source              = "../modules/azure_devops_elastic_pool_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_queue_id        = module.azure_devops_elastic_pool_linux_vmss_pool.vmssAgentQueueId
  ado_pipeline_id     = azuredevops_build_definition.broadseabuildpipeline.id

  depends_on = [
    module.azure_devops_elastic_pool_linux_vmss_pool,
    azuredevops_build_definition.broadseabuildpipeline
  ]
}

#############################
# Import Azure DevOps Build Pipelines
# Broadsea Release Pipeline
#############################
resource "azuredevops_build_definition" "broadseareleasepipeline" {
  project_id = azuredevops_project.project.id
  name       = var.broadsea_release_pipeline_name
  path       = "\\OHDSIOnAzure\\${var.prefix}-${var.environment}\\Broadsea"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = var.broadsea_release_pipeline_path
  }

  # map variable groups to pipeline
  variable_groups = [
    azuredevops_variable_group.adoenvvg.id
  ]

  variable {
    name = "broadseaBuildPipelineId"
    value = azuredevops_build_definition.broadseabuildpipeline.id
  }

  depends_on = [
    azuredevops_build_definition.broadseabuildpipeline
  ]
}

module "azure_devops_elastic_pool_for_broadsea_releasepipeline_assignment" {
  source              = "../modules/azure_devops_elastic_pool_pipeline_assignment"
  authorized          = true
  ado_org_service_url = var.ado_org_service_url
  ado_pat             = var.ado_pat
  ado_project_name    = azuredevops_project.project.name
  ado_queue_id        = module.azure_devops_elastic_pool_linux_vmss_pool.vmssAgentQueueId
  ado_pipeline_id     = azuredevops_build_definition.broadseareleasepipeline.id

  depends_on = [
    module.azure_devops_elastic_pool_linux_vmss_pool,
    azuredevops_build_definition.broadseareleasepipeline
  ]
}