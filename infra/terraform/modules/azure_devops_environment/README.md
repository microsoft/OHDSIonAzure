# Azure DevOps Environment

This module uses the [Azure devops provider](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/environment) to create an Azure DevOps environment.

## Local Version Usage

Ensure that you use the TF Azure DevOps provider with versions >= `0.2.1` as it contains a [401 authorization error fix](https://github.com/microsoft/terraform-provider-azuredevops/issues/541).

You will need to ensure that you can successfully `terraform init` from the root of your project to confirm your Terraform providers are setup correctly.

## How to configure

1. Make sure you have [setup your Azure DevOps provider](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/guides/authenticating_using_the_personal_access_token#configure-environment-variables)
    * Ensure that your Azure DevOps PAT also has the following permissions:
        * Environment: Read & Manage

2. Ensure that you have the following variables for use with the module:

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| environment_name | string | `my-ado-environment` | Desired name for your Azure DevOps environment. |
| ado_project_id | guid | `my-guid` | Azure DevOps Project ID which will host the Azure DevOps environment. |
| ado_org_service_url | string | `https://dev.azure.com/my-org` | Azure DevOps Organization URL e.g. https://dev.azure.com/my-org for your Azure DevOps environment. |
| ado_pat | sensitive string | `my-PAT` | Azure DevOps PAT which will be used to provision the Azure DevOps environment. |
