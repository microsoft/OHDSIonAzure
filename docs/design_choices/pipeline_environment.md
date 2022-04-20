# Separate Environments

* Environments are separated through an Azure DevOps project and repository (e.g. `prefix-environment-OHDSIonAzure` for your project and `prefix-environment-OHDSIonAzure` for your repository) per environment as a scale unit to ease security and permissioning for future teams.
  * E.g. your dev team can have access to `<prefix>-dev-OHDSIonAzure` inside of Azure DevOps, but only your QA team can access `<prefix>-qa-OHDSIonAzure`.  Users can be [mapped](https://docs.microsoft.com/en-us/azure/devops/organizations/security/add-users-team-project?view=azure-devops&tabs=preview-page) by your [Azure DevOps administrator](https://docs.microsoft.com/en-us/azure/devops/organizations/security/add-remove-manage-user-group-security-group?view=azure-devops&tabs=preview-page#prerequisites).

* Having separate environments also eases testing for different versions of the application and setup.

## Pipeline Environment Settings

* Setup Azure DevOps pipelines on a per folder basis to represent your environment.
  * e.g. Your pipelines can be imported into a folder structure for `my-dev`:
    * `/OHDSIOnAzure/my-dev/Broadsea`
    * `/OHDSIOnAzure/my-dev/Terraform`
    * `/OHDSIOnAzure/my-dev/Vocabulary`

* You can use your corresponding variable groups (e.g. `my-dev-` variable groups) to represent your environment settings for your pipeline and should only be authorized for your corresponding pipelines on a per environment basis
  * When importing your pipeline, Terraform will map the appropriate variable groups to your [build definition](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition#variable_groups).  This will simplify environment promotion as you will have a linear mapping between environment variable group and pipeline.

    * Your [environment Terraform pipeline](/pipelines/README.md#environment-pipeline) will use 2 variable groups:
        1. A variable group ending with [bootstrap-vg](/docs/update_your_variables.md#1-bootstrap-vg) which is linked to [Azure Key Vault secrets](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) to run with your Environment Pipeline
        2. A variable group ending with [bootstrap-settings-vg](/docs/update_your_variables.md#2-bootstrap-settings-vg) which is **not** linked to Azure Key Vault to configure running your Environment pipeline

    * Your application pipelines (e.g. [broadsea pipelines](/pipelines/README.md/#broadsea-pipelines) and [vocabulary pipelines](/pipelines//README.md/#vocabulary-pipelines)) will use One (1) variable group ending with [omop-environment-settings-vg](/docs/update_your_variables.md#3-omop-environment-settings-vg)

  * The variable groups should be authorized according to usage (E.g. [bootstrap-vg](/docs/update_your_variables.md#1-bootstrap-vg) will be authorized for your [Environment pipeline](/pipelines/README.md#environment-pipeline) but not your [Vocabulary Build pipeline](/pipelines/README.md#)).
    > This will prevent your [Vocabulary Build Pipline](/pipelines/README.md#vocabulary-build-pipeline) from reading Key Vault linked secrets in your [bootstrap-vg](/docs/update_your_variables.md#1-bootstrap-vg).

  * Given that the `prefix` and `environment` will be coming into the pipeline from the authorized [variable groups](/docs/update_your_variables.md), some features like [build completion triggers](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/pipeline-triggers?tabs=yaml&view=azure-devops#configure-pipeline-resource-triggers) will need to be re-enabled later by directly mapping the values into the pipeline yaml.
    > See the [Vocabulary Release Pipeline](/pipelines/vocabulary_release_pipeline.yaml) for an example.

### Setting up Agent Pools

While you can manually spin up your Azure DevOps agent pools, you can also use the Azure DevOps REST API in order to provision and manage the Azure DevOps Agent pools.  Since this API version is not available for the Azure DevOps TF Provider, instead you can use the REST API with shell scripts to provision and manage permissions to your Azure DevOps VMSS agent pools.

For example, you can review the [azure_devops_elastic_pool TF module](/infra/terraform/modules/azure_devops_elastic_pool/v0/README.md) which is a workaround as the Azure DevOps Terraform provider doesn't include the Azure DevOps [7.1 API](https://github.com/MicrosoftDocs/vsts-rest-api-specs/tree/master/specification/distributedTask/7.1).

## Observability Notes

* infra:
  * Use az cli to validate infrastructure is ready
    * Services in bootstrap-rg
    * Services in omop-rg
  * potentially check Azure Monitor / kusto queries

* Get version information

* Application level smoke tests (start simple):
  * curl for broadsea-appservice/WebAPI/source/sources
  * Check Atlas is available (curl broadsea-appservice/Atlas)
  * Check vocabulary files are available (see [example](/pipelines/templates/smoke_test/smoke_test_vocabulary_files.yaml)
  * Check vocabulary is updated in CDM (currently included in the dacpacs)
