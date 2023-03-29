# Setup Achilles and ETL-Synthea

Below are steps to setup [Achilles](https://github.com/OHDSI/Achilles) and [ETL-Synthea](https://github.com/OHDSI/ETL-Synthea).

> Note this guide is part of setting up Broadsea

[Setup Broadsea](https://user-images.githubusercontent.com/2498998/167233874-1f1ebf77-0deb-4694-b1ce-f1a8df4de1eb.mp4)

> You can also check under the [video links doc](/docs/video_links.md) for other setup guides.

## Prerequisites
  
1. You've successfully setup [Atlas](/docs/setup/setup_atlas_webapi.md)

2. Confirm your [variable groups](/docs/update_your_variables.md#3-omop-environment-settings-vg) reflect your environment settings.

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

1. Locate your [Broadsea Pipelines](/pipelines/README.md/#broadsea-pipelines)

![Locate Broadsea Pipelines](/docs/media/run_broadsea_pipeline_0.png)

2. Run the [Broadsea Build Pipeline](/pipelines/README.md/#broadsea-build-pipeline) on your feature branch to **Build and publish broadsea-methods (Achilles / ETL-Synthea)** to Azure Container Registry.

![Broadsea Build Pipeline for Achilles / ETL-Synthea](/docs/media/broadsea_build_pipeline_achilles_etl_synthea.png)

> Note that the [broadsea-methods](/apps/broadsea-methods/README.md) image is a combined image used both by Achilles & ETL-Synthea. The option to **Build and publish broadsea-methods (Achilles / ETL-Synthea)** will **build and push** the image to ACR. You will need to ensure that the `broadsea-methods` container image is in ACR in order to run the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline).

You should be able to review ACR to see the [broadsea-methods](/apps/broadsea-methods/README.md) image in your environment.

![Confirm Broadsea Methods in ACR](/docs/media/confirm_acr_broadsea_methods_1.png)

3. Run the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) on your feature branch.

- You can fill in the [pipeline parameter details](/pipelines/README.md/#broadsea-release-pipeline-parameters), whether to run the [ETL-Synthea](/apps/broadsea-methods/README.md/#synthea-etl) process, and whether to run the [achilles characterization](/apps/broadsea-methods/README.md/#achilles) on your Azure SQL DB.

![Select Broadsea Release Pipeline Settings](/docs/media/broadsea_release_pipeline_achilles_etl_synthea_1.png)

### Step 3. Validate Achilles & ETL-Synthea

1. If Synthea and Achilles are set up correctly, you should see the following by checking https://my-app-service.azurewebsites.net/atlas/#/datasources/webapi-CDMV5/dashboard:

![Confirm Achilles and Synthea](/docs/media/confirm_achilles_synthea_1.png)

> You should see some information in the dashboard populated through Synthea (reflecting the patient population) and the Achilles script should populate the reports.

2. You can also check for Synthea-based person information by checking for a person id: https://my-app-service.azurewebsites.net/atlas/#/profiles/webapi-CDMV5/

![Confirm Achilles and Synthea](/docs/media/confirm_achilles_synthea_2.png)

> Note that the person id in this case corresponds a person id in Azure SQL.  For example, you can query for a person id in Azure SQL:

```sql
SELECT TOP 1 [person_id]
  FROM [dbo].[person]
```

## Troubleshooting Notes

Check the corresponding [troubleshooting notes](/docs/troubleshooting/troubleshooting_achilles_synthea.md) for more details.
