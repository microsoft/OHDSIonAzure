# Vocabulary Setup Notes

As part of your OMOP Common Data Model (CDM), you should deploy your [OMOP vocabularies](https://www.ohdsi.org/data-standardization/vocabulary-resources/) which should conform to your CDM.

## Prerequisites

1. Setup your environment based on the [infra readme](/infra/README.md) as part of the terraform deployment.

2. Download the Vocabulary from [Athena](http://athena.ohdsi.org/)
> Given that the vocabulary files are large, you may try downloading the vocabularies into an [Azure VM](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal) in the same region as your [Azure Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview).
  
3. Load your vocabulary files into your Azure Storage Account blob container using [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/).  The default naming for the vocabulary container is `vocabularies`, and you can create a sub-folder path for a specific version (e.g. `19-AUG-2021` can hold the vocabulary from August 19, 2021).  Note that the filepaths are case-sensitive.
  ![Loaded Vocabularies](/docs/media/vocabulary_storage_account.png)

> The source_to_concept_map.csv (tab delimited) can be empty and just include the header:
```csv
source_code	source_concept_id	source_vocabulary_id	source_code_description	target_concept_id	target_vocabulary_id	valid_start_date	valid_end_date	invalid_reason
```

4. You have `git clone` the repository

```bash
git clone https://github.com/microsoft/OHDSIonAzure
```

## Steps

1. In your local git cloned repo create a feature branch (e.g. [your_alias)]/[new_feature_name]). An example would be `jane_doe/new_feature`

2. Update your [variables.yaml](/pipelines/variables.yaml) to reflect your environment settings. See the notes for [updating your variables.yaml](/docs/update_your_variables.yaml.md) for more info

3. Run the [Vocabulary Build Pipeline](/pipelines//vocabulary_build_pipeline.yaml) using your feature branch to build the artifacts for the SQL projects
![Run Vocabulary Build](/docs/media/vocabulary_build_pipeline.png)

4. Run the [Vocabulary Release pipeline](/pipelines/vocabulary_release_pipeline.yaml) to deploy the data model and the populate the vocabulary using your feature branch.  Ensure the options for **Run the Post TF Deploy script**, **Run the Vocabulary Load Data Dacpac**, and **Run the Indices and Constraints Dacpac** are checked.
> Note the Post TF deploy script is a one-time run to add access for Azure SQL.
![Run Vocabulary Release](/docs/media/vocabulary_release_pipeline.png)

## Troubleshooting

You can review these [troubleshooting notes](/docs/troubleshooting/troubleshooting_vocabulary.md) for additional details.