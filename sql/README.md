# SQL Server Notes

The SQL scripts will help with deploying the [Common Data Model](#cdm-notes) and setting up [Web Api](#web-api-notes).

## CDM Notes

The CDM SQL Projects ([Vocabulary DDL](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj) and [Vocabulary Indexes Constraints](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj)) are wrapped as [Dacpacs](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15) for [deployment](#deployment-notes) into Azure SQL.

The scripts in the [CDM v5.3.1 folder](/sql/cdm/v5.3.1/) are based on the SQL Server scripts for the [CommonDataModel 5.3.1](https://github.com/OHDSI/CommonDataModel/tree/v5.3.1/Sql%20Server).

There's also a [vocabulary loading script](/sql/cdm/v5.3.1/omop_vocabulary_ddl/Scripts/Script.PostDeployment.sql) included in the [Vocabulary DDL folder](/sql/cdm/v5.3.1/omop_vocabulary_ddl) which requires [additional setup](#vocabulary-notes).

### Deployment Notes

You can use the [Vocabulary Build Pipeline](/pipelines/README.md/#vocabulary-build-pipeline) to build the artifacts ([script](#post-tf-deploy-script-notes) and [dacpacs](#cdm-notes)) for the vocabulary, and you can use the [Vocabulary Release Pipeline](/pipelines/README.md/#vocabulary-release-pipeline) to publish the artifacts to your Azure SQL CDM.

Similarly, you can use the [Broadsea Build Pipeline](/pipelines/README.md/#broadsea-build-pipeline) to build the [web api script](#web-api-notes) and the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) to publish the script to your Azure SQL CDM.

### Modifications from OHDSI

In standing up the OHDSI CDM, it appeared there were some CDM data model conflicts with [Synthea](https://github.com/OHDSI/ETL-Synthea/blob/master/inst/sql/sql_server/cdm_version/v531/insert_device_exposure.sql) and with the [vocabulary from Athena](https://athena.ohdsi.org/).  As such you can expect to modify CDM to support the incoming data for the vocabulary and for the (synthetic) patient data.

> For example, in a scenario with transformed EHR data, you may need to modify the CDM data model to accommodate the EHR data.  Further, you may also have vocabulary data conflicts, which you can address with a combination of modifying the vocabulary data, as well as the CDM vocabulary schema.

Here's some modifications from the existing [CommonDataModel 5.3.1](https://github.com/OHDSI/CommonDataModel/tree/v5.3.1/Sql%20Server):

1. Expand column `unique_device_id` for [device_exposure table](/sql/cdm/v5.3.1/omop_vocabulary_ddl/dbo/Tables/device_exposure.sql) to address a synthea conflict
2. Remove constraint `uq_concept_synonym` for [concept_synonym table](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/dbo/Tables/concept_synonym.sql) to address a vocabulary conflict, and it's taken out as part of the [5.3.2 release](https://github.com/OHDSI/CommonDataModel/releases/tag/v5.3.2).  Also remove constraint `fpk_concept_synonym_concept` to address a vocabulary conflict.
3. Remove constraints `fpk_concept_ancestor_concept_1` and `fpk_concept_ancestor_concept_2` for [concept_ancestor table](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/dbo/Tables/concept_ancestor.sql) to address a vocabulary conflict
4. Expand column `concept_name` for [concept table](/sql/cdm/v5.3.1/omop_vocabulary_ddl/dbo/Tables/concept.sql) to address a vocabulary conflict
5. Remove constraints `fpk_concept_relationship_c_1` and `fpk_concept_relationship_c_2` for [concept_relationship table](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/dbo/Tables/concept_relationship.sql) to address a vocabulary conflict
6. Remove constraint `fpk_cohort_subject_concept` for [cohort_definition table](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/dbo/Tables/cohort_definition.sql) to address a vocabulary conflict

### Vocabulary Notes

You will need to ensure your Azure Storage Account is already populated with a vocabulary, see the [vocabulary setup](/docs/setup/setup_vocabulary.md) for more details.

The vocabulary load is handled through a [post deployment script](/sql/cdm/v5.3.1/omop_vocabulary_ddl/Scripts/Script.PostDeployment.sql).  This script relies on additonal setup which is handled through the [Post TF Deploy script](/sql/README.md/#post-tf-deploy-script-notes).

This script also relies on the following [SQLCMD variables](https://docs.microsoft.com/en-us/sql/ssms/scripting/sqlcmd-use-with-scripting-variables?view=sql-server-ver15):

| Variable Name | Description  |
|--------------|-----------|
| DSVocabularyBlobStorageName | Name of the linked data source in Azure SQL for your Azure Storage account with your vocabulary files.  This should be setup through your [variables.yaml](/docs/update_your_variables.yaml.md/#dsvocabularyblobstoragename) for your environment. |
| VocabulariesContainerPath | This is the vocabularies container path (e.g. `vocabularies/19-AUG-2021`) which has the vocabulary files.  This should be setup as part of your [variables.yaml](/docs//update_your_variables.yaml.md/#vocabulariescontainerpath) for your environment. |

#### Post TF Deploy script Notes

The [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql) will setup access for Azure SQL and Azure Storage, as well as access for Azure App Service MI and the Azure VMSS MI to access Azure SQL.

This script also relies on the following [SQLCMD variables](https://docs.microsoft.com/en-us/sql/ssms/scripting/sqlcmd-use-with-scripting-variables?view=sql-server-ver15):

| Variable Name | Description  |
|--------------|-----------|
| StorageAccountName | Azure Storage Account name with your [Vocabularies](/docs/setup/setup_vocabulary.md).  For example, if your Azure Storage Account URL is `https://mystorageaccount.blob.core.windows.net` you would use `mystorageaccount`.  This should be setup as part of your [variables.yaml](/docs//update_your_variables.yaml.md/#storageaccount) for your environment. |
| BroadseaAppServiceName | Azure App Service name which hosts the [Broadsea webtools](/docs/setup/setup_atlas_webapi.md) image. This should be setup as part of your [variables.yaml](/docs/update_your_variables.yaml.md/#appsvcname) for your environment.|
| ADOVMSSBuildAgentPoolName | Azure VMSS MI (which is the same name as the Azure VMSS) used for the Azure DevOps Agent Pool as part of the [setup infra prerequisites](/docs/setup/setup_infra.md/#prerequisites).  This should be setup as part of your [variables.yaml](/docs/update_your_variables.yaml.md/#adovmssbuildagentpoolname) for your environment. |

## Web Api Notes

The [Web Api Refresh script](/sql/scripts/Web_Api_Refresh.sql) can be used to refresh [Web Api](https://github.com/OHDSI/WebAPI) using the [Broadsea Release Pipeline](/pipelines/broadsea_release_pipeline.yaml).

You can refer to the [broadsea build pipeline notes](/pipelines/README.md/#broadsea-build-pipeline) and the [broadsea release pipeline notes](/pipelines/README.md/#broadsea-release-pipeline) for how the script is used.

This script also relies on the following [SQLCMD variables](https://docs.microsoft.com/en-us/sql/ssms/scripting/sqlcmd-use-with-scripting-variables?view=sql-server-ver15):

| Variable Name | Description  |
|--------------|-----------|
| SQL_SERVER_NAME | Azure SQL Server Name (e.g. `my-sql-server` if you using `my-sql-server.database.windows.net`).  This should be setup as part of your [variables.yaml](/docs/update_your_variables.yaml.md/#sqlservername) for your environment. |
| SQL_DATABASE_NAME | Azure SQL Database Name (e.g. `my-sql-server-db`) which has the CDM.  This should be setup as part of your [variables.yaml](/docs/update_your_variables.yaml.md/#sqlserverdbname) for your environment. |