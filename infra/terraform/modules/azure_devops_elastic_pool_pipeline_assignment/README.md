# Azure DevOps Elastic Pools Pipeline Assignment

This module is a workaround as the Azure DevOps Terraform provider doesn't include the Azure DevOps [7.1 API](https://github.com/MicrosoftDocs/vsts-rest-api-specs/tree/master/specification/distributedTask/7.1).

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
```

You can also destroy the assignment using something like this:

```bash
terraform destroy --target module.azure_devops_elastic_pool_for_pipeline_assignment.null_resource.azure_devops_elastic_pool_pipeline_assignment_remove
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
| authorized | bool | `false` | Whether to authorize your [Azure DevOps Pipeline](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops) to use an [Azure DevOps Environment](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops), defaults to `false`. |
| ado_queue_id | string | `3` | Your Azure DevOps Agent Pool id, check under `https://dev.azure.com/<my-org>/<my-project>/_settings/agentqueues` to find your Agent Pool. |
| ado_pipeline_id | string | `5` | Your Azure DevOps Pipeline id, check under `https://dev.azure.com/<my-org>/<my-project>/_build`. |
| ado_project_name | string | `my-project` | Azure DevOps Project Name which hosts the Azure DevOps environment and the Azure DevOps pipeline, e.g. for the URL https://dev.azure.com/my-org/my-project you will provide `my-project`. |
| ado_org_service_url | string | `https://dev.azure.com/my-org` | Azure DevOps Organization URL e.g. `https://dev.azure.com/my-org` for your Azure DevOps environment. |
| ado_pat | sensitive string | `my-PAT` | Azure DevOps PAT which will be used to provision the Azure DevOps environment. |
