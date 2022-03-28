prefix              = "sharing"
environment         = "dev"
resource_group_name = "myAdoResourceGroup"

location = "westus3"

tags = {
  "Deployment"  = "OHDSI on Azure"
  "Environment" = "dev"
}

admin_user_jumpbox     = "azureuser"
admin_password_jumpbox = "P@$$w0rd1234!"

admin_user     = "azureuser"
admin_password = "replaceP@SSW0RD"

ado_org_service_url = "https://dev.azure.com/US-HLS-AppInnovations"
ado_project_name    = "OHDSIonAzure"
ado_repo_name       = "OHDSIonAzure"
ado_pat             = "someAdoPAT"

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
azure_vmss_sku = "Standard_D4s_v3"
azure_vmss_instances = 2

azure_windows_vmss_sku = "Standard_D4s_v3"
azure_windows_vmss_instances = 1

#### ACR
acr_sku_edition = "Premium" # Network_rule_set_set can only be specified for a Premium Sku, the default is Standard sku and we are currently overriding this with Premium

#### Application Service Plan
asp_kind_edition = "Linux"
asp_sku_tier     = "PremiumV2" #In the dedicated compute tiers (Basic, Standard, Premium, PremiumV2)
asp_sku_size     = "P2V2"      # TODO: Check P2V2