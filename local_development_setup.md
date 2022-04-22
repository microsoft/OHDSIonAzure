# Local Development Notes

These notes cover how you can setup a local development environment.

## Setup Local Tools

* Install [VSCode](https://code.visualstudio.com/) or another editor of choice

* For SQL:
  1. Install [Visual Studio](https://docs.microsoft.com/en-us/visualstudio/install/install-visual-studio?preserve-view=true&view=vs-2022)
    You can use Visual Studio to open the [SQL CDM Solution](/sql/cdm/v5.3.1/cdm_omop.sln).
  2. Install [Visual Studio with SSDT](https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt?view=sql-server-ver15)
    > This is useful if you'd like to compare [schema changes](https://docs.microsoft.com/en-us/sql/ssdt/how-to-use-schema-compare-to-compare-different-database-definitions?view=sql-server-ver15#:~:text=To%20compare%20database%20definitions%201%20On%20the%20SQL,created%20in%20the%20previous%20procedure.%20More%20items...%20) as part of updating your [CDM](/sql/cdm/v5.3.1/) for your [vocabulary setup](/docs/setup/setup_vocabulary.md).
  3. Install [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15)
    > You can use SQL Server Management Studio to connect to your Azure SQL [CDM](/sql/cdm/v5.3.1/)

* Install [Azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
    > You can use this to manage your Azure Subscription

* Install [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)
    > You can use this to manage your Azure Storage Accounts (e.g. for [setting up your vocabulary](/docs/setup/setup_vocabulary.md))

* Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)

    ```bash
    # Ensure that your system is up to date, and you have the gnupg, software-properties-common, and curl packages installed
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

    # Add the HashiCorp GPG key.
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

    # Add the official HashiCorp Linux repository.
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

    # Update to add the repository, and install the Terraform CLI.
    sudo apt-get update && sudo apt-get install terraform
    ```

* Install [jq](https://stedolan.github.io/jq/download/)

    ```bash
    sudo apt-get install jq
    ```

* Install [python3](https://docs.microsoft.com/en-us/learn/modules/python-install-vscode/3-exercise-install-python3?pivots=linux)

* Install [git](https://docs.microsoft.com/en-us/contribute/get-started-setup-tools#install-git-client-tools)

* Clone this repository locally:

```bash
git clone https://github.com/microsoft/OHDSIonAzure
```

## Setup a Python Virtual Environment

You can setup a [python virtual environment](https://docs.python-guide.org/dev/virtualenvs/#virtualenvironments-ref) for local development.

```bash
# from the repository root working directory

python3 -m venv my-venv # create a virtual environment

. my-venv/bin/activate # activate your virtual environment
```

## Linting

For local development, you can install these tools for linting:

* Dockerfiles [with Hadolint](/local_development_setup.md/#dockerfiles-with-hadolint)
* SQL [with SQLFluff](/local_development_setup.md/#sql-with-sqlfluff)
* Bash [with Shellcheck](/local_development_setup.md/#bash-with-shellcheck)
* PowerShell [with PSScriptAnalyzer](/local_development_setup.md/#powershell-with-psscriptanalyzer)
* Markdown [with Markdownlint](/local_development_setup.md/#markdown-with-markdownlint)
* YAML [with Yamllint](/local_development_setup.md/#yaml-with-yamllint)
* Terraform [with TFLint](/local_development_setup.md/#terraform-with-tflint)

These linters are also used as part of CI validation in a [github action](/.github/workflows/build-validation.yml) through [super-linter](https://github.com/github/super-linter), so ensuring your changes work locally before pushing commits can accelerate your feedback cycle.

### Dockerfiles with Hadolint

You can use [hadolint](https://github.com/hadolint/hadolint) to lint Dockerfiles.

> Note this setup assumes you have Docker setup for linux

1. Run the following from your repository root directory:

    ```bash
    # from the repository root working directory

    docker run --rm -i hadolint/hadolint < apps/broadsea-methods/Dockerfile

    docker run --rm -i hadolint/hadolint < apps/broadsea-webtools/Dockerfile
    ```

### SQL with Sqlfluff

[SQLfluff](https://github.com/sqlfluff/sqlfluff) will provide linting for `SQL` dialects including `T-SQL`.

You can also review the [Configuration documentation](https://docs.sqlfluff.com/en/stable/configuration.html) to adjust how the linter works.

1. Ensure that you have activated your [python virtual environment](/local_development_setup.md/#setup-a-python-virtual-environment).

2. You can install `SQLFluff` using `python`:

    ```bash
    # Assuming you have activated your virtual environment

    python3 -m pip install sqlfluff # install sqlfluff in your virtual environment
    ```

3. Now that `sqlfluff` is installed, you can use it from your repository root directory:

    ```bash
    # from the repository root working directory

    sqlfluff lint --config .github/linters/.sqlfluff sql
    ```

4. You can review the current configuration rules which are stored in the [.github/linters folder](.github/linters/.sqlfluff).

### Bash with Shellcheck

You can use [shellcheck](https://github.com/koalaman/shellcheck) to lint your `bash` scripts.

> If you prefer, you can install the VSCode Extension [vscode-shellcheck](https://github.com/timonwong/vscode-shellcheck)

1. In your bash terminal, you can install `shellcheck`:

    ```bash
    sudo apt install shellcheck
    ```

2. You can use `shellcheck` to lint bash scripts in the repository.

    ```bash
    # from the repository root working directory

    shellcheck path/to/my/bash/script.sh
    ```

### PowerShell with PSScriptAnalyzer

You can use [PsScriptAnalyzer](https://github.com/PowerShell/Psscriptanalyzer) to lint `PowerShell` files.

1. Install the PowerShell module

```powershell
Install-Module -Name PSScriptAnalyzer
```

2. You can lint a file

```powershell
Invoke-ScriptAnalyzer -Path .\path\to\script.ps1
```

> For example, you can use `Invoke-ScriptAnalyzer -Path .\infra\terraform\bootstrap\scripts\build-agent-dependencies.ps1` from the repository root directory

3. You can also lint a folder recursively

```powershell
Invoke-ScriptAnalyzer -Path .\path\to\module -Recurse
```

### Markdown with Markdownlint

You can use [markdownlint](https://github.com/DavidAnson/markdownlint) to lint `markdown` files.

You can also review the [configuration options](https://github.com/DavidAnson/markdownlint#optionsconfig) to adjust how the linter works.

> For convenience, you can install the [vscode-markdownlint extension for VSCode](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) which can detect issues with markdown files as you are editing them in VSCode.

1. In order to install, you will need to have `node` and `npm`.

    * Add nodejs to your repo:

    ```bash
    # Add nodejs 14 to your repo
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    ```

    * Install `nodejs` and `npm`:

    ```bash
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # Install nodejs (which should include npm install)
    sudo apt-get install -y nodejs

    # confirm node installed
    node -v

    # confirm npm version
    npm -v
    ```

2. Once you have `node` and `npm` installed, you can install the linter:

    * Install the cli

    ```bash
    npm install -g markdownlint-cli
    ```

3. You can run `markdownlint` on your `markdown` file:

    ```bash
    # use the markdownlint configuration file with a markdown file
    markdownlint -c .github/linters/.markdownlint.json local_development_setup.md
    ```

3. You can review the current configuration rules which are stored in the [.github/linters folder](./.github/linters/.markdownlint.json).

### YAML with Yamllint

You can use [yamllint](https://github.com/adrienverge/yamllint) for linting `yaml` files.

1. Ensure that you have activated your [python virtual environment](/local_development_setup.md/#setup-a-python-virtual-environment).

2. You can use `pip` to install `yamllint`:

```bash
python3 -m pip install yamllint
```

3. You can lint your `yaml` files:

```bash
# Lint all YAML files in a directory
yamllint .

# Use a custom lint configuration
yamllint -c /path/to/myconfig file-to-lint.yaml
```

> For example, you can use `yamllint -c .github/linters/.yaml-lint.yml pipelines` to lint the pipeline `yaml` files.

4. You can review the current configuration rules which are stored in the [.github/linters folder](./.github/linters/.yaml-lint.yml).

### Terraform with TFLint

You can use [TFLint](https://github.com/terraform-linters/tflint) for linting `terraform` files.

1. You can [install tflint](https://github.com/terraform-linters/tflint#installation):

Using bash (Linux):

```bash
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

Using Homebrew (macOS):

```shell
brew install tflint
```

Using Chocolatey (Windows):

```powershell
choco install tflint
```

2. You can use [tflint on files or folders](https://github.com/terraform-linters/tflint#usage):

```bash
tflint path/to/folder/or/file
```

For example, from the repository root directory, you can run `tflint infra/terraform`.
