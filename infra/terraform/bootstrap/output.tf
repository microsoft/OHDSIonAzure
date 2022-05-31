output "vmss_public_ip_fqdn" {
  value     = azurerm_public_ip.vmss.fqdn
  sensitive = true
}

output "jumpbox_public_ip_fqdn" {
  value     = azurerm_public_ip.jumpbox.fqdn
  sensitive = true
}

output "jumpbox_public_ip" {
  value     = azurerm_public_ip.jumpbox.ip_address
  sensitive = true
}

output "vmssElasticPoolId" {
  value = module.azure_devops_elastic_pool_linux_vmss_pool.vmssElasticPoolId
}

output "vmssAgentPoolId" {
  value = module.azure_devops_elastic_pool_linux_vmss_pool.vmssAgentPoolId
}

output "vmssAgentQueueId" {
  value = module.azure_devops_elastic_pool_linux_vmss_pool.vmssAgentQueueId
}

output "adoEnvironmentPipelineIds" {
  value = module.azure_devops_environment_tf_plan_pipeline_assignment.azure_devops_environment_authorized_pipeline_ids
}