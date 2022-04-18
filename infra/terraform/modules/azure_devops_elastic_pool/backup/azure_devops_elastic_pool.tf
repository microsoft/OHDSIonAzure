# # Workaround: TF doesn't have the Azure DevOps 6.1 API so this is a placeholder until the TF provider is updated
# # https://github.com/MicrosoftDocs/vsts-rest-api-specs/tree/master/specification/distributedTask/6.1

# data "external" "AddVMSSAgentPool" {
#   program = ["bash","${path.module}/VMSSAgentPoolCreate2.sh"]
#   query = {
#       pat                    = var.ado_pat
#       poolname               = var.ado_agent_pool_name
#       adoOrgServiceUrl    = var.ado_org_service_url
#       projectId             = var.ado_project_id
#       serviceEndpointId    = var.ado_service_endpoint_id
#       resourceId            = var.ado_vmss_resource_id
#       osType                = var.ado_vmss_os_type
#       maxCapacity           = var.ado_vmss_max_capacity
#       desiredIdle           = var.ado_vmss_desired_idle
#       recycleAfterEachUse = var.ado_vmss_recycle_after_each_use
#       desiredSize           = var.ado_vmss_desired_size
#       timeToLiveMinutes   = var.ado_vmss_time_to_live_minutes
#   }
#   depends_on = [
#     var.ado_vmss_resource_id,   # you have your Azure VMSS available
#     var.ado_service_endpoint_id # you have provisioned your Azure DevOps Service Endpoint
#   ]
# }

# # resource "null_resource" "AddVMSSAgentPool" {
# #   provisioner "local-exec" {
# #     # command = "${path.module}/VMSSAgentPoolCreate.sh > ${path.module}/vmssAgentPoolCreate.txt && tail -n 1 ${path.module}/vmssAgentPoolCreate.txt > ${path.module}/tailVmssAgentPoolCreate.txt"
# #     command = "echo add vmss agent pool script commented"
# #     # Use environment variables for script
# #     environment = {
# #       PAT                    = self.triggers.ado_pat
# #       POOLNAME               = self.triggers.ado_agent_pool_name
# #       ADO_ORG_SERVICE_URL    = self.triggers.ado_org_service_url
# #       PROJECT_ID             = self.triggers.ado_project_id
# #       SERVICE_ENDPOINT_ID    = self.triggers.ado_service_endpoint_id
# #       RESOURCE_ID            = self.triggers.ado_vmss_resource_id
# #       OS_TYPE                = self.triggers.ado_vmss_os_type
# #       MAX_CAPACITY           = self.triggers.ado_vmss_max_capacity
# #       DESIRED_IDLE           = self.triggers.ado_vmss_desired_idle
# #       RECYCLE_AFTER_EACH_USE = self.triggers.ado_vmss_recycle_after_each_use
# #       DESIRED_SIZE           = self.triggers.ado_vmss_desired_size
# #       TIME_TO_LIVE_MINUTES   = self.triggers.ado_vmss_time_to_live_minutes
# #     }
# #   }
# #   triggers = {
# #     always_run                      = "${timestamp()}" # force creation to always run
# #     ado_pat                         = var.ado_pat
# #     ado_agent_pool_name             = var.ado_agent_pool_name
# #     ado_org_service_url             = var.ado_org_service_url
# #     ado_project_id                  = var.ado_project_id
# #     ado_service_endpoint_id         = var.ado_service_endpoint_id
# #     ado_vmss_resource_id            = var.ado_vmss_resource_id
# #     ado_vmss_os_type                = var.ado_vmss_os_type
# #     ado_vmss_max_capacity           = var.ado_vmss_max_capacity
# #     ado_vmss_desired_idle           = var.ado_vmss_desired_idle
# #     ado_vmss_recycle_after_each_use = var.ado_vmss_recycle_after_each_use
# #     ado_vmss_desired_size           = var.ado_vmss_desired_size
# #     ado_vmss_time_to_live_minutes   = var.ado_vmss_time_to_live_minutes
# #   }
# #   depends_on = [
# #     var.ado_vmss_resource_id,   # you have your Azure VMSS available
# #     var.ado_service_endpoint_id # you have provisioned your Azure DevOps Service Endpoint
# #   ]
# # }

# resource "null_resource" "RemoveVMSSAgentPool" {
#   triggers = {
#     ado_pat             = var.ado_pat
#     ado_agent_pool_name = var.ado_agent_pool_name
#     ado_org_service_url = var.ado_org_service_url
#   }
#   provisioner "local-exec" {
#     when = destroy
#     command = "${path.module}/VMSSAgentPoolDestroy.sh"
#     # Use environment variables for script
#     environment = {
#       PAT                 = self.triggers.ado_pat
#       POOLNAME            = self.triggers.ado_agent_pool_name
#       ADO_ORG_SERVICE_URL = self.triggers.ado_org_service_url
#     }
#   }
# }

# # resource "null_resource" "contents_if_missing" {
# #   depends_on = [
# #     null_resource.AddVMSSAgentPool
# #   ]

# #   lifecycle {
# #     ignore_changes = [
# #       triggers
# #     ]
# #   }

# #   triggers = {
# #     vmssAgentPoolCreate = fileexists("${path.module}/tailVmssAgentPoolCreate.txt") ? chomp(file("${path.module}/tailVmssAgentPoolCreate.txt")) : null
# #     vmssAgentPoolId = fileexists("${path.module}/tailVmssAgentPoolCreate.txt") ? jsondecode(chomp(file("${path.module}/tailVmssAgentPoolCreate.txt"))).elasticPool.poolId : null
# #   }
# # }

# # resource "null_resource" "contents" {
# #   depends_on = [
# #     null_resource.contents_if_missing
# #   ]
# #   triggers = {
# #     # when the shell resource changes (var.trigger etc), this causes evaluation to happen after
# #     # using depends_on would be true for the subsequent apply causing terraform to explode
# #     id = null_resource.AddVMSSAgentPool.id

# #     # the lookup values are actually never returned, they just need to be there (!)
# #     vmssAgentPoolCreate = fileexists("${path.module}/tailVmssAgentPoolCreate.txt") ? chomp(file("${path.module}/tailVmssAgentPoolCreate.txt")) : (null_resource.contents_if_missing.triggers == null ? "" : lookup(null_resource.contents_if_missing.triggers, "vmssAgentPoolCreate", ""))
# #     vmssAgentPoolId = fileexists("${path.module}/tailVmssAgentPoolCreate.txt") ? jsondecode(chomp(file("${path.module}/tailVmssAgentPoolCreate.txt"))).elasticPool.poolId : (null_resource.contents_if_missing.triggers == null ? "" : lookup(null_resource.contents_if_missing.triggers, "vmssAgentPoolId", ""))
# #   }
# # }