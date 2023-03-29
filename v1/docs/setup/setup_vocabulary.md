# Vocabulary Setup Notes

As part of your OMOP Common Data Model (CDM), you should deploy your [OMOP vocabularies](https://www.ohdsi.org/data-standardization/vocabulary-resources/) which should conform to your CDM.

[Setup Vocabulary](https://user-images.githubusercontent.com/2498998/167502866-eb7d49da-83fa-429f-a0dd-bb066d12482c.mp4)

> You can also check under the [video links doc](/docs/video_links.md) for other setup guides.

## Prerequisites

1. Setup your environment based on the [infra readme](/infra/README.md) as part of the terraform deployment.

2. Download the Vocabulary from [Athena](http://athena.ohdsi.org/)

> Given that the vocabulary files are large, you may try downloading the vocabularies into an [Azure VM](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal) in the same region as your [Azure Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview) in your [Environment](/infra/terraform/omop/README.md/#environment-terraform)
  
3. Load your vocabulary files into your Azure Storage Account blob container using [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/).  The default naming for the vocabulary container is `vocabularies`, and you can create a sub-folder path for a specific version (e.g. `19-AUG-2021` can hold the vocabulary from August 19, 2021).  Note that the filepaths are case-sensitive.
  ![Loaded Vocabularies](/docs/media/vocabulary_storage_account.png)

> Alternatively, you can also copy the demo vocabulary files from the demo Azure Storage account which should be setup through your [Environment Pipeline](/infra/terraform/omop/README.md#step-2-use-your-tf-environment-pipeline)

```shell
destinationAzureStorageAccountKey='<your-storage-account-key>' # include your Azure Storage Account key for your vocabulary files.
destinationAzureStorageAccountName='<your-storage-account-name>' # include your Azure Storage Account name for your vocabulary files.
destinationContainer='vocabularies' # save the vocabularies in a container named 'vocabularies'
sourceAccountName='demovocabohdsionazure' # This is the name for the public demo Azure Storage Account with the demo vocabulary files
sourceContainer='vocabularies' # copy vocabulary files from a container named 'vocabularies' in your source storage account
pattern='19-AUG-2021/*.csv' # Pull in vocabularies from 19-AUG-2021 from the public demo storage account

az storage blob copy start-batch \
  --account-key "$destinationAzureStorageAccountKey" \
  --account-name "$destinationAzureStorageAccountName" \
  --destination-container "$destinationContainer" \
  --pattern "$pattern" \
  --source-account-name "$sourceAccountName" \
  --source-container "$sourceContainer"
```

> The source_to_concept_map.csv (tab delimited) can be empty and just include the header:

```csv
source_code	source_concept_id	source_vocabulary_id	source_code_description	target_concept_id	target_vocabulary_id	valid_start_date	valid_end_date	invalid_reason
```

4. You have `git clone` the repository

```bash
git clone https://github.com/microsoft/OHDSIonAzure
```

## Steps

### Step 1. Setup your Repo

1. Clone the repository

    ```bash
    git clone https://github.com/microsoft/OHDSIonAzure
    ```

2. Create a feature branch (e.g. [your_alias)]/[new_feature_name]). An example would be `jane_doe/new_feature`

3. Confirm your [variable groups](/docs/update_your_variables.md) reflect your environment settings.

> These settings will be used with the application pipelines (for more information, you can review how to run the [vocabulary pipelines](/pipelines/README.md/#vocabulary-pipelines) and the [broadsea pipelines](/pipelines/README.md/#broadsea-pipelines))

### Step 2. Run the Pipelines

1. Locate your [Vocabulary Pipelines](/pipelines/README.md/#vocabulary-pipelines)

![Locate Vocabulary Pipelines](/docs/media/run_vocabulary_pipeline_0.png)

2. Run the [Vocabulary Build Pipeline](/pipelines//vocabulary_build_pipeline.yaml) using your feature branch to build the artifacts for the SQL projects

![Run Vocabulary Build](/docs/media/vocabulary_build_pipeline.png)

3. Run the [Vocabulary Release pipeline](/pipelines/vocabulary_release_pipeline.yaml) to deploy the data model and the populate the vocabulary using your feature branch.  Ensure the options for **Run the Post TF Deploy script**, **Run the Vocabulary Load Data Dacpac**, and **Run the Indices and Constraints Dacpac** are checked.

> Note the Post TF deploy script is a one-time run to add access for Azure SQL.

![Run Vocabulary Release](/docs/media/vocabulary_release_pipeline.png)

### Step 3. Validate the Results

1. Confirm the vocabulary tables are loaded by checking your [Vocabulary Release Pipeline](/pipelines/README.md/#vocabulary-release-pipeline) in Azure DevOps:

![Validate Vocabulary Load](/docs/media/validate_vocabulary_load.png)

2. You can also confirm the constraints and indexes are applied successfully by your [Vocabulary Release Pipeline](/pipelines/README.md#vocabulary-release-pipeline) in Azure DevOps:

![Validate Vocabulary Indexes and Constraints](/docs/media/validate_vocabulary_load_1.png)

## Troubleshooting

You can review these [troubleshooting notes](/docs/troubleshooting/troubleshooting_vocabulary.md) for additional details.
