# Troubleshooting Achilles & ETL-Synthea Setup

Here's some notes for troubleshooting around Achilles & ETL-Synthea.

Be sure you work through the steps outlined in the [Setup Achilles & ETL-Synthea Notes](/docs/setup/setup_atlas_webapi.md).

1. Confirm [Build Agent Access to ACR](#confirm-build-agent-access-to-acr)
    * Confirm [broadsea-methods image exists in ACR](#confirm-broadsea-methods-image-exists-in-acr)
2. Confirm [Build Agent Access to Azure SQL](#confirm-build-agent-access-to-azure-sql)
    * Confirm [Build Agent ETL-Synthea Access to Azure SQL](#confirm-build-agent-etl-synthea-access-to-azure-sql)
    * Confirm [Build Agent Achilles Access to Azure SQL](#confirm-build-agent-achilles-access-to-azure-sql)
3. You can also review other [Debugging Notes](#debugging-notes)
    * Verify [User Roles in Azure SQL](#verify-user-roles-in-azure-sql)
    * Notes around [Known Errors](#known-errors)
      * [Unsupported CDM specified](#unsupported-cdm-specified)
      * The query processor [ran out of internal resources and could not produce a query plan](#the-query-processor-ran-out-of-internal-resources-and-could-not-produce-a-query-plan)
      * Arithmetic overflow [error converting numeric to data type varchar](#arithmetic-overflow-error-converting-numeric-to-data-type-varchar)
    * Modifying the [Container Build to use a different version](#modifying-the-container-build-to-use-a-different-version)

## Confirm Build Agent Access to ACR

The following settings should be covered through TF and the [administrative steps](/infra/README.md/#administrative-steps).

1. Connect to ACR in the Azure Portal

2. Confirm SP service connection is added to ACR with at least `ACRPush`.

  ![Azure Container Registry ACRPush for SP Service Connection](/docs/media/acr_sp_service_connection_mi.png)
  > In this case the Service Connection has `Contributor` which should be sufficient access

### Confirm broadsea-methods image exists in ACR

This assumes that the [Build Agent has access to ACR](#confirm-build-agent-access-to-acr) and that you are able to run the [Broadsea Build Pipeline](/pipelines/README.md#broadsea-build-pipeline) using your branch and include the option **build and publish broadsea-methods (Achilles / ETL-Synthea)** to push a new image to ACR.

1. Connect to ACR in the Azure Portal

2. Check the `broadsea-methods` image exists, and has an image with the tag `latest`
  ![image.png](/docs/media/confirm_acr_broadsea_methods_1.png)

3. You can re-run the [Broadsea Build Pipeline](/pipelines/README.md#broadsea-build-pipeline) using your branch and include the option **build and publish broadsea-methods (Achilles / ETL-Synthea)** to push a new image to ACR

![Build and push Achilles / ETL-Synthea using the pipeline](/docs/media/broadsea_build_pipeline_achilles_etl_synthea.png)
  > Note that you will want to run the [Broadsea Build Pipeline](/pipelines/README.md#broadsea-build-pipeline) using your branch and include the option **build and publish broadsea-methods (Achilles / ETL-Synthea)** to ensure an image is in ACR **before** running the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) using your branch.

## Confirm Build Agent Access to Azure SQL

The following settings should be covered through the [administrative steps](/infra/README.md/#administrative-steps) and [vocabulary setup](/docs/setup/setup_vocabulary.md/#steps).

1. Connect to ACR in the [Azure Portal](https://portal.azure.com/)

2. Confirm Build Agent VMSS has Managed Identity enabled
![Azure VMSS Managed Identity enabled](/docs/media/azure_vmss_mi.png)

3. Confirm with your administrator that the Azure SQL Managed Identity has [Directory Reader](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial#assign-directory-readers-permission-to-the-sql-logical-server-identity) enabled as part of the [administrative steps](/infra/README.md/#administrative-steps), which should also include granting access for your [Azure VMSS Managed Identity](/infra/terraform/omop/README.md/#step-4-run-post-terraform-deployment-steps) to Azure SQL.

4. Confirm Build Agent VMSS MI is added as a user in Azure SQL in your environment based on the [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql), which should be included as part of your [vocabulary setup](/docs/setup/setup_vocabulary.md/#steps).

> You can verify the [MI is added as a user in Azure SQL](#verify-user-roles-in-azure-sql) using a query.

### Confirm Build Agent ETL-Synthea Access to Azure SQL

The following settings should be covered through the [administrative steps](/infra/README.md/#administrative-steps) and [vocabulary setup](/docs/setup/setup_vocabulary.md/#steps).

1. Confirm [ETL-Synthea connection string](/apps/broadsea-methods/synthea-etl.R) uses Authentication Mode [ActiveDirectoryMsi](https://docs.microsoft.com/en-us/sql/connect/jdbc/connecting-using-azure-active-directory-authentication?view=sql-server-ver15).

```R
connection_string <- stringr::str_interp("jdbc:sqlserver://${sql_server_name}.database.windows.net:1433;database=${sql_database_name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;Authentication=ActiveDirectoryMsi;")
```

2. Confirm your [variable groups](/docs/update_your_variables.md) reflect your environment settings., see [Setup Achilles & ETL-Synthea](/docs/setup/setup_achilles_synthea.md/#step-2-run-the-broadsea-methods-pipeline) for more details.

3. Rerun the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) using your branch

### Confirm Build Agent Achilles Access to Azure SQL

The following settings should be covered through TF.

1. Confirm [Achilles connection string](/apps/broadsea-methods/achilles.R) uses Authentication Mode [ActiveDirectoryMsi](https://docs.microsoft.com/en-us/sql/connect/jdbc/connecting-using-azure-active-directory-authentication?view=sql-server-ver15).

```R
connectionString <- stringr::str_interp("jdbc:sqlserver://${sql_server_name}.database.windows.net:1433;database=${sql_database_name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;Authentication=ActiveDirectoryMsi;")
```

2. Confirm your [variable groups](/docs/update_your_variablegroups.md) reflect your environment settings, see [Setup Achilles & ETL-Synthea](/docs/setup/setup_achilles_synthea.md/#step-2-run-the-broadsea-methods-pipeline) for more details.

3. Rerun the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) using your branch.

## Debugging Notes

First check the [repo readme](/apps/broadsea-methods/README.md) for additional context on working with Achilles including the Achilles [R script details](/apps/broadsea-methods/README.md/#script-notes).

### Verify User Roles in Azure SQL

You can verify if the roles are assigned using the following query in Azure SQL:

```sql
select name as username,
       create_date,
       modify_date,
       type_desc as type,
       authentication_type_desc as authentication_type
from sys.database_principals
where type not in ('A', 'G', 'R', 'X')
      and sid is not null
      and name != 'guest'
order by username;
```

### Known Errors

Here's some notes on known errors.

#### Unsupported CDM specified

1. You may see an error in the [Azure DevOps Pipeline logs](https://docs.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops#view-and-download-logs) with something like this:

```bash
[1] "Performing Synthea ETL"
Caught an error!
<simpleError in ETLSyntheaBuilder::LoadEventTables(connectionDetails = cd, cdmSchema = cdm_schema_full,     syntheaSchema = synthea_schema_full, cdmVersion = cdm_version,     syntheaVersion = synthea_version): Unsupported CDM specified. Supported CDM versions are "5.3" and "5.4">
All done, quitting.
```

2. If you are seeing this error, you can either use a [different container build for ETL-Synthea](#modifying-the-container-build-to-use-a-different-version), or you can ensure that the environment variable for [CDM_VERSION](/docs/update_your_variables.md/#cdmversion) is passed in through your [broadsea release pipeline](/pipelines/broadsea_release_pipeline.yaml) as a simplified version (e.g. `5.3` instead of `5.3.1`).  For this project, the second option is included, although you may run into additional scenarios where you need to use a different container build for ETL-Synthea.

In the pipeline you can simplify your `$CDM_VERSION` (assuming it's set as `5.3.1` through your [variable groups](/docs/update_your_variables.md#cdmversion) using `bash`:

```bash
# Simplify the cdmVersion (e.g it may come in as 5.3.1, but Synthea expects just 5.3)
# see https://github.com/OHDSI/ETL-Synthea/blob/master/R/CreateVocabMapTables.r#L25
simpleCDMVersion="$(echo $CDM_VERSION | cut -d '.' -f1).$(echo $CDM_VERSION | cut -d '.' -f2)"
```

### The query processor ran out of internal resources and could not produce a query plan

There's a couple of approaches for this known issue:

1. Scale up Azure SQL
<a id='known_issue_query_plan_approach_2'></a>
2. Use a lower [compatibility level](https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=sql-server-ver15) for Azure SQL

The current workaround approach is to use [approach #2](#known_issue_query_plan_approach_2), with the steps included as part of the [achilles script](/apps/broadsea-methods/README.md#script-notes), and the scenario is recapped below:

1. You may see an error in the Azure DevOps Pipeline for the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) logs:

```console
Analysis 2004 -- ERROR Error in FALSE: Error executing SQL:
com.microsoft.sqlserver.jdbc.SQLServerException: The query processor ran out of internal resources and could not produce a query plan. This is a rare event and only expected for extremely complex queries or queries that reference a very large number of tables or partitions. Please simplify the query. If you believe you have received this message in error, contact Customer Support Services for more information.
```

2. As a workaround, you can adjust the [Compatibility Level](https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=sql-server-ver15) for Azure SQL to a lower level.

```sql
ALTER DATABASE [mydatabase] SET compatibility_level = 110;
```

Achilles generates a complex query with multiple subqueries, and in combination with the size of an incoming data set for characterization, can cause Azure SQL to run into this error.  One workaround is to set the Compatibility Level to 110 for Azure SQL.  In the above example, Azure SQL will take the default compatibility level associated with SQL Server 2012 so Azure SQL can use an [older query optimizer](https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=sql-server-ver15#differences-between-lower-compatibility-levels-and-level-120) to produce the query plan.

> If the compatibility_level is set to a lower level than the default for Azure SQL, you will run into issues if you are relying on the default compatibility level for Azure SQL (e.g. you are calling SQL functions which are not available in earlier versions of SQL Server).

3. Once the work is completed (e.g. Achilles can run successfully in the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline), you will want to restore Azure SQL back to the prior default compatibility level.

```sql
ALTER DATABASE [mydatabase] SET compatibility_level = 150;
```

#### Arithmetic overflow error converting numeric to data type varchar

1. You may see an error in the Azure DevOps Pipeline for the [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) logs:

```console
Analysis 2004 -- ERROR Error in FALSE: Error executing SQL:
com.microsoft.sqlserver.jdbc.SQLServerException: Arithmetic overflow error converting numeric to data type varchar.
```

2. In order to address this error, make sure you [rebuild Achilles](/apps/broadsea-methods/README.md#step-2-build-achilles-synthea-etl-image) to pick up the [Achilles committed](https://github.com/OHDSI/Achilles/commit/e21c7e16cb4cbd653e3e572db86b536cdda86aca) fix.

### Modifying the Container Build to use a different version

You may find that the latest versions of the repository are causing conflicts.  Until the latest versions are stabilized, you can choose to build a specific version of your [broadsea methods container](/apps/broadsea-methods/README.md/#broadsea-methods).

The following is an example for working with a tagged version for ETL-Synthea to pull in desired behavior:

1. You can update the [Broadsea Methods Dockerfile](/apps/broadsea-methods/Dockerfile) to use a [tagged version of ETL-Synthea](https://github.com/OHDSI/ETL-Synthea/pull/100):

```diff
# Error seen with original: Unsupported CDM specified. Supported CDM versions are "5.3" and "5.4"
RUN installGithub.r \
	OHDSI/Achilles \
+	OHDSI/ETL-Synthea@a58bfd32715a05f8031790c98d35888e02af17b5 \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds
```

Instead of the latest version of [ETL-Synthea](https://github.com/OHDSI/ETL-Synthea):

```diff
## Install OHDSI R packages
RUN installGithub.r \
	OHDSI/Achilles \
-	OHDSI/ETL-Synthea \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds
```
