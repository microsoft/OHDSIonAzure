# CI Validation Choices

Automating validation is part of the CI strategy, which includes:

1. [Linting](/docs/design_choices/ci_validation.md#linting)
2. [Testing](/docs/design_choices/ci_validation.md#testing)
3. [Portable Build and Deployment Environment](/docs/design_choices/ci_validation.md#portable-build-and-deployment-environment)

## Linting

You can use [super-linter](https://github.com/github/super-linter) to lint various languages in the repository as part of a [github action workflow](https://github.com/github/super-linter#example-connecting-github-action-workflow).  The github action workflow will use the [super-linter slim image](https://github.com/github/super-linter#slim-image) as this has a smaller image size and will speed up the build and download time, and this repository does not require the standard image.

The linters should cover the following:

* Dockerfile using [hadolint](https://github.com/hadolint/hadolint)
* SQL using [SQLfluff](https://github.com/sqlfluff/sqlfluff)
* Bash using [shellcheck](https://github.com/koalaman/shellcheck)
* PowerShell using [PSScriptAnalyzer](https://github.com/PowerShell/Psscriptanalyzer)
* Markdown using [markdownlint](https://github.com/DavidAnson/markdownlint)
* YAML using [yamllint](https://github.com/adrienverge/yamllint)
* Terraform using [tflint](https://github.com/terraform-linters/tflint)
* Python using [flake8](https://flake8.pycqa.org/en/latest) and [black](https://black.readthedocs.io/en/stable/getting_started.html)
* Github Actions with [Actionlint](https://github.com/rhysd/actionlint/)

## Testing

* The application pipelines include [smoketests](/pipelines/templates/smoke_test/).

* Setup Test Suite and add into github actions workflow
  * SQL - this project will use [pytest](https://docs.pytest.org/en/7.1.x/) to wrap a test suite for working with the [SQL project](/sql) including the [CDM](/sql/cdm/) through [dacpacs](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15).  By default, the test suite will run against a local [SQL Server 2019 Docker container](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-ver15) instead of Azure SQL.
    * The test suite can be run [locally](/local_development_setup.md#sql-testing), and it is included as part of CI validation.  The test suite is also included as part of the [Vocabulary Release Pipeline](/pipelines/README.md/#vocabulary-release-pipeline).
      * Using [Azurite](https://github.com/Azure/Azurite) to stand in for Azure Storage works for some cases (e.g. adding files into Azure Storage with [Azure Storage Explorer](https://github.com/Azure/Azurite#storage-explorer)), but the test suite uses Bulk Insert which has [access issues with Azurite](https://github.com/Azure/Azurite/issues/1474).  For this reason, loading files locally for use with [Bulk Insert](/sql/cdm/v5.3.1/omop_vocabulary_ddl/Scripts/Script.PostDeployment.UnitTest.sql) is a workaround until the access issues are resolved.
    * The test suite is also included with the [vocabulary release pipeline](/pipelines/README.md/#vocabulary-release-pipeline) as a step prior to publishing in your environment.

  * Terraform
    * The [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) and the [omop Terraform project](/infra/terraform/omop/README.md) can be both checked with `terraform fmt -check` and `terraform validate` as rudimentary [unit tests](https://www.hashicorp.com/blog/testing-hashicorp-terraform).  Further, you can run `terraform init` to ensure that the providers are available for each project.  Finally, you can incorporate `terraform plan` to verify prospective changes that would be pushed into your Azure subscription.  Currently this is enabled with the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md).

    * You can use `terraform plan` for [omop Terraform project](/infra/terraform/omop/README.md) in the CI validation [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment).  This will allow checking for the `terraform plan` results when making PR's to main.  The testing strategy includes `terraform plan` as part of [unit testing](https://www.hashicorp.com/blog/testing-hashicorp-terraform).
      * The CI environment uses [environment secrets](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets) to manage settings required for validating `main` within the CI environment.

    * You can use `terraform apply` for both the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) and the [omop Terraform project](/infra/terraform/omop/README.md) to check that the OHDSI on Azure environment will deploy correctly.  This is rolled up with orchestrating the [pipelines](/pipelines/README.md) as part of an automated Demo [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) from a github actions workflow (see `.github/workflows/deploy.yml` as a starting point), which also serves as an integration test when making changes to the `main` branch.
      * This approach also relies on using an [Azure Storage remote backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) for both the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) and the [omop Terraform project](/infra/terraform/omop/README.md).
      * The demo environment uses [environment secrets](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets) to manage settings required for setting up the OHDSI on Azure demo environment.
      * This approach further assumes that the `main` branch is the default branch, as the [azure devops pipeline github action](https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/github-actions?#branch-considerations) relies on calling the default branch when calling a pipeline.  Currently you cannot set the default branch when importing a project through the [Azure DevOps provider](https://github.com/microsoft/terraform-provider-azuredevops/issues/297).

## Portable Build and Deployment Environment

OHDSI on Azure uses [Porter](https://porter.sh/docs/) to have a build environment wrapped in an OCI container to capture dependencies and setup steps in a [CNAB (Cloud Native Application Bundle)](https://github.com/cnabio/cnab-spec) bundle manifest.

Using a containerized environment will ensure that the deployment experience will be consistent provided you have met baseline dependencies setup locally (e.g. you can run Docker, you have an Azure subscription with administrative access, and you have an Azure DevOps PAT).  This approach also allows you to use the Porter OHDSI on Azure bundle from a deployment (CD) pipeline.

The goal for the bundle is to wrap the OHDSI on Azure setup into a set of [commands](https://porter.sh/cli/porter/#see-also) and [actions](https://porter.sh/cli/porter_invoke/) using Porter, including handling the following:

1. Install - provided you have setup your Porter parameters and credentials, you can use this command to bootstrap your OHDSI on Azure environment
2. Deploy Environment - This is an action which you can run after the install.  This will setup your OHDSI on Azure OMOP Resource Group
3. Deploy Vocabulary - This action will deploy your vocabulary in your OHDSI on Azure OMOP resource group
4. Deploy Broadsea - This action will deploy broadsea in your OHDSI on Azure OMOP resource group
5. Uninstall - You can use this command to clean up your OHDSI on Azure environment

Wrapping the deployment steps into commands and scripts will reduce manual operational steps for running OHDSI on Azure.

You can also use the lower level actions to troubleshoot and debug your deployment.  For example, you can call `porter invoke --action check-pipeline-run` to check on a particular pipeline run.
