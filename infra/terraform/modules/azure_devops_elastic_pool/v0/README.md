# Azure DevOps Elastic Pools

This module is a workaround as the Azure DevOps Terraform provider doesn't include the Azure DevOps [6.1 API](https://github.com/MicrosoftDocs/vsts-rest-api-specs/tree/master/specification/distributedTask/6.1).

Using scripts is a placeholder until the TF provider is updated.

## Basic Usage

This module is a wrapper around the [script](/infra/terraform/modules/azure_devops_elastic_pool_pipeline_assignment/azure_devops_elastic_pool_pipeline_assignment.sh) which will let you authorize an [Azure DevOps VMSS Agent Pools](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?&view=azure-devops) for an [Azure DevOps Pipeline](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops).

```hcl
module "azure_devops_elastic_pool_for_pipeline_assignment" {
  source              = "modules/azure_devops_elastic_pool_pipeline_assignment"
  authorized          = true
  ado_org_service_url = "https://dev.azure.com/my-org/"
  ado_pat             = "my-ado-pat"
  ado_project_name    = "my-ado-project"
  ado_queue_id        = 3 # assuming you have setup your Azure DevOps VMSS Agent Pool and its id is 3 
  ado_pipeline_id     = 5 # Assuming you have setup a build definition 
}

module "azure_devops_elastic_pool_linux_vmss_pool" {
  source                          = "modules/azure_devops_elastic_pool/v0"
  ado_agent_pool_name             = "my-ado-build-linux-vmss-agent-pool"
  ado_org_service_url             = "https://dev.azure.com/my-org/"
  ado_pat                         = "my-ado-pat"
  ado_project_id                  = "my-project-id" # a guid for your Azure DevOps project
  ado_vmss_resource_id            = "/subscriptions/<my-sub-id>/resourceGroups/my-ado-bootstrap-omop-rg/providers/Microsoft.Compute/virtualMachineScaleSets/my-ado-build-linux-vmss-agent"
  ado_service_endpoint_id         = "my-service-endpoint-id" # a guid for your Azure DevOps Service Endpoint
  ado_vmss_max_capacity           = 2 # Set your max capacity for your Azure VMSS pool
  ado_vmss_desired_size           = 1 # Set your desired size for your Azure VMSS pool
  ado_vmss_desired_idle           = 1 # Set your desired idle for your Azure VMSS pool
  ado_vmss_time_to_live_minutes   = 30 # Set the time to live in minutes for your Azure VMSS instances
  ado_vmss_recycle_after_each_use = false # Set whether you should recycle the Azure VMSS instance after each use
  ado_vmss_os_type                = "linux" # set to 'linux' for linux
}

```

You can also destroy the assignment using something like this:

```bash
terraform destroy --target module.azure_devops_elastic_pool_linux_vmss_pool.null_resource.RemoveVMSSAgentPool
```

You will need to ensure that you can successfully `terraform init` from the root of your project to pull in this module.

## How to configure

1. Make sure you have [setup your Azure DevOps provider](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/guides/authenticating_using_the_personal_access_token#configure-environment-variables)
    * Ensure that your Azure DevOps PAT also has the following permissions:
        * Agent Pools: Read & Manage
        * Build: Read & Manage

2. Ensure that you have the following variables for use with the module:

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| ado_agent_pool_name | string | `my-ado-vmss-agent-pool` | Set the name for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| ado_project_id | string | `some-guid` | Your Azure DevOps Project Id, you can also pass in your Azure DevOps project name e.g. if your project is hosted at `https://dev.azure.com/<my-org>/<my-project>` you ca specify `my-project`. |
| ado_vmss_resource_id | string | `/subscriptions/<my-sub-id>/resourceGroups/my-ado-bootstrap-omop-rg/providers/Microsoft.Compute/virtualMachineScaleSets/my-ado-build-linux-vmss-agent` | Your Azure DevOps Project Id, you can also pass in your Azure DevOps project name e.g. if your project is hosted at `https://dev.azure.com/<my-org>/<my-project>` you can specify `my-project`. |
| ado_service_endpoint_id | string | `some-guid` | Your Azure DevOps Service Endpoint Id, check under `https://dev.azure.com/<my-org>/<my-project>/_settings/adminservices` to find your specific Service Endpoint, and then you can check for your resource id under `https://dev.azure.com/<my-org>/<my-project>/_settings/adminservices?resourceId=some-guid`. |
| ado_vmss_max_capacity | number | `2` | Set your max capacity for your Azure VMSS Agent Pool. |
| ado_vmss_desired_size | number | `1` | Set your desired size for your Azure VMSS Agent Pool. |
| ado_vmss_desired_idle | number | `1` | Set your desired idle for your Azure VMSS Agent Pool. |
| ado_vmss_time_to_live_minutes | number | `30` | Set your time to live in minutes for your Azure VMSS Agent Pool instances. |
| ado_vmss_recycle_after_each_use | bool | `false` | Set whether to recycle each VMSS instance after each use for your Azure VMSS Agent Pool. |
| ado_vmss_os_type | string | `linux` | Set to either `linux` for [Azure Linux VMSS](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-create-vmss) or `windows` for [Azure Windows VMSS](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-create-vmss) for your Azure VMSS Agent Pool. |
| ado_pipeline_id | string | `5` | Your Azure DevOps Pipeline id, check under `https://dev.azure.com/<my-org>/<my-project>/_build`. |
| ado_project_name | string | `my-project` | Azure DevOps Project Name which hosts the Azure DevOps environment and the Azure DevOps pipeline, e.g. for the URL https://dev.azure.com/my-org/my-project you will provide `my-project`. |
| ado_org_service_url | string | `https://dev.azure.com/my-org` | Azure DevOps Organization URL e.g. `https://dev.azure.com/my-org` for your Azure DevOps environment. |
| ado_pat | sensitive string | `my-PAT` | Azure DevOps PAT which will be used to provision the Azure DevOps environment. |
