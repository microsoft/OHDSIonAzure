# Creating your Environment with Github Actions Notes

This guide will let you work through the E2E for setting up your environment in your Azure subscription and Azure DevOps project.

This approach relies on using [github actions workflows](https://docs.github.com/en/github-ae@latest/actions/using-workflows/about-workflows) in the `.github/workflows` folder combined with some prerequisite steps to achieve setting up your environment.

## Prerequisites

### Step 1. Setup your Azure Service Principal

1. You (or your Administrator) should be able to setup an Azure Service Principal with appropriate permissions for your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) and your [OMOP Terraform project](/infra/terraform/omop/README.md).

> You should provision an Azure Storage account for your [remote backend for the bootstrap Terraform Project](/infra/terraform/bootstrap/README.md#using-an-azure-storage-account-for-your-remote-backend)

### Step 2. Confirm your Azure DevOps PAT has appropriate permissions

1. Confirm Your Azure DevOps PAT has [appropriate permissions](/infra/terraform/bootstrap/README.md#ado-pat-notes) including:

* Agent Pools - Read & Manage
* Build - Read & Execute
* Code - Full
* Environment - Read & Manage
* Extension Data - Read & Write
* Extensions - Read & Manage
* Project and Team - Read, Write, & Manage
* Service Connections - Read, Query, & Manage
* Token Administration - Read & Manage
* Tokens - Read & Manage
* User Profile - Read & Write
* Variable Groups - Read, Create, & Manage
* Work Items - Read

### Step 3. Confirm you can manage your github repository environments, secrets, and workflows

1. Confirm you (or your github repository administrator), are able to:

* [Create environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)

* Manage [environment secrets](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets)

* Run [github actions workflows](https://docs.github.com/en/actions/using-workflows/triggering-a-workflow).

### Step 4. Confirm access to your vocabulary storage account

You should have access to the demo vocabulary azure storage account.  The vocabulary files should be accessible so the vocabulary can be copied into your OHDSI on Azure vocabulary storage account.

* This demo Azure Storage account (`demovocabohdsionazure`) has public access, so you should be able to read the following files:

* CONCEPT_ANCESTOR.csv
* CONCEPT_CLASS.csv
* CONCEPT_CPT4.csv
* CONCEPT_RELATIONSHIP.csv
* CONCEPT_SYNONYM.csv
* CONCEPT.csv
* DOMAIN.csv
* RELATIONSHIP.csv
* source_to_concept_map.csv
* VOCABULARIES.csv

## Steps

### Step 1. Setup An Azure Service Principal for your environment

You can create an Azure Service Principal using Azure CLI:

```bash
az ad sp create-for-rbac -n "demoSp" --role "Owner" --scopes /subscriptions/<subscription-id>
```

Upon success, you should get a response similar to the following:

```json
{
  "appId": "some-guid",
  "displayName": "demoSp",
  "password": "some-client-secret",
  "tenant": "some-guid"
}
```

Where the `appId` can be considered your `ARM_CLIENT_ID`, the `password` is your `ARM_CLIENT_SECRET`, and the `tenant` is your `ARM_TENANT_ID` for your environment.  You can save these values for later when you fill in your environment secrets in github.  You can also use your current subscription id (which you can retrieve with `az account show` for the `id` field) and use this value for your `ARM_SUBSCRIPTION_ID`.

You can also retrieve your Service Principal objectId using Azure CLI:

```bash
SP_APP_ID="some-guid" # you can retrieve this value from the appId when running `az ad sp create-for-rbac`
az ad sp show --id $SP_APP_ID --query "id" -o tsv
```

You can save this value for later as well, and this will be used for your `ARM_CLIENT_OBJECT_ID` for your environment secrets.

### Step 2. Grant roles to your Azure Service Principal

You can assign the following roles to your [Service Principal using the portal](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-users-assign-role-azure-portal):

> These roles should be assigned for you as part of the OHDSI on Azure [porter setup](/local_development_setup.md/#setup-porter).

* [Application Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#application-administrator)
* [Groups Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#groups-administrator)
* [User Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#user-administrator)
* [Privileged Role Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#privileged-role-administrator)

### Step 3. Setup a Github environment

In your github OHDSI On Azure repository with administrative context, you can setup an [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment).

> If you don't have rights to setup an environment, you can work with your repository owners.  Conversely, you can also fork the github repository and manage your own environment.

In this case, you can name your environment `demo`.  You can also restrict which branches are allowed to deploy to this environment using branch filtering.

![set environment branch filter](/docs/media/github_create_environment_0.png)

### Step 4. Setup Your Github Environment Secrets

You can setup your [Environment Secrets](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets) to reflect your environment settings:

| Setting Name | Setting Type | Sample Value | Notes |
|--|--|--|--|
| ADMIN_USER_JUMPBOX | string | `azureuser` | This is your Azure VM Jumpbox user name. |
| ADMIN_PASSWORD_JUMPBOX | string | `P@$$w0rd1234!` | This is your Azure VM Jumpbox password. |
| ADMIN_USER | string | `azureuser` | This is your Azure VMSS user name. |
| ADMIN_PASSWORD | string | `replaceP@SSW0RD` | This is your Azure VMSS password. |
| ADO_PAT | string | `my-PAT` | This is your Azure [DevOps PAT](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows).  You should use the Azure DevOps PAT which is setup as part of the [prerequisites steps](/infra/terraform/bootstrap/README.md/#ado-pat-notes). |
| ADO_ORGANIZATION_NAME | string | `my-org` | This is your Azure DevOps [organization name](https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls), so assuming your Azure DevOps URL is: `https://dev.azure.com/<my-org>`, you would specify `my-org`. |
| ARM_CLIENT_ID | string | `some-guid` | This is your Azure Service Principal `appId`.  You can get this from [Step 1](/docs/creating_your_environment_with_github_actions.md/#step-1-setup-an-azure-service-principal-for-your-environment). |
| ARM_CLIENT_OBJECT_ID | string | `some-guid` | This is your Azure Service Principal `objectId`.  You can get this from [Step 1](/docs/creating_your_environment_with_github_actions.md/#step-1-setup-an-azure-service-principal-for-your-environment). |
| ARM_CLIENT_SECRET | string | `some-password` | This is your Azure Service Principal `password`.  You can get this from [Step 1](/docs/creating_your_environment_with_github_actions.md/#step-1-setup-an-azure-service-principal-for-your-environment). |
| ARM_SUBSCRIPTION_ID | string | `some-guid` | This is the Azure Subscription ID which has your Azure Service Principal.  You can get this from [Step 1](/docs/creating_your_environment_with_github_actions.md/#step-1-setup-an-azure-service-principal-for-your-environment). |
| ARM_TENANT_ID | string | `some-guid` | This is the Azure Tenant ID which has your Azure Service Principal.  You can get this from [Step 1](/docs/creating_your_environment_with_github_actions.md/#step-1-setup-an-azure-service-principal-for-your-environment). |
| BOOTSTRAP_TF_STATE_CONTAINER_NAME | string | `<prefix>-<environment>-tfstate` | This is the name of your Bootstrap Terraform State File Azure Storage Container name.  This should correspond to the container name you set for your [remote backend for the bootstrap Terraform project](/infra/terraform/bootstrap/README.md#using-an-azure-storage-account-for-your-remote-backend) |
| BOOTSTRAP_TF_STATE_FILE_NAME | string | `terraform.tfstate` | This is the name of your Bootstrap Terraform State File Azure Storage Blob name.  This is the default name for your [remote backend for the bootstrap Terraform project](/infra/terraform/bootstrap/README.md#using-an-azure-storage-account-for-your-remote-backend) |
| BOOTSTRAP_TF_STATE_RG | string | `some-bootstrap-rg` | This is the resource group name which has your Azure Storage account for your [remote backend for the bootstrap Terraform project](/infra/terraform/bootstrap/README.md#using-an-azure-storage-account-for-your-remote-backend) |
| BOOTSTRAP_TF_STATE_STORAGE_ACCOUNT | string | `bootstraptfstate` | This is the Azure Storage Account name for your [remote backend for the bootstrap Terraform project](/infra/terraform/bootstrap/README.md#using-an-azure-storage-account-for-your-remote-backend) |
| BOOTSTRAP_TF_STATE_STORAGE_ACCOUNT | string | `bootstraptfstate` | This is the Azure Storage Account name for your [remote backend for the bootstrap Terraform project](/infra/terraform/bootstrap/README.md#using-an-azure-storage-account-for-your-remote-backend) |
| CREATE_NEW_AZURE_SERVICE_PRINCIPAL | string | `1` | Indicate whether to create a new Azure Service Principal for your porter bootstrap setup, and this value defaults to `1`.  If you would like to bring your own Service principal, set this value to `0` and be sure to specify `ARM_CLIENT_ID`, `ARM_CLIENT_OBJECT_ID`, `ARM_CLIENT_SECRET`, `ARM_SUBSCRIPTION_ID`, and `ARM_TENANT_ID`. |
| ENVIRONMENT | string | `demo` | Use this to designate your TF environment for your [bootstrap Terraform variables](/infra/terraform/bootstrap/README.md#step-1-update-your-variables) and will be populated in your [Variable Group](/docs/update_your_variables.md/#2-bootstrap-settings-vg). |
| INCLUDE_KEY_VAULT_PORTER_SECRETS | string | `1` | Indicate whether to use Azure Key Vault for your porter bootstrap setup, this value defaults to `1`.  If you set it to `0` you will instead rely on environment variables. |
| OMOP_PASSWORD | sensitive string | `some-password` | This is your Azure SQL DB Admin password for your [Environment](/infra/terraform/omop/README.md) which will be populated in your [Key Vault linked Variable Group](/docs/update_your_variables.md/#1-bootstrap-vg).  This is user supplied for your [bootstrap Terraform variables](/infra/terraform/bootstrap/README. |
| PREFIX | string | `sharing` | This is the prefix for your environment (from your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#step-1-update-terraformtfvars)), see the notes for [more details](/infra/terraform/bootstrap/README.md#prefix). |
| SOURCE_VOCABULARIES_STORAGE_ACCOUNT_CONTAINER | string | `vocabularies` | This is your source vocabularies Azure Storage Account container name.  The default is `vocabularies`.  You can review this value from [confirming access to your vocabulary storage account](/docs/creating_your_environment_with_github_actions.md/#step-4-confirm-access-to-your-vocabulary-storage-account). |
| SOURCE_VOCABULARIES_STORAGE_ACCOUNT_NAME | string | `demovocabohdsionazure` | This is your source vocabularies Azure Storage Account container name.  The default is `demovocabohdsionazure`.  You can review this value from [confirming access to your vocabulary storage account](/docs/creating_your_environment_with_github_actions.md/#step-4-confirm-access-to-your-vocabulary-storage-account). |
| VOCABULARIES_CONTAINER_NAME | string | `vocabularies` | This is your destination vocabularies Azure Storage Account container name.  The Azure Storage account will be available as part of deployment (e.g. `.github/workflows/deploy.yml`). |
| VOCABULARIES_CONTAINER_PATH | string | `vocabularies/19-AUG-2021` | This is your destination vocabularies Azure Storage Account container path.  The Azure Storage account will be available as part of deployment (e.g. `.github/workflows/deploy.yml`). |
| VOCABULARIES_SEARCH_PATTERN | string | `19-AUG-2021/*.csv` | This is your search pattern to use to find the vocabulary files in your source vocabularies Azure Storage Account container path. |

### Step 5. Deploying with github actions workflows

Currently the deployment workflows (under `.github/workflows/deploy.yml`) run on a schedule and on PR to the `main` branch based on your `demo` environment settings.

> This approach is wrapped with an OHDSI on Azure [Porter bundle](/local_development_setup.md#setup-porter) to manage installing, running your deployment for your environment, vocabulary, and broadsea, and also uninstalling workflows.
> This approach also relies on using an [Azure Storage remote backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) for both the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) and the [omop Terraform project](/infra/terraform/omop/README.md).
> The demo environment uses [environment secrets](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets) to manage settings required for setting up the OHDSI on Azure demo environment.
> This approach further assumes that the `main` branch is the default branch, as the [azure devops pipeline github action](https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/github-actions?#branch-considerations) relies on calling the default branch when calling a pipeline.  Currently you cannot set the default branch when importing a project through the [Azure DevOps provider](https://github.com/microsoft/terraform-provider-azuredevops/issues/297).

The `deploy.yml` workflow covers the following:

1. Deploy the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md).

* This deployment will also include setting up your Azure DevOps VMSS agent pools.
  * You will need to ensure that the Azure DevOps VMSS agent pools are ready so the following deployment pipelines can run.  If you are running into issues with your Azure DevOps VMSS Agent Pools, you can review the [troubleshooting notes](/docs/troubleshooting/troubleshooting_azure_vmss_agent_pool.md).

2. Deploy the [omop Terraform project](/infra/terraform/omop/README.md)

* This deployment will stand up your OHDSI on Azure OMOP Resource Group.
  * You (or your administrator) can confirm the [post Terraform deployment steps](/infra/terraform/omop/README.md#step-3-run-post-terraform-deployment-steps) prior to setting up your vocabualry.  This step is handled through the porter action but you can review the changes manually if desired.

3. Setup your [vocabulary in your OHDSI on Azure environment](/docs/setup/setup_vocabulary.md) by ensuring your [vocabulary files are populated](/docs/setup/setup_vocabulary.md) in your vocabulary Azure Storage Account and triggering your [vocabulary pipelines](/pipelines/README.md#vocabulary-pipelines).  If the vocabulary files are not available, the workflow will attempt to copy the vocabulary files from the [demo Vocabulary Azure Storage account](/docs/creating_your_environment_with_github_actions.md#step-4-confirm-access-to-your-vocabulary-storage-account) into your vocabulary Azure Storage Account.

4. Deploy [Broadsea](/apps/README.md) to your OHDSI on Azure Environment by triggering the [broadsea pipelines](/pipelines/README.md#broadsea-pipelines)
