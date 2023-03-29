# Workaround: TF doesn't have the Azure DevOps 6.1 API so this is a placeholder until the TF provider is updated
# https://github.com/MicrosoftDocs/vsts-rest-api-specs/tree/master/specification/distributedTask/6.1

data "external" "azure_devops_environment_pipeline_assignment" {
  program = ["bash", "${path.module}/azure_devops_environment_pipeline_assignment.sh"]
  query = {
    pat              = var.ado_pat
    adoProjectName   = var.ado_project_name
    adoOrgServiceUrl = var.ado_org_service_url
    adoEnvironmentId = var.ado_environment_id
    adoPipelineId    = var.ado_pipeline_id
    authorized       = var.authorized
  }
  depends_on = [
    var.ado_pipeline_id,   # your Azure DevOps pipeline is available
    var.ado_environment_id # your Azure DevOps environment is available
  ]
}

resource "null_resource" "azure_devops_environment_pipeline_assignment_remove" {
  triggers = {
    ado_pat             = var.ado_pat
    ado_project_name    = var.ado_project_name
    ado_org_service_url = var.ado_org_service_url
    ado_environment_id  = var.ado_environment_id
    ado_pipeline_id     = var.ado_pipeline_id
  }
  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/azure_devops_environment_pipeline_assignment.sh > azure_devops_environment_pipeline_assignment.txt"
    # Use environment variables for script
    environment = {
      PAT                 = self.triggers.ado_pat
      ADO_ORG_SERVICE_URL = self.triggers.ado_org_service_url
      ADO_PROJECT_NAME    = self.triggers.ado_project_name
      ENVIRONMENT_ID      = self.triggers.ado_environment_id
      PIPELINE_ID         = self.triggers.ado_pipeline_id
      AUTHORIZED          = false
    }
  }
}
