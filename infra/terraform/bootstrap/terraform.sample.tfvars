resource_group_name = "myAdoResourceGroup"

location = "westus3"

tags = {
  "Deployment"  = "OHDSI on Azure"
  "Environment" = "dev"
}

application_port = 80
admin_user       = "azureuser"
admin_password   = "<my-password>"

org_service_url  = "https://dev.azure.com/my-org/"
ado_project_name = "my-project"
ado_repo_name    = "OHDSIonAzure"
ado_pat          = "<my-ado-pat>"

environment_pipeline_path = "/pipelines/environments/TF-OMOP.yaml"
vocabulary_build_pipeline_path = "/pipelines/vocabulary_build_pipeline.yaml"
vocabulary_release_pipeline_path = "/pipelines/vocabulary_release_pipeline.yaml"
broadsea_build_pipeline_path = "/pipelines/broadsea_build_pipeline.yaml"
broadsea_release_pipeline_path = "/pipelines/broadsea_release_pipeline.yaml"

azure_subscription_name   = "my Azure subscription name"