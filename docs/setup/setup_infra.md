# Infrastructure provisioning
 
The following steps walkthrough setting up infra for OHDSI on Azure.

## Prerequisites

1. You are able to work through the [infra setup notes](/infra/README.md/#setup), including working with your administrator to go through the [administrative steps](/infra/README.md/#administrative-steps) and pushing the [backend state to Azure Storage](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli).
    * For convenience, administrative steps are included in the [bootstrap Terraform Project](/infra/terraform/bootstrap/README.md/#bootstrap-terraform).

2. You have an Azure DevOps project and have [imported this repository](https://docs.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?msclkid=94de3857aa3a11ecaf02a55e0c750c5b&view=azure-devops).

3. Confirm you (or your Administrator) have configured Azure DevOps, including the following:
    * You have [imported the Azure DevOps pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/clone-import-pipeline?view=azure-devops&tabs=yaml#export-and-import-a-pipeline) from [this repository](/pipelines/)
    * You have [created an environment](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops) including one for **Terraform plan** and one for **Terraform approval**
    * You have [created a service connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml).  Your administrator can refer to the [administrative steps](/infra/README.md/#administrative-steps) for more details to get the SP to use with the Service Connection.  Ensure the Service Principal has the Owner role access to the resource group where we will be deploying resources.
    * You have setup an [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops).  Your administrator can refer to the [administrative steps](/infra/README.md/#administrative-steps) and the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md#setup-azure-devops) for additional guidance.
    * You have [created an Azure DevOps variable group](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml) for sensitive values.  Your administrator can refer to the [administrative steps](/infra/README.md/#administrative-steps) and the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md#setup-azure-devops) for an example.  The variable group should be [linked to Azure KeyVault](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) through the service connection.

4. You have `git clone` the repository

```bash
git clone https://github.com/microsoft/OHDSIonAzure
```

## Steps

Assuming you can complete the [prerequisites](#prerequisites), you can work through the following steps.

### Step 1. Update terraform.tfvars

1. In your local git cloned repo create a feature branch (e.g. [your_alias)]/[new_feature_name]). An example would be `jane_doe/new_feature`

2. You can update your [terraform.tfvars](/infra/terraform/omop/terraform.tfvars) with the following values, which you can confirm with your administrator after they have completed the [administrative steps](/infra/README.md/#administrative-steps).
> You can update your Terraform tfvars locally for testing, but you should also review your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) before running your changes through the [Environment Pipeline](/pipelines/README.md#environment-pipeline).

```
omop_password   = "" # this should be filled in through the pipeline via Azure DevOps Variable Group
prefix              = "sharing" # set to a given prefix for your environment

environment         = "dev" # this should match the naming convention for your environment from your bootstrap Terraform project

# this can be set locally for testing purposes, but the values should be passed in through your variable group.
aad_admin_login_name = "some-sharing-DB-Admins"

# this can be set locally for testing purposes, but the values should be passed in through your variable group.
aad_admin_object_id  = "some-guid"
```

You can also review the following table which describes some OMOP Terraform variables.  

> You can refer to the [environment Terraform project](/infra/terraform/omop/README.md#step-1-update-your-variables) for the complete list and for more details.

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| omop_password | string | `replaceThisP@SSW0RD` | While you can fill in this value for local testing, since this is a sensitive value, you should be using the [Azure DevOps Variable Group linked to Azure KeyVault](/docs/update_your_variable_groups.md#1-bootstrap-vg) as part of your [TF environment pipeline](/pipelines/README.md/#environment-pipeline).  You can review the approach for [working with sensitive values](#working-with-sensitive-values) for more details. |
| prefix | string | `sharing` | This is a prefix used for your TF environment. |
| environment | string | `dev` | Use this to designate your TF environment.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md). |
| aad_admin_login_name | string | `my-sharing-DBAdmins-group` | This is the Azure AD Group name that will be added as an [Azure SQL Server AD Administrator](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?msclkid=79f8d6b2a97811ec80227a313d713490&tabs=azure-powershell).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| aad_admin_object_id | string | `some-guid` | This is the Azure AD Group Object Id that will be added as an [Azure SQL Server AD Administrator](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?msclkid=79f8d6b2a97811ec80227a313d713490&tabs=azure-powershell).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| aad_directory_readers_login_name | string | `my-omop-sql-server-directory-readers` | This is the Azure AD Group name that will be assigned [Directory Reader for your Azure SQL Server Managed Identity](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| aad_directory_readers_object_id | string | `some-guid` | This is the Azure AD Group Object Id that will be assigned [Directory Reader for your Azure SQL Server Managed Identity](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |

#### Working with Sensitive Values

When working with sensitive values, you can use an [Azure DevOps Variable Group linked to Azure KeyVault](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) as part of your [TF environment pipeline](/pipelines/README.md/#environment-pipeline).  With this approach, you do not need to check in secrets into your repository, instead, the secrets can be managed with Azure Key Vault for your environment setup.  Furthermore, you can restrict access to your SP used for your Service Connection in Azure Key Vault using an access policy.

Your administrator can help populate the Azure Key Vault and your linked Variable Group, and you can refer to the [administrative steps](/infra/README.md/#administrative-steps) including the [bootstrap Terraform project ](/infra/terraform/bootstrap/README.md#setup-azure-bootstrap-resource-group) for guidance.

### Step 2. Setup the Environment Pipeline

We will initialize the infrastructure using the existing state file.

1. Update your [TF environment pipeline](/pipelines/environments/TF-OMOP.yaml) variables to include values to reflect your environment.
  > For convenience, variables which may need to be updated for your environment when **just getting started** are marked as **bold**, e.g. **some setting name**.
  > You will also want to ensure you're using the correct [Azure DevOps Variable Group](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml) which should be setup by your administrator through the [administrative steps](/infra/README.md/#administrative-steps).

You can review some of the OMOP variables in the following table.  For the full list, please refer to the [environment Terraform project](/infra/terraform/omop/README.md/#step-1-update-your-variables).

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| tf_directory | string | `infra/terraform/omop` | Terraform directory within the repository.  Default is `infra/terraform/omop`. |
| terraform_version | string | `1.1.4` | Terraform Version to use within the pipeline in your environment.  Default is `1.1.4`. |
| pool | string | `Azure Pipelines` | Specify which [Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops&tabs=yaml%2Cbrowser) to use, defaults to `Azure Pipelines` which is [Microsoft Hosted](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops) |
| enable_cleanup | string | `false` | Specify whether you should clean up the [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops) working directory after running your terraform task, defaults to `false`. |
| **azure_service_connection** | string | `sp-service-connection` | This is your SP Service Connection name which has access to your Azure Subscription. |
| **tf_storage_resource_group** | string | `ado-bootstrap-rg` | This is the resource group for your Azure Storage Account with your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file. |
| **tf_storage_region** | string | `westus2` | This is the region for your Azure Storage Account with your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file. |
| **tf_storage_account_name** | string | `omopdevtfstatestoracc` |  This is the storage account name with your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file. |
| **tf_storage_container_name** | string | `dev-omop-statefile-container` |  This is the storage account container name with your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file. |
| **tf_state_filename** | string | `terraform.tfstate` |  This is the name of your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file in Azure Storage. |
| tf_command_variables | string | `-var="prefix=my-prefix"` | This variable will be used to append to the command line for Terraform plan [command line options](https://www.terraform.io/cli/commands/plan), Terraform refresh [command line options](https://www.terraform.io/cli/commands/refresh), and Terraform apply [command line options](https://www.terraform.io/cli/commands/apply). |
| tf_init_command_options | string | `-input=false` | Terraform init [command line options](https://www.terraform.io/cli/commands/init#general-options).  Defaults to `-input=false`. |
| tf_validate_command_options | string | '' | Terraform init [command line options](https://www.terraform.io/cli/commands/validate).  Defaults to ''. |
| tf_refresh_command_options | string | `-input=false -lock=false` | Terraform refresh [command line options](https://www.terraform.io/cli/commands/refresh).  Defaults to `-input=false -lock=false`. |
| tf_plan_command_options | string | `-input=false -lock=false -refresh=false -out plan.out` | Terraform plan [command line options](https://www.terraform.io/cli/commands/plan).  You can also use this to fill in [variables](https://www.terraform.io/language/values/variables#variables-on-the-command-line), e.g. you can use `-input=false -refresh=false -var="some_variable=some_value"`.  Defaults to `-input=false -lock=false -refresh=false -out plan.out`. |
| tf_apply_command_options | string | `-input=false -refresh=false` | Terraform apply [command line options](https://www.terraform.io/cli/commands/apply).  You can also use this to fill in [variables](https://www.terraform.io/language/values/variables#variables-on-the-command-line), e.g. you can use `-input=false -refresh=false -var="some_variable=some_value"`.  Defaults to `-input=false -refresh=false`. |
| **tf_plan_environment** | string | `omop-tf-plan-environment` |  This is the name of your [Azure DevOps environment](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops) for **Terraform Plan** which should be completed by your administrator as part of the [prerequisites](#prerequisites). |
| **tf_approval_environment** | string | `omop-tf-approval-environment` |  This is the name of your [Azure DevOps environment](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops) for **Terraform Approval** which should be completed by your administrator as part of the [prerequisites](#prerequisites). |

### Step 3: Run and Validate the Terraform Pipeline

1. Locate pipeline to run that points to the environment directory (e.g. `/infra/terraform/omop`) and run the [pipeline](/pipelines/README.md/#environment-pipeline).  You can review an [example pipeline](/pipelines/environments/TF-OMOP.yaml) for more details.

![Run Environment Pipeline](/docs/media/run_environment_pipeline_1.png)

2. Run the pipeline and ensure you have selected your [bootstrap variable group](/docs/update_your_variable_groups.md/#1-bootstrap-vg) and [bootstrap settings variable group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) for your environment

![Run Environment Pipeline](/docs/media/run_environment_pipeline_2.png)

2. Manually validate resource deployment in Azure portal.

![Azure OMOP Resource Group](/docs/media/azure_omop_resource_group.png)

## Troubleshooting

If you experience any issues please see [infrastructure troubleshooting](/docs/troubleshooting/troubleshooting_infra.md).
