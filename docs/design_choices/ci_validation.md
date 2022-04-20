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

## Testing

* The application pipelines include [smoketests](/pipelines/templates/smoke_test/).

* TODO: Setup Test Suite and add into github actions workflow
  * SQL
  * Terraform (tfplan)
