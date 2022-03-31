resource_group_name = "myAdoResourceGroup"
environment         = "dev"

location = "westus3"

tags = {
  "Deployment"  = "OHDSI on Azure"
  "Environment" = "dev"
}

admin_user_jumpbox     = "azureuser"
admin_password_jumpbox = "<my-jumpbox-password>"

admin_user     = "azureuser"
admin_password = "<my-password>"

org_service_url  = "https://dev.azure.com/my-org/"
ado_project_name = "my-project"
ado_repo_name    = "OHDSIonAzure"
ado_pat          = "<my-ado-pat>"

tf_environment_build_pipeline_name = "TF OMOP Environment Pipeline"
vocabulary_build_pipeline_name     = "Vocabulary Build Pipeline"
vocabulary_release_pipeline_name   = "Vocabulary Release Pipeline"
broadsea_build_pipeline_name       = "Broadsea Build Pipeline"
broadsea_release_pipeline_name     = "Broadsea Release Pipeline"

environment_pipeline_path        = "/pipelines/environments/TF-OMOP.yaml"
vocabulary_build_pipeline_path   = "/pipelines/vocabulary_build_pipeline.yaml"
vocabulary_release_pipeline_path = "/pipelines/vocabulary_release_pipeline.yaml"
broadsea_build_pipeline_path     = "/pipelines/broadsea_build_pipeline.yaml"
broadsea_release_pipeline_path   = "/pipelines/broadsea_release_pipeline.yaml"

azure_subscription_name = "my Azure subscription name"

#### Azure SQL
omop_db_size = 100
omop_db_sku  = "GP_Gen5_8"

#### Azure VMSS Settings
azure_vmss_sku       = "Standard_D4s_v3"
azure_vmss_instances = 2

azure_windows_vmss_sku       = "Standard_D4s_v3"
azure_windows_vmss_instances = 1

# Azure DevOps Linux VMSS Agent Pool Settings
ado_linux_vmss_agent_pool_settings = {
  max_capacity           = 2       # Azure VMSS Max Capacity
  desired_size           = 1       # Azure VMSS desired size
  desired_idle           = 1       # Azure VMSS desired idle
  time_to_live_minutes   = 30      # Azure VMSS time to live in minutes
  recycle_after_each_use = false   # Azure VMSS recycle after each use
  ostype                 = "linux" # Azure VMSS ostype e.g. linux
}

# Azure DevOps Windows VMSS Agent Pool Settings
ado_windows_vmss_agent_pool_settings = {
  max_capacity           = 2         # Azure VMSS Max Capacity
  desired_size           = 1         # Azure VMSS desired size
  desired_idle           = 1         # Azure VMSS desired idle
  time_to_live_minutes   = 30        # Azure VMSS time to live in minutes
  recycle_after_each_use = false     # Azure VMSS recycle after each use
  ostype                 = "windows" # Azure VMSS ostype e.g. linux
}

#### ACR
acr_sku_edition = "Premium" # Network_rule_set_set can only be specified for a Premium Sku, the default is Standard sku and we are currently overriding this with Premium

#### Application Service Plan
asp_kind_edition = "Linux"
asp_sku_tier     = "PremiumV2" #In the dedicated compute tiers (Basic, Standard, Premium, PremiumV2)
asp_sku_size     = "P2V2"      # TODO: Check P2V2