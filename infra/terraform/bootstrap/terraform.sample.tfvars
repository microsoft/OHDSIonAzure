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

environment_pipeline_path        = "/pipelines/environments/TF-OMOP.yaml"
vocabulary_build_pipeline_path   = "/pipelines/vocabulary_build_pipeline.yaml"
vocabulary_release_pipeline_path = "/pipelines/vocabulary_release_pipeline.yaml"
broadsea_build_pipeline_path     = "/pipelines/broadsea_build_pipeline.yaml"
broadsea_release_pipeline_path   = "/pipelines/broadsea_release_pipeline.yaml"

azure_subscription_name = "my Azure subscription name"

#### Azure SQL
omop_db_size = 100
omop_db_sku  = "GP_Gen5_8"

#### ACR
acr_sku_edition = "Premium" # Network_rule_set_set can only be specified for a Premium Sku, the default is Standard sku and we are currently overriding this with Premium

#### Application Service Plan
asp_kind_edition = "Linux"
asp_sku_tier     = "PremiumV2" #In the dedicated compute tiers (Basic, Standard, Premium, PremiumV2)
asp_sku_size     = "P2V2"      # TODO: Check P2V2