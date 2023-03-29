# Testing Notes

The [sql tests project](/sql/tests) uses [pytest](https://docs.pytest.org/en/7.1.x/) to wrap a test suite for checking your [CDM](/sql/cdm/) using [dacpacs](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15).

By default, the test suite will run against a local [sql server 2019 docker container](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-ver15) instead of Azure SQL.

## Local Development

Check the [local development setup notes](/local_development_setup.md) for how you can get a local development environment.

You can also review the [sql testing section](/local_development_setup.md#sql-testing) for basic usage notes.

### TODO

* Incorporate data loading for the [post deployment script](/sql/cdm/v5.3.1/omop_vocabulary_ddl/Scripts/Script.PostDeployment.sql) with local testing.  Currently this is skipped within the test suite.
