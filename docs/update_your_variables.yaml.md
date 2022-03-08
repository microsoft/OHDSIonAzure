# Updating your Variables.yaml

As you update your [variables.yaml](/pipelines/variables.yaml) to reflect your environment settings you may need to track down some values.

## Prerequisites

1. You will need to access a successfully completed Dev Environment based on the [infrastructure setup](/infra/README.md).

## List of Variables

The following is a list of variables used in the [variables.yaml](/pipelines/variables.yaml).

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| environment | string | `DEV` | This is the designated environment, see the notes for [more details](#environment). |
| serviceConnection | string | `my-service-connection` | This is the name of the Azure DevOps Service Connection to the Azure Subscription, see the notes for [more details](#serviceconnection). |
| adoVMSSBuildAgentPoolName | string | `vmssagentspool` | This is the name of the Azure Virtual Machine Scale Set used for the Azure DevOps Agent Pool, see [where to find it](#adovmssbuildagentpoolname). |
| containerRegistry | string | my-container-registry | This is the Azure Container Registry Name, see [where to find it](#containerregistry). |
| appSvcRg | string | my-rg-CI | This is the Resource Group name which hosts the Azure App Service, see [where to find it](#appsvcrg). |
| appSvcName | string | my-app-service | This is the name of the Azure App Service for Broadsea, see [where to find it](#appsvcname). |
| sqlServerName | string | my-sql-server | This is the logical Azure SQL Server Name, see [where to find it](#sqlservername). |
| sqlServerDbName | string | my-sql-server-db | This is the name of the Azure SQL Server DB, see [where to find it](#sqlserverdbname). |
| vocabulariesContainerPath | string | `vocabularies` | This is path in the Azure Storage account where the vocabularies to load can be found, see [where to find it](#vocabulariescontainerpath).  For example, if the vocabulary file `CONCEPT.csv` is stored under `vocabularies/19-AUG-2021/CONCEPT.csv` then you would want to use `vocabularies` as the value.  Further note that the file names and file paths are case sensitive. |
| vocabularyVersion | string | `19-AUG-2021` | This is the vocabulary version path in the Azure Storage account container where the vocabularies to load can be found, see [where to find it](#vocabularyversion).  For example, if the vocabulary file `CONCEPT.csv` is stored under `vocabularies/19-AUG-2021/CONCEPT.csv` then you would want to use `19-AUG-2021` as the value.  Further note that the file names and file paths are case sensitive. |
| dSVocabularyBlobStorageName | string | `DSVocabularyBlobStorage` | Set to `DSVocabularyBlobStorage` which should match the name of the external data source mapped in Azure SQL.  If the name of the external data source is different, use the appropriate value.  See [where to find it](#dsvocabularyblobstoragename) |
| storageAccount | string | `sharingdevomopsa` | Set to `sharingdevomopsa` which should match the name of the storage account used by the [dSVocabularyBlobStorageName](#dsvocabularyblobstoragename) in Azure SQL.  See [where to find it](#storageaccount) |
| webapiSources | string | https://my-app-service.azurewebsites.net/WebAPI/source | This is the endpoint for working with WebAPI, see [where to find it](#webapisources). |
| cdmVersion | string | 5.3.1 | This is the CDM Version used.  For more details you can [check the notes](#cdmversion).|
| cdmSchema | string | dbo | This is the CDM schema used.  For more details you can [check the notes](#cdmschema). |
| syntheaSchema | string | synthea | This is the synthea schema used.  For more details you can [check the notes](#syntheaschema). |
| vocabSchema | string | dbo | This is the vocab schema used.  For more details you can [check the notes](#vocabschema). |
| resultsSchema | string | webapi | This is the webapi schema used.  For more details you can [check the notes](#resultsschema). |
| syntheaVersion | string | 2.7.0 | This is the synthea version used.  For more details you can [check the notes](#syntheaversion). |

## Details for the Variable Values

These are notes on where to find the values to supply to your [variables.yaml](/pipelines/variables.yaml) to reflect your environment settings.

### environment

1. This is the corresponding environment value for your environment.  Example values should be `INT`, `QA`, `STG`, and `PROD`.  You can also set this to your own value like `DEV`.

### serviceConnection

1. Check your Azure DevOps project settings and navigate to the service connections
    * If you have rights to view your service connection, you should find one which matches with your environment, e.g. `my-service-connection`.

![Service Connection Name](/docs/media/azure_devops_service_connection_name.png)

> If you are unable to view the appropriate one for your environment, reach out to your Administrator to get the appropriate value.

### adoVMSSBuildAgentPoolName

1. Check your Azure DevOps project settings and navigate to your Azure DevOps Agent pools which is using your [Azure VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops)

![Azure Devops Agent Pool VMSS Name](/docs/media/azure_devops_agent_pool_vmss_name.png)

### containerRegistry

1. You can check your Resource Group and get the name of your Azure Container Registry for your environment.
    * You can also filter the resources and search for `container registry`:

![Azure Container registry name](/docs/media/azure_container_registry_name.png)

### appSvcRg

1. You can check your Resource Group which contains your Azure App Service for your environment.

![Azure App Service RG Name](/docs/media/azure_app_service_rg_name.png)

### appSvcName

1. You can check your Resource Group and get the name of your Azure App Service for your environment.
    * You can also filter the resources and search for `app service`

![Azure App Service Name](/docs/media/azure_app_service_name.png)

### sqlServerName

1. You can check your Resource Group and get the name of your Azure SQL Server for your environment.
    * You can also filter the resources and search for `SQL Server`:

![Azure SQL Server Name](/docs/media/azure_sql_server_name.png)

### sqlServerDbName

1. You can check your Resource Group and get the name of your Azure SQL Server DB for your environment.
    * You can also filter the resources and search for `SQL DB`:

![Azure SQL Server DB Name](/docs/media/azure_sql_server_db_name.png)

### vocabulariesContainerPath

1. Open your Azure Storage account in your environment using [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)
    * Check the storage account `vocabularies` container for your corresponding vocabulary.
    * In this example the vocabulary file `CONCEPT.csv` is stored under `vocabularies/19-AUG-2021/CONCEPT.csv`, so the value you should use is `vocabularies` and the [vocabularyVersion](#vocabularyVersion) should be appended.
![image.png](/docs/media/vocabulary_container_path.png)

> Note that the file names and file paths are case sensitive.

### vocabularyVersion

1. Open your Azure Storage account in your environment using [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)
    * Check the storage account `vocabularies` container for your corresponding vocabulary.
    * In this example the vocabulary file `CONCEPT.csv` is stored under `vocabularies/19-AUG-2021/CONCEPT.csv`, so the value you should use is `19-AUG-2021`.
![Vocabulary Version](/docs/media/vocabulary_storage_account.png)

> Note that the file names and file paths are case sensitive.

### dSVocabularyBlobStorageName

1. Connect to Azure SQL in your environment
    * Confirm that you have set up your data source in Azure SQL, which should be covered through the prior step to [create your MI credential and setup your data source](/sql/README.md/#vocabulary-notes)

### storageAccount

1. Connect to your RG in the Azure Portal
    * Check for the storage account which holds your vocabulary

![Vocabulary Azure Storage Account Name](/docs/media/azure_storage_account_name.png)

### webapiSources

1. This is derived from your [appSvcName](#appsvcname)
    * You will need to replace the value `replace-me` in `https://<replace-me>.azurewebsites.net/WebAPI/source` with your [appSvcName](#appsvcname)

![Azure App Service URL](/docs/media/azure_app_service_url.png)

### cdmVersion

1. `cdmVersion` should be set to `5.3.1` as a default value.  This value reflects the [CDM 5.3.1](https://github.com/OHDSI/CommonDataModel/blob/v5.3.1/Sql%20Server/OMOP%20CDM%20sql%20server%20ddl.txt) schema populated in Azure SQL.

### cdmSchema

1. `cdmSchema` should be set to `dbo` as a default value.  If the CDM is populated in a different schema in Azure SQL you should update the value to the new schema name.

### syntheaSchema

1. `syntheaSchema` should be set to `synthea` as a default value.  Having a separate schema for the `synthea` objects in Azure SQL is advisable.
a.  This is also used as part of the [Broadsea Release Pipelines](/pipelines/README.md/#broadsea-release-pipeline) to generate the synthea-based population in Azure SQL.

### vocabSchema

1. `vocabSchema` should be set to `dbo` as a default value.  If the vocabulary is populated in a different schema in Azure SQL you should update the value to the new schema name.

### resultsSchema

1. `resultsSchema` should be set to `webApi` as a default value.  Having a separate schema for the `webApi` objects in Azure SQL is advisable.

### syntheaVersion

1. `syntheaVersion` should be set to `2.7.0` as a default value.  See [Synthea documentation](https://github.com/OHDSI/ETL-Synthea#step-by-step-example).
