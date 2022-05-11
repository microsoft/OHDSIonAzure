# CI Validation Choices

Automating validation is part of the CI strategy, which includes:

1. [Linting](/docs/design_choices/ci_validation.md#linting)
2. [Testing](/docs/design_choices/ci_validation.md#testing)

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

## Testing

* The application pipelines include [smoketests](/pipelines/templates/smoke_test/).

* Setup Test Suite and add into github actions workflow
  * SQL - this project will use [pytest](https://docs.pytest.org/en/7.1.x/) to wrap a test suite for working with the [SQL project](/sql) including the [CDM](/sql/cdm/) through [dacpacs](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15).  By default, the test suite will run against a local [SQL Server 2019 Docker container](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-ver15) instead of Azure SQL.
    * The test suite can be run [locally](/local_development_setup.md#sql-testing), and it is included as part of CI validation.  The test suite is also included as part of the [Vocabulary Release Pipeline](/pipelines/README.md/#vocabulary-release-pipeline).
      * Using [Azurite](https://github.com/Azure/Azurite) to stand in for Azure Storage works for some cases (e.g. adding files into Azure Storage with [Azure Storage Explorer](https://github.com/Azure/Azurite#storage-explorer)), but the test suite uses Bulk Insert which has [access issues with Azurite](https://github.com/Azure/Azurite/issues/1474).  For this reason, loading files locally for use with [Bulk Insert](/sql/cdm/v5.3.1/omop_vocabulary_ddl/Scripts/Script.PostDeployment.UnitTest.sql) is a workaround until the access issues are resolved.
    * The test suite is also included with the [vocabulary release pipeline](/pipelines/README.md/#vocabulary-release-pipeline) as a step prior to publishing in your environment.

  * Terraform
    * The [bootstrap Terraform project](/infra/terraform/bootstrap/README.md) and the [omop Terraform project](/infra/terraform/omop/README.md) can be both checked with `terraform fmt -check` and `terraform validate` as rudimentary [unit tests](https://www.hashicorp.com/blog/testing-hashicorp-terraform).  Further, you can run `terraform init` to ensure that the providers are available for each project.  Finally, you can incorporate `terraform plan` to verify prospective changes that would be pushed into your Azure subscription.  Currently this is enabled with the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md).
      * TODO: Enable Terraform Plan for [omop Terraform project](/infra/terraform/omop/README.md).  Need to consider if having an actual CI environment (from main) will be helpful.
