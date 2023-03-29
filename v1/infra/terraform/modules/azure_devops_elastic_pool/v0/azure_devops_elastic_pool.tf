# Workaround: TF doesn't have the Azure DevOps 6.1 API so this is a placeholder until the TF provider is updated
# https://github.com/MicrosoftDocs/vsts-rest-api-specs/tree/master/specification/distributedTask/6.1

data "external" "AddVMSSAgentPool" {
  program = ["bash", "${path.module}/VMSSAgentPoolCreate.sh"]
  query = {
    pat                 = var.ado_pat
    poolname            = var.ado_agent_pool_name
    adoOrgServiceUrl    = var.ado_org_service_url
    projectId           = var.ado_project_id
    serviceEndpointId   = var.ado_service_endpoint_id
    resourceId          = var.ado_vmss_resource_id
    osType              = var.ado_vmss_os_type
    maxCapacity         = var.ado_vmss_max_capacity
    desiredIdle         = var.ado_vmss_desired_idle
    recycleAfterEachUse = var.ado_vmss_recycle_after_each_use
    desiredSize         = var.ado_vmss_desired_size
    timeToLiveMinutes   = var.ado_vmss_time_to_live_minutes
  }
  depends_on = [
    var.ado_vmss_resource_id,   # you have your Azure VMSS available
    var.ado_service_endpoint_id # you have provisioned your Azure DevOps Service Endpoint
  ]
}

resource "null_resource" "RemoveVMSSAgentPool" {
  triggers = {
    ado_pat             = var.ado_pat
    ado_agent_pool_name = var.ado_agent_pool_name
    ado_org_service_url = var.ado_org_service_url
  }
  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/VMSSAgentPoolDestroy.sh"
    # Use environment variables for script
    environment = {
      PAT                 = self.triggers.ado_pat
      POOLNAME            = self.triggers.ado_agent_pool_name
      ADO_ORG_SERVICE_URL = self.triggers.ado_org_service_url
    }
  }
}

