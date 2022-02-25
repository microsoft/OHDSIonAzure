# OHDSI on Azure - Infrastructure Deployment

This guide will assist you in deploying the infrastructure required for an OHDSI CDM in Azure using Azure SQL Server. The OHDSI on Azure comes in two parts: (1) Infrastructure Deployment (2) [OHDSI Application Deployment](../apps/README.md).

## Setup

### Prerequisites

This installation requires that you have access to the following:

1. Azure subscription
2. Terraform

### Running Terraform

We leverage Terraform to automate the creaation of resources to support the deployment of OHDSI CDM on Azure. The Terraform resources will inclulde:

- Azure SQL Server
- Azure SQL Database
- Storage Account
- Key Vault
- App Service

Before running terraform, you will need to provide the required variables:

- environment name (i.e `dev`)
- resource location (i.e. `westus2`)
- SQL Database admin password (will be stored in Key Vault)


## Footnotes:

* Separation between infra and application -
* Managed Identity with ACR
* Create Storage Account Container - manually done outside of Terraform
* dacpac to deploy vocabulary
