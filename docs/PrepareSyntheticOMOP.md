# How to create a Synthetic OMOP CDM

## Overview

The purpose of this document is to guide you thru the process of creating a synthetic OMOP CDM database.

## Follow these steps

* Install Java Open JDK from bellsoft (Liberica JDK) [Download OpenJDK builds of Liberica JDK, Java 8, 11, 17, 19 | BellSoft Java (bell-sw.com)](https://bell-sw.com/pages/downloads/)

    * Set JAVA_HOME to C:\Program Files\BellSoft\LibericaJDK-17\
    * Add C:\Program Files\BellSoft\LibericaJDK-17\bin\ to PATH 
    * Make sure you've got the following version by running java -version:

    ```
    openjdk version "17.0.6" 2023-01-17 LTS
	OpenJDK Runtime Environment (build 17.0.6+10-LTS)
    OpenJDK 64-Bit Server VM (build 17.0.6+10-LTS, mixed mode, sharing)
    ```


* Download Synthea v3.0.0 https://github.com/synthetichealth/synthea/releases/tag/v3.0.0

* Create config file named `synthea-settings.conf` with the following content:

    ```
    exporter.csv.export = true
    exporter.json.export = false
    exporter.fhir.export = false
    exporter.fhir.transaction_bundle = false
    exporter.hospital.fhir.export = false
    exporter.practitioner.fhir.export = false
    exporter.baseDirectory = ./output
    exporter.encoding = UTF-8
    ```

* Run Synthea from command line:

`java -jar synthea-with-dependencies.jar -p <num of patients> -c synthea-settings.conf`

* Download vocabularies from Athena - [https://athena.ohdsi.org/](https://athena.ohdsi.org/), you'll need to register first, choose "LOINC", "RxNorm" as vocabs version 5.x. When the files are ready you will get an email with a link to download a compressed file which weights about ~850MB

* Create PostgreSQL Database
* Create 4 schemas with correct permissions to your db user (cdm, cdm_results, native and temp)

    ```sql
	CREATE SCHEMA IF NOT EXISTS cdm
	    AUTHORIZATION postgres_admin;
	GRANT USAGE ON SCHEMA cdm TO ohdsi_admin;
	GRANT USAGE ON SCHEMA cdm TO ohdsi_app;
	GRANT ALL ON SCHEMA cdm TO postgres_admin;


	CREATE SCHEMA IF NOT EXISTS native
	    AUTHORIZATION postgres_admin;
	GRANT ALL ON SCHEMA native TO postgres_admin;
	
	CREATE SCHEMA IF NOT EXISTS cdm_results
	    AUTHORIZATION postgres_admin;
	GRANT USAGE ON SCHEMA cdm_results TO ohdsi_admin;
	GRANT USAGE ON SCHEMA cdm_results TO ohdsi_app;
	GRANT ALL ON SCHEMA cdm_results TO postgres_admin;


    CREATE SCHEMA IF NOT EXISTS temp
	    AUTHORIZATION postgres_admin;
	GRANT ALL ON SCHEMA temp TO postgres_admin;
    ```

* Install [RStudio and Hades packages](https://ohdsi.github.io/Hades/rSetup.html) or run [Broadsea](https://github.com/OHDSI/Broadsea) with docker-compose and enable basic authentication.
* Install ETL-Synthea and Achilles OHDSI R packages by running the following script inside RStudio

    ```r
    install.packages("devtools")
    install.packages("remotes")
    ```
* Restart R session
* Download PostgreSQL jdbc driver

    ```r
    DatabaseConnector::downloadJdbcDrivers(
        'postgresql',
        pathToDriver = 'jdbcdrivers',
        method = "auto")
    ```
* Configure and run the following script

    ```r
    connectionDetails <- DatabaseConnector::createConnectionDetails(
        dbms            = "postgresql",
        server          = "your_postresql_server/db_name",
        user            = "postgres",
        password        = "mypass",
        port            = 5432,  
        pathToDriver    = "jdbcdrivers"
    )

    cdmVersion        <- "5.4"
    cdmDatabaseSchema <- "cdm"
    syntheaSchema     <- "native"
    syntheaFileLoc    <- "synthea/10person"
    vocabFileLoc      <- "/vocab/vocabulary"
    syntheaVersion    <- "3.0.0"

    # Create CDM tables
    ETLSyntheaBuilder::CreateCDMTables(connectionDetails,cdmDatabaseSchema,cdmVersion)
    # Create synthea tables
    ETLSyntheaBuilder::CreateSyntheaTables(connectionDetails,syntheaSchema, syntheaVersion)
    # Populate synthea tables
    ETLSyntheaBuilder::LoadSyntheaTables(connectionDetails,syntheaSchema,syntheaFileLoc)
    # Populate vocabulary tables
    ETLSyntheaBuilder::LoadVocabFromCsv(connectionDetails,cdmDatabaseSchema,vocabFileLoc)
    # Populate event tables
    ETLSyntheaBuilder::LoadEventTables(connectionDetails,cdmDatabaseSchema,syntheaSchema,cdmVersion,syntheaVersion)

    library(Achilles)

    achillesResults <- Achilles::achilles(
        connectionDetails       = connectionDetails, 
        cdmDatabaseSchema       = "cdm", 
        resultsDatabaseSchema   = "cdm_results",
        vocabDatabaseSchema     = "cdm",         
        scratchDatabaseSchema   = "temp",
        numThreads              = 1,
        cdmVersion              = "5.4", 
        outputFolder            = "output",
        optimizeAtlasCache      = TRUE)
    ```

* Generate DDL scripts using OHDSI WebAPI website by posting to:

```
http://<server:port>/WebAPI/ddl/results?dialect=postresql&schema=cdm_results&vocabSchema=cdm&tempSchema=temp&initConceptHierarchy=true
```

for more info see [https://github.com/OHDSI/WebAPI/wiki/CDM-Configuration#results-schema-setup](https://github.com/OHDSI/WebAPI/wiki/CDM-Configuration#results-schema-setup). 

* Save and run the generated SQL statements using [pgAdmin](https://www.pgadmin.org/).

* Add you new OMOP CDM Source to Atlas.

