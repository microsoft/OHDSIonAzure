# Troubleshooting Vocabulary

Here's some notes around troubleshooting vocabulary.

1. Verify [Vocabulary Data Conforms](#verify-vocabulary-data-conforms)
    * You can also check on the [Empty source_to_concept_map.csv](#empty-source_to_concept_map.csv)

2. Connecting [Azure SQL and Azure Storage](#connecting-azure-sql-and-azure-storage)

3. Checking on [Data Load through Pipeline Timeouts](#data-load-through-pipeline-timeouts)

## Verify the appropriate SQL settings

1.  Verify the storage account is configured as a data source

    ```
    SELECT
        eds.[name],
        eds.[location],
        eds.[type_desc]
    FROM sys.external_data_sources eds
    WHERE eds.name = 'DSVocabularyBlobStorage'
    ```
1. Verify the MI Service connection is configured for access:

   ```
   SELECT NAME AS username,
         create_date,
         modify_date,
         TYPE_DESC AS TYPE,
         authentication_type_desc AS authentication_type
   FROM sys.database_principals
   WHERE TYPE NOT IN ('A', 'G', 'R', 'X')
         AND SID IS NOT NULL
         AND NAME != 'guest'
   ORDER BY username;
   ```

## Verify Data is in the Storage container

Using [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/), you can validate that the Vocabulary Files are populated in the storage account container with the corresponding file name based on the initial setup steps:

| Vocabulary Filename | Target Table | Note |
|--|--|--|
| CONCEPT.csv | concept |  |
| CONCEPT_ANCESTOR.csv | concept_ancestor |  |
| CONCEPT_CLASS.csv | concept_class |  |
| CONCEPT_RELATIONSHIP.csv | concept_relationship |  |
| CONCEPT_SYNONYM.csv | concept_synonym |  |
| DOMAIN.csv | domain |  |
| DRUG_STRENGTH.csv | drug_strength |  |
| RELATIONSHIP.csv | relationship |  |
| source_to_concept_map.csv | source_to_concept_map | This is currently a file with only the matching row header included, so you should expect 0 rows of data. |
| VOCABULARY.csv | vocabulary |  |

![Vocabulary Files](/docs/media/vocabulary_storage_account.png)

## Verify Vocabulary Data Conforms

Confirm your vocabulary data will conform to the schema described as part of the project.

You may need to modify the vocabulary files to conform to the schema, or, you may also need to confirm desired schema updates too.  You may need to modify the [data model](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/).

You may run into additional issues with loading the data after **indexes** or **constraints** are applied.  For example, you can review the [modifications from OHDSI notes](/sql/README.md#modifications-from-ohdsi) which list changes made to the data model to address vocabulary conflicts.

### Empty source_to_concept_map.csv

1. Review your vocabulary container for your environment with [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/).

2. Confirm that you have a file named source_to_concept_map.csv
![source_to_concept_map.csv in storage account](/docs/media/vocabulary_storage_account_source_to_concept_mapping.png)

3. Download the **tab-delimited** file and confirm the file contents contains **only a row header**:
```csv
source_code	source_concept_id	source_vocabulary_id	source_code_description	target_concept_id	target_vocabulary_id	valid_start_date	valid_end_date	invalid_reason
```

4. If the `source_to_concept_map.csv` file does not exist in the desired vocabulary container path, create a file named `source_to_concept_map.csv` with the contents from step 3 and upload it to the desired vocabulary container path using Azure Storage Explorer.

## Connecting Azure SQL and Azure Storage

The following settings should be covered through TF.

1. You need to ensure that Azure SQL has [Managed Identity enabled](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/tutorial-windows-vm-access-sql#enable).

2. Ensure that the Azure Storage Account has granted [Storage Blob Data Reader](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-reader) permissions to the Azure SQL Managed Identity.

![image.png](/docs/media/vocabulary_storage_account_rbac.png)

## Data Load through Pipeline Timeouts

If you notice that loading the data from the Azure Storage Account to Azure SQL is taking some time or even causing timeouts, you may consider scaling up the storage and vCores for the Azure SQL DB.

You may even notice that Azure SQL will have errors relating to insufficient space, in which case you may consider scaling storage.

You can control these settings through different methods including:
1. [Terraform](/infra/terraform/omop) including updating your [variable group](/docs/update_your_variable_groups.md/#2-bootstrap-settings-vg)
2. Manually updating the settings in the Portal for your [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/single-database-scale#change-storage-size)

![Scale Azure SQL Server in the Portal](/docs/media/vocabulary_azure_sql_scale.png)