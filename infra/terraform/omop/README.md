# Environment Terraform

This Terraform project will setup your OMOP environment for OHDSI on Azure.

![OMOP Environment Setup](../../media/infrastructure_deployment.png)

This project will cover the resources in the `OMOP Resource Group`, which is in the right side of the diagram.  This includes the following:

- [Azure SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/database/logical-servers)
- [Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview)
- [Azure Blob Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/overview)
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro)

## Prerequisites

You (or your administrator) should be able to successfully run the [bootstrap terraform](/infra/terraform/bootstrap/README.md) prior to running this project.

You can also further review the [infra notes](/infra/README.md/#running-terraform) for more details.