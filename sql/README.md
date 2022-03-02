# SQL Server Notes

The SQL scripts will help with deploying the [Common Data Model](#cdm-notes) and setting up [Web Api](#web-api-notes).

## CDM Notes

The scripts in the [CDM v5.3.1 folder](./CDM/v5.3.1/) are based on the SQL Server scripts for the [CommonDataModel 5.3.1](https://github.com/OHDSI/CommonDataModel/tree/v5.3.1/Sql%20Server).

There's also a [vocabulary loading script](./CDM/v5.3.1/OMOP_Vocabulary_DDL/Scripts/Script.PostDeployment.sql) included in the [Vocabulary DDL folder](./CDM/v5.3.1/OMOP_Vocabulary_DDL) which requires [additional setup](#vocabulary-notes).

### Modifications from OHDSI

Here's some modifications from the existing [CommonDataModel 5.3.1](https://github.com/OHDSI/CommonDataModel/tree/v5.3.1/Sql%20Server):

1. Expand column `unique_device_id` for [device_exposure table](./CDM/v5.3.1/OMOP_Vocabulary_DDL/dbo/Tables/device_exposure.sql) to address a synthea conflict
2. Remove constraint `uq_concept_synonym` for [concept_synonym table](./CDM/v5.3.1/OMOP_Vocabulary_Indexes_Constraints/dbo/Tables/concept_synonym.sql) to address a vocabulary conflict, and it's taken out as part of the [5.3.2 release](https://github.com/OHDSI/CommonDataModel/releases/tag/v5.3.2).  Also remove constraint `fpk_concept_synonym_concept` to address a vocabulary conflict.
3. Remove constraints `fpk_concept_ancestor_concept_1` and `fpk_concept_ancestor_concept_2` for [concept_ancestor table](./CDM/v5.3.1/OMOP_Vocabulary_Indexes_Constraints/dbo/Tables/concept_ancestor.sql) to address a vocabulary conflict
4. Expand column `concept_name` for [concept table](./CDM/v5.3.1/OMOP_Vocabulary_DDL/dbo/Tables/concept.sql) to address a vocabulary conflict
5. Remove constraints `fpk_concept_relationship_c_1` and `fpk_concept_relationship_c_2` for [concept_relationship table](./CDM/v5.3.1/OMOP_Vocabulary_Indexes_Constraints/dbo/Tables/concept_relationship.sql) to address a vocabulary conflict
6. Remove constraint `fpk_cohort_subject_concept` for [cohort_definition table](./CDM/v5.3.1/OMOP_Vocabulary_Indexes_Constraints/dbo/Tables/cohort_definition.sql) to address a vocabulary conflict

### Vocabulary Notes

The vocabulary load is handled through a [post deployment script](./OMOP_Vocabulary_DDL/Scripts/Script.PostDeployment.sql).

You will need to ensure your Azure Storage Account is already populated with a vocabulary.

1. Download the Vocabulary from Athena (into an Azure VM in the same region as your Azure Storage Account)
2. As a one time setup, you can run the [Post_TF_Deploy script](./scripts/Post_TF_Deploy.sql) using the [Vocabulary Build pipeline](../pipelines/vocabulary_build_pipeline.yaml) and the [Vocabulary Release pipeline](../pipelines/vocabulary_release_pipeline.yaml) while ensuring the Post TF Deploy option is selected.
  a. ** TODO: fill in additional notes around using the pipelines **
3. You can use the [Vocabulary Release pipeline](../pipelines/vocabulary_release_pipeline.yaml) to deploy the data model and the populate the vocabulary.

## Web Api Notes

The [Web Api Refresh script](./scripts/Web_Api_Refresh.sql) can be used to refresh [Web Api](https://github.com/OHDSI/WebAPI) using the [Broadsea Release Pipeline](../pipelines/broadsea_release_pipeline.yaml).

** TODO: Fill in additional notes around using the pipelines **