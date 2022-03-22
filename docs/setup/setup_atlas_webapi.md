# Setup Atlas and Web API

Below are instructions for setting up Atlas and WebAPI, including:
* Connecting Azure App Service to ACR using MI
* Connecting Azure App Service to Azure SQL using MI
* Connecting the Build Agent to Azure SQL and ACR

## Prerequisites

This page assumes you have completed all the steps in the [infra setup doc](/docs/setup/setup_infra.md) and [setup your vocabulary](/docs/setup/setup_vocabulary.md) for your environment.
 
## Steps

### Step 1. Setup your Repo

1. Clone the repository
    ```bash
    git clone https://github.com/microsoft/OHDSIonAzure
    ```

2. Create a feature branch (e.g. [your_alias)]/[new_feature_name]). An example would be `jane_doe/new_feature`

3. Confirm your [variable groups](/docs/update_your_variable_groups.md) reflect your environment settings.
 
> These settings will be used with the application pipelines (for more information, you can review how to run the [vocabulary pipelines](/pipelines/README.md/#vocabulary-pipelines) and the [broadsea pipelines](/pipelines/README.md/#broadsea-pipelines))

### Step 2. Run the Pipelines

1. Locate your [Broadsea Pipelines](/pipelines/README.md/#broadsea-pipelines)

![Locate Broadsea Pipelines](/docs/media/run_broadsea_pipeline_0.png)

2. Run the [Broadsea Build Pipeline](/pipelines/README.md/#broadsea-build-pipeline) to build and push [broadsea-webtools](/apps/broadsea-webtools/README.md) to Azure Container Registry

![Broadsea Build Pipeline for Atlas / WebApi](/docs/media/broadsea_build_pipeline_atlas_webapi.png)

> Note that the [broadsea-webtools](/apps/broadsea-webtools/README.md) image is a combined image used both by Atlas & WebApi. The option to **Build and publish broadseawebtools (Atlas / WebApi)** will **build and push** the image to ACR. You will need to ensure that the `broadsea-webtools` container image is in ACR in order to run the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline).

You should be able to review ACR to see broadsea methods in your environment.

![Confirm Broadsea Methods in ACR](/docs/media/confirm_acr_broadsea_webtools_1.png)

3. Run the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) on your feature branch to get Azure App Service to pull the [broadsea-webtools](/apps/broadsea-webtools/README.md) image from ACR and refresh WebAPI

### Step 3. Validate the Results

You can check if Atlas and WebAPI are successfully running in your environment.

1. If WebAPI and Atlas are set up correctly, you should see the following by checking https://my-app-service.azurewebsites.net/atlas:
![Confirm Atlas is Up](/docs/media/confirm_atlas_1.png)

2. You can visit the page https://my-app-service.azurewebsites.net/WebAPI/source/sources and get back something like this:

```json
[
    {
        "sourceId": 1,
        "sourceName": "webapi CDM V5 Database",
        "sourceDialect": "sql server",
        "sourceKey": "webapi-CDMV5",
        "daimons": [
            {
                "sourceDaimonId": 1,
                "daimonType": "CDM",
                "tableQualifier": "dbo",
                "priority": 2
            },
            {
                "sourceDaimonId": 2,
                "daimonType": "Vocabulary",
                "tableQualifier": "dbo",
                "priority": 2
            },
            {
                "sourceDaimonId": 3,
                "daimonType": "Results",
                "tableQualifier": "webapi",
                "priority": 2
            },
            {
                "sourceDaimonId": 4,
                "daimonType": "CEM",
                "tableQualifier": "webapi",
                "priority": 2
            }
        ]
    }
]
```

You can also check the configuration once this step is complete:
https://my-app-service.azurewebsites.net/atlas/#/configure

![Confirm Atlas Configuration](/docs/media/confirm_atlas_2.png)

# Troubleshooting Notes

Check the corresponding [troubleshooting notes](/docs/troubleshooting/troubleshooting_atlas_webapi.md) for more details.
