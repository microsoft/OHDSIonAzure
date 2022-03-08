# Pipelines

You can use the pipelines in this repository as part of your OHDSIonAzure setup.

1. Setup and run the [TF Environment Pipeline](#environment-pipeline)
2. Setup and run the [Vocabulary Pipelines](#vocabulary-pipelines)
    * Setup and run the [Vocabulary Build Pipeline](#vocabulary-build-pipeline)
    * Setup and run the [Vocabulary Release Pipeline](#vocabulary-release-pipeline)
3. Setup and run the [Broadsea Pipelines](#broadsea-pipelines)
    * Setup and run the [Broadsea Build Pipeline](#broadsea-build-pipeline)
    * Setup and run the [Broadsea Release Pipeline](#broadsea-release-pipeline)

## Prerequisites

The pipelines are intended to be run after working through the [infra setup](/infra/README.md) including the [administrative steps](/infra/README.md/#administrative-steps) with your administrator.

## Environment Pipeline

The environment pipeline can help run your changes in [Terraform](../infra/terraform/) for your environment.

You can work through the details in the [setup notes](/docs/setup/setup_infra.md) for your environment, which includes more details around using the [example environment pipeline](/pipelines/environments/TF-OMOP-DEV.yaml) which will run [Terraform](/infra/terraform/) for your environment.

## Vocabulary Pipelines

The vocabulary pipelines consist of the [Vocabulary Build Pipeline](#vocabulary-build-pipeline) and the [Vocabulary Release Pipeline](#vocabulary-release-pipeline)

### Vocabulary Build Pipeline

The [vocabulary build pipeline](/pipelines/vocabulary_build_pipeline.yaml) will create pipeline artifacts for [dacpacs](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15) and [sql scripts](/sql/scripts/Post_TF_Deploy.sql) used for setting up the vocabulary in your Azure SQL CDM.

This pipeline uses the [variables.yaml](/pipelines/variables.yaml) for environment settings.  You can review the [update your variables.yaml](/docs/update_your_variables.yaml.md) for more guidance.

This pipeline assumes that the [TF environment pipeline](#environment-pipeline) and [infra setup](/infra/README.md) have been completed successfully in your environment.  You can also refer to the [vocabulary setup](/docs/setup/setup_vocabulary.md) for additional guidance.

#### Vocabulary Build Pipeline Workflow

The Vocabulary Build Pipeline looks to achieve the following steps:

1. Publish the [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql) as a pipeline artifact
2. Build and publish a [dacpac](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15) for the [OMOP Vocabulary DDL](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj)
3. Build and publish a [dacpac](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15) for the [OMOP Vocabulary Indexes and Constraints](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj)

#### Vocabulary Build Pipeline Parameters

Here's an overview of the pipeline parameters used:

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| buildConfiguration | string | `Release` | Which build configuration to use with the sql projects for building the dacpacs for [OMOP Vocabulary DDL](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj) and for [OMOP Vocabulary Indexes Constraints](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj). Choice between `Release` and `Dev`, with `Release` as the default. |
| cdmVersion | string | `v5.3.1` | Which cdm version to with the sql projects for building the dacpacs for the repository path [/sql/cdm](/sql/cdm/).  Defaults to `v5.3.1`. |
| sourceFolder | string | `v5.3.1` | Source folder for scripts (e.g. for sql/scripts use sql).  Defaults to `sql`. |
| buildArtifactFolderPathPostTFDeploy | string | `vocab/posttfdeploy` | Build Artifact Folder Path for [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql).  Defaults to `vocab/posttfdeploy`. |
| buildArtifactNamePostTFDeploy | string | `PostTFDeployScript` | Build Artifact Name for [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql).  Defaults to `PostTFDeployScript`. |
| scriptFileNamePostTFDeploy | string | `Post_TF_Deploy.sql` | Script file name for [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql).  Defaults to `Post_TF_Deploy.sql`. |
| buildArtifactFolderPathVocabularyDDL | string | `vocab/ddl` | Build Artifact Folder Path for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj).  Defaults to `vocab/ddl`. |
| buildArtifactNameVocabularyDDL | string | `VocabularyDDLDacpac` | Build Artifact Name for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj).  Defaults to `VocabularyDDLDacpac`. |
| sourceFileNameVocabularyDDL | string | `OMOP_Vocabulary_DDL.sqlproj` | SQLProj file name for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj).  Defaults to `OMOP_Vocabulary_DDL.sqlproj`. |
| sourceProjectFolderNameVocabularyDDL | string | `OMOP_Vocabulary_DDL` | Source project folder for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj).  Defaults to `OMOP_Vocabulary_DDL`. |
| dacpacFileNameVocabularyDDL | string | `OMOP_Vocabulary_DDL.dacpac` | Built dacpac name for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj).  Defaults to `OMOP_Vocabulary_DDL.dacpac`. |
| buildArtifactFolderPathVocabularyIndexesConstraints | string | `vocab/indexesconstraints` | Build Artifact Folder Path for [OMOP_Vocabulary_Indexes_Constraints.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj).  Defaults to `vocab/indexesconstraints`. |
| buildArtifactNameVocabularyIndexesConstraints | string | `VocabularyIndexesConstraintsDacpac` | Build Artifact Name for [OMOP_Vocabulary_Indexes_Constraints.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj).  Defaults to `VocabularyIndexesConstraintsDacpac`. |
| sourceFileNameVocabularyIndexesConstraints | string | `OMOP_Vocabulary_Indexes_Constraints.sqlproj` | SQLProj file name for [OMOP_Vocabulary_Indexes_Constraints.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj).  Defaults to `OMOP_Vocabulary_Indexes_Constraints.sqlproj`. |
| sourceProjectFolderNameVocabularyIndexesConstraints | string | `OMOP_Vocabulary_Indexes_Constraints` | Source project folder for [OMOP_Vocabulary_Indexes_Constraints.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj).  Defaults to `OMOP_Vocabulary_Indexes_Constraints`. |
| dacpacFileNameVocabularyIndexesConstraints | string | `OMOP_Vocabulary_Indexes_Constraints.dacpac` | Built dacpac name for [OMOP_Vocabulary_Indexes_Constraints.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj).  Defaults to `OMOP_Vocabulary_Indexes_Constraints.dacpac`. |

### Vocabulary Release Pipeline

The [vocabulary release pipeline](/pipelines/vocabulary_release_pipeline.yaml) will consume the pipeline artifacts built by the [vocabulary build pipeline](#vocabulary-build-pipeline), including the [dacpacs](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15) and [sql scripts](/sql/scripts/Post_TF_Deploy.sql) to deploy the vocabulary in your Azure SQL CDM.

This pipeline uses the [variables.yaml](/pipelines/variables.yaml) for environment settings.  You can review the [update your variables.yaml](/docs/update_your_variables.yaml.md) for more guidance.

This pipeline assumes that the [TF environment pipeline](#environment-pipeline), [infra setup](/infra/README.md), and the [vocabulary build pipeline](#vocabulary-build-pipeline) have been completed successfully in your environment.  You can also refer to the [vocabulary setup](/docs/setup/setup_vocabulary.md) for additional guidance.

#### Vocabulary Release Pipeline Workflow

At a high level, the pipeline looks the achieve the following steps:

1. As a one-time step, you can publish the [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql) to setup Azure SQL access
2. You can run the [OMOP Vocabulary DDL](/sql/cdm/v5.3.1/omop_vocabulary_ddl/) as a dacpac to deploy the vocabulary data model and vocabulary to the Azure SQL CDM.  This step includes a [smoke test](/pipelines/templates/smoke_test/smoke_test_vocabulary_files.yaml) to validate the vocabulary files exist.
3. You can run the [OMOP Vocabulary Indexes and Constraints](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/) dacpac to deploy the vocabulary indexes and constraints to the Azure SQL CDM.

#### Vocabulary Release Pipeline Parameters

Here's an overview of the pipeline parameters used:

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| publishPostTFDeploy | boolean | `true` | If `true`, run the [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql) on your Azure SQL CDM.  Choice of `true` or `false`, and defaults to `true`. |
| publishVocabularyDDL | boolean | `true` | If `true`, run the dacpac built for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj) on your Azure SQL CDM.  Choice of `true` or `false`, and defaults to `true`. |
| publishVocabularyIndexesConstraints | boolean | `true` | If `true`, run the dacpac built for [OMOP_Vocabulary_Indexes_Constraints.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj) on your Azure SQL CDM.  Choice of `true` or `false`, and defaults to `true`. |
| sourcePipelineArtifactProjectName | boolean | `OHDSIonAzure` | Project Name which has the Source Pipeline with the built the pipeline artifacts (e.g. use `myproject` for https://dev.azure.com/myorg/<myproject>/).  Defaults to `OHDSIonAzure`. |
| sourcePipelineArtifactPipelineName | boolean | `Vocabulary Build` | Pipeline Name which has built the pipeline artifacts (E.g `Vocabulary Build`).  Defaults to `Vocabulary Build`. |
| buildArtifactNamePostTFDeploy | string | `PostTFDeployScript` | Build Artifact Name for [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql).  Defaults to `PostTFDeployScript`. |
| scriptFileNamePostTFDeploy | string | `Post_TF_Deploy.sql` | Script file name for [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql).  Defaults to `Post_TF_Deploy.sql`. |
| buildArtifactNameVocabularyDDL | string | `VocabularyDDLDacpac` | Build Artifact Name for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj).  Defaults to `VocabularyDDLDacpac`. |
| dacpacFileNameVocabularyDDL | string | `OMOP_Vocabulary_DDL.dacpac` | OMOP CDM Vocabulary DDL Dacpac file name for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj).  Defaults to `OMOP_Vocabulary_DDL.dacpac`. |
| buildArtifactNameVocabularyIndexesConstraints | string | `VocabularyIndexesConstraintsDacpac` | Build Artifact Name for [OMOP_Vocabulary_Indexes_Constraints.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/OMOP_Vocabulary_Indexes_Constraints.sqlproj).  Defaults to `VocabularyIndexesConstraintsDacpac`. |
| dacpacFileNameVocabularyIndexesConstraints | string | `OMOP_Vocabulary_Indexes_Constraints.dacpac` | OMOP CDM Indexes Constraints Dacpac file name for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj).  Defaults to `OMOP_Vocabulary_Indexes_Constraints.dacpac`. |

## Broadsea Pipelines

The broadsea pipelines consist of the [Broadsea Build Pipeline (CI)](#broadsea-build-pipeline) and the [Broadsea Release Pipeline (CD)](#broadsea-release-pipeline).

### Broadsea Build Pipeline

The [broadsea build pipeline](/pipelines/broadsea_build_pipeline.yaml) will create pipeline artifact for the [Web API Script](/sql/scripts/Web_Api_Refresh.sql) and push the `broadsea-webtools` and `broadsea-methods` images to ACR in your environment.

This pipeline uses the [variables.yaml](/pipelines/variables.yaml) for environment settings.  You can review the [update your variables.yaml](/docs/update_your_variables.yaml.md) for more guidance.

This pipeline assumes that the [TF environment pipeline](#environment-pipeline) and [infra setup](/infra/README.md) have been completed successfully in your environment.  You can also refer to the [setup Atlas/Webapi notes](/docs/setup/setup_atlas_webapi.md) and [setup Achilles/Synthea notes](/docs/setup/setup_achilles_synthea.md) for additional guidance.

#### Broadsea Build Pipeline Workflow

At a high level, the pipeline looks to achieve the following steps:

1. Publish the [Web API Script](/sql/scripts/Web_Api_Refresh.sql) as a pipeline artifact
2. Build and publish the [Broadsea-webtools (for Atlas/WebApi)](/apps/broadsea-webtools/Dockerfile) image to ACR
3. Build and publish the [Broadsea-methods (for Achilles/Synthea)](/apps/broadsea-methods/Dockerfile) image to ACR

#### Broadsea Build Pipeline Parameters

Here's an overview of the pipeline parameters used:

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| publishBroadseaWebApiScript | boolean | `true` | If `true`, publish the [Web Api script](/sql/scripts/Web_Api_Refresh.sql) as a pipeline artifact.  Choice of `true` or `false`, and defaults to `true`. |
| publishVocabularyDDL | boolean | `true` | If `true`, run the dacpac built for [OMOP_Vocabulary_DDL.sqlproj](/sql/cdm/v5.3.1/omop_vocabulary_ddl/OMOP_Vocabulary_DDL.sqlproj) on your Azure SQL CDM.  Choice of `true` or `false`, and defaults to `true`. |
| publishBroadseaWebtools | boolean | `true` | If `true`, build and push the [broadsea webtools (for Atlas/WebApi)](/apps/broadsea-webtools/Dockerfile) image to your ACR.  Choice of `true` or `false`, and defaults to `true`. |
| publishBroadseaMethods | boolean | `true` | If `true`, build and push the [broadsea methods (for Achilles/Synthea)](/apps/broadsea-methods/Dockerfile) image to your ACR.  Choice of `true` or `false`, and defaults to `true`. |
| buildConfiguration | string | `dev` | Build Configuration for scripts, and defaults to `dev`. |
| sourceFolder | string | `sql` | Source folder for [scripts](/sql/scripts/) (e.g. for sql/scripts use sql), and defaults to `sql`. |
| buildArtifactFolderPathWebApi | string | `webApi` | Build Artifact Folder Path for [WebAPI Script](/sql/scripts/Web_Api_Refresh.sql).  Defaults to `webApi`. |
| buildArtifactNameWebApi | string | `webApiScript` | Build Artifact for [WebApi Script](/sql/scripts/Web_Api_Refresh.sql).  Defaults to `webApiScript`. |
| scriptFileNameWebApi | string | `Web_Api_Refresh.sql` | Script file name for [WebApi Script](/sql/scripts/Web_Api_Refresh.sql).  Defaults to `Web_Api_Refresh.sql`. |
| dockerBuildSourceFolderBroadseaWebTools | string | `apps/broadsea-webtools` | Source Folder used for docker build for [broadsea-webtools](/apps/broadsea-webtools/Dockerfile), e.g. if the folder `my-folder` has the Dockerfile, specify `my-folder`.  Defaults to `apps/broadsea-webtools`. |
| dockerBuildImageNameBroadseaWebTools | string | `broadsea-webtools` | Image Name for [broadsea-webtools](/apps/broadsea-webtools/Dockerfile) (e.g. broadsea-webtools) to push into ACR.  Defaults to `broadsea-webtools`. |
| dockerBuildImageTagBroadseaWebTools | string | `latest` | Image Tag for [broadsea-webtools](/apps/broadsea-webtools/Dockerfile) (e.g. latest) to push into ACR.  Defaults to `latest`. |
| dockerBuildSourceFolderBroadseaMethods | string | `apps/broadsea-methods` | Source Folder used for docker build for [broadsea-methods](/apps/broadsea-methods/Dockerfile), e.g. if the folder `my-folder` has the Dockerfile, specify `my-folder`.  Defaults to `apps/broadsea-methods`. |
| dockerBuildImageNameBroadseaMethods | string | `broadsea-methods` | Image Name for [broadsea-methods](/apps/broadsea-methods/Dockerfile) (e.g. broadsea-methods) to push into ACR.  Defaults to `broadsea-methods`. |
| dockerBuildImageTagBroadseaMethods | string | `latest` | Image Tag for [broadsea-methods](/apps/broadsea-methods/Dockerfile) (e.g. latest) to push into ACR.  Defaults to `latest`. |

### Broadsea Release Pipeline

The [broadsea release pipeline](/pipelines/broadsea_release_pipeline.yaml) will consume artifacts built by the [broadsea build pipeline](#broadsea-build-pipeline), including the ACR images for [broadsea-webtools](/apps/broadsea-webtools/Dockerfile) and [broadsea-methods](/apps/broadsea-methods/Dockerfile), and [sql scripts](/sql/scripts/Web_Api_Refresh.sql) to deploy the `broadsea-webtools` and `broadsea-methods` in your Azure environment.

This pipeline uses the [variables.yaml](/pipelines/variables.yaml) for environment settings.  You can review the [update your variables.yaml](/docs/update_your_variables.yaml.md) for more guidance.

This pipeline assumes that the [TF environment pipeline](#environment-pipeline), [infra setup](/infra/README.md), [vocabulary setup](/docs/setup/setup_vocabulary.md), and the [broadsea build pipeline](#broadsea-build-pipeline) have been completed successfully in your environment.

#### Broadsea Release Pipeline Workflow

At a high level, the pipeline looks to achieve the following steps:

1. Deploy [Broadsea-webtools (for Atlas/WebApi)](/apps/broadsea-webtools/Dockerfile) including using a [refresh script](/sql/README.md/#web-api-notes) for WebApi to your environment
2. (Optional) Generate Synthetic Data and use [ETL-Synthea](/apps/broadsea-methods/README.md/#synthea-etlr-notes) to transfer the generated dataset into your CDM in Azure SQL using the [Broadsea-methods (for Achilles/Synthea)](/apps/broadsea-methods/Dockerfile) image from ACR.  Once finished, run the [Smoke Test](/apps/broadsea-methods/README.md/#synthea-etl-testr-notes)
3. Run the [Achilles characterization script](/apps/broadsea-methods/README.md/#achillesr) using the [Broadsea-methods (for Achilles/Synthea)](/apps/broadsea-methods/Dockerfile) image from ACR to characterize data in your Azure SQL CDM.  Once finished, run the [Achilles Smoke Test script](/apps/broadsea-methods/README.md/#achilles-testr) using the `Broadsea-methods` image.

#### Broadsea Release Pipeline Parameters

Here's an overview of the pipeline parameters used:

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| deployBroadseaWebtools | boolean | `true` | If `true`, deploy the [broadsea webtools image](/apps/broadsea-webtools/Dockerfile) from ACR to your Azure environment.  Choice of `true` or `false`, and defaults to `true`. |
| runETL | boolean | `true` | If `true`, use [Synthea](/apps/broadsea-methods/README.md/#running-r-example-packages-via-dockerfile) to generate a population and then run the [ETL-Synthea script](/apps/broadsea-methods/synthea-etl.R) to transfer the synthetic population into your CDM in Azure SQL.  Choice of `true` or `false`, and defaults to `true`. |
| runAchilles | boolean | `true` | If `true`, run the [Achilles script](/apps/broadsea-methods/achilles.R) on the [broadsea-methods image](/apps/broadsea-methods/Dockerfile) from ACR to characterize the data populated in your Azure SQL CDM.  Choice of `true` or `false`, and defaults to `true`. |
| broadseaWebtoolsDockerBuildImageName | string | `broadsea-webtools` | Broadsea Webtools Container Image Name (e.g. broadsea-webtools) to pull from ACR.  Defaults to `broadsea-webtools`. |
| broadseaWebtoolsDockerBuildImageTag | string | `latest` | Broadsea Webtools Container Image Tag (e.g. latest) to pull from ACR.  Defaults to latest. |
| sourcePipelineArtifactProjectName | boolean | `OHDSIonAzure` | Project Name which has the Source Pipeline with the built the pipeline artifacts (e.g. use `myproject` for https://dev.azure.com/myorg/<myproject>/).  Defaults to `OHDSIonAzure`. |
| sourcePipelineArtifactPipelineName | boolean | `Broadsea Build` | Pipeline Name which has built the pipeline artifacts (E.g `Broadsea Build`).  Defaults to `Broadsea Build`. |
| buildArtifactNameWebApi | string | `webApiScript` | Build Artifact for [WebApi Script](/sql/scripts/Web_Api_Refresh.sql), and defaults to `webApiScript`. |
| buildArtifactNameWebApi | string | `Web_Api_Refresh.sql` | [WebApi Script](/sql/scripts/Web_Api_Refresh.sql) file name, and defaults to `Web_Api_Refresh.sql`. |
| broadseaMethodsDockerBuildImageName | string | `broadsea-methods` | [Broadsea Methods](/apps/broadsea-methods/Dockerfile) container Image Name (e.g. `broadsea-methods`) to pull from ACR.  Defaults to `broadsea-methods`. |
| broadseaMethodsDockerBuildImageTag | string | `latest` | [Broadsea Methods](/apps/broadsea-methods/Dockerfile) Image Tag (e.g. `latest`) to pull for broadsea-methods from ACR.  Defaults to `latest`. |
| sourceFolder | string | `apps/broadsea-methods` | Source folder which has the [Achilles and Synthea scripts](/apps/broadsea-methods) (e.g. `apps/broadsea-methods`).  Defaults to `apps/broadsea-methods`. |
| populationSize | number | `100` | [Synthea](/apps/broadsea-methods/README.md/#running-r-example-packages-via-dockerfile) Live Population Size.  Defaults to `100`. |
| syntheaETLScriptFileName | string | `synthea-etl.R` | [Synthea ETL script](/apps/broadsea-methods/synthea-etl.R) file name (e.g. `synthea-etl.R`)  Defaults to `synthea-etl.R`. |
| syntheaETLSmokeTestScriptFileName | string | `synthea-etl-test.R` | [Synthea ETL Smoke Test script](/apps/broadsea-methods/synthea-etl-test.R) file name (e.g. `synthea-etl.R`)  Defaults to `synthea-etl-test.R`. |
| achillesScriptFileName | string | `achilles.R` | [Achilles script](/apps/broadsea-methods/achilles.R) file name (e.g. `achilles.R`)  Defaults to `achilles.R`. |
| achillesSmokeTestScriptFileName | string | `achilles-test.R` | [Achilles Smoke Test script](/apps/broadsea-methods/achilles-test.R) file name (e.g. `achilles-test.R`)  Defaults to `achilles-test.R`. |
