-- This is a one time script that will setup Azure SQL Access for your Managed Identities
BEGIN TRY
    CREATE DATABASE SCOPED CREDENTIAL DSCAzureSqlServerMI
    WITH IDENTITY = 'Managed Identity'

    CREATE EXTERNAL DATA SOURCE DSVocabularyBlobStorage
    WITH ( TYPE = BLOB_STORAGE,
        LOCATION = 'https://$(StorageAccountName).blob.core.windows.net',
        CREDENTIAL = DSCAzureSqlServerMI)

    SELECT
        eds.[name],
        eds.[location],
        eds.[type_desc]
    FROM sys.external_data_sources eds
    WHERE eds.name = 'DSVocabularyBlobStorage'
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS [ERROR_MESSAGE],
           ERROR_LINE() AS [ERROR_LINE],
           ERROR_NUMBER() AS [ERROR_NUMBER],
           ERROR_SEVERITY() AS [ERROR_SEVERITY],
           ERROR_STATE() AS [ERROR_STATE]
END CATCH

/* Add in Azure App Service MI User */
BEGIN TRY
    /* TODO: Could add service connection SP */
    -- Grant access to your Azure App Service MI in Azure SQL
    CREATE USER [$(BroadseaAppServiceName)] FROM EXTERNAL PROVIDER
    ALTER ROLE db_datareader ADD MEMBER [$(BroadseaAppServiceName)]
    ALTER ROLE db_datawriter ADD MEMBER [$(BroadseaAppServiceName)]
    ALTER ROLE db_owner ADD MEMBER [$(BroadseaAppServiceName)]
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS [ERROR_MESSAGE],
           ERROR_LINE() AS [ERROR_LINE],
           ERROR_NUMBER() AS [ERROR_NUMBER],
           ERROR_SEVERITY() AS [ERROR_SEVERITY],
           ERROR_STATE() AS [ERROR_STATE]
END CATCH

/* Add in Azure VMSS builder MI User */
BEGIN TRY
    /* Get the ADO Build Agent VMSS Name 
    This should come from the Variable Group through /infra/terraform/bootstrap/main.tf
    The ADO builder should have MI enabled */
    -- Grant access to your Azure VMSS MI used for the Agent Pool in Azure SQL
    CREATE USER [$(ADOAgentPoolVMSSName)] FROM EXTERNAL PROVIDER;
    ALTER ROLE db_datareader ADD MEMBER [$(ADOAgentPoolVMSSName)]
    ALTER ROLE db_datawriter ADD MEMBER [$(ADOAgentPoolVMSSName)]
    ALTER ROLE db_owner ADD MEMBER [$(ADOAgentPoolVMSSName)]
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS [ERROR_MESSAGE],
           ERROR_LINE() AS [ERROR_LINE],
           ERROR_NUMBER() AS [ERROR_NUMBER],
           ERROR_SEVERITY() AS [ERROR_SEVERITY],
           ERROR_STATE() AS [ERROR_STATE]
END CATCH

/* Confirm Users are added */
BEGIN TRY
    SELECT NAME AS username,
        create_date,
        modify_date,
        TYPE_DESC AS TYPE,
        authentication_type_desc AS authentication_type
    FROM sys.database_principals
    WHERE TYPE NOT IN ('A', 'G', 'R', 'X')
        AND SID IS NOT NULL
        AND NAME != 'guest'
    ORDER BY username;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS [ERROR_MESSAGE],
           ERROR_LINE() AS [ERROR_LINE],
           ERROR_NUMBER() AS [ERROR_NUMBER],
           ERROR_SEVERITY() AS [ERROR_SEVERITY],
           ERROR_STATE() AS [ERROR_STATE]
END CATCH