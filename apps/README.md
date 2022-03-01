# OHDSI on Azure - Application Deployment

This guide will outline how to deploy OHDSI applications to your CDM on Azure.

To automate the application deployments, Azure DevOps pipelines are used. THe pipelines will deploy the following applications:

- [WebAPI](https://github.com/OHDSI/WebAPI)
- [ATLAS](https://github.com/OHDSI/Atlas/)
- [ETL-Synthea](https://github.com/OHDSI/ETL-Synthea) (_optional_)
- [Achilles](https://github.com/OHDSI/Achilles)

## Prerequisites
- Azure resources spun up from Terraform (more information can be found in [Infrastructure Deployment](../infra/README.md))
- CDM Vocabulary uploaded to Storage Account
- Pipelines imported using YAML files

## Setup

The application deployment heavily relies on the use of docker images and Azure DevOps pipelines. There are two Docker images that are modified from OHDSI in order to be compatible with Azure: (1) Broadsea WebTools Library (WebAPI + ATLAS) and (2) Broadsea Methods Library (ETL-Synthea + Achilles).

### 1. Broadsea WebTools Build and Push Pipeline

### 2. Broadsea WebTools Release Pipeline

### 3. Synthetic Data Pipeline

### 4. Achilles Pipeline
