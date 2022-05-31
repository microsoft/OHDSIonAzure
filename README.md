# Introduction

OHDSI on Azure GitHub repository is designed to ease deployment of tools provided by the Observational Health Data Sciences and Informatics (OHDSI, pronounced "Odyssey") community on to Azure. We are guided by our Hypothesis and core objectives.

**Hypothesis -** “OHDSI on Azure will empower IT department and operations teams to support researchers, thus increasing researchers' motivation to act on new ideas”

## Objectives

1. Decreased Deployment challenges
2. Increased access to funding
3. Simplified adoption strategy

OHDSI on Azure is a set of scripts, templates, and DevOps pipelines designed to automate the deployment of the OHDSI in the Microsoft Azure cloud using Terraform & PaaS services. It is designed to facilitate standardized scalable deployments within customer managed Azure subscriptions. Provide best practices for running OHDSI on Azure. Ease the burden of management and cost monitoring of research projects.

OHDSI on Azure has taken a container-based approach to operating OHDSI tools. Therefore, OHDSI on Azure does it’s best to not host code developed by the [OHDSI community](https://github.com/OHDSI). Our deployment templates pull containers from Docker Hub.

We encourage customers to perform their due diligence as part of the pipeline deployments. CI/CD pipelines can be modified to fit your organization’s requirements. Our goal is to get a Sandbox environment setup and provide starter tools for deploying to other environments (DEV/Test, Staging, and Production).

We invite you and your organization to participate in the continued feature expansion of OHDSI on Azure.

This repository assumes the end user is familiar with the OHDSI/ OMOP community, Azure, and Terraform.

Some of the OHDSI projects included:

* [Common Data Model (CDM)](https://github.com/OHDSI/CommonDataModel), including [Vocabulary](https://github.com/OHDSI/Vocabulary-v5.0)
* [Atlas](https://github.com/OHDSI/Atlas)
* [WebApi](https://github.com/OHDSI/WebAPI)
* [Achilles](https://github.com/OHDSI/Achilles)
* [ETL-Synthea](https://github.com/OHDSI/ETL-Synthea)

## Overview

![Overview](/docs/media/azure_overview.png)

You can use [Azure DevOps pipelines](/pipelines/README.md/#pipelines) to manage your environment, see the guide for [creating your environment](/docs/creating_your_environment.md) for an overview.

Your administrator can manage Azure Resources in your [bootstrap resource group](/infra/terraform/bootstrap/README.md) and your Azure DevOps setup [using Terraform](/infra/README.md/#bootstrap-deployment-overview).  You will also need to work with your Azure administrator to setup your Azure DevOps using the [administrative steps](/infra/README.md/#administrative-steps).

The Azure resources in the [OMOP resource group](/infra/terraform/omop/README.md) are [managed through Terraform](/infra/README.md/#running-terraform).

You can host your [CDM in Azure SQL](/sql/README.md#cdm-notes).  You can [load your vocabularies](/docs/setup/setup_vocabulary.md) into Azure Storage so that the [Azure DevOps Vocabulary Release Pipeline](/pipelines/README.md/#vocabulary-release-pipeline) can populate your [Azure SQL CDM](/sql/README.md/#vocabulary-notes).

You can [setup Atlas and Webapi](/docs/setup/setup_atlas_webapi.md) using the [Broadsea Build Pipeline](/pipelines/README.md/#broadsea-build-pipeline) to build and push the [Broadsea webtools (for Atlas / WebApi)](/apps/broadsea-webtools/README.md) image into Azure Container Registry. You can then run the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) to configure Atlas and WebApi in your Azure App Service.

You can also [setup Achilles and Synthea](/docs/setup/setup_achilles_synthea.md) using the [Broadsea Build Pipeline](/pipelines/README.md/#broadsea-build-pipeline) to build and push the [Broadsea Methods (for Achilles and Synthea)](/apps/broadsea-methods/README.md) image into Azure Container Registry.  You can then run the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) to perform the following steps:

1. Run an [ETL job](/apps/broadsea-methods/README.md/#synthea-etl) and use [Synthea to generate synthetic patient data](/apps/broadsea-methods/README.md/#use-synthea-to-generate-synthetic-patient-data) as an optional step
2. Run [Achilles](/apps/broadsea-methods/README.md/#achilles) to characterize the CDM data in Azure SQL

[Setup E2E Overview](https://user-images.githubusercontent.com/2498998/167233869-dfe1c4ca-4b75-4104-8486-ae6b1c6a6084.mp4)

## CDM Version

This setup supports a modified version of the CDM [v5.3.1](/sql/cdm/v5.3.1/) schema based on the [CDM v5.3.1 for SQL Server](https://github.com/OHDSI/CommonDataModel/tree/v5.3.1/Sql%20Server).

You can review more notes on the modifications in the [readme](/sql/README.md/#modifications-from-ohdsi).

## Getting Started

To get started, first clone the repository.

```console
git clone https://github.com/microsoft/OHDSIonAzure
```

You can work through the notes on [creating your environment](/docs/creating_your_environment.md) which will walk through how to set up OHDSI on Azure.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [https://cla.opensource.microsoft.com](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
