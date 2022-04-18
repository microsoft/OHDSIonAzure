# Troubleshooting Infrastructure Provisioning

## TODO: Revisit

## Table of contents

1. [Service Connection Issues](#service-connection-issues)
2. [Storage Account Container Access](#storage-account-container-access)
3. [Issues with Connecting to Application Service](#application-service-troubleshooting)
4. [Issues with tearing down infrastructure](#how-to-tear-down-infrastructure)

## Service Connection Issues

If you notice that your Service Connection isn't able to `az login`, you may need to work with your administrator to ensure that the [Service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) is recreated.

You can re-run your [TF environment pipeline](/pipelines/README.md/#environment-pipeline) to validate that the service connection is able to provision Azure resources.

## Storage Account Container Access

If you run into being unable to reach the storage account container, you can try to remove the storage account container and re-run through the TF refresh.

TODO: Check if this is still occurring, and if there's an example error message

If after the redeploy attempt you still cannot connect to the storage container and have confirmed the appropriate access controls are in place, contact your administrator.

## Application Service Troubleshooting

### Troubleshoot connecting to ACR

You should confirm that the [Azure App Service can connect to ACR](/docs/troubleshooting/troubleshooting_atlas_webapi.md/#connecting-azure-app-service-to-azure-container-registry).

### Azure App Service Logstream

You can also confirm if there's any errors using the [Azure App Service logstream](/docs/troubleshooting/troubleshooting_atlas_webapi.md/#manually-check-logs-from-azure-app-service)

## How to tear down Infrastructure

1. Comment out code in [main.tf](/infra/terraform/omop/main.tf) in your branch.
> You will want to keep the provider and the cred data block commented in for the TF tear down

```terraform
# Keep this commented in
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

terraform {
  backend "azurerm" {}
  required_version = "~> 1.1.4"

  required_providers {
    azurerm = {
      version = "~> 2.90.0"
      source  = "hashicorp/azurerm"
    }
  }
}

data "azurerm_client_config" "current" {}
```
2. Run your [TF environment pipeline](/pipelines/README.md/#environment-pipeline) using your branch to clean out resources
