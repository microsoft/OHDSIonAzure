## TODO - Revisit these notes

# Broadsea-Methods

This is a combined image for [Achilles](https://github.com/OHDSI/Achilles) and [ETL-Synthea](https://github.com/OHDSI/ETL-Synthea).

## Achilles

[Achilles](https://github.com/OHDSI/Achilles) is an R package used to automate the characterization of OMOP CDM data. It provides descriptive statistics and data quality checks on the OMOP CDM databases. Achilles will generally only succeed if there is data that exists in the OMOP CDM, so it is important to run this step after data has been imported.

### Prerequisites

In order to set up Achilles, you can work through the following steps:

<a id='prerequisite_step_1'></a>
## Step 1. Import Data

As a prerequisite to running Achilles, you will need to have OMOP CDM data.  You can use one of the following approaches to accomplish this step:

1. For development and test purposes, you can import data to your OMOP CDM using the [synthetic_data_pipeline](../pipelines/synthetic_data_pipeline.yaml) which includes a step to run [synthea-etl](../docs/synthea-etl-achilles.md).

<a id='prerequisite_step_2_build_image'></a>
## Step 2. Build achilles-synthea-etl Image

1. You can build and push the achilles-synthea-etl image to Azure Container Registry using the [synthetic_data_pipeline](../pipelines/synthetic_data_pipeline.yaml).  You can refer to these [Pipeline Notes](../docs/synthea-etl-achilles.md) for more details.

### Script Notes

The following scripts will be mounted as part of the [achilles_pipeline](../pipelines/achilles_pipeline.yaml).

<a id='achilles_r_script_notes'></a>
## Achilles.R

The [achilles.R script](../achilles/achilles.R) will be loaded with the Docker container.  This script will connect to the OMOP CDM and perform the following steps:

1. Set database [compatibility level](https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=sql-server-ver15) to a lower level for running `achilles`
    ```sql
    ALTER DATABASE [my_sql_database_name] SET compatibility_level = 110
    ```
    > This step is included in the script as a workaround for the issue where ['the query processor ran out of internal resources and could not produce a query plan'](../docs/synthea-etl-achilles.md/#known_issue_query_plan).  By setting the compatibility level to 110, Azure SQL will take the default compatibility level associated with SQL Server 2012, which will cause Azure SQL to use an [older query optimizer](https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=sql-server-ver15#differences-between-lower-compatibility-levels-and-level-120) to produce the query plan.  Using this setting has a tradeoff which is Azure SQL will not be able to run ADF pipelines which require the default compatibility level for Azure SQL.
2. Run [achilles](https://raw.githubusercontent.com/OHDSI/Achilles/master/extras/Achilles.pdf)
   > You may run into an known issue with an [arithmetic overflow error](../docs/synthea-etl-achilles.md/#known_issue_arithmetic_overflow).  You will need to ensure you're picking up the latest changes for Achilles by [rebuilding Achilles](#prerequisite_step_2_build_image) to pick up the [Achilles committed](https://github.com/OHDSI/Achilles/commit/e21c7e16cb4cbd653e3e572db86b536cdda86aca) fix.
3. Set database compatibility level back to the default for Azure SQL
    ```sql
    ALTER DATABASE [my_sql_database_name] SET compatibility_level = 150
    ```
    > If Azure SQL is set to a compatibility_level other than the default you will notice issues when running the [transform data load ADF Pipeline](https://dev.azure.com/veradigm/Clinical%20Research%20Network/_git/CDR.DataFactory?path=/pipeline_tests/readme.md) as part of [Prerequisite step 1](#prerequisite_step_1).

This script also uses the following environment variables:

| Environment Variable Name | Description  |
|--------------|-----------|
| SQL_SERVER_NAME | Azure SQL Server Name (e.g. `my-sql-server` if you using `my-sql-server.database.windows.net`) |
| SQL_DATABASE_NAME | Azure SQL Database Name (e.g. `my-sql-server-db`) which has the CDM |
| CDM_SCHEMA | Schema for CDM (e.g. `dbo`) |
| RESULTS_SCHEMA | Schema for Results used by Achilles (e.g. `webapi`) |
| VOCAB_SCHEMA | Schema for Vocabulary (e.g. `dbo`) |
| SOURCE_NAME | CDM source name, the default is `OHDSI CDM V5 Database` |
| NUM_THREADS | Number of threads to use with Achilles, the default is `1` |

### Achilles-test.R

The [achilles-test.R script](../achilles/achilles-test.R) will perform a smoke test which checks if the `achilles_results` and `achilles_analysis` tables are populated.

This script also uses the following environment variables:

| Environment Variable Name | Description  |
|--------------|-----------|
| SQL_SERVER_NAME | Azure SQL Server Name (e.g. `my-sql-server` if you using `my-sql-server.database.windows.net`) |
| SQL_DATABASE_NAME | Azure SQL Database Name (e.g. `my-sql-server-db`) which has the CDM |

## Synthea-ETL

This directory contains exploratory work for generating and loading synthetic patient data via scripts found here: https://github.com/OHDSI/ETL-Synthea.

### Running R example packages via Dockerfile

- Generate Synthea files via release jar (Synthea v2.7.0)
```sh
# From this /synthea-etl directory
wget https://github.com/synthetichealth/synthea/releases/download/v2.7.0/synthea-with-dependencies.jar

SAMPLE_SIZE=10 # Will generate 10 live patients, possibly extra dead patients as well.

java -jar synthea-with-dependencies.jar -p $SAMPLE_SIZE -c synthea-settings.conf
```

[Other generation seeds and configurations can be specified as well.](https://github.com/synthetichealth/synthea#generate-synthetic-patients)


- OPTIONAL - Download Vocabulary files from [ATHENA](https://athena.ohdsi.org/vocabulary/list)
```sh
# From this /synthea-etl directory
# Downloading default selected vocabulary from Athena and unzipped to: ./vocab_files/
```

This step may be completely removed if we are depending on vocabularies already existing in the target db,


- Build Docker container with R dependencies
```sh
# From this /synthea-etl directory
docker build -t synthea-etl .
```


- Upload to DB via R Script running in Docker Container
```sh
# From this /synthea-etl directory

export SQL_SERVER_NAME='omop-sql-server'
export SQL_DATABASE_NAME='synthea830'

# database schema used for connecting to the CDM.
export CDM_SCHEMA='cdm'
export CDM_VERSION='5.3.1'
export SYNTHEA_SCHEMA='synthea'
export SYNTHEA_VERSION='2.7.0'

# Location of the synthea output CSV files.
export SYNTHEA_PATH='/home/docker/synthea_data/csv/'

# TODO: Remove when no longer needed.
export VOCAB_PATH='/home/docker/vocab_files'
export CREATE_CDM_SCHEMA='true'

# Run with volume mount and env vars as parameters
docker run -t --rm -v "$PWD":/home/docker -w /home/docker \
-e OMOP_USER -e OMOP_PASS -e SQL_SERVER_NAME -e SQL_DATABASE_NAME \
-e CDM_SCHEMA -e CDM_VERSION -e SYNTHEA_SCHEMA -e SYNTHEA_VERSION \
-e SYNTHEA_PATH -e VOCAB_PATH -e CREATE_CDM_SCHEMA synthea-etl Rscript synthea-etl.R
```

### Notes
- [Sql Server DatabaseConnector - prefix schema with database name.](https://forums.ohdsi.org/t/how-to-use-databaseconnector-createconnectiondetails-for-sql-server-to-connect-to-the-right-database/12725)
- [Learnings from using the Synthea data generator for use with ETL-Synthea](https://github.com/OHDSI/ETL-Synthea/issues/45)
- [Fixes required to load Synthea Tables](https://github.com/OHDSI/ETL-Synthea/commit/af15bc1f42097fb08b2291066daf399ed2b68fa1)
