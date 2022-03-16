prefix              = "sharing"
resource_group_name = "myAdoResourceGroup"

location = "westus3"

tags = {
  "Deployment"  = "OHDSI on Azure"
  "Environment" = "dev"
}

application_port = 80
admin_user       = "azureuser"
admin_password   = "replaceP@SSW0RD"

ado_org_service_url = "https://dev.azure.com/US-HLS-AppInnovations"
ado_project_name    = "OHDSIonAzure"
ado_repo_name       = "OHDSIonAzure"
ado_pat             = "h7xh4o63jr53j2zuggw276dikuzkzahakmzq3hemq4xoaojoj3ia"

environment_pipeline_path = "/pipelines/environments/TF-OMOP.yaml"
vocabulary_build_pipeline_path = "/pipelines/vocabulary_build_pipeline.yaml"
vocabulary_release_pipeline_path = "/pipelines/vocabulary_release_pipeline.yaml"
broadsea_build_pipeline_path = "/pipelines/broadsea_build_pipeline.yaml"
broadsea_release_pipeline_path = "/pipelines/broadsea_release_pipeline.yaml"

azure_subscription_name   = "US HLS External Demo Sub"