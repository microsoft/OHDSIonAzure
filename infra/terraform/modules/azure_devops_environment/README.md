# Azure DevOps Environment

This module uses the [Azuredevops provider](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/environment) to create an Azure DevOps environment.

## Local Version Usage

While you can use versions >= `0.2.0` for the Azure DevOps provider, you may run into issues where there are fixes available in a prior version (e.g. `0.1.8` for example with Azure DevOps variable groups).  In this case, you may choose to mirror the higher version (`0.2.0`) locally for use with this module.

```bash
# Get a local copy of the Azure DevOps Provider 0.2.0 and refer to it as azuredevops2 within terraform
PLUGIN_PATH=/usr/share/terraform/plugins/registry.terraform.io/microsoft/azuredevops2/0.2.0/linux_amd64
mkdir -p $PLUGIN_PATH
curl -sLo_ 'https://github.com/microsoft/terraform-provider-azuredevops/releases/download/v0.2.0/terraform-provider-azuredevops_0.2.0_linux_amd64.zip'
unzip -p _ 'terraform-provider-azuredevops*' > ${PLUGIN_PATH}/terraform-provider-azuredevops2_v0.2.0
rm _
chmod 755 ${PLUGIN_PATH}/terraform-provider-azuredevops2_v0.2.0
```

With this setup, you can refer to your provider like the following:

```hcl
resource "azuredevops_environment" "adoenvironment" {
  provider = azuredevops2
  ...
```

You will need to ensure that you can successfully from `terraform init` from the root of your project to confirm that are able to run multiple versions of the same provider.

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
