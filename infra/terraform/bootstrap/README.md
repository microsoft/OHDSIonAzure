# Bootstrap Terraform

This Terraform project should run before the [environment terraform](../omop/README.md).

![bootstrap environment](/infra/media/bootstrap_deployment.png)

This project includes the bootstrap Resource Group and steps to ease your Azure DevOps environment setup, which are depicted in the left side of the diagram.

## Bootstrap Terraform Overview

This project will look to ease running your [environment terraform](/infra/terraform/omop/README.md) and running OHDSI in Azure.  You are likely to only run this bootstrap terraform project when you are first setting up an environment, or if you need to use Terraform to manage other Azure DevOps settings.

### Setup Azure Bootstrap Resource Group

The bootstrap Terraform project will setup the following resources per environment:

* Setup your Azure Bootstrap Resource Group including:
  * Setup [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview) including [secrets](https://docs.microsoft.com/en-us/azure/key-vault/secrets/about-secrets)
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

## Prerequisites

You will need to ensure you have completed the following steps before running the [bootstrap Terraform project](/infra/terraform/bootstrap/main.tf).

1. You and your Administrator have access to your Azure Subscription
    * Make sure you have [installed Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and you have [logged in](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli) to your Azure Subscription to confirm access
    * You can use the following steps to login to your subscription:
      1. `az login`
      2. `az account set -s <my-subscription-id>`
      3. `az account show` to confirm you have logged in

2. You have [imported this git repository](https://docs.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops) to Azure DevOps

3. You have setup an [Azure DevOps PAT](/infra/terraform/bootstrap/README.md/#ado-pat-notes)

4. Ensure you have appropriate [Azure AD permissions](#azure-ad-permissions) setup

5. You have [installed terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started) locally
    * Ensure you have also setup the Azure DevOps provider for Terraform.  Until the next release for the [Azure DevOps provider](https://github.com/microsoft/terraform-provider-azuredevops/issues/541) is available, you will need to ensure that you can run [two different versions](/infra/terraform/modules/azure_devops_environment/README.md/#local-version-usage) of the Azure DevOps provider.
    
    * This has been tested with `Terraform v1.0.10`, and you can confirm your terraform version with `terraform --version`

6. You have `git clone` the repository

```bash
git clone https://github.com/microsoft/OHDSIonAzure
```

### Azure AD Permissions

The [bootstrap Terraform project](/infra/terraform/bootstrap/main.tf) includes setting up [Azure AD groups](#setup-azure-ad-group).

Your administrator should have the appropriate [permissions](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group#api-permissions) including the following directory roles:

* [Groups Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#groups-administrator)
* [User Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#user-administrator)

Your administrator will need one of the following directory roles to [Assign the Directory Readers Role](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role?#assigning-the-directory-readers-role):

* [Global Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#global-administrator)

* [Privileged Role Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#privileged-role-administrator)

### ADO PAT Notes

Follow the instructions to create your [Azure DevOps PAT](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows#create-a-pat).

Your Azure DevOps PAT should include the [following scopes](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows#modify-a-pat) as part of your [Azure DevOps setup](#setup-azure-devops):
> Be sure to review all scopes for your [Azure DevOps PAT](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)

* Agent Pools - Read & Manage
* Build - Read & Execute
* Code - Full
* Environment - Read & Manage
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

```
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
| environment_pipeline_path | string | `/pipelines/environments/TF-OMOP.yaml` | This is the repository path for the [Environment Pipeline](/pipelines/environments/TF-OMOP.yaml) which will be imported into your Azure DevOps project.  The default is `/pipelines/environments/TF-OMOP.yaml`. |
| location | string | `westus3` | This is the location for the bootstrap resource group for your TF environment and will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| omop_password | sensitive string | `some-password` | This is your Azure SQL DB Admin password for your [Environment](/infra/terraform/omop/README.md) which will be populated in your [Key Vault linked Variable Group](/docs/update_your_variables.md/#1-bootstrap-vg).  This is user supplied. |
| omop_db_size | string | `100` | This is the size in Gb for your [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-single-databases) in your [Environment](/infra/terraform/omop/README.md) which will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| omop_db_sku | string | `GP_Gen5_2` | This is the SKU for your [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-single-databases) in your [Environment](/infra/terraform/omop/README.md) which will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| prefix | string | `sharing` | This is a prefix used for your TF environment and will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| resource_group_name | string | `myAdoResourceGroup` | This is the name of your [bootstrap TF resource group](/infra/terraform/bootstrap/README.md/#bootstrap-terraform). |
| tags | string | <code>{<br>&nbsp;&nbsp;"Deployment"  = "OHDSI on Azure"<br>&nbsp;&nbsp;"Environment" = "dev"<br>}</code> | These are the [tags](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=json) for your bootstrap Azure resource group, and you can use the default specified for your environment. |
| tf_environment_build_pipeline_name | string | `TF OMOP Environment Pipeline` | This is the name for your [Environment Pipeline](/pipelines/environments/TF-OMOP.yaml) which will be imported into your Azure DevOps project.  The default is `TF OMOP Environment Pipeline`. |
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

2. Review the [main.tf resources](/infra/terraform/bootstrap/main.tf) and [azure_ad.tf resources](/infra/terraform/bootstrap/azure_ad.tf) before you run the project

    * Importing an existing Azure DevOps project and repository into your terraform state

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

      terraform import azuredevops_git_repository.repo OHDSIonAzure/OHDSIonAzure # Import your existing azure devops repo assuming the project is named "OHDSIonAzure" and the repository is anmed "OHDSIonAzure"
      ```

    * You can choose which Azure VM to use for your jumpbox.  For example, you may prefer to use an [Azure Linux VM](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview) for your jumpbox, so you can uncomment the resource in the [main.tf](/infra/terraform/bootstrap/main.tf) script.

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

    * Your Azure SQL Managed Identity should have [Directory Reader assigned](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial#assign-directory-readers-permission-to-the-sql-logical-server-identity) to grant access for your Managed Identities in Azure SQL.  You will need to ensure you have [AAD premium activated](https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept#license-requirements) so you can assign your [Azure AD Group](https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-concept) the Directory Readers role.  If you cannot assign the Directory Readers role to your Azure SQL Server Managed Identity, you can follow a [workaround](/infra/terraform/omop/README.md/#step-4-run-post-terraform-deployment-steps).

      1. Uncomment the argument for `assignable_to_role` in the [azure_ad.tf](/infra/terraform/bootstrap/azure_ad.tf) if you have AAD premium, which will allow you to assign the Azure AD Group to a role:

      ```diff
      resource "azuread_group" "dbadminsaadgroup" {
        ...        
        # uncomment this if you have AAD premium enabled in your Azure       subscription
        # https://docs.microsoft.com/en-us/azure/active-directory/      roles/groups-concept
      + assignable_to_role = true
      + # assignable_to_role = true
      ```

      Uncomment the `azuread_directory_role` and `azuread_directory_role_member` in the [azure_ad.tf](/infra/terraform/bootstrap/azure_ad.tf) resource block to assign the Azure AD group to a role:

      ```hcl
      # Uncomment the following section to get the Directory Readers role
      # resource "azuread_directory_role" "directoryreaders" {
      #   display_name = "Directory Readers"
      # }

      # Uncomment the following section if you have AAD premium enabled in your Azure subscription
      # resource "azuread_directory_role_member" "directoryreadersmember" {
      #   role_object_id   = azuread_directory_role.directoryreaders.object_id
      #   member_object_id = azuread_group.directoryreadersaadgroup.object_id
      # }
      ```

3. Run Terraform for your project:
    > You will need to specify values for variables which are not specified through your defaults in your [variables.tf](/infra/terraform/bootstrap/variables.tf) or [terraform.tfvars](/infra/terraform/bootstrap/README.md/#step-1-update-your-variables).  For example, you may need to supply a value for `omop_password`.

    * Initialize Terraform:

      ```hcl
      terraform init
      ```

    * Check the Terraform Plan:
      
      ```hcl
      terraform plan
      ```

    * Run Terraform Apply:
      
      ```hcl
      terraform apply
      ```
      
      > You may need to ensure that your administrator has logged to Azure (e.g. `azure login`) using [elevated access](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin).  Your administrator should also lower their elevated access when finished with the deployment.

### Step 3. Confirm Bootstrap Resource Group Setup from Terraform

1. Navigate to your bootstrap resource group in the Azure Portal

2. Confirm Terraform deployed your Azure Resources in your [bootstrap resource group](/infra/terraform/bootstrap/README.md/#setup-azure-bootstrap-resource-group)

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

Note, you will still need to work with your administrator to run your [environment post Terraform deployment steps](/infra/terraform/omop/README.md#step-4-run-post-terraform-deployment-steps).

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

### The user '' is not authorized to access this resource.

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