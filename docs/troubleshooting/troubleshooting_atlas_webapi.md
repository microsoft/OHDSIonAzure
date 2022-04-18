# Troubleshooting Atlas and WebAPI Setup

Here's some notes for troubleshooting around Atlas and WebAPI.  Be sure to work through the [setup Atlas and WebApi notes](/docs/setup/setup_atlas_webapi.md) too.

1. Connecting Azure [App Service To Azure Container Registry](#connecting-azure-app-service-to-azure-container-registry)
2. Connecting Azure [App Service to Azure SQL](#connecting-azure-app-service-to-azure-sql)
3. Connecting the [Build Agent to Azure SQL](#connecting-the-build-agent-to-azure-sql)
4. Connecting the [Build Agent to Azure App Service](#connecting-the-build-agent-to-azure-app-service)
5. You can also review other [debugging notes](#debugging-notes)
    1. Manually [Check the Azure App Service is up](#manually-check-the-azure-app-service-is-up)
    2. Manually [Check logs from Azure App Service](#manually-check-logs-from-azure-app-service)
    3. Manually check [container logs in Azure App Service](#manually-check-container-logs-in-azure-app-service)
    4. Verify [User Roles in Azure SQL](#verify-user-roles-in-azure-sql)
    5. Check your [Data with a query](#check-data-with-a-query)
    6. Confirm [Web API Schema Exists](#confirm-web-api-schema-exists)
        * Manually [Setup Second WebAPI schema for object comparison](#manually-setup-second-webapi-schema-for-object-comparison)


## Connecting Azure App Service To Azure Container Registry

1. Terraform should incorporate access for the Azure App Service MI to access Azure Container registry.  You can confirm these changes in the Azure Portal after having run Terraform for your [environment](/pipelines/README.md/#environment-pipeline).
    * Confirm Azure App Service has Managed Identity enabled
    ![Azure App Service has MI](/docs/media/azure_app_service_acr_access_1.png)
    * Confirm the Azure App Service Managed Identity has `AcrPull` access to Azure Container Registry
    ![Azure App Service MI has access to Azure Container Registry](/docs/media/azure_app_service_acr_access_2.png)

2. You should also confirm that the ACR has your image built and pushed to it with the appropriate tag.  Confirm your [variable groups](/docs/update_your_variables.md) reflect your environment ACR before running the [Broadsea Build pipeline](/pipelines/README.md/#broadsea-build-pipeline) and [Broadsea Release pipeline](/pipelines/README.md/#broadsea-release-pipeline)

![Confirm ACR Has Broadsea Webtools](/docs/media/confirm_acr_broadsea_webtools_1.png)

3. You can check the Azure App Service Settings to see if it's pointing to the Azure Container Registry and using the managed identity.

![Confirm Azure App Service MI connects to ACR for Broadsea Webtools](/docs/media/confirm_acr_broadsea_webtools_2.png)

If you need to set the Docker settings, you can use the [Broadea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) using your branch.

You can also set the site settings for the App Service within [Terraform](/infra/terraform/omop/main.tf) and then re-run the [TF environment pipeline](/pipelines/README.md/#environment-pipeline) against your branch:

```json
  site_config {
    app_command_line = ""
    # This will be called from the other pipeline.  You can uncomment the `linux_fx_version` if you're trying to isolate standing up the App Service without using the application pipeline.
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.name}.azurecr.io/${var.broadsea_image}:${var.broadsea_image_tag}" # could be handled through pipeline instead
    always_on        = true
    acr_use_managed_identity_credentials = true # Connect ACR with MI
  }
```

## Connecting Azure App Service to Azure SQL

1. Confirm that the Azure App Service MI is added to Azure SQL, which should be handled through the [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql)
    * Validate that the Azure App Service MI has [Directory Reader](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role) enabled with **your administrator**, and that the administrator is able to grant the Azure App Service MI login access to Azure SQL.  An example is included as part of the [Post Terraform Deployment steps](/infra/terraform/omop/README.md/#step-4-run-post-terraform-deployment-steps).

Within Azure SQL, you can the following query for your Azure App Service:

```sql
CREATE USER [my-app-service-name] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [my-app-service-name]
ALTER ROLE db_datawriter ADD MEMBER [my-app-service-name]
ALTER ROLE db_owner ADD MEMBER [my-app-service-name]
```

You can verify the [MI is added as a user in Azure SQL](#verify-user-roles-in-azure-sql) using a query.

3. Check the Azure App Service Connection String includes `ActiveDirectoryMsi`
![Azure App Service Connection String](/docs/media/azure_app_service_connection_string.png)

```json
[
  {
    "name": "ConnectionStrings:Default",
    "value": "jdbc:sqlserver://my-sql-server.database.windows.net:1433;database=mydb;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;Authentication=ActiveDirectoryMsi",
    "type": "SQLServer",
    "slotSetting": false
  }
]
```

4. Check the Azure SQL DB to see if there's any objects populated in the `[webapi]` schema:
![Azure App Service can connect to Azure SQL for WebApi](/docs/media/azure_app_service_azure_sql_webapi.png)

## Connecting the Build Agent to Azure SQL

1. Check that the Azure VMSS build agent has the system assigned MI setup:
![Confirm Azure VMSS MI Enabled](/docs/media/azure_vmss_mi.png).  This should be handled through the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md/#setup-azure-ad-group) by your administrator.

2. Confirm that the Azure VMSS MI is added to Azure SQL, which should be handled through the [Post TF Deploy script](/sql/scripts/Post_TF_Deploy.sql)
    * Validate that the Azure VMSS MI has [Directory Reader](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role) enabled with **your administrator**, and that the administrator is able to grant the Azure VMSS MI login access to Azure SQL.  An example is included as part of the [Post Terraform Deployment Steps](/infra/terraform/omop/README.md#step-4-run-post-terraform-deployment-steps).

You can use the following query to create to add your Azure VMSS MI to Azure SQL:

```sql
CREATE USER [my-build-agent-name] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [my-build-agent-name]
ALTER ROLE db_datawriter ADD MEMBER [my-build-agent-name]
ALTER ROLE db_owner ADD MEMBER [my-build-agent-name]
```

You can verify the [MI is added as a user in Azure SQL](#verify-user-roles-in-azure-sql) using a query.

## Connecting the Build Agent to Azure App Service

The Azure App service should have open networking through TF.  You can confirm with your administrator there aren't network restrictions preventing access for the Azure VMSS to communicate with the Azure App service in your environment.

## Debugging Notes

### Manually Check the Azure App Service is up

1. If WebAPI and Atlas are set up correctly, you should see the following by checking https://my-app-service.azurewebsites.net/atlas:
![Confirm Atlas](/docs/media/confirm_acr_broadsea_webtools_1.png)

2. You can also check the WebAPI refresh by checking https://my-app-service.azurewebsites.net/WebAPI/source/sources:
![Confirm WebApi](/docs/media/confirm_webapi_1.png)

#### Web API responds with a 404

You may run into 404's when trying to connect to https://my-app-service.azurewebsites.net/WebAPI/source/sources.

1. You can start with checking the [container logs in Azure App Service](#manually-check-container-logs-in-azure-app-service) to see if there's any issues with the Azure App Service container connecting to Azure SQL.
2. Confirm connectivity for [App Service to Azure SQL](#connecting-azure-app-service-to-azure-sql)
3. Confirm connectivity for the [Build Agent to Azure SQL](#connecting-the-build-agent-to-azure-sql)
4. Restart the App Service in the portal
![Restart Azure App Service](/docs/media/azure_app_service_restart.png)
5. Run the [Broadsea Release Pipeline](/pipelines/README.md#broadsea-release-pipeline) on your feature branch to get Azure App Service to pull the [Broadsea Webtools](/apps/broadsea-webtools/README.md) image from ACR and refresh WebAPI.  Make sure you have updated your [variable groups](/docs/update_your_variables.md) to reflect your environment.

### Manually Check logs from Azure App Service

1. You can enable Application Logging for the Azure App Service
![Azure App Service logs](/docs/media/azure_app_service_logs_1.png)

2. You can also check the log stream to make sure the container has started
![Azure App service Log Stream](/docs/media/azure_app_service_logs_2.png)

### Manually check container logs in Azure App Service

Assuming that the Azure App Service can [pull an image from ACR](#connecting-azure-app-service-to-azure-container-registry), you can then try to connect to the Azure App Service Container using `SSH`.

1. Navigate to https://my-app-service.scm.azurewebsites.net/webssh/host

2. Once you have connected to the container using SSH, you can also validate that the container has started correctly by checking the container logs:

```bash
tail -f -n 500 /var/log/supervisor/deploy-script-stdout*
```
### Application Logs in Azure Monitoring

## TODO: Verify this is available

All of the application logging in the App Service container can be found in Applications Insights. More information on how to do this can be found [here](https://docs.microsoft.com/en-us/azure/azure-monitor/app/azure-web-apps).

### Verify User Roles in Azure SQL

You can verify if the roles are assigned using the following query in Azure SQL. There should be a role for the app service and build agent MI:

```sql
SELECT NAME AS username,
       create_date,
       modify_date,
       TYPE_DESC AS type,
       authentication_type_desc AS authentication_type
FROM sys.database_principals
WHERE type NOT IN ('A', 'G', 'R', 'X')
      AND SID IS NOT NULL
      AND NAME != 'guest'
ORDER BY username;
```

#### Check Data With a Query

You can check for person data in Azure SQL using the following queries:

```sql
SELECT TOP 10 * FROM person
```

### Confirm Web API Schema Exists

You may notice connection errors between Atlas and WebAPI.  In this case, you can verify if Web API objects exist using some queries as well in Azure SQL.

1. Verify Views exist:

```sql
SELECT v.name
FROM sys.views v
WHERE OBJECT_SCHEMA_NAME(v.object_id) = 'webapi'
```

2. Verify Tables exist:

```sql
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'webapi' and TABLE_TYPE = 'BASE TABLE'
```

3. Verify Sequences exist:

```sql
SELECT s.NAME
FROM sys.sequences s
WHERE OBJECT_SCHEMA_NAME(s.object_id) = 'webapi'
```

4. Confirm source and source_daimontables are populated, which should be covered through the [Web Api Refresh script](/sql/scripts/Web_Api_Refresh.sql):

```sql
SELECT * FROM webapi.source
SELECT * FROM webapi.source_daimon
```

#### Manually Setup Second WebAPI schema for object comparison

If you are running into issues with the WebApi schema, you can validate that the WebApi can be setup on a second schema before remediating your original schema.

##### Step 1. Setup new webapi schema in Broadsea App Service

You can also update your Broadsea App Service Configuration to point to a test schema (e.g. `webapi2`) to confirm the webapi SQL objects are setup correctly.

1. Update your Broadsea App Service Configuration

| Setting Name | Sample Value | 
|--|--|
| datasource.ohdis.schema | `webapi2` |
| flyway.placeholders.ohdsiSchema | `webapi2` |
| flyway.schemas | `webapi2` |
| spring.batch.repository.tableprefix | `my-sql-db-cdm-name.webapi2.BATCH_` |
| spring.jpa.properties.hibernate.default_schema | `webapi2` |

![Azure App Service WebAPI different schema](/docs/media/azure_app_service_webapi_different_schema.png)

2. Once the values are saved, click the Save button.

3. Restart your App Service.
  > This step should allow WebAPI to create objects in the new schema

![Restart App Service](/docs/media/azure_app_service_restart.png)

##### Step 2. Compare SQL Objects Between 2 schemas

You can now compare the objects that are created with the original `webapi` schema and `webapi2` schema in Azure SQL.

1. Check Views
```sql
SELECT OBJECT_SCHEMA_NAME(v.object_id) + '.' + v.name AS [Name]
FROM sys.views v
WHERE OBJECT_SCHEMA_NAME(v.object_id) IN ('webapi', 'webapi2')
```

2. Check Tables
```sql
SELECT TABLE_SCHEMA + '.' + TABLE_NAME AS [Name]
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('webapi', 'webapi2') and TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME
```

3. Check Sequences
```sql
SELECT OBJECT_SCHEMA_NAME(s.object_id) + '.' + s.Name
FROM sys.sequences s
WHERE OBJECT_SCHEMA_NAME(s.object_id) in ('webapi', 'webapi2')
ORDER BY s.name
```

##### Step 3. Drop SQL Objects in new schema
You can use the following queries to run in Azure SQL.

1. Drop Tables - This will generate a list of Drop Table SQL statements, which you can check before copying and pasting the queries to actually run:

```sql
DECLARE @schema_name NVARCHAR(255)
SET @schema_name = 'webapi2'
DECLARE @SqlStatement NVARCHAR(MAX)
SELECT @SqlStatement = 
    COALESCE(@SqlStatement, N'') + N'DROP TABLE [' + @schema_name + '].' + QUOTENAME(TABLE_NAME) + N';' + CHAR(13)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = @schema_name and TABLE_TYPE = 'BASE TABLE'
PRINT @SqlStatement
```

2. Drop Sequences - This will generate a list of Drop Sequence SQL statements, which you can check before copying and pasting the queries to run them:

```sql
DECLARE @schema_name NVARCHAR(255)
SET @schema_name = 'webapi2'
DECLARE @SqlStatement NVARCHAR(MAX)
SELECT @SqlStatement = 
    COALESCE(@SqlStatement, N'') + N'DROP SEQUENCE [' + @schema_name + '].' + QUOTENAME(NAME) + N';' + CHAR(13)
FROM sys.sequences s
WHERE OBJECT_SCHEMA_NAME(s.object_id) = @schema_name
PRINT @SqlStatement
```

3. Drop Views - This will generate a list of Drop View SQL statements, which you can check before copying and pasting the queries to run them:

```sql
DECLARE @schema_name NVARCHAR(255)
SET @schema_name = 'webapi2'
DECLARE @SqlStatement NVARCHAR(MAX)
SELECT @SqlStatement = 
    COALESCE(@SqlStatement, N'') + N'DROP VIEW [' + @schema_name + '].' + QUOTENAME(NAME) + N';' + CHAR(13)
FROM sys.views v
WHERE OBJECT_SCHEMA_NAME(v.object_id) = @schema_name
PRINT @SqlStatement
```

4. Drop Schema
> Once the dependent objects from the new schema are dropped, you can drop the new schema:

```sql
DROP SCHEMA webapi2
```