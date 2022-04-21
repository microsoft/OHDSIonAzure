prefix      = "yvonne"
environment = "test"

location = "westus3"

tags = {
  "Deployment"  = "OHDSI on Azure"
  "Environment" = "dev"
}

omop_password = "P@$$w0rd1234!"

admin_user_jumpbox     = "azureuser"
admin_password_jumpbox = "P@$$w0rd1234!"

admin_user     = "azureuser"
admin_password = "replaceP@SSW0RD"

ado_org_service_url = "https://dev.azure.com/US-HLS-AppInnovations"
ado_project_name    = "OHDSIonAzure"
ado_repo_name       = "OHDSIonAzure"
ado_pat             = ""

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

azure_subscription_name = "US HLS External Demo Sub"

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

#### Vocabulary Path

# The name of the blob container in the CDR storage account that will be used for vocabulary file uploads
cdr_vocab_container_name = "vocabularies"

# The path in the vocabulary blob container in the CDR storage account that will be used for vocabulary file uploads.  E.g. if the vocabulries are stored under /vocabularies/19-AUG-2021 you should specify 19-AUG-2021."
cdr_vocab_version = "19-AUG-2021"
