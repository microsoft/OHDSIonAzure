# Test Settings
TESTS_DIR=tests

TEST_REPORT_FILE=tests_report.xml
PYTEST_OPTIONS=--junitxml=$(TEST_REPORT_FILE) --strict-markers -s -vv

MAX_LINE_LENGTH=120
LINT_REPORT_FILE=lint_report.xml
FLAKE8_OPTIONS=--config ../.github/linters/.flake8 --format=junit-xml --output-file=$(LINT_REPORT_FILE) --max-line-length=$(MAX_LINE_LENGTH)
# Max line length handled through pyproject.toml
BLACK_OPTIONS=--config ../.github/linters/pyproject.toml

SQL_SERVER_DOCKER_IMAGE=mcr.microsoft.com/mssql/server:2019-latest
SQL_SERVER_NAME=sql1
SA_PASSWORD=You-can-run-a-unit-test.

SQL_SERVER_DATA_SOURCE_NAME="<UnitTest>"
SQL_SERVER_VOCABULARIES_CONTAINER_PATH="<UnitTest>"

# URL format needs to be one expected by SQLAlchemy (https://docs.sqlalchemy.org/en/14/core/engines.html#database-urls)
UNIT_TEST_DB_URL=mssql+pymssql://sa:$(SA_PASSWORD)@localhost:1433/unit_test_db
SQL_PACKAGE_CONNECTION_STRING="User Id=sa;Password=$(SA_PASSWORD);Server=localhost,1433;Database=unit_test_db"
# might need to split this out to two different connection strings

# Set up paths

# No trailing or leading slash required for relative path from repo/sql directory
SQL_CDM_PATH=cdm/v5.3.1
DACPATH_BIN_RELEASE_PATH=$(SQL_CDM_PATH)/bin/Release/netstandard2.0
DOTNET_VOCABULARY_DDL_DACPAC=dotnet_vocabulary_ddl.dacpac
DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC=dotnet_vocabulary_indexes_constraints.dacpac
DOTNET_EMPTY_DACPAC=dotnet_empty.dacpac
DOTNET_VOCABULARY_DDL_DACPAC_PATH=$(DACPATH_BIN_RELEASE_PATH)/$(DOTNET_VOCABULARY_DDL_DACPAC)
DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC_PATH=$(DACPATH_BIN_RELEASE_PATH)/$(DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC)
DOTNET_EMPTY_DACPAC_PATH=$(DACPATH_BIN_RELEASE_PATH)/$(DOTNET_EMPTY_DACPAC)
SQLPACKAGE_PATH=/sqlpackage/sqlpackage

########################################
# Make targets

.PHONY: \
	all \
	check \
	bash-dev-env \
	bash-dev-env-build-vocabulary-ddl-dacpac \
	bash-dev-env-build-vocabulary-indexes-constraints-dacpac \
	bash-dev-env-build-supporting-dacpacs \
	bash-dev-env-build-empty-dacpac \
	bash-dev-env-check-tests \
	bash-dev-env-clean \
	bash-dev-env-install-dotnet-runtime \
	bash-dev-env-install-dotnet-sql-proj \
	bash-dev-env-install-sqlpackage \
	check-clean \
	check-style \
	check-style-clean \
	check-tests \
	check-tests-clean \
	clean \
	docker-sql-server \
	docker-sql-server-clean \
	help \
	install \
	macos-dev-env \
	macos-dev-env-clean \
	macos-dotnet-env \
	macos-dotnet-env-clean \
	macos-sqlpackage-env \
	macos-sqlpackage-env-clean \
	macos-freetds \
	macos-freetds-clean \
	maintainer-clean \
	pipenv \
	pipenv-clean \
	python-dependencies \
	python-dependencies-clean

all: check install

bash-dev-env: python-dependencies docker-sql-server

bash-dev-env-clean: python-dependencies-clean docker-sql-server-clean

# https://github.com/rr-wfm/MSBuild.Sdk.SqlProj#publishing-support
bash-dev-env-install-dotnet-sql-proj:
	dotnet new --install MSBuild.Sdk.SqlProj.Templates

bash-dev-env-build-supporting-dacpacs: bash-dev-env-build-vocabulary-ddl-dacpac bash-dev-env-build-vocabulary-indexes-constraints-dacpac bash-dev-env-build-empty-dacpac

#TODO: Not sure if these need to be run twice
bash-dev-env-build-vocabulary-ddl-dacpac:
	rm -rf $(DOTNET_VOCABULARY_DDL_DACPAC_PATH) && \
	dotnet build $(SQL_CDM_PATH)/dotnet_vocabulary_ddl.csproj -c Release

#TODO: Not sure if these need to be run twice
bash-dev-env-build-vocabulary-indexes-constraints-dacpac:
	rm -rf $(DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC_PATH) && \
	dotnet build $(SQL_CDM_PATH)/dotnet_vocabulary_indexes_constraints.csproj -c Release

#TODO: Not sure if these need to be run twice
bash-dev-env-build-empty-dacpac:
	rm -rf $(DOTNET_EMPTY_DACPAC_PATH) && \
	dotnet build $(SQL_CDM_PATH)/dotnet_empty.csproj -c Release

# should happen on a one-time basis
bash-dev-env-build-dacpac-dependencies: bash-dev-env-install-sqlpackage bash-dev-env-install-dotnet-runtime bash-dev-env-install-dotnet-sql-proj	

