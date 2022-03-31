# TODO: Get Elastic Pool ID, Name, and other attributes
# output "stdout" {
#   value = null_resource.contents.triggers == null ? null : lookup(null_resource.contents.triggers, "vmssAgentPoolCreate", null)
# }

# output "vmssAgentPoolId" {
#   value = null_resource.contents.triggers == null ? null : lookup(null_resource.contents.triggers, "vmssAgentPoolId", null)
# }

output "vmssElasticPoolId" {
  value = data.external.AddVMSSAgentPool.result.elastic_pool_id
}

output "vmssAgentPoolId" {
  value = data.external.AddVMSSAgentPool.result.agent_pool_id
}

output "vmssAgentQueueId" {
  value = data.external.AddVMSSAgentPool.result.agent_queue_id
}