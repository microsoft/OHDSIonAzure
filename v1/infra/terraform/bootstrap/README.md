# Bootstrap Terraform

This Terraform project should run before the [environment terraform](../omop/README.md).

![bootstrap environment](/infra/media/bootstrap_deployment.png)

This project includes the bootstrap Resource Group and steps to ease your Azure DevOps environment setup, which are depicted in the left side of the diagram.

## Bootstrap Terraform Overview

This project will look to ease running your [environment terraform](/infra/terraform/omop/README.md) and running OHDSI in Azure.  You are likely to only run this bootstrap terraform project when you are first setting up an environment, or if you need to use Terraform to manage other Azure DevOps settings.

[Setup Bootstrap Resource Group](https://user-images.githubusercontent.com/2498998/169098316-8ae4d3c9-f2c5-491b-b6be-a101d14fb093.mp4)

> You can also check under the [video links doc](/docs/video_links.md) for other setup guides.

### Setup Azure Bootstrap Resource Group

The bootstrap Terraform project will setup the following resources per environment:

* Setup your Azure Bootstrap Resource Group including:
  * Setup [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview) including [secrets](https://docs.microsoft.com/en-us/azure/key-vault/secrets/about-secrets)
    * The name of the Azure Key Vault is globally unique and therefore needs to be defined by a unique combination of "prefix" and "environment" variables to avoid naming conflicts upon creation.
  * Setup [Azure Storage Container](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) for your backend TF statefile
    * You will still need to configure your [Environment Terraform](/infra/terraform/omop/) to use the backend state in Azure Storage, see the [readme](/infra/README.md/#running-terraform) for more guidance
  * Setup [Azure Virtual Machine Scale Set](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview) for use later with your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops)
    * You will provision an Azure VMSS which uses an Ubuntu image setup by [cloud-init](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-deploy-app#install-an-app-to-a-linux-vm-with-cloud-init), which is configured through the [ado builder config](./adobuilder.conf)
    * You will also provision an Azure Windows VMSS which uses a Windows image setup by [custom script extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows), which is configured through the [PowerShell script](./scripts/build-agent-dependencies.ps1)
  * Setup Azure VM Jumpbox connect to an [Azure Virtual Network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) to interact with the Azure VMSS
    * The bootstrap Terraform project includes an [Azure Linux VM](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview) and an [Azure Windows VM](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/overview), and you can choose which one to use for your jumpbox.

You can review the Terraform for [main.tf](/infra/terraform/bootstrap/main.tf) for more details.

### Setup Azure DevOps

The bootstrap Terraform project will also look to setup your Azure DevOps project for OHDSI on Azure, including the following:

* Setup [Azure DevOps Environments](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops) for use with the [Environment Pipeline](/pipelines/environments/TF-OMOP.yaml) for `terraform plan` and `terraform apply`.
* Setup [Azure DevOps Variable Groups](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml):
  * Two (2) variable groups for environment setup:
    1. A variable group ending with [bootstrap-vg](/docs/update_your_variables.md#1-bootstrap-vg) which is linked to [Azure Key Vault secrets](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) to run with your Environment Pipeline
    2. A variable group ending with [bootstrap-settings-vg](/docs/update_your_variables.md#2-bootstrap-settings-vg) which is **not** linked to Azure Key Vault to configure running your Environment pipeline
  * One (1) variable group ending with [omop-environment-settings-vg](/docs/update_your_variables.md#3-omop-environment-settings-vg) for application pipelines (e.g. [broadsea pipelines](/pipelines/README.md/#broadsea-pipelines) and [vocabulary pipelines](/pipelines//README.md/#vocabulary-pipelines)) per environment
* Setup [Azure DevOps Service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) to connect the Azure DevOps pipelines to Azure
* Setup and Import Azure DevOps Pipelines into your Azure DevOps Project:
  1. [Environment Pipeline](/pipelines/environments/TF-OMOP.yaml)
  2. [Vocabulary Build Pipeline](/pipelines/vocabulary_build_pipeline.yaml)
  3. [Vocabulary Release Pipeline](/pipelines/vocabulary_release_pipeline.yaml)
  4. [Broadsea Build Pipeline](/pipelines/broadsea_build_pipeline.yaml)
  5. [Broadsea Release Pipeline](/pipelines/broadsea_release_pipeline.yaml)

You can review the Terraform for [azure_devops.tf](/infra/terraform/bootstrap/azure_devops.tf), [azure_devops_build_definitions.tf](/infra/terraform/bootstrap/azure_devops_build_definitions.tf), and [azure_devops_variable_groups.tf](/infra/terraform/bootstrap/azure_devops_variable_groups.tf) for more details.

### Setup Azure AD Group

The bootstrap Terraform project will also setup an Azure AD group for use later with your Azure SQL in your [Environment Azure SQL Server](/infra/terraform/omop/README.md).

This project will also setup an Azure AD group which will be assigned [Directory Readers](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group) for use later with your [Environment Azure SQL Server](/infra/terraform/omop/README.md) Managed Identity.

You can review the Terraform for [azure_ad.tf](/infra/terraform/bootstrap/azure_ad.tf) for more details.

> You can use Terraform to assign Azure AD Groups and roles if you have [AAD Premium P2 enabled](https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept).  Otherwise, you can use a workaround described for [assigning Directory Reader to your Azure SQL Managed Identity](/infra/terraform/bootstrap/README.md#assign-directory-reader-to-your-azure-sql-managed-identity).

## Prerequisites

You will need to ensure you have completed the following steps before running the [bootstrap Terraform project](/infra/terraform/bootstrap/main.tf).

1. You and your Administrator have access to your Azure Subscription
    * Make sure you have [installed Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and you have [logged in](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli) to your Azure Subscription to confirm access
    * You can use the following steps to login to your subscription:
      1. `az login`
      2. `az account set -s <my-subscription-id>`
      3. `az account show` to confirm you have logged in

2. You are able to [import this git repository](https://docs.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops) to Azure DevOps.  The bootstrap terraform project will attempt to [create an Azure DevOps git repository and import contents from the public git repo](/infra/terraform/bootstrap/README.md#creating-an-azure-devops-project-and-a-repository-and-importing-a-public-git-repository)

3. You have setup an [Azure DevOps PAT](/infra/terraform/bootstrap/README.md/#ado-pat-notes)

4. Ensure you have appropriate [Azure AD permissions](#azure-ad-permissions) setup

5. You have [installed terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started) locally

* Ensure you have also setup the Azure DevOps provider for Terraform and are using the `0.2.1` version which contains a fix for the [Azure DevOps provider](https://github.com/microsoft/terraform-provider-azuredevops/issues/541)

* This has been tested with `Terraform v1.0.10`, and you can confirm your terraform version with `terraform --version`

* You will also need `jq`, which you can install with `sudo apt-get install jq`.  For other tooling, you can refer to the [local development setup notes](https://github.com/microsoft/OHDSIonAzure/blob/main/local_development_setup.md).

* You will need to ensure your Azure CLI also has the [Azure DevOps extension](https://docs.microsoft.com/en-us/azure/devops/cli/?view=azure-devops) installed

```shell
az config set extension.use_dynamic_install=yes_without_prompt

az extension add --name azure-devops
```

* If you are running WSL, you may need to update your line endings.  You can use `dos2unix`:

```shell
sudo apt install dos2unix # Install dos2unix
find infra -name '*.sh' -exec dos2unix {} + # convert scripts
```

6. You have `git clone` the repository

```bash
git clone https://github.com/microsoft/OHDSIonAzure
```

### Azure AD Permissions

The [bootstrap Terraform project](/infra/terraform/bootstrap/main.tf) includes setting up [Azure AD groups](#setup-azure-ad-group).  You should also ensure you have [AAD premium](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs) enabled so you can [assign Directory Reader to your Azure SQL Managed Identity](/infra/terraform/bootstrap/README.md#assign-directory-reader-to-your-azure-sql-managed-identity).

Your administrator should have the appropriate [permissions](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group#api-permissions) including the following directory roles:

* [Groups Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#groups-administrator)
* [User Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#user-administrator)

> In the case that you'd like to use an Azure Service Principal for your administrator Azure credential context, you will also need to assign the [Application administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#application-administrator) role to your credential.  You can also use your Azure Service Principal for your [Azure context with terraform](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret).

Your administrator will need one of the following directory roles to [Assign the Directory Readers Role](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role?#assigning-the-directory-readers-role):

* [Global Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#global-administrator)
  > If your Azure administrator has `Global Administrator` rights, you will not need to assign the other directory roles (Groups Administrator, User Administrator, Privileged Role Administrator).  However, this directory role is usually reserved and should be assigned intentionally.

* [Privileged Role Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#privileged-role-administrator)
  > You can use this directory role in combination with the Groups Administrator and User Administrator for your Azure adminstrative principal.  This is preferred as the combination of these directory roles is less permissive than assigning Global Administrator.

For example, if you'd like to give your Azure principal a specific directory role, you can work through the following steps:

1. Navigate to your Azure AD directory in the Azure Portal

![Azure AD Overview](/docs/media/azure_ad_prerequisites_0.png)

2. Search for the directory role you'd to use.  For example, in this case, you can look for the `Groups Administrator` directory role:

![Search for directory role in Azure AD](/docs/media/azure_ad_prerequisites_1.png)

3. You can click add assignments to add in your Azure principal to the directory role

![Add in directory role for Azure principal](/docs/media/azure_ad_prerequisites_2.png)

4. Proceed with adding your Azure principal to your Directory Role

![Add in directory role for Azure principal](/docs/media/azure_ad_prerequisites_3.png)

### ADO PAT Notes

Follow the instructions to create your [Azure DevOps PAT](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows#create-a-pat).

Your Azure DevOps PAT should include the [following scopes](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows#modify-a-pat) as part of your [Azure DevOps setup](#setup-azure-devops):
> Be sure to review all scopes for your [Azure DevOps PAT](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)

* Agent Pools - Read & Manage
* Build - Read & Execute
* Code - Full
* Environment - Read & Manage
* Extension Data - Read & Write
* Extensions - Read & Manage
* Project and Team - Read, Write, & Manage
* Service Connections - Read, Query, & Manage
* Token Administration - Read & Manage
* Tokens - Read & Manage
* User Profile - Read & Write
* Variable Groups - Read, Create, & Manage
* Work Items - Read

Your Azure DevOps instance should also include permissions for the account which will be used to bootstrap.  Your administrator may be part of the [project collection administrators group](https://docs.microsoft.com/en-us/azure/devops/organizations/security/change-organization-collection-level-permissions?view=azure-devops&tabs=preview-page#add-members-to-the-project-collection-administrators-group) and can perform the following tasks to manage user access.

For example, you may be mapped to the Contributors Group for your [project](https://docs.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#project-level-permissions) and you need to manage your [repository level permissions](https://docs.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#git-repository-object-level):

![Azure DevOps Permissions Contributors](/docs/media/azure_devops_permissions_1.png)

* You should ensure that you are allowed to create a repository, and delete or disable a repository.

Further, your [user should also have access](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/add-organization-users?view=azure-devops&tabs=preview-page#manage-users) to the Azure DevOps repository.  For example you can include users as Project Contributor.

![Azure DevOps Permissions Project Contributors](/docs/media/azure_devops_permissions_2.png)

## Steps

Assuming you can complete the [prerequisites](#prerequisites), you can work through the following steps.

### Step 1. Update Your Variables

1. In your local git cloned repo create a feature branch (e.g. [your_alias)]/[new_feature_name]). An example would be `jane_doe/new_feature`

2. You can update your [terraform.tfvars](/infra/terraform/bootstrap/terraform.tfvars) with the following values

```hcl
prefix              = "sharing" # set to a given prefix for your environment
environment         = "dev" # This is your environment

ado_org_service_url = "https://dev.azure.com/my-organization" # This is your Azure DevOps organization url
ado_project_name    = "OHDSIonAzure" # This is your Azure DevOps project name
ado_repo_name       = "OHDSIonAzure" # This is your Azure DevOps repository name
ado_pat             = "my-ado-PAT" # This is your Azure DevOps PAT

# The name of the blob container in the CDR storage account that will be used for vocabulary file uploads
cdr_vocab_container_name = "vocabularies"

# The path in the vocabulary blob container in the CDR storage account that will be used for vocabulary file uploads.  E.g. if the vocabulries are stored under /vocabularies/19-AUG-2021 you should specify 19-AUG-2021."
cdr_vocab_version = "19-AUG-2021"
```

You can also review the following table which describes the other bootstrap Terraform variables.

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| acr_sku_edition | string | `Premium` | This is the SKU for your [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus) in your [Environment](/infra/terraform/omop/README.md) which will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg).  The default is `Premium` as this SKU supports networking rules. |
| admin_user_jumpbox | string | `azureuser` | This is your Azure VM Jumpbox user name. |
| admin_password_jumpbox | string | `P@$$w0rd1234!` | This is your Azure VM Jumpbox password. |
| admin_user | string | `azureuser` | This is your Azure VMSS user name. |
| admin_password | string | `replaceP@SSW0RD` | This is your Azure VMSS password. |
| ado_linux_vmss_agent_pool_settings | object | <code>{ <br> &nbsp; max_capacity           = 2       # VMSS Max Capacity <br> &nbsp; desired_size           = 1       # VMSS desired size <br> &nbsp; desired_idle           = 1       # VMSS desired idle <br> &nbsp; time_to_live_minutes   = 30      # VMSS time to live in minutes <br> &nbsp; recycle_after_each_use = false   # VMSS recycle after each use <br> &nbsp; ostype                 = "linux" # VMSS ostype e.g. linux <br>}</code> | Specify settings for your [Azure DevOps Linux VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops#create-the-scale-set-agent-pool). |
| ado_org_service_url | string | `https://dev.azure.com/<my-org>` | This is your Azure DevOps [organization url](https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http#how-the-primary-url-is-used). |
| ado_project_name | string | `OHDSIonAzure` | This is your Azure DevOps [Project Name](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/create-project?view=azure-devops&tabs=preview-page). |
| ado_repo_name | string | `OHDSIonAzure` | This is your Azure DevOps [Repository Name](https://docs.microsoft.com/en-us/azure/devops/repos/git/repo-rename?view=azure-devops&tabs=browser).  By default this should be `OHDSIonAzure`. |
| ado_pat | string | `my-PAT` | This is your Azure [DevOps PAT](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows).  You should use the Azure DevOps PAT which is setup as part of the [prerequisites steps](/infra/terraform/bootstrap/README.md/#ado-pat-notes). |
| ado_windows_vmss_agent_pool_settings | object | <code>{ <br> &nbsp; max_capacity           = 2       # VMSS Max Capacity <br> &nbsp; desired_size           = 1       # VMSS desired size <br> &nbsp; desired_idle           = 1       # VMSS desired idle <br> &nbsp; time_to_live_minutes   = 30      # VMSS time to live in minutes <br> &nbsp; recycle_after_each_use = false   # VMSS recycle after each use <br> &nbsp; ostype                 = "windows" # VMSS ostype e.g. windows <br>}</code> | Specify settings for your [Azure DevOps Windows VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops#create-the-scale-set-agent-pool). |
| adoVMSSBuildAgentPoolName | string | `some-ado-build-agent-vmss-pool` | This is the name of the Azure Virtual Machine Scale Set used for the Azure DevOps Agent Pool.  This will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| asp_kind_edition | string | `Linux` | This is the Operating System for your [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) in your [Environment](/infra/terraform/omop/README.md), and the default is `Linux` to host the [broadsea-webtools container](/apps/broadsea-webtools/README.md).  This will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| asp_sku_size | string | `P2V2` | This is the size for your [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) in your [Environment](/infra/terraform/omop/README.md), and the default is `P2V2`.  This will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| asp_sku_tier | string | `PremiumV2` |  This is the tier for your [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) in your [Environment](/infra/terraform/omop/README.md), and the default is `PremiumV2`.  This will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| azure_subscription_name | string | `My Azure Subscription` | This is your Azure Subscription which will be used to setup your [Azure DevOps Service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml).  This will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| azure_vmss_sku | string | `Standard_D4s_v3` | This is your Azure VMSS sku for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_vmss_instances | number | `2` | This is the number of instances to provision for your Azure VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_vmss_source_image_publisher | string | `Canonical` | This is the image publisher to use with your Azure VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_vmss_source_image_offer | string | `0001-com-ubuntu-server-focal` | This is the image offer to use with your Azure VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_vmss_source_image_sku | string | `20_04-lts` | This is the image sku to use with your Azure VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_vmss_source_image_version | string | `latest` | This is the image version to use with your Azure VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_windows_vmss_sku | string | `Standard_D4s_v3` | This is your Azure Windows VMSS sku for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_windows_vmss_instances | number | `1` | This is the number of instances to provision for your Azure Windows VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_windows_vmss_source_image_publisher | string | `MicrosoftWindowsServer` | This is the image publisher to use with your Azure Windows VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_windows_vmss_source_image_offer | string | `WindowsServer` | This is the image offer to use with your Azure Windows VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_windows_vmss_source_image_sku | string | `2019-Datacenter` | This is the image sku to use with your Azure Windows VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| azure_windows_vmss_source_image_version | string | `latest` | This is the image version to use with your Azure Windows VMSS for your [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops). |
| broadsea_build_pipeline_name | string | `Broadsea Build Pipeline` | This is the name for your [Broadsea Build Pipeline](/pipelines/broadsea_build_pipeline.yaml) which will be imported into your Azure DevOps project.  The default is `Broadsea Build Pipeline`. |
| broadsea_build_pipeline_path | string | `/pipelines/broadsea_build_pipeline.yaml` | This is the repository path for the [Broadsea Build Pipeline](/pipelines/broadsea_build_pipeline.yaml) which will be imported into your Azure DevOps project.  The default is `/pipelines/broadsea_build_pipeline.yaml`.  This will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg).|
| broadsea_release_pipeline_name | string | `Broadsea Release Pipeline` | This is the name for your [Broadsea Release Pipeline](/pipelines/broadsea_release_pipeline.yaml) which will be imported into your Azure DevOps project.  The default is `Broadsea Release Pipeline`. |
| broadsea_release_pipeline_path | string | `/pipelines/broadsea_release_pipeline.yaml` | This is the repository path for the [Broadsea Release Pipeline](/pipelines/broadsea_release_pipeline.yaml) which will be imported into your Azure DevOps project.  The default is `/pipelines/broadsea_release_pipeline.yaml`. |
| cdr_vocab_container_name | string | `vocabularies` | The name of the blob container in the CDR storage account that will be used for vocabulary file uploads for your [Environment](/infra/terraform/omop/README.md) and will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg).  The default is `vocabularies`. |
| cdr_vocab_version | string | `vocabularies` | The path in the vocabulary blob container in the CDR storage account that will be used for vocabulary file uploads for your [Environment](/infra/terraform/omop/README.md) and will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg).  For example, if the vocabulries are stored under `/vocabularies/19-AUG-2021` you should specify `19-AUG-2021`.  The default is `19-AUG-2021`. |
| data_source_vocabulary_name | string | `DSVocabularyBlobStorage` | Set to `DSVocabularyBlobStorage` which should match the name of the external data source mapped in Azure SQL and will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg).  If the name of the external data source is different, use the appropriate value. See [Variable Groups](/docs/update_your_variables.md/#dsvocabularyblobstoragename) for more details. |
| environment | string | `dev` | Use this to designate your TF environment and will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| tf_apply_environment_pipeline_path | string | `/pipelines/environments/omop_terraform_apply.yaml` | This is the repository path for the [Environment Pipeline](/pipelines/environments/TF-OMOP.yaml) which will be imported into your Azure DevOps project.  The default is `/pipelines/environments/omop_terraform_apply.yaml`. |
| tf_destroy_environment_pipeline_path | string | `/pipelines/environments/omop_terraform_destroy.yaml` | This is the repository path for the [Environment Pipeline](/pipelines/environments/TF-OMOP.yaml) which will be imported into your Azure DevOps project.  The default is `/pipelines/environments/omop_terraform_destroy.yaml`. |
| location | string | `westus3` | This is the location for the bootstrap resource group for your TF environment and will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| omop_password | sensitive string | `some-password` | This is your Azure SQL DB Admin password for your [Environment](/infra/terraform/omop/README.md) which will be populated in your [Key Vault linked Variable Group](/docs/update_your_variables.md/#1-bootstrap-vg).  This is user supplied. |
| omop_db_size | string | `100` | This is the size in Gb for your [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-single-databases) in your [Environment](/infra/terraform/omop/README.md) which will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| omop_db_sku | string | `GP_Gen5_2` | This is the SKU for your [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-single-databases) in your [Environment](/infra/terraform/omop/README.md) which will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| prefix | string | `sharing` | This is a prefix used for your TF environment and will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| resource_group_name | string | `myAdoResourceGroup` | This is the name of your [bootstrap TF resource group](/infra/terraform/bootstrap/README.md/#bootstrap-terraform). |
| tags | string | <code>{<br>&nbsp;&nbsp;"Deployment"  = "OHDSI on Azure"<br>&nbsp;&nbsp;"Environment" = "dev"<br>}</code> | These are the [tags](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=json) for your bootstrap Azure resource group, and you can use the default specified for your environment. |
| tf_apply_environment_pipeline_name | string | `TF Apply OMOP Environment Pipeline` | This is the name for your [Terraform Apply Environment Pipeline](/pipelines/environments/omop-terraform-apply.yaml) which will be imported into your Azure DevOps project.  The default is `TF Apply OMOP Environment Pipeline`. |
| tf_destroy_environment_pipeline_name | string | `TF Destroy OMOP Environment Pipeline` | This is the name for your [Terraform Destroy Environment Pipeline](/pipelines/environments/omop-terraform-destroy.yaml) which will be imported into your Azure DevOps project.  The default is `TF Destroy OMOP Environment Pipeline`. |
| vocabulary_build_pipeline_name | string | `Vocabulary Build Pipeline` | This is the name for your [Vocabulary Build Pipeline](/pipelines/vocabulary_build_pipeline.yaml) which will be imported into your Azure DevOps project.  The default is `Vocabulary Build Pipeline`. |
| vocabulary_build_pipeline_path | string | `/pipelines/vocabulary_build_pipeline.yaml` | This is the repository path for the [Vocabulary Build Pipeline](/pipelines/vocabulary_build_pipeline.yaml) which will be imported into your Azure DevOps project.  The default is `/pipelines/vocabulary_build_pipeline.yaml`. |
| vocabulary_release_pipeline_name | string | `Vocabulary Release Pipeline` | This is the name for your [Vocabulary Build Pipeline](/pipelines/vocabulary_release_pipeline.yaml) which will be imported into your Azure DevOps project.  The default is `Vocabulary Release Pipeline`. |
| vocabulary_release_pipeline_path | string | `/pipelines/vocabulary_release_pipeline.yaml` | This is the repository path for the [Vocabulary Release Pipeline](/pipelines/vocabulary_release_pipeline.yaml) which will be imported into your Azure DevOps project.  The default is `/pipelines/vocabulary_release_pipeline.yaml`. |

### Step 2. Run your Terraform Bootstrap Project

Assuming you have updated your [variables](/infra/terraform/bootstrap/README.md/#step-1-update-your-variables), you can work next on running Terraform locally.

1. Make sure your working directory is the [bootstrap directory](/infra/terraform/bootstrap/)

```bash
# from the repository root working directory
cd infra/terraform/bootstrap
```

2. Review the [main.tf resources](/infra/terraform/bootstrap/main.tf), [azure_ad.tf resources](/infra/terraform/bootstrap/azure_ad.tf), and [azure_devops.tf resources](/infra/terraform/bootstrap/azure_devops.tf) before you run the project

* Review the following options before running the project

#### Using a local backend

1. For simplicity, you may choose to use a local backend for the bootstrap project.  This is the preferred path for getting started.  You will need to update your [main.tf](/infra/terraform/bootstrap/main.tf) and comment out the `backend` configuration:

```diff
terraform {
+ # backend "azurerm" {
+ # }
...
}
```

#### Using an Azure Storage Account for your remote backend

Using a [Azure Storage Account for your remote backend state](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) is the default approach for the project.  This approach sets up your project for use in a shared environment (e.g. from a [github actions workflow](/docs/creating_your_environment_with_github_actions.md)), as the state will be persisted in Azure Storage, so you can connect to it without needing to manage or share your terraform state locally.

1. You can use Azure CLI to stand up your storage account:

```bash
# Setup TF State Account for Bootstrap Remote Backend
#!/bin/bash

RESOURCE_GROUP_NAME=bootstrap-tf-state-rg
STORAGE_ACCOUNT_NAME=bootstraptfstate # use a unique name for your azure storage account
CONTAINER_NAME=tfstate
LOCATION=westus3

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

# Store your account key an environment variable
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
export ARM_ACCESS_KEY="$ACCOUNT_KEY"
```

2. Update your [main.tf](/infra/terraform/bootstrap/main.tf) to use the `backend` configuration block:

```diff
terraform {
+ backend "azurerm" {
+ }
  ...
}
```

3. When you call `terraform init`, you can supply variables on the command line for your backend configuration.

```bash
terraform init \
  -backend-config='resource_group_name=bootstrap-tf-state-rg' \
  -backend-config='storage_account_name=bootstraptfstate' \
  -backend-config='container_name=tfstate' \
  -backend-config='key=terraform.tfstate'
```

> If you'd like to simplify the command to use `terraform init` only, you can also specify your Azure Storage Account settings in the [main.tf](/infra/terraform/bootstrap/main.tf):

```diff
terraform {
+ backend "azurerm" {
+   resource_group_name  = "bootstrap-tf-state-rg"
+   storage_account_name = "bootstraptfstate"
+   container_name       = "tfstate"
+   key                  = "terraform.tfstate"
+ }
...
}
```

#### Creating an Azure DevOps project and a repository, and importing a public git repository

1. If desired, you can name your project `OHDSIonAzure`.  You will need to update your [azure_devops.tf](/infra/terraform/bootstrap/azure_devops.tf) accordingly:

```diff
  resource "azuredevops_project" "project" {
+   name = "OHDSIonAzure" # If you have an existing project named OHDSIonAzure, you can set the name
+   # name             = "${var.prefix}-${var.environment}-OHDSIonAzure" # You would use this naming convention if you prefer to have a separate environment Azure DevOps project
  ...
  }
```

2. The default name for your Azure DevOps repository is `OHDSIonAzure`, and you can import from the public git repository:

```diff
resource "azuredevops_git_repository" "repo" {
  project_id = azuredevops_project.project.id
+ name       = "OHDSIonAzure" # keep this if you are just importing an existing repository according to the name
+ # name       = "${var.prefix}-${var.environment}-OHDSIonAzure" # you have an option to rename the repository

+ # Comment this out if you want to make a new repo
+ # initialization {
+ #   init_type = "Uninitialized"
+ # }

+ # Use Terraform import instead, otherwise this resource will destroy the existing repository.
+ lifecycle {
+   prevent_destroy = true # prevent destroying the repo
+ # ignore_changes = [
+ #   # Ignore changes to initialization to support importing existing repositories
+ #   # Given that a repo now exists, either imported into terraform state or created by terraform,
+ #   # we don't care for the configuration of initialization against the existing resource
+ #   initialization, # comment this out if you are making a new repo (and want to import from an existing repository)
+ # ]
}

+ ## Uncomment this section to import the contents of another git repo into this repo
+ initialization {
+   init_type             = "Import"
+   source_type           = "Git"
+   # you can import from an existing ADO repository
+   # source_url            = "${var.ado_org_service_url}/${var.ado_project_name}/_git/${var.ado_repo_name}" # you can import from an existing ADO repository
+   # service_connection_id = azuredevops_serviceendpoint_generic_git.serviceendpoint.id

+   # You can import from a public repository
+  source_url            = "https://github.com/microsoft/OHDSIonAzure.git"
}

...
}

```

3. For more details and other examples, you can review the [Azure DevOps TF provider docs](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository)

#### Importing an existing Azure DevOps project and repository into your terraform state

1. If desired, you can name your project `OHDSIonAzure`.  You will need to update your [azure_devops.tf](/infra/terraform/bootstrap/azure_devops.tf) accordingly:

```diff
  resource "azuredevops_project" "project" {
+   name = "OHDSIonAzure" # If you have an existing project named OHDSIonAzure, you can set the name
+   # name             = "${var.prefix}-${var.environment}-OHDSIonAzure" # You would use this naming convention if you prefer to have a separate environment Azure DevOps project
  ...
  }
```

2. The default name for your Azure DevOps repository is `OHDSIonAzure`, but if you'd like to rename it you can do so to avoid conflicts:

```diff
resource "azuredevops_git_repository" "repo" {
  project_id = azuredevops_project.project.id
+ # name       = "OHDSIonAzure" # keep this if you are just importing an existing repository according to the name
+ name       = "${var.prefix}-${var.environment}-OHDSIonAzure" # you have an option to rename the repository
  ...
}

```

3. You will need to import your Azure DevOps project and your Azure DevOps repository:

```bash
terraform init # ensure you have initialized the project
terraform import azuredevops_project.project "OHDSIonAzure" # Import your existing project assuming your project in ADO is named "OHDSIonAzure"

terraform import azuredevops_git_repository.repo OHDSIonAzure/OHDSIonAzure # Import your existing azure devops repo assuming the project is named "OHDSIonAzure" and the repository is named "OHDSIonAzure"
```

#### Choosing your Jumpbox Azure VM

You can choose which Azure VM to use for your jumpbox.  For example, you may prefer to use an [Azure Linux VM](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview) for your jumpbox, so you can uncomment the resource in the [main.tf](/infra/terraform/bootstrap/main.tf) script.

1. Using an [Azure Linux VM](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview) for your jumpbox, be sure to uncomment your `resource "azurerm_virtual_machine" "jumpbox"` and comment out your `resource "azurerm_windows_virtual_machine" "jumpbox-windows"` in the [main.tf](/infra/terraform/bootstrap/main.tf) script:

```diff
## Uncomment if you prefer to use an Azure Linux VM for your jumpbox
+ resource "azurerm_virtual_machine" "jumpbox" {
+ ...
+ }

...

## Uncomment if you prefer to use an Azure Windows VM for your jumpbox
+ # resource "azurerm_windows_virtual_machine" "jumpbox-windows" {
+ #  ...
+ # }
```

2. If you prefer to use an [Azure Windows VM](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/overview) instead for your jumpbox, be sure to comment out your `resource "azurerm_virtual_machine" "jumpbox"` and uncomment your `resource "azurerm_windows_virtual_machine" "jumpbox-windows"` in the [main.tf](/infra/terraform/bootstrap/main.tf) script:

```diff
## Uncomment if you prefer to use an Azure Linux VM for your jumpbox
+ # resource "azurerm_virtual_machine" "jumpbox" {
+ #  ...
+ # }

...

## Uncomment if you prefer to use an Azure Windows VM for your jumpbox
+ resource "azurerm_windows_virtual_machine" "jumpbox-windows" {
+  ...
+ }
```

#### Assign Directory Reader to your Azure SQL Managed Identity

Your Azure SQL Managed Identity should have [Directory Reader assigned](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial#assign-directory-readers-permission-to-the-sql-logical-server-identity) to grant access for your Managed Identities in Azure SQL.  You will need to ensure you have [AAD premium activated](https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept#license-requirements) so you can assign your [Azure AD Group](https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept) the Directory Readers role.
If you cannot assign the Directory Readers role to your Azure SQL Server Managed Identity, you can follow a [workaround](/infra/terraform/omop/README.md/#step-3-run-post-terraform-deployment-steps).

1. Uncomment the argument for `assignable_to_role` in the [azure_ad.tf](/infra/terraform/bootstrap/azure_ad.tf) if you have [AAD premium](https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept), which will allow you to assign the Azure AD Group to a role:

```diff
resource "azuread_group" "dbadminsaadgroup" {
  ...
  # uncomment this if you have AAD premium enabled in your Azure subscription
  # https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept
+ assignable_to_role = true
+ # assignable_to_role = true
```

Uncomment the `azuread_directory_role` and `azuread_directory_role_member` in the [azure_ad.tf](/infra/terraform/bootstrap/azure_ad.tf) resource block to assign the Azure AD group to a role:

```diff
# Uncomment the following section to get the Directory Readers role
+ resource "azuread_directory_role" "directoryreaders" {
+   display_name = "Directory Readers"
+ }

# Uncomment the following section if you have AAD premium enabled in your Azure subscription
+ resource "azuread_directory_role_member" "directoryreadersmember" {
+   role_object_id   = azuread_directory_role.directoryreaders.object_id
+   member_object_id = azuread_group.directoryreadersaadgroup.object_id
+ }
```

3. Run Terraform for your project:
    > You will need to specify values for variables which are not specified through your defaults in your [variables.tf](/infra/terraform/bootstrap/variables.tf) or [terraform.tfvars](/infra/terraform/bootstrap/README.md/#step-1-update-your-variables).  For example, you may need to supply a value for `omop_password`.

    * Initialize Terraform:

      ```shell
      terraform init
      ```

    * Check the Terraform Plan:

      ```shell
      terraform plan -var 'omop_password=beSureToReplaceYourP@SSW0RD'
      ```

    * Run Terraform Apply:

      ```shell
      terraform apply -var 'omop_password=beSureToReplaceYourP@SSW0RD'
      ```

      > You may need to ensure that your administrator has logged to Azure (e.g. `azure login`) using [elevated access](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin).  Your administrator should also lower their elevated access when finished with the deployment.

### Step 3. Confirm Bootstrap Resource Group Setup from Terraform

1. Navigate to your bootstrap resource group in the Azure Portal

2. Confirm Terraform deployed your Azure Resources in your [bootstrap resource group](/infra/terraform/bootstrap/README.md/#setup-azure-bootstrap-resource-group)

![Validate Bootstrap Resource Group](/docs/media/azure_devops_bootstrap_resource_group.png)

### Step 4. Confirm Azure DevOps Project Setup from Terraform

1. Confirm Terraform deployed your Azure DevOps resources in [your Azure DevOps project](/infra/terraform/bootstrap/README.md/#setup-azure-devops)

### Step 5. Confirm your Azure DevOps Agent Pool Setup

Assuming the prior steps have completed successfully, you can confirm that you have setup your [Azure Devops VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops):

1. Check that your Azure DevOps Agent Pool name matches in your variable group ending in [omop-environment-settings-vg](/docs/update_your_variables.md/#3-omop-environment-settings-vg).

> Your Azure VMSS is setup from [your bootstrap resource group](/infra/terraform/bootstrap/README.md/#setup-azure-bootstrap-resource-group).

![Setup your Azure DevOps Agent Pool](/docs/media/azure_devops_agent_pool_vmss_1.png)

You can also review the [Troubleshooting Azure VMSS Agent Pool](/docs/troubleshooting/troubleshooting_azure_vmss_agent_pool.md) notes if you need additional guidance.

### Step 6. Run your environment Terraform project

Assuming you have completed the rest of the bootstrap steps successfully, you can now setup your [environment](/infra/terraform/omop/README.md).

Note, you will still need to work with your administrator to run your [environment post Terraform deployment steps](/infra/terraform/omop/README.md#step-3-run-post-terraform-deployment-steps).

## Known Errors

### Could not retrieve the list of available versions for provider

You may come across an issue from trying to run `terraform plan` or `terraform apply` like the following:

```bash
Could not retrieve the list of available versions for provider
microsoft/azuredevops2: provider registry registry.terraform.io does not have
a provider named registry.terraform.io/microsoft/azuredevops2
```

1. Ensure you have completed the [prerequisites](#prerequisites) including setting up [two different versions](/infra/terraform/modules/azure_devops_environment/README.md/#local-version-usage) for your Azure DevOps provider.

2. You should be able to `terraform init` to pull in the second version of the Azure DevOps provider.

### The user '' is not authorized to access this resource

You may come across an issue when trying to run `terraform plan` or `terraform apply` indicating your Azure DevOps provider isn't authorized:

```bash
│ Error: TF400813: The user '' is not authorized to access this resource.
│
│   with module.azure_devops_environment_tf_plan.provider["registry.terraform.io/microsoft/azuredevops2"],
```

1. Ensure you have setup your Azure [DevOps PAT](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows) for your [terraform variables](#step-1-update-your-variables).

### Authorization_RequestDenied

You may come across an error when trying to provision your Azure AD groups similar to the following:

```bash
Error: Creating group "some-test-omop-sql-server-admins"
  with azuread_group.dbadminsaadgroup,
...
GroupsClient.BaseClient.Post(): unexpected status 403 with OData error: Authorization_RequestDenied: Insufficient privilege to complete the operation.
```

1. You should work with your administrator to ensure you have permissions to create [Azure AD Groups](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal).

2. Once you have permissions granted, be sure to use `az login` to refresh your credentials before retrying to run `terraform init`, `terraform plan`, and `terraform apply`.

### The data source received an unexpected error while attempting to execute the program

If you are running [WSL](https://docs.microsoft.com/en-us/windows/wsl/install), you may run into a similar error message:

```bash
│ The data source received an unexpected error while attempting to execute the program.
│
│ Program: /usr/bin/bash
│ Error Message: ../modules/azure_devops_elastic_pool/v0/VMSSAgentPoolCreate.sh: line 2: $'\r':
│ command not found
```

To address this issue, you will need to run the following steps from your cloned repository root directory:

1. Ensure you have installed `dos2unix`

```bash
sudo apt install dos2unix # Install dos2unix
```

2. Convert scripts to use proper endings with `dos2unix`:

```bash
find infra -name '*.sh' -exec dos2unix {} + # convert scripts
```

### On first run for your pipelines, you notice prompts to authorize Azure DevOps Resources

You can manuallly authorize an Azure DevOps pipeline to enable access to your [Azure DevOps Environments](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
 or [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops).

The bootstrap Terraform project will attempt to authorize the pipelines, and you can try to force a re-apply through the following steps:

1. Check your Terraform State to see if your `agent_pool_id`, `agent_queue_id`, and `elastic_pool_id` are not null:

```bash
# Check your Azure DevOps Linux Azure VMSS Pool
terraform show -json | jq -c '.values.root_module.child_modules[] | select(.address == "module.azure_devops_elastic_pool_linux_vmss_pool").resources[0].values.result' | jq

# Check your Azure DevOps Windows Azure VMSS Pool
terraform show -json | jq -c '.values.root_module.child_modules[] | select(.address == "module.azure_devops_elastic_pool_windows_vmss_pool").resources[0].values.result' | jq
```

If you get a json result like the following, then you will need to make sure your Azure DevOps agent pools have updated ids.

```json
{
  "agent_pool_id": "null",
  "agent_queue_id": "null",
  "elastic_pool_id": "null"
}
```

2. You can recreate your Azure DevOps VMSS Pool

```bash
# force recreation of the Azure DevOps Azure VMSS Pools
terraform destroy \
    --target module.azure_devops_elastic_pool_linux_vmss_pool.null_resource.RemoveVMSSAgentPool \
    --target module.azure_devops_elastic_pool_windows_vmss_pool.null_resource.RemoveVMSSAgentPool
```

After you have destroyed, you can `terraform apply` to pick up changes:

```bash
terraform apply
```

* You can check your terraform state (as in step 1) to see if you are now getting non-null values:

```json
{
  "agent_pool_id": "11",
  "agent_queue_id": "22",
  "elastic_pool_id": "11"
}
```

3. If you are still seeing null values for your result from Step 1, you can also look to remove pipeline assignments through Terraform:

```bash
# example to remove pipeline assignments
terraform destroy \
    --target module.azure_devops_elastic_pool_linux_vmss_pool.null_resource.RemoveVMSSAgentPool \
    --target module.azure_devops_elastic_pool_windows_vmss_pool.null_resource.RemoveVMSSAgentPool \
    --target module.azure_devops_elastic_pool_for_broadsea_build_pipeline_assignment.null_resource.azure_devops_elastic_pool_pipeline_assignment_remove \
    --target module.azure_devops_elastic_pool_for_broadsea_releasepipeline_assignment.null_resource.azure_devops_elastic_pool_pipeline_assignment_remove \
    --target module.azure_devops_elastic_pool_for_environment_pipeline_assignment.null_resource.azure_devops_elastic_pool_pipeline_assignment_remove \
    --target module.azure_devops_elastic_pool_for_vocabulary_build_pipeline_assignment.null_resource.azure_devops_elastic_pool_pipeline_assignment_remove \
    --target module.azure_devops_elastic_pool_for_vocabulary_release_pipeline_assignment.null_resource.azure_devops_elastic_pool_pipeline_assignment_remove \
    --target module.azure_devops_environment_broadsea_build_pipeline_assignment.null_resource.azure_devops_environment_pipeline_assignment_remove \
    --target module.azure_devops_environment_broadsea_release_pipeline_assignment.null_resource.azure_devops_environment_pipeline_assignment_remove \
    --target module.azure_devops_environment_tf_apply_pipeline_assignment.null_resource.azure_devops_environment_pipeline_assignment_remove \
    --target module.azure_devops_environment_tf_plan_pipeline_assignment.null_resource.azure_devops_environment_pipeline_assignment_remove \
    --target module.azure_devops_environment_vocabulary_build_pipeline_assignment.null_resource.azure_devops_environment_pipeline_assignment_remove \
    --target module.azure_devops_environment_vocabulary_release_pipeline_assignment.null_resource.azure_devops_environment_pipeline_assignment_remove
```

After you have destroyed, you can `terraform apply` to pick up changes:

```bash
# refresh the environment
terraform apply
```

* You can check your terraform state (as in step 1) to see if you are now getting non-null values:

```json
{
  "agent_pool_id": "11",
  "agent_queue_id": "22",
  "elastic_pool_id": "11"
}
```

### Permission Denied Error for running scripts

You may run into `permission denied` messages like the following when running `terraform apply`:

```bash
Error: local-exec provisioner error
│
│   with module.azure_devops_environment_vocabulary_release_pipeline_assignment.null_resource.azure_devops_environment_pipeline_assignment_remove,
│   on ../modules/azure_devops_environment_pipeline_assignment/azure_devops_environment_pipeline_assignment.tf line 28, in resource "null_resource" "azure_devops_environment_pipeline_assignment_remove":
│   28:   provisioner "local-exec" {
│
│ Error running command
│ '../modules/azure_devops_environment_pipeline_assignment/azure_devops_environment_pipeline_assignment.sh >
│ azure_devops_environment_pipeline_assignment.txt': exit status 126. Output: /bin/sh:
│ ../modules/azure_devops_environment_pipeline_assignment/azure_devops_environment_pipeline_assignment.sh:
│ Permission denied
```

1. You can update your permissions for the modules directory using the following command:

```bash
# run from your repository root directory
chmod -R -x infra/modules
```

> You may need to elevate your permissions in order to run `chmod` using `sudo`.  You can also review permissions using `stat path/to/module`.

### Issues with deleting an Azure DevOps project

If you are using `terraform destroy` to tear down the bootstrap project, you should be careful to not actually destroy Azure DevOps project.

In the case that you have **unintentionally** deleted your Azure DevOps project, you will need to work with your Azure DevOps [Project Collection Administrator](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/restore-project?view=azure-devops#prerequisites) to [restore your project](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/restore-project?view=azure-devops).

#### Intentional Delete for your Azure DevOps project and repository

The Azure DevOps project and repository are marked with `prevent_destroy = true` to address **unintentional** delete for your Azure DevOps project and repository:

```diff
resource "azuredevops_project" "project" {
  ...
  lifecycle {
+   prevent_destroy = true # prevent destroying the project
  ...
  }
  ...
}

resource "azuredevops_git_repository" "repo" {
  project_id = azuredevops_project.project.id
  ...

  lifecycle {
+    prevent_destroy = true # prevent destroying the repo
  ...
  }
  ...
}
```

If you **intend** to remove your Azure DevOps project and repository, you can comment out the `prevent_destroy` attribute and proceed with your `terraform destroy`.

> Note, your Azure DevOps account may not have permissions to delete an Azure DevOps project, in which case attempting to delete the project through `terraform destroy` will not work.

#### Remove your Azure DevOps project and repository from your terraform context

This is a **non-destructive** path and is preferred and safer compared to removing your Azure DevOps project and repository.

To safely remove your Azure DevOps project and repository from your terraform context (and not actually delete your Azure DevOps project and repository), you can update your terraform state using the following steps:

1. Remove Repository from Terraform state:

```bash
terraform state rm azuredevops_git_repository.repo
```

2. Remove Project from Terraform state:

```bash
terraform state rm azuredevops_project.project
```

3. You can proceed with your `terraform destroy`

### Issues with Extensions property on your Azure VMSS

If you are running `terraform destroy` to clean up your bootstrap Terraform project, you may run into the following issue with your Azure VMSS:

```bash
Error: deleting Extension "some-test-build-agent-dependencies" (Virtual Machine Scale Set "some-test-ado-build-windows-vmss-agent" / Resource Group "some-test-ado-bootstrap-omop-rg"): compute.
VirtualMachineScaleSetExtensionsClient#Delete: Failure sending request: StatusCode=400 -- Original Error: Code="BadRequest" Message="On resource 'some-test-ado-build-windows-vmss-agent', extension 'Microsoft.Azure.DevOps.Pipelines.Agent' specifies 'some-test-build-agent-dependencies' in its provisionAfterExtensions property, but the extension 'some-test-build-agent-dependencies' will no longer exist. First, remove the extension 'Microsoft.Azure.DevOps.Pipelines.Agent' or remove 'some-test-build-agent-dependencies' from the provisionAfterExtensions property of 'Microsoft.Azure.DevOps.Pipelines.Agent
```

1. Uninstall the `Microsoft.Azure.DevOps.Pipelines.Agent` from your Azure Windows VMSS

* You can manually uninstall the extension in the Azure Portal:

![Remove Azure VMSS Extension](/docs/media/azure_devops_vmss_agent_extension_remove.png)

* If preferred, you can also use [azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

```bash
az vmss extension delete -n 'Microsoft.Azure.DevOps.Pipelines.Agent' -g some-ado-bootstrap-rg --vmss-name some-ado-build-windows-vmss-agent
```

2. Once you have removed the extension from your [Azure Windows VMSS](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview), you can proceed with `terraform destroy` to continue your clean up.

### Issues Deleting nic from your VM

If you are running `terraform destroy` to clean up your bootstrap Terraform project, you may run into the following issue with your Azure VM:

```bash
│ Error: deleting Network Interface: (Name "some-jumpbox-nic" / Resource Group "some-ado-bootstrap-omop-rg"): network.InterfacesClient#Delete: Failure sending request: StatusCode=400 -- Original Error: Code="NicInUse" Message="Network Interface /subscriptions/<subid>/resourceGroups/some-ado-bootstrap-omop-rg/providers/Microsoft.Network/networkInterfaces/some-jumpbox-nic is used by existing resource /subscriptions/<subid>/resourceGroups/some-ado-bootstrap-omop-rg/providers/Microsoft.Compute/virtualMachines/somejump. In order to delete the network interface, it must be dissociated from the resource. To learn more, see aka.ms/deletenic." Details=[]
```

1. You can manually remove your Azure VM in the portal.

![Remove Azure VM](/docs/media/azure_vm_clean_up.png)

2. Update your terraform state

```bash
terraform state rm azurerm_network_interface.jumpbox
```

3. Once you have updated your terraform state, you can proceed with `terraform destroy`
