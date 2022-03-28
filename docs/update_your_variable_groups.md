# Updating your Variable Groups

The [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#setup-azure-devops) will setup [Azure DevOps Variable Groups](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?msclkid=ae56333ca94a11ec876141a976a04b73&view=azure-devops&tabs=yaml) in your environment, including:

* Two (2) variable groups for environment setup:
    1. A variable group ending with `bootstrap-vg` which is linked to [Azure Key Vault secrets](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) to run with your Environment Pipeline
    2. A variable group ending with `bootstrap-settings-vg` which is **not** linked to Azure Key Vault to configure running your Environment pipeline
* One (1) variable group ending with `env-rg` for application pipelines per environment

You can of course work with your administrator to modify the [terraform](/infra/terraform/bootstrap/main.tf) to reflect desired changes, and you can also look to update some of the settings in Azure DevOps once the variable groups are made available.

## Prerequisites

1. You will need to access a successfully completed Dev Environment based on the [infrastructure setup](/infra/README.md).

## Variable Groups

You can review how the variable groups are used in the following sections.

### 1. Bootstrap VG

This variable group (ending in `bootstrap-vg`) will pick up [Azure Key Vault secrets](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) which will then be used by the [Environment Pipeline](/pipelines/README.md/#environment-pipeline).

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| bootstrapAdminObjectId | string | `some-guid` | This is the bootstrap admin object_id (e.g. the administrator has logged into Azure CLI using `az login` and can run `az ad signed-in-user show` to retrieve their `object_id`, see the [docs](https://docs.microsoft.com/en-us/cli/azure/ad/signed-in-user?msclkid=079fdfb0a97711ec81390314e3967d78&view=azure-cli-latest) for more details). |
| omopPassword | string | `replaceP@SSW0RD` | This is the Azure SQL administrative password, and should come from an [Azure Key Vault Secret](https://docs.microsoft.com/en-us/azure/key-vault/secrets/about-secrets?msclkid=887f3060a97711ecac7382204b3ea023). |
| spServiceConnectionObjectId | string | `some-guid` | This is the Azure DevOps Service Principal used for the Azure DevOps Service Connection.  This value should come from an [Azure Key Vault Secret](https://docs.microsoft.com/en-us/azure/key-vault/secrets/about-secrets?msclkid=887f3060a97711ecac7382204b3ea023).  |
| vmssManagedIdentityObjectId | string | `some-guid` | This is the Azure VMSS Managed Identity used for the [Azure DevOps VMSS Agent Pool](/infra/terraform/bootstrap/README.md/#setup-azure-devops).  This value should come from an [Azure Key Vault Secret](https://docs.microsoft.com/en-us/azure/key-vault/secrets/about-secrets?msclkid=887f3060a97711ecac7382204b3ea023).  |

### 2. Bootstrap Settings VG

This variable group (ending in `bootstrap-settings-vg`) is **not** linked to Azure Key Vault.  This variable group is also used by the [Environment Pipeline](/pipelines/README.md/#environment-pipeline).

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| aad_admin_login_name | string | `my-omop-sql-server-admins` | This is the Azure AD Group name that will be added as an [Azure SQL Server AD Administrator](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?msclkid=79f8d6b2a97811ec80227a313d713490&tabs=azure-powershell).  This Azure AD group should be provisioned by your administrator. |
| aad_admin_object_id | string | `some-guid` | This is the Azure AD Group Object Id that will be added as an [Azure SQL Server AD Administrator](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?msclkid=79f8d6b2a97811ec80227a313d713490&tabs=azure-powershell).  This Azure AD group should be provisioned by your administrator. |
| aad_directory_readers_login_name | string | `my-omop-sql-server-directory-readers` | This is the Azure AD Group name that will be assigned [Directory Reader for your Azure SQL Server Managed Identity](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group).  This Azure AD group should be provisioned by your administrator. |
| aad_directory_readers_object_id | string | `some-guid` | This is the Azure AD Group Object Id that will be assigned [Directory Reader for your Azure SQL Server Managed Identity](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role-tutorial#add-azure-sql-managed-identity-to-the-group).  This Azure AD group should be provisioned by your administrator. |
| acr_sku_edition | string | `Premium` | This is the SKU for your [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus?msclkid=a5537ec1aa1111eca1ac128561448abb) in your [Environment](/infra/terraform/omop/README.md).  The default is `Premium` as this SKU supports networking rules. |
| ado_agent_pool_vmss_name | string | `some-ado-build-vmss-agent` | This is the name of your [Azure VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops) used for Azure DevOps, see the notes for [more details](#adoagentpoolvmssname) |
| adoVMSSBuildAgentPoolName | string | `some-ado-build-agent-vmss-pool` | This is the name of the Azure Virtual Machine Scale Set used for the Azure DevOps Agent Pool, see [where to find it](#adovmssbuildagentpoolname). |
| asp_kind_edition | string | `Linux` | This is the Operating System for your [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) in your [Environment](/infra/terraform/omop/README.md), and the default is `Linux` to host the [broadsea-webtools container](/apps/broadsea-webtools/README.md). |
| asp_sku_tier | string | `PremiumV2` |  This is the tier for your [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) in your [Environment](/infra/terraform/omop/README.md), and the default is `PremiumV2`. |
| asp_sku_size | string | `P2V2` | This is the size for your [Azure App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) in your [Environment](/infra/terraform/omop/README.md), and the default is `P2V2`. |
| azure_service_connection_name | string | `sp-omop-service-connection` | This is the name of your [Azure DevOps Service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) for your Azure DevOps project. |
| cdr_vocab_container_name | string | `vocabularies` | The name of the blob container in the CDR storage account that will be used for vocabulary file uploads for your [Environment](/infra/terraform/omop/README.md).  The default is `vocabularies`. |
| environment | string | `dev` | This is the designated environment (from your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#step-1-update-terraformtfvars)), see the notes for [more details](#environment). |
| location | string | `westus3` | This is the location for the bootstrap resource group for your TF environment and will be used for your [Environment](/infra/terraform/omop/README.md).  The default is `westus3`. |
| omop_db_size | string | `100` | This is the size in Gb for your [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-single-databases) in your [Environment](/infra/terraform/omop/README.md). |
| omop_db_sku | string | `GP_Gen5_2` | This is the SKU for your [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-single-databases) in your [Environment](/infra/terraform/omop/README.md). |
| prefix | string | `sharing` | This is the prefix for your environment (from your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#step-1-update-terraformtfvars)), see the notes for [more details](#prefix). |
| tf_approval_environment | string | `omop-tf-apply-environment` | This is the name of your `terraform apply` [Azure DevOps Environment](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops) for your Azure DevOps project. |
| tf_plan_environment | string | `omop-tf-apply-environment` | This is the name of your `terraform plan` [Azure DevOps Environment](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops) for your Azure DevOps project. |
| tf_state_filename | string | `terraform.tfstate` | This is the name of your [Terraform State file in Azure Storage](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli). |
| tf_storage_account_name | string | `sometfstatesa` | This is the name of your Azure Storage account which has your [Terraform State file](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli). |
| tf_storage_container_name | string | `some-statefile-container` | This is the container name in your Azure Storage account which has your [Terraform State file](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli). |
| tf_storage_region | string | `westus3` | This is the region for your Azure Storage account which has your [Terraform State file](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli). |
| tf_storage_resource_group | string | `some-ado-bootstrap-omop-rg` | This is the [bootstrap resource group](/infra/terraform/bootstrap/README.md/#setup-azure-bootstrap-resource-group) name for your Azure Storage account which has your [Terraform State file](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli). |

### 3. Environment VG

The following variables are included through the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#setup-azure-devops) which should be used by your pipelines (e.g. [vocabulary build pipeline](/pipelines/README.md/#vocabulary-build-pipeline), [vocabulary release pipeline](/pipelines/README.md/#vocabulary-release-pipeline), [broadsea build pipeline](/pipelines/README.md/#broadsea-build-pipeline), and [broadsea release pipeline](/pipelines/README.md/#broadsea-release-pipeline)).

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| adoAgentPoolVMSSName | string | `some-ado-build-agent-vmss` | This is the name of the Azure Virtual Machine Scale Set used for the Azure DevOps Agent Pool, see [where to find it](#adoagentpoolvmssname). |
| adoAgentPoolWindowsVMSSName | string | `some-ado-build-agent-windows-vmss` | This is the name of the Azure Windows Virtual Machine Scale Set used for the Azure DevOps Agent Pool, see [where to find it](#adoagentpoolwindowsvmssname). |
| adoVMSSBuildAgentPoolName | string | `some-ado-build-agent-vmss-pool` | This is the name of the Azure Virtual Machine Scale Set used for the Azure DevOps Agent Pool, see [where to find it](#adovmssbuildagentpoolname). |
| adoWindowsVMSSBuildAgentPoolName | string | `some-ado-build-agent-windows-vmss-pool` | This is the name of the Azure Windows Virtual Machine Scale Set used for the Azure DevOps Agent Pool, see [where to find it](#adowindowsvmssbuildagentpoolname). |
| appSvcName | string | `my-app-service` | This is the name of the Azure App Service for Broadsea, see [where to find it](#appsvcname). |
| appSvcRg | string | `my-rg-CI` | This is the Resource Group name which hosts the Azure App Service, see [where to find it](#appsvcrg). |
| broadseaBuildPipelineName | string | `Broadsea Build Pipeline` | This is the default name for the [Broadsea Build Pipeline](/pipelines/README.md/#broadsea-build-pipeline) after you import the pipeline with the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#setup-azure-devops). |
| broadseaReleasePipelineName | string | `Broadsea Release Pipeline` | This is the default name for the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) after you import the pipeline with the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#setup-azure-devops). |
| cdmSchema | string | `dbo` | This is the CDM schema used.  For more details you can [check the notes](#cdmschema). |
| cdmVersion | string | `5.3.1` | This is the CDM Version used.  For more details you can [check the notes](#cdmversion).|
| containerRegistry | string | `my-container-registry` | This is the Azure Container Registry Name, see [where to find it](#containerregistry). |
| dSVocabularyBlobStorageName | string | `DSVocabularyBlobStorage` | Set to `DSVocabularyBlobStorage` which should match the name of the external data source mapped in Azure SQL.  If the name of the external data source is different, use the appropriate value.  See [where to find it](#dsvocabularyblobstoragename) |
| environment | string | `dev` | This is the designated environment (from your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#step-1-update-terraformtfvars)), see the notes for [more details](#environment). |
| prefix | string | `sharing` | This is the prefix for your environment (from your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#step-1-update-terraformtfvars)), see the notes for [more details](#prefix). |
| resultsSchema | string | `webapi` | This is the webapi schema used.  For more details you can [check the notes](#resultsschema). |
| serviceConnection | string | `my-service-connection` | This is the name of the Azure DevOps Service Connection to the Azure Subscription, see the notes for [more details](#serviceconnection). |
| sqlServerDbName | string | `my-sql-server-db` | This is the name of the Azure SQL Server DB, see [where to find it](#sqlserverdbname). |
| sqlServerName | string | `my-sql-server` | This is the logical Azure SQL Server Name, see [where to find it](#sqlservername). |
| storageAccount | string | `sharingdevomopsa` | Set to `sharingdevomopsa` which should match the name of the storage account used by the [dSVocabularyBlobStorageName](#dsvocabularyblobstoragename) in Azure SQL.  See [where to find it](#storageaccount) |
| syntheaSchema | string | `synthea` | This is the synthea schema used.  For more details you can [check the notes](#syntheaschema). |
| syntheaVersion | string | `2.7.0` | This is the synthea version used.  For more details you can [check the notes](#syntheaversion). |
| vocabSchema | string | `dbo` | This is the vocab schema used.  For more details you can [check the notes](#vocabschema). |
| vocabulariesContainerPath | string | `vocabularies/19-AUG-2021` | This is path in the Azure Storage account where the vocabularies to load can be found, see [where to find it](#vocabulariescontainerpath).  For example, if the vocabulary file `CONCEPT.csv` is stored under `vocabularies/19-AUG-2021/CONCEPT.csv` then you would want to use `vocabularies/19-AUG-2021` as the value.  Further note that the file names and file paths are case sensitive. |
| vocabularyBuildPipelineId | string | `21` | This is the Azure DevOps Build definition id for your [vocabulary build pipeline](/pipelines/README.md/#vocabulary-build-pipeline) after it is imported through the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#setup-azure-devops). |
| vocabularyBuildPipelineName | string | `Vocabulary Build Pipeline` | This is the Azure DevOps Build Pipeline name for your [vocabulary build pipeline](/pipelines/README.md/#vocabulary-build-pipeline) after it is imported through the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#setup-azure-devops).  The default is `Vocabulary Build Pipeline` |
| vocabularyReleasePipelineName | string | `Vocabulary Release Pipeline` | This is the Azure DevOps Build Pipeline name for your [vocabulary release pipeline](/pipelines/README.md/#vocabulary-release-pipeline) after it is imported through the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#setup-azure-devops).  The default is `Vocabulary Release Pipeline` |
| vocabularyVersion | string | `19-AUG-2021` | This is the vocabulary version path in the Azure Storage account container where the vocabularies to load can be found, see [where to find it](#vocabularyversion).  For example, if the vocabulary file `CONCEPT.csv` is stored under `vocabularies/19-AUG-2021/CONCEPT.csv` then you would want to use `19-AUG-2021` as the value.  Further note that the file names and file paths are case sensitive. |
| webapiSources | string | https://my-app-service.azurewebsites.net/WebAPI/source | This is the endpoint for working with WebAPI, see [where to find it](#webapisources). |

## Details for the Variable Values

These are notes on where to find the values to supply to your variable groups to reflect your environment settings.

### adoAgentPoolVMSSName

> Also known as `ado_agent_pool_vmss_name` for your [environment pipeline](/pipelines/README.md/#environment-pipeline).

1. Check your Azure DevOps project settings and navigate to your Azure DevOps Agent pools which is using your [Azure VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops)

![Azure Devops Agent Pool VMSS Name](/docs/media/azure_devops_agent_pool_vmss_name.png)

### adoAgentPoolWindowsVMSSName

1. Check your Azure DevOps project settings and navigate to your Azure DevOps Agent pools which is using your [Azure VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops)

![Azure Devops Agent Pool Windows VMSS Name](/docs/media/azure_devops_agent_pool_vmss_name.png)

### adoVMSSBuildAgentPoolName

1. Check your Azure DevOps project settings and navigate to your Azure DevOps Agent pools which is using your [Azure VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops)

![Azure Devops VMSS Agent Pool Name](/docs/media/azure_devops_vmss_agent_pool_name.png)

### adoWindowsVMSSBuildAgentPoolName

1. Check your Azure DevOps project settings and navigate to your Azure DevOps Agent pools which is using your [Azure Windows VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops)

![Azure Devops VMSS Agent Pool Name](/docs/media/azure_devops_vmss_agent_pool_name.png)

### appSvcName

1. You can check your Resource Group and get the name of your Azure App Service for your environment.
    * You can also filter the resources and search for `app service`

![Azure App Service Name](/docs/media/azure_app_service_name.png)

### appSvcRg

1. You can check your Resource Group which contains your Azure App Service for your environment.

![Azure App Service RG Name](/docs/media/azure_app_service_rg_name.png)

### cdmSchema

1. `cdmSchema` should be set to `dbo` as a default value.  If the CDM is populated in a different schema in Azure SQL you should update the value to the new schema name.

### cdmVersion

1. `cdmVersion` should be set to `5.3.1` as a default value.  This value reflects the [CDM 5.3.1](https://github.com/OHDSI/CommonDataModel/blob/v5.3.1/Sql%20Server/OMOP%20CDM%20sql%20server%20ddl.txt) schema populated in Azure SQL.

### containerRegistry

1. You can check your Resource Group and get the name of your Azure Container Registry for your environment.
    * You can also filter the resources and search for `container registry`:

![Azure Container registry name](/docs/media/azure_container_registry_name.png)

### dSVocabularyBlobStorageName

1. Connect to Azure SQL in your environment
    * Confirm that you have set up your data source in Azure SQL, which should be covered through the prior step to [create your MI credential and setup your data source](/sql/README.md/#vocabulary-notes)

2. This value should correspond with your [Post_TF_Deploy script](/sql/scripts/Post_TF_Deploy.sql) used by the [Vocabulary Build Pipeline](/pipelines/README.md/#vocabulary-build-pipeline) and the [Vocabulary Release Pipeline](/pipelines/README.md/#vocabulary-release-pipeline):

```sql
    -- The name of the Data source is DSVocabularyBlobStorage
    CREATE EXTERNAL DATA SOURCE DSVocabularyBlobStorage
    ...
```

### environment

1. This is a designation that you will set in your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#step-1-update-terraformtfvars) which can indicate the environment as part of the naming convention for your OHDSI on Azure resources.  For example, your OMOP resource group could be named `sharing-dev-omop-rg` if your [prefix](#prefix) is `sharing` and your `environment` is `dev`.

### prefix

1. This is a designation that you will set in your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#step-1-update-terraformtfvars) which can indicate the prefix as part of the naming convention for your OHDSI on Azure resources.  For example, your OMOP resource group could be named `sharing-dev-omop-rg` if your `prefix` is `sharing` and your [environment](#environment) is `dev`.

### resultsSchema

1. `resultsSchema` should be set to `webApi` as a default value.  Having a separate schema for the `webApi` objects in Azure SQL is advisable.

### serviceConnection

1. Check your Azure DevOps project settings and navigate to the service connections
    * If you have rights to view your service connection, you should find one which matches with your environment, e.g. `my-service-connection`.

![Service Connection Name](/docs/media/azure_devops_service_connection_name.png)

### sqlServerDbName

1. You can check your Resource Group and get the name of your Azure SQL Server DB for your environment.
    * You can also filter the resources and search for `SQL DB`:

![Azure SQL Server DB Name](/docs/media/azure_sql_server_db_name.png)

### sqlServerName

1. You can check your Resource Group and get the name of your Azure SQL Server for your environment.
    * You can also filter the resources and search for `SQL Server`:

![Azure SQL Server Name](/docs/media/azure_sql_server_name.png)

### storageAccount

1. Connect to your RG in the Azure Portal
    * Check for the storage account which holds your vocabulary

![Vocabulary Azure Storage Account Name](/docs/media/azure_storage_account_name.png)

### syntheaSchema

1. `syntheaSchema` should be set to `synthea` as a default value.  Having a separate schema for the `synthea` objects in Azure SQL is advisable.
a.  This is also used as part of the [Broadsea Release Pipelines](/pipelines/README.md/#broadsea-release-pipeline) to generate the synthea-based population in Azure SQL.

### syntheaVersion

1. `syntheaVersion` should be set to `2.7.0` as a default value.  See [Synthea documentation](https://github.com/OHDSI/ETL-Synthea#step-by-step-example).

### vocabSchema

1. `vocabSchema` should be set to `dbo` as a default value.  If the vocabulary is populated in a different schema in Azure SQL you should update the value to the new schema name.

### vocabulariesContainerPath

1. Open your Azure Storage account in your environment using [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)
    * Check the storage account `vocabularies` container for your corresponding vocabulary.
    * In this example the vocabulary file `CONCEPT.csv` is stored under `vocabularies/19-AUG-2021/CONCEPT.csv`, so the value you should use is `vocabularies/19-AUG-2021` which includes the [vocabularyVersion](#vocabularyVersion).
![image.png](/docs/media/vocabulary_container_path.png)

> Note that the file names and file paths are case sensitive.

### vocabularyVersion

1. Open your Azure Storage account in your environment using [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)
    * Check the storage account `vocabularies` container for your corresponding vocabulary.
    * In this example the vocabulary file `CONCEPT.csv` is stored under `vocabularies/19-AUG-2021/CONCEPT.csv`, so the value you should use is `19-AUG-2021`.
![Vocabulary Version](/docs/media/vocabulary_storage_account.png)

> Note that the file names and file paths are case sensitive.

### webapiSources

1. This is derived from your [appSvcName](#appsvcname)
    * You will need to replace the value `replace-me` in `https://<replace-me>.azurewebsites.net/WebAPI/source` with your [appSvcName](#appsvcname)

![Azure App Service URL](/docs/media/azure_app_service_url.png)
