# Environment Terraform

This Terraform project will setup your OMOP environment for OHDSI on Azure.

![OMOP Environment Setup](/infra/media/infrastructure_deployment.png)

This project will cover the resources in the `OMOP Resource Group`, which is depicted in the right side of the diagram.  This includes the following:

- [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/logical-servers)
- [Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview)
- [Azure Blob Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview)
  * This will host your [Vocabulary Files](/docs/setup/setup_vocabulary.md)
- [Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/overview)
  * This will host your [Broadsea-webtools](/apps/broadsea-webtools/README.md/#broadsea-webtools-notes) container
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro)
  * This will hold container images for [Broadsea-webtools](/apps/broadsea-webtools/README.md) and for [Broadsea-methods](/apps/broadsea-methods/README.md)

## Prerequisites

You will need to ensure you have completed the following steps before running the [OMOP Terraform project](/infra/terraform/omop/main.tf).

1. You (or your administrator) should be able to successfully run the [bootstrap terraform](/infra/terraform/bootstrap/README.md) prior to running this project.

2. You and your Administrator have access to your Azure Subscription
    * Make sure you have [installed Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and [login](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?msclkid=4b5e4270a95711ec9bc7afbe01e61a5a) to your Azure Subscription to confirm

3. You have [imported this git repository](https://docs.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?msclkid=ecf209a2a95611ecaa79334480ca77ad&view=azure-devops) to Azure DevOps

4. You have [installed terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started) locally

5. You have `git clone` the repository

```bash
git clone https://github.com/microsoft/OHDSIonAzure
```

## Steps

Assuming you can complete the [prerequisites](#prerequisites), you can work through the following steps.

### Step 1. Update Your Variables

You can update your Terraform tfvars locally for testing, but you should also update your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) when running your changes through the [Environment Pipeline](/pipelines/README.md#environment-pipeline).

1. In your local git cloned repo create a feature branch (e.g. [your_alias)]/[new_feature_name]). An example would be `jane_doe/new_feature`

2. You can update your [terraform.tfvars](/infra/terraform/omop/terraform.tfvars) with the following values:

```
prefix              = "sharing" # set to a given prefix for your environment

environment         = "dev" # this should match the naming convention for your environment from your bootstrap Terraform project

# this can be set locally for testing purposes, but the values should be passed in through your variable group.  This is for your Azure SQL DB Admin Azure AD Group.
aad_admin_login_name = "some-sharing-DB-Admins"

# this can be set locally for testing purposes, but the values should be passed in through your variable group.  This is for your Azure SQL DB Admin Azure AD Group.
aad_admin_object_id = "some-guid"

# this can be set locally for testing purposes, but the values should be passed in through your variable group.  This is for your Azure SQL Directory Readers Azure AD Group.
aad_directory_readers_login_name = "some-sharing-DB-Directory-Readers"

# this can be set locally for testing purposes, but the values should be passed in through your variable group.  This is for your Azure SQL Directory Readers Azure AD Group.
aad_directory_readers_object_id = "some-guid"
```

You can also review the following table which describes other OMOP Terraform variables.

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| aad_admin_login_name | string | `my-sharing-DBAdmins-group` | This is the Azure AD Group name that will be added as an [Azure SQL Server AD Administrator](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?msclkid=79f8d6b2a97811ec80227a313d713490&tabs=azure-powershell).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| aad_admin_object_id | string | `some-guid` | This is the Azure AD Group Object Id that will be added as an [Azure SQL Server AD Administrator](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?msclkid=79f8d6b2a97811ec80227a313d713490&tabs=azure-powershell).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| aad_directory_readers_login_name | string | `my-omop-sql-server-directory-readers` | This is the Azure AD Group name that will be assigned [Directory Reader for your Azure SQL Server Managed Identity](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| aad_directory_readers_object_id | string | `some-guid` | This is the Azure AD Group Object Id that will be assigned [Directory Reader for your Azure SQL Server Managed Identity](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| acr_sku_edition | string | `Premium` | This is the SKU for your [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus?msclkid=a5537ec1aa1111eca1ac128561448abb), and the default is `Premium` as this SKU supports networking rules.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| ado_agent_pool_vmss_name | string | `some-ado-build-vmss-agent` | This is the name of your [Azure VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops) used for Azure DevOps.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| asp_kind_edition | string | `Linux` | This is the Operating System for your [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans), and the default is `Linux` to host the [broadsea-webtools container](/apps/broadsea-webtools/README.md).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| asp_sku_size | string | `P2V2` | This is the size for your [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans), and the default is `P2V2`.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| asp_sku_tier | string | `PremiumV2` | This is the tier for your [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans), and the default is `PremiumV2`.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| azure_service_connection_name | string | `sp-omop-service-connection` | This is the name of your [Azure DevOps Service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) for your Azure DevOps project.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg).  Note that this will be used to connect to Azure from your environment pipeline but will not be used to deploy an Azure DevOps service connection as this is handled through the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#setup-azure-devops) |
| cdr_vocab_container_name | string | `vocabularies` | The name of the blob container in the CDR storage account that will be used for vocabulary file uploads for your [Environment](/infra/terraform/omop/README.md).  The default is `vocabularies`.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md). |
| environment | string | `dev` | Use this to designate your TF environment.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md). |
| location | string | `westus3` | This is the location for the bootstrap resource group for your TF environment and will be used for your [Environment](/infra/terraform/omop/README.md).  The default is `westus3`.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md). |
| omop_db_size | string | `100` | This is the size in Gb for your [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-single-databases).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| omop_db_sku | string | `GP_Gen5_8` | This is the SKU for your [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-single-databases).  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| omop_password | string | `some-password` | This is your Azure SQL Admin Password, and it is should be populated from your [Key Vault Linked Variable Group](/docs/update_your_variable_groups.md/#1-bootstrap-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md).  You can also read through the guidance for [working with sensitive values](/docs/setup/setup_infra.md#working-with-sensitive-values) for more details. |
| prefix | string | `sharing` | This is a prefix used for your TF environment.  This should be populated from your [Variable Group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg) by the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) |
| tags | string | <code>{<br>&nbsp;&nbsp;"Deployment"  = "OHDSI on Azure"<br>&nbsp;&nbsp;"Environment" = "dev"<br>}</code> | These are the [tags](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?msclkid=dcc71ffdaa0f11ecacbd56b9b50917c5&tabs=json) for your OMOP Azure resource group, and you can use the default specified for your environment. |

