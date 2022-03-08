# Infrastructure provisioning
 
The following steps walkthrough setting up infra for OHDSI on Azure.

## Prerequisites

1. You are able to work through the [infra setup notes](/infra/README.md/#setup), including working with your administrator to go through the [administrative steps](/infra/README.md/#administrative-steps) and pushing the [backend state to Azure Storage](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli).

2. You have an Azure DevOps repo which has access to this repository.

3. You (or your Administrator) have configured Azure DevOps, including the following:
    * You have [imported the Azure DevOps pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/clone-import-pipeline?view=azure-devops&tabs=yaml#export-and-import-a-pipeline) from [this repository](/pipelines/)
    * You have [created an environment](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops) including one for **Terraform plan** and one for **Terraform approval**
    * You have [created a service connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml).  Your administrator can refer to the [administrative steps](/infra/README.md/#administrative-steps) for more details to get the SP to use with the Service Connection.  Ensure the Service Principal has the Owner role access to the resource group where we will be deploying resources.
    * You have setup an [Azure DevOps VMSS Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops).  Your administrator can refer to the [administrative steps](/infra/README.md/#administrative-steps) and the [ado bootstrap script](/infra/scripts/ado_bootstrap.sh) for additional guidance.
    * You have [created an Azure DevOps variable group](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml) for sensitive values.  Your administrator can refer to the [administrative steps](/infra/README.md/#administrative-steps) and the [ado bootstrap script](/infra/scripts/ado_bootstrap.sh) for an example.  The variable group should be [linked to Azure KeyVault](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) through the service connection.

4. You have `git clone` the repository

```bash
git clone https://github.com/microsoft/OHDSIonAzure
```

## Steps

Assuming you can complete the [prerequisites](#prerequisites), you can work through the following steps.

### Step 1. Update terraform.tfvars

1. In your local git cloned repo create a feature branch (e.g. [your_alias)]/[new_feature_name]). An example would be `jane_doe/new_feature`

2. You can update your [terraform.tfvars](/infra/terraform/terraform.tfvars) with the following values, which you can confirm with your administrator after they have completed the [administrative steps](/infra/README.md/#administrative-steps)

```
omop_password   = "" # this should be filled in through the pipeline via Azure DevOps Variable Group
prefix          = "sharing"
ad_admin_login_name  = "xxx"
ad_admin_object_id   = "xxx"
```

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| omop_password | string | `replaceThisP@SSW0RD` | While you can fill in this value for local testing, since this is a sensitive value, you should be using the [Azure DevOps Variable Group linked to Azure KeyVault](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) as part of your [TF environment pipeline](/pipelines/README.md/#environment-pipeline).  You can review the approach for [working with sensitive values](#working-with-sensitive-values) for more details. |
| prefix | string | `sharing` | This is a prefix used for your TF environment. |
| ad_admin_login_name | string | `My-DBA-Group` | This is the name for your Azure AD group used for Azure SQL DB Admins. This is a value which should come from your administrator assuming they have worked through the [administrative steps](/infra/README.md/#administrative-steps) including the [sql setup notes](/infra/scripts/sql_bootstrap.sh) |
| ad_admin_object_id | string | `some-guid` | This is the object id for your Azure AD group used for Azure SQL DB Admins. This is a value which should come from your administrator assuming they have worked through the [administrative steps](/infra/README.md/#administrative-steps) including the [sql setup notes](/infra/scripts/sql_bootstrap.sh) |

#### Working with Sensitive Values

When working with sensitive values, you can use an [Azure DevOps Variable Group linked to Azure KeyVault](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) as part of your [TF environment pipeline](/pipelines/README.md/#environment-pipeline).  With this approach, you do not need to check in secrets into your repository, instead, the secrets can be managed with Azure Key Vault for your environment setup.  Furthermore, you can restrict access to your SP used for your Service Connection in Azure Key Vault using an access policy.

Your administrator can help populate the Azure Key Vault and your linked Variable Group, and you can refer to the [administrative steps](/infra/README.md/#administrative-steps) including the [ado bootstrap script](/infra/scripts/ado_bootstrap.sh) for guidance.

### Step 2. Setup the Environment Pipeline

We will initialize the infrastructure using the existing state file.

1. Update your [TF environment pipeline](/pipelines/environments/TF-OMOP-DEV.yaml) variables to include values to reflect your environment.
  > For convenience, variables which may need to be updated for your environment when **just getting started** are marked as bold, e.g. **some setting name**.
  > You will also want to ensure you're using the correct [Azure DevOps Variable Group](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml) which should be setup by your administrator through the [administrative steps](/infra/README.md/#administrative-steps) including the [ado bootstrap script](/infra/scripts/ado_bootstrap.sh).


| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| tf_directory | string | `infra/terraform` | Terraform directory within the repository.  Default is `infra/terraform`. |
| terraform_version | string | `1.1.4` | Terraform Version to use within the pipeline in your environment.  Default is `1.1.4`. |
| pool | string | `Azure Pipelines` | Specify which [Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops&tabs=yaml%2Cbrowser) to use, defaults to `Azure Pipelines` which is [Microsoft Hosted](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops) |
| **azure_service_connection** | string | `sp-service-connection` | This is your SP Service Connection name which has access to your Azure Subscription. |
| **tf_storage_resource_group** | string | `ado-bootstrap-rg` | This is the resource group for your Azure Storage Account with your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file. |
| **tf_storage_region** | string | `westus2` | This is the region for your Azure Storage Account with your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file. |
| **tf_storage_account_name** | string | `omopdevtfstatestoracc` |  This is the storage account name with your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file. |
| **tf_storage_container_name** | string | `dev-omop-statefile-container` |  This is the storage account container name with your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file. |
| **tf_state_filename** | string | `terraform.tfstate` |  This is the name of your [TF backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) state file in Azure Storage. |
| tf_init_command_options | string | `-input=false` | Terraform init [command line options](https://www.terraform.io/cli/commands/init#general-options).  Defaults to `-input=false`. |
| tf_validate_command_options | string | '' | Terraform init [command line options](https://www.terraform.io/cli/commands/validate).  Defaults to ''. |
| tf_refresh_command_options | string | `-input=false -lock=false` | Terraform refresh [command line options](https://www.terraform.io/cli/commands/refresh).  Defaults to `-input=false -lock=false`. |
| tf_plan_command_options | string | `-input=false -lock=false -refresh=false -out plan.out` | Terraform plan [command line options](https://www.terraform.io/cli/commands/plan).  You can also use this to fill in [variables](https://www.terraform.io/language/values/variables#variables-on-the-command-line), e.g. you can use `-input=false -refresh=false -var="some_variable=some_value"`.  Defaults to `-input=false -lock=false -refresh=false -out plan.out`. |
| tf_apply_command_options | string | `-input=false -refresh=false` | Terraform apply [command line options](https://www.terraform.io/cli/commands/apply).  You can also use this to fill in [variables](https://www.terraform.io/language/values/variables#variables-on-the-command-line), e.g. you can use `-input=false -refresh=false -var="some_variable=some_value"`.  Defaults to `-input=false -refresh=false`. |
| **tf_plan_environment** | string | `omop-tf-plan-environment` |  This is the name of your [Azure DevOps environment](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops) for **Terraform Plan** which should be completed by your administrator as part of the [prerequisites](#prerequisites). |
| **tf_approval_environment** | string | `omop-tf-approval-environment` |  This is the name of your [Azure DevOps environment](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops) for **Terraform Approval** which should be completed by your administrator as part of the [prerequisites](#prerequisites). |

### Step 3: Run and Validate the Terraform Pipeline

1. Locate pipeline to run that points to the directory and run the [pipeline](/pipelines/README.md/#environment-pipeline), see an [example pipeline](/pipelines/environments/TF-OMOP-DEV.yaml)

2. Manually validate resource deployment in Azure portal.

## Troubleshooting

If you experience any issues please see [infrastructure troubleshooting](/docs/troubleshooting/troubleshooting_infra.md).
