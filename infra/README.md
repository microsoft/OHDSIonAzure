# OHDSI on Azure - Infrastructure Deployment

This guide will assist you in deploying the infrastructure required for an OHDSI CDM in Azure using Azure SQL Server. The OHDSI on Azure comes in two parts: (1) Infrastructure Deployment (2) [OHDSI Application Deployment](/apps/README.md).

Separation between infrastructure and application deployment allows for the benefit of removing dependencies between the two components. With OHDSI applications in constant development, it makes it challenging for Azure resources to pin to specific version everytime they are deployed or modified. Logical separation between infrastructure and application code could help reduce upkeeping of the terraform state file, difficulties with rolling back, and troubleshooting when an error occurs.

## Setup

### Prerequisites

This installation requires that you have access to the following:

1. Azure subscription
2. Terraform
3. Azure Storage Account to store TF state files

### Administrative Steps

You can work with your administrator to setup your Azure environment.

Prior to working with [Terraform](/infra/README.md/#running-terraform), you will need to set up Azure DevOps.

#### Bootstrap Deployment Overview

![bootstrap setup](/infra/media/bootstrap_deplyment.png)

You can work with your administrator to setup the bootstrap resource group (depicted on the left side), and to setup Azure Devops.

Working with your administrator in Azure DevOps, you can import this repository, [import the pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/clone-import-pipeline?view=azure-devops&tabs=yaml#export-and-import-a-pipeline), set up [Azure DevOps Environments](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops), and set up your [Service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml).

You can use a [custom image](/infra/scripts/ado_builder_capture.sh) with your [Azure VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops#update-an-existing-scale-set-with-a-new-custom-image) for your [Azure DevOps agent pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops), and your Azure DevOps pipelines can use a [Variable Group Linked to Azure Key Vault](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault).

#### Administrative Steps Detailed

You will need to work with your administrator to work through the steps noted in the [scripts](./scripts/) directory:

1. Work through the guidance in the [ado_bootstrap script](./scripts/ado_bootstrap.sh) to setup a [Service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml), [Azure DevOps Builder VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops), [Azure DevOps Variable Group Linked to Azure Key Vault](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault), and to [store your TF State in Azure Storage](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli)
    - Make sure to setup an [ado_builder image](./scripts/ado_builder.sh)
    - Be sure to capture the image based on the [ado_builder_capture notes](./scripts/ado_builder_capture.sh)
2. Set up [Azure SQL with AAD access](./scripts/sql_bootstrap.sh)

You can also review the [setup infra notes](/docs/setup/setup_infra.md) to ensure that you have completed the Azure DevOps configuration.

### Running Terraform

We leverage Terraform to automate the creation of resources to support the deployment of OHDSI CDM on Azure. Some of the major Terraform resources will include:

- [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/logical-servers)
- [Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview)
- [Azure Blob Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/overview)
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro)

![Infrastructure Deployment](/infra/media/infrastructure_deployment.png)

Before running terraform, you will need to provide the required variables:

- environment name (i.e `dev`)
- resource location (i.e. `westus3`)

These variables can be used in the `variables.tf` file itself or provided upon running terraform commands. Execute the following commands when in the `infra/terraform` directory:

```
terraform init
terraform plan
terraform apply
```

Note, while you can run the terraform steps locally, you can also utilize the [TF environment pipeline](../pipelines/environments/TF-OMOP-DEV.yaml) to manage your environment too assuming that you have already pushed your [backend state to Azure Storage](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli).

### Security

Azure resources in this setup rely heavily on Managed Identities (MI) to authenticate with other services. This is powerful in the sense that it eliminates the need to manage passwords and other secrets. Examples of how MI is leveraged:

- Writing and reading from Azure SQL database
- Pulling Docker image from ACR
- Reading from Storage

#### Security Notes

Here's an overview for how MI (Managed Identity) vs. SP (Service Principal) are used with the Azure resources.

![MI Usage](./media/mi_usage.png)

Depending on the workflow, the Azure DevOps pipeline can either use the [Microsoft Hosted Agent](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops&tabs=yaml) or an [Azure VMSS Agent](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops).

1. The Azure DevOps Pipeline will use the SP Service Connection to get secrets from Key Vault for a [Key Vault linked Azure DevOps Variable Group](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault).  You can check the [TF Environment Pipeline](/pipelines/README.md/#environment-pipeline) for an example.
2. The Azure DevOps pipeline will use the SP Service Connection to retrieve the Terraform state file from Azure Storage.  You can check the [TF Environment Pipeline](/pipelines/README.md/#environment-pipeline) for an example.
3. The Azure DevOps Pipeline will use the SP Service Connection to connect to Azure SQL to setup the CDM (e.g. release using [sqlpackage](https://docs.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage?view=sql-server-ver15) for [dacpacs](https://docs.microsoft.com/en-us/sql/ssdt/extract-publish-and-register-dacpac-files?view=sql-server-ver15) or with [sqlcmd](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15) for scripts).  You can check the [Vocabulary Release Pipeline](/pipelines/README.md/#vocabulary-release-pipeline) for an example.
4. The Azure DevOps Pipeline will anonymously check the Azure App Service to see if it has started.  You can check the [Broadsea Release Pipeline](/pipelines/README.md#broadsea-release-pipeline) for an example.
5. The Azure DevOps Pipeline will use the SP Service Connection which has ACR pull rights to pull an image from Azure Container Registry.  You can check the [Broadsea Release Pipeline](/pipelines/README.md#broadsea-release-pipeline) for an example.
6. The Azure DevOps Pipeline will use the custom Azure VMSS agent pool and use the SP Service connection to pull the Broadsea Methods image from Azure Container Registry.  You can check the [Broadsea Release Pipeline](/pipelines/README.md#broadsea-release-pipeline) for an example.
7. The Azure DevOps Pipeline can also use a custom agent pool pointing to an Azure VMSS.  For example in the [Broadsea Release Pipeline](/pipelines/README.md#broadsea-release-pipeline) the Azure VMSS MI will connect to Azure SQL to run Achilles using the Broadsea Methods container.
8. The Azure SQL Managed Identity can connect to Azure Storage to load the vocabulary into the CDM as part of the [Vocabulary Release Pipeline](/pipelines/README.md/#vocabulary-release-pipeline).
9. The Azure App Service MI can connect to Azure Container Registry to pull down the Broadsea Webtools container.  This is setup through the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline).
10. The Azure App Service MI will be used by the Broadsea Webtools container to connect to Azure SQL.  This is setup through the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline).

#### Networking Notes

By design, this architecture has open networking.

![vnet usage](./media/vnet_usage.png)

The Azure VMSS used by the Azure DevOps Pipeline has an [Azure Virtual Network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview), but it does not have any network restrictions.

Further, the Azure resources (Azure Container Registry, Azure Key Vault, Azure Storage, Azure SQL, and Azure App Services) allow public network access, which reflects the dev / test setup.  This networking setup is **not advisable** for a production scenario, which should have restricted network access based on your networking requirements.

## Next Step

- You will want to make sure you can [setup the vocabulary](/docs/setup/setup_vocabulary.md) for your environment.