bash-dev-env-check-tests: bash-dev-env-build-supporting-dacpacs check-tests

# SqlProj nuget package supports dotnet-sdk-5.0
bash-dev-env-install-dotnet-runtime:
	sudo apt-get update && \
	sudo apt-get install -y apt-transport-https && \
	sudo apt-get update && \
	sudo apt-get install -y dotnet-sdk-5.0

# https://docs.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download?view=sql-server-ver15#get-sqlpackage-net-core-for-linux
bash-dev-env-install-sqlpackage:
	sudo apt-get install -y unzip && \
	sudo apt-get install libunwind8 && \
	sudo apt-get install libicu66 && \
	sudo rm -rf sqlpackage.zip && \
	wget -O sqlpackage.zip https://go.microsoft.com/fwlink/?linkid=2157202 && \
	# clean up existing files && \
	sudo rm -rf /sqlpackage && \
	sudo mkdir /sqlpackage && \
	sudo unzip sqlpackage.zip -d /sqlpackage && \
	# export PATH="$$PATH:/sqlpackage" && \
	sudo chmod a+x /sqlpackage/sqlpackage && \
	sudo ls -al /sqlpackage
	echo 'checking sqlpackage version:' && \
	/sqlpackage/sqlpackage /version

build-dir: $(BUILD_DIR)

check: check-tests check-style

check-style: python-dependencies build-dir
	python3 -m pipenv run flake8 $(FLAKE8_OPTIONS) $(TESTS_DIR) && \
	python3 -m pipenv run black $(BLACK_OPTIONS) $(TESTS_DIR)
	
check-style-clean: python-dependencies build-dir
	rm -f $(LINT_REPORT_FILE)

check-tests: python-dependencies build-dir
	export SQL_PACKAGE_CONNECTION_STRING=$(SQL_PACKAGE_CONNECTION_STRING) && \
	export DOTNET_VOCABULARY_DDL_DACPAC_PATH=$(DOTNET_VOCABULARY_DDL_DACPAC_PATH) && \
	export DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC_PATH=$(DOTNET_VOCABULARY_INDEXES_CONSTRAINTS_DACPAC_PATH) && \
	export DOTNET_EMPTY_DACPAC_PATH=$(DOTNET_EMPTY_DACPAC_PATH) && \
	export UNIT_TEST_DB_URL=$(UNIT_TEST_DB_URL) && \
	export SQLPACKAGE_PATH=$(SQLPACKAGE_PATH) && \
	export SQL_SERVER_NAME=$(SQL_SERVER_NAME) && \
	export SQL_SERVER_DATA_SOURCE_NAME=$(SQL_SERVER_DATA_SOURCE_NAME) && \
	export SQL_SERVER_VOCABULARIES_CONTAINER_PATH=$(SQL_SERVER_VOCABULARIES_CONTAINER_PATH) && \
	python3 -m pipenv run pytest $(PYTEST_OPTIONS) $(TESTS_DIR)

check-tests-clean:
	rm -f $(TEST_REPORT_FILE)

clean:
	rm -rf \
	$(TESTS_DIR)/*.pyc \
	$(TESTS_DIR)/*.pyo

docker-sql-server:
	docker run -e "ACCEPT_EULA=Y" \
	-e "SA_PASSWORD=$(SA_PASSWORD)" \
	-p 1433:1433 \
	--name $(SQL_SERVER_NAME) \
	-h $(SQL_SERVER_NAME) \
	-d $(SQL_SERVER_DOCKER_IMAGE)

docker-sql-server-clean:
	docker rm -f $(SQL_SERVER_NAME)

help:
	echo 'Needs implementation!'

install:
	echo 'Needs implementation!'

macos-dev-env: docker-sql-server macos-freetds macos-sqlpackage python-dependencies

macos-dev-env-clean: python-dependencies-clean macos-sqlpackage-clean macos-dotnet-clean macos-freetds-clean docker-sql-server-clean

macos-dotnet:
	brew tap isen-ng/dotnet-sdk-versions && brew install --cask dotnet-sdk5-0-400

macos-dotnet-clean:
	brew uninstall --cask dotnet-sdk5-0-400

macos-freetds:
	brew install freetds

macos-freetds-clean:
	brew uninstall freetds

# Modified slightly from the instructions at the following URL:
# https://docs.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download?view=sql-server-ver15#get-sqlpackage-net-core-for-macos
macos-sqlpackage: macos-dotnet
	wget -O sqlpackage.zip https://go.microsoft.com/fwlink/?linkid=2157203 && \
	rm -rf ~/sqlpackage && \
	unzip sqlpackage.zip -d ~/sqlpackage && \
	chmod +x ~/sqlpackage/sqlpackage && \
	(grep ~/.bash_history sqlpackage || echo 'export PATH="$$PATH:~/sqlpackage"' >> ~/.bash_profile) && \
	source ~/.bash_profile && \
	sqlpackage /version && \
	rm sqlpackage.zip

macos-sqlpackage-clean:
	rm -rf ~/sqlpackage/

maintainer-clean: clean
	echo 'Add additional statements for bringing project back to fresh repository check-out state.'

pipenv:
	python3 -m pip install pipenv

pipenv-clean:
	python3 -m pip uninstall pipenv

python-dependencies: pipenv
	python3 -m pipenv install -d

python-dependencies-clean:
	python3 -m pipenv uninstall --all