### Step 2. Run your Terraform OMOP Project

Assuming you have updated your [variables](/infra/terraform/omop/README.md/#step-1-update-your-variables) for your environment, you can work next on running Terraform locally.

1. Make sure your working directory is the [Environment omop directory](/infra/terraform/omop/)
  
    ```bash
    # from the repository root working directory
    cd infra/terraform/omop
    ```

2. Review the [main.tf resources](/infra/terraform/omop/main.tf) before you run your project

3. Run Terraform for your project:
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

### Step 3. Use your TF Environment Pipeline

While you can run Terraform locally, you should use the [TF environment pipeline](/pipelines/environments/TF-OMOP.yaml) to manage your environment.

1. Ensure you have pushed your [backend state to Azure Storage](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) which should be made available through the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md#setup-azure-bootstrap-resource-group)

2. Run the [TF environment pipeline](/pipelines/environments/TF-OMOP.yaml) with your branch, and validate the Azure Resources appear in your environment resource group in the Azure Portal

![Validate Azure OMOP Resource Group](/docs/media/azure_omop_resource_group.png)

### Step 4. Run Post Terraform Deployment Steps

Assuming your [environment pipeline](#step-3-use-your-tf-environment-pipeline) ran successfully, you will need to work with your administrator to ensure your Azure App Service for [broadsea-webtools](/apps/broadsea-webtools/README.md) can connect to Azure SQL.

1. Navigate to your successful Azure DevOps [Environment pipeline](/pipelines/README.md/#environment-pipeline) run and check the outputs for the terraform apply task

![Add Azure App Service to Azure SQL AD Group](/docs/media/environment_pipeline_2.png)

2. Share the command with your administrator and ensure they are able to successfully run the Azure CLI command.  This command will add your [Azure App Service Managed Identity](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity) and your [Azure SQL Server Managed Identity](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group) to your Azure AD group which is an [Azure AD Administrator for your Azure SQL](/infra/terraform/bootstrap/README.md/#setup-azure-ad-group).  You will also need to add in your [Azure SQL Server Managed Identity to your Directory Readers Azure AD Group](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group), and the Azure AD Group should be setup by your administrator through the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md#setup-azure-ad-group).

Your administrator should modify this [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) command and run it for your environment:

```bash
# Add your Azure App Service Managed Identity to Azure AD Group
az ad group member add -g $myAzureADGroupObjectId --member-id $myAzureAppServiceMIPrincipalId

# Add your Azure SQL Managed Identity to Azure AD Group for Directory Readers
az ad group member add -g $myAzureADGroupDirectoryReadersObjectId --member-id $myAzureSQLMIPrincipalId
```

3. You will also need to run the query with your [Azure SQL Azure AD Administrator](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?tabs=azure-powershell) in Azure SQL to ensure that your Managed Identities can access Azure SQL.  For convenience, you can also check the outputs in the terraform apply task in your Azure DevOps [Environment pipeline](/pipelines/README.md/#environment-pipeline).
    > This step is a workaround in case you have not assigned the [Directory Readers](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial#assign-directory-readers-permission-to-the-sql-logical-server-identity) role for your Azure SQL Managed Identity (directly or through Azure AD Group membership).  See [step 2](/infra/terraform/omop/README.md#step-2-run-your-terraform-omop-project) for more details.  If your Azure SQL Managed Identity has Directory Readers assigned, then the [Post TF Deploy script](/sql/README.md/#post-tf-deploy-script-notes) should be able to grant access for Azure SQL.

![Add Azure App Service and Azure VMSS access to Azure SQL](/docs/media/environment_pipeline_3.png)

Your administrator should modify this SQL Query and run it with your Azure SQL Database for your environment:

> You can use various methods to connect to [Azure SQL to run a query](https://docs.microsoft.com/en-us/azure/azure-sql/database/connect-query-content-reference-guide).   [SQL Server Management Studio](https://docs.microsoft.com/en-us/azure/azure-sql/database/connect-query-ssms) was used for this guide.

```sql
-- Grant access to your Azure App Service MI in Azure SQL
CREATE USER [MyBroadseaAppServiceName] FROM EXTERNAL PROVIDER
ALTER ROLE db_datareader ADD MEMBER [MyBroadseaAppServiceName]
ALTER ROLE db_datawriter ADD MEMBER [MyBroadseaAppServiceName]
ALTER ROLE db_owner ADD MEMBER [MyBroadseaAppServiceName]

-- Grant access to your Azure VMSS MI used for the Agent Pool in Azure SQL
CREATE USER [MyADOAgentPoolVMSSName] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [MyADOAgentPoolVMSSName]
ALTER ROLE db_datawriter ADD MEMBER [MyADOAgentPoolVMSSName]
ALTER ROLE db_owner ADD MEMBER [MyADOAgentPoolVMSSName]
```

4. Connect your [Azure DevOps Agent Pool to your Azure VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops).

  > As a one-time step, you will need to ensure that you have a matching name for you Azure DevOps Agent Pool in your Azure DevOps pipeline before you run the pipeline, which will allow Azure DevOps to authorize your pipeline with your newly added Azure DevOps Agent Pool.  Once you have authorized your pipeline, you can update the pipeline to instead pull the Azure DevOps Agent pool name from a variable in your [Variable Group](/docs/update_your_variable_groups.md/#3-environment-vg).  This approach is applicable to the [pipelines](/pipelines/README.md/) which can use the Variable Group to source the pool name.
  
  The following example shows how you can enable your pipeline to authorize the pool.  This is for your [Broadsea Release Pipeline](/pipelines/README.md#broadsea-release-pipeline), but the same approach can be applied for your [Broadsea Build Pipeline](/pipelines/README.md#broadsea-build-pipeline), your [Vocabulary Release Pipeline](/pipelines/README.md#vocabulary-release-pipeline), and your [Environment Pipeline](/pipelines/README.md#environment-pipeline):

  ```yaml
  ...
  # pool: $(adoVMSSBuildAgentPoolName) # re-enable when VMSS is ready and you have granted access to the agent pool
  
  pool: 'some-ado-build-linux-vmss-agent-pool' # this should match the name of your azure devops VMSS agent pool.  You can comment this out when you have authorized your Azure DevOps agent pool and then rely on the variable from your Variable Group.
  ...
  ```
  
  You should see a prompt similar to the following to authorize your pipeline:

  ![Authorize Broadsea Release Pipeline](/docs/media/broadsea_release_pipeline_achilles_etl_synthea_0.png)

  Once you have authorized the pipeline to use your Azure DevOps Agent Pool, you can update your [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) to use a variable from your [Variable Group](/docs/update_your_variable_groups.md/#3-environment-vg) instead:

  ```yaml
  ...
  pool: $(adoVMSSBuildAgentPoolName) # re-enable when VMSS is ready and you have granted access to the agent pool
  
  # pool: 'some-ado-build-linux-vmss-agent-pool' # this should match the name of your azure devops VMSS agent pool.  You can comment this out when you have authorized your Azure DevOps agent pool and then rely on the variable from your Variable Group.
  ...
  ```

  For your [Vocabulary Build Pipeline](/pipelines/README.md#vocabulary-build-pipeline), you can also use a similar approach to authorize the pipeline to use the Agent Pool VMSS.

  You can use the name of the Agent Pool
  ```yaml
  ...
  # pool: $(adoWindowsVMSSBuildAgentPoolName) # re-enable when Azure Windows VMSS is ready and you have granted access to the agent pool
  
  pool: 'some-ado-build-windows-vmss-agent-pool' # this should match the name of your azure devops Windows VMSS agent pool.  You can comment this out when you have authorized your Azure DevOps agent pool and then rely on the variable from your Variable Group.
  ...
  ```

  Once you have authorized the agent pool for your pipeline, you can update the pipeline to use your variable group instead:
  
  ```yaml
  ...
  pool: $(adoWindowsVMSSBuildAgentPoolName) # re-enable when Azure Windows VMSS is ready and you have granted access to the agent pool
  
  # pool: 'some-ado-build-windows-vmss-agent-pool' # this should match the name of your azure devops Windows VMSS agent pool.  You can comment this out when you have authorized your Azure DevOps agent pool and then rely on the variable from your Variable Group.
  ...
  ```