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
  * Ensure you are using Azure CLI version >= `2.37`, you can check the version you have installed with `az --version`.

  * You can use Azure CLI to manage your Azure Subscription

  * You will need to ensure your Azure CLI also has the [Azure DevOps extension](https://docs.microsoft.com/en-us/azure/devops/cli/?view=azure-devops) installed

    ```shell
    az config set extension.use_dynamic_install=yes_without_prompt

    az extension add --name azure-devops
    ```

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

  * Ensure you are using `jq` version >= `1.6`, and you can check the version you have installed with `jq --version`.

* Install [python3](https://docs.microsoft.com/en-us/learn/modules/python-install-vscode/3-exercise-install-python3?pivots=linux)

* Install [docker](https://docs.docker.com/get-docker/)

* Install make `sudo apt install make`

* Install [git](https://docs.microsoft.com/en-us/contribute/get-started-setup-tools#install-git-client-tools)

* Clone this repository locally:

```bash
git clone https://github.com/microsoft/OHDSIonAzure
```

* Install [porter](https://porter.sh/install/)

## Setup Porter

You can install [porter](https://porter.sh/install/) per the docs.

For convenience, call the [setup](./setup.sh) script to install porter and configure it for your OHDSI on Azure environment.

> This setup script assumes you have `docker`, `az` (Azure CLI), and administrative access to your Azure subscription and to your Azure DevOps organization.  Your Azure Service Principal should be unique per environment.  You should also ensure you have permissions to execute the script which you can set through `chmod +x setup.sh`.

```shell
./setup.sh \
    --AZURE_SERVICE_PRINCIPAL_NAME "myOHDSIOnAzureSP" \
    --BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_NAME "mybootstraptfstatesa" \
    --BOOTSTRAP_TF_BACKEND_RESOURCE_GROUP_NAME "my-bootstrap-rg" \
    --BOOTSTRAP_TF_BACKEND_STORAGE_ACCOUNT_CONTAINER_NAME "my-tfstate" \
    --ADO_PAT "my-Azure-DevOps-PAT" \
    --OMOP_PASSWORD "replaceMyP@SSW0RD" \
    --ADMIN_USER_JUMPBOX "azureuser" \
    --ADMIN_PASSWORD_JUMPBOX "replaceMyP@SSW0RD@ls0" \
    --ADMIN_USER "azureuser" \
    --ADMIN_PASSWORD "replaceMyP@SSW0RDT00" \
    --PREFIX "ohdsi" \
    --ENVIRONMENT "dev01" \
    --ADO_ORGANIZATION_NAME "my-ADO-organization-name"
```

The setup script should setup your backend Azure Storage account for your bootstrap, install porter, and setup an OHDSI on Azure environment configuration file, which you can pull into your local environment with the following command:

```shell
# This command should be an output from the setup.sh call
source "ohdsi-dev01-OHDSIOnAzure.env"
```

### Install Mixins

The setup script will include installing [mixins](https://release-v1.porter.sh/mixins/) for your OHDSI on Azure environment.  If you need to install one, you can use the following `porter` command:

```shell
# Install the az mixin
porter mixin install az
```

### Install Plugins

The setup script will include installing the [azure plugin](https://porter.sh/plugins/azure/) for your OHDSI on Azure environment, which is covered with the following command:

```shell
porter plugin install azure
```

### Build your bundle

OHDSI on Azure uses [Porter](https://porter.sh/docs/) to have a build environment wrapped in an OCI container to capture dependencies and setup steps in a [CNAB (Cloud Native Application Bundle)](https://github.com/cnabio/cnab-spec) bundle manifest.  Using a bundle will provide a consistent build and deployment experience for OHDSI on Azure.

You can perform a local build for porter with the following command:

```shell
porter build
```

### Configure your Credentials and Parameters

If desired, you can configure your porter credentials for your environment (e.g. you'd like to more variables to pull from environment variables or other sources, see the included [creds.json](./creds.json)):

```shell
# Fill in credentials with environment variables
porter credentials generate creds
porter credentials show creds --output json > creds.json
```

Similarly, you can also configure your porter parameters if you need to adjust from the default mapping (see the included [parameters.json](./parameters.json)).

```shell
porter parameters generate parameters
porter parameters show parameters --output json > parameters.json
```

### Using Porter commands

For a full view of the bundle, you can use `porter explain`.

#### Install

You can `install` your bootstrap:

```shell
porter install \
    --cred ./creds.json \
    -p ./parameters.json
```

#### Invoke Actions

You can invoke actions after you have installed successfully.

For example, you can call the deployment actions:

1. You can call the action `deploy-environment` to deploy your environment:

```shell
porter invoke --action deploy-environment \
    --cred ./creds.json \
    -p ./parameters.json
```

2. You can call the action `deploy-vocabulary` to deploy your vocabulary:

```shell
porter invoke --action deploy-vocabulary \
    --cred ./creds.json \
    -p ./parameters.json
```

3. You can call the action `deploy-broadsea` to deploy broadsea:

```shell
porter invoke --action deploy-broadsea \
    --cred ./creds.json \
    -p ./parameters.json
```

And you can check your pipeline status with `check-pipeline-run`:

```shell
porter invoke --action check-pipeline-run \
    --cred ./creds.json \
    -p ./parameters.json \
    --param build_id=13
```

#### Uninstall

You can also `uninstall` your OHDSI on Azure environment:

```shell
porter uninstall \
    --cred ./creds.json \
    -p ./parameters.json
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
* Python with [Flake8](/local_development_setup.md#python-with-flake8) and [Black](/local_development_setup.md#python-with-black)
* Github Actions with [Actionlint](/local_development_setup.md#github-actions-with-actionlint)

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

### Python with flake8

You can use [flake8](https://flake8.pycqa.org/en/latest/) for linting `python` files.

1. You can [install flake8](https://flake8.pycqa.org/en/latest/#installation):

> This assumes you have already activated your [virtual environment](/local_development_setup.md#setup-a-python-virtual-environment)

```bash
python3 -m pip install flake8
```

2. You can use [flake8](https://flake8.pycqa.org/en/latest/#using-flake8) on files or folders:

```bash
flake8 --config path/config/.flake8 path/to/code/to/check.py
# or
flake8 --config path/config/.flake8 path/to/code/
```

For example, from the repository root directory, you can run `flake8 --config .github/linters/.flake8 sql/tests`

### Python with black

You can use [black](https://black.readthedocs.io/en/stable/getting_started.html) for linting `python` files.

1. You can [install black](https://black.readthedocs.io/en/stable/getting_started.html#installation):

> This assumes you have already activated your [virtual environment](/local_development_setup.md#setup-a-python-virtual-environment)

```bash
python3 -m pip install black
```

2. You can use [black](https://black.readthedocs.io/en/stable/getting_started.html#basic-usage) on files or folders:

```bash
black --config path/to/pyproject.toml path/to/code/to/check.py
# or
black --config path/to/pyproject.toml  path/to/code/
```

For example, from the repository root directory, you can run `black --config .github/linters/pyproject.toml sql/tests`

### Github Actions with Actionlint

You can use [actionlint](https://github.com/rhysd/actionlint/) for linting github actions workflows.

1. You can [install](https://github.com/rhysd/actionlint/blob/main/docs/install.md) if you desire.

2. You can use [actionlint](https://github.com/rhysd/actionlint/blob/main/docs/usage.md#docker) with docker:

```bash
cat /path/to/workflow.yml | docker run --rm -i rhysd/actionlint:latest -color -
```

For example, from the repository root directory, you can run `cat .github/workflows/build-validation.yml | docker run --rm -i rhysd/actionlint:latest -color -`.

## Testing

You can setup testing for SQL.

### SQL Testing

The SQL test project uses [pytest](https://docs.pytest.org/en/7.1.x/) to wrap a test suite for working with the [SQL project](/sql) including the [CDM](/sql/cdm/) through [dacpacs](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15).  By default, the test suite will run against a local [SQL Server 2019 Docker container](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-ver15) instead of Azure SQL.

1. From the repository root directory, you can navigate to the [sql/tests](/sql/tests/) folder.

```bash
# from repository root directory
cd sql/tests
```

2. You can use `make` to setup your environment:

> Note, if you don't have make, you can use `sudo apt-get install make` to setup make in your `bash` shell.

```bash
# you can setup your development environment for bash
make bash-dev-env
```

> As a one-time step (or if you have local changes to SQL that you'd like to test), you can build the dacpac build dependencies.

```bash
make bash-dev-env-build-dacpac-dependencies
```

3. Confirm the [sql docker container](https://mcr.microsoft.com/v2/mssql/server/tags/list) is running

```bash
# confirm that you have sql running in docker
docker ps
```

4. Create dacpacs for testing

```bash
# create dacpacs
make bash-dev-env-build-supporting-dacpacs
```

5. Run your tests

```bash
make check-tests
```

6. You can clean up your environment as well

```bash
make bash-dev-env-clean
```
