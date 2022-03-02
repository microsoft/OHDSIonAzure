-- This is a one time script that will setup Azure SQL MI Access

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

/* TODO: Could add service connection SP */

CREATE USER [$(BroadseaAppServiceName)] FROM EXTERNAL PROVIDER
ALTER ROLE db_datareader ADD MEMBER [$(BroadseaAppServiceName)]
ALTER ROLE db_datawriter ADD MEMBER [$(BroadseaAppServiceName)]
ALTER ROLE db_owner ADD MEMBER [$(BroadseaAppServiceName)]

/* Get the ADO Build Agent VMSS Name from the ./scripts/ado_bootstrap.sh
The ADO builder should have MI enabled */
CREATE USER [$(ADOVMSSBuildAgentPoolName)] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [$(ADOVMSSBuildAgentPoolName)]
ALTER ROLE db_datawriter ADD MEMBER [$(ADOVMSSBuildAgentPoolName)]
ALTER ROLE db_owner ADD MEMBER [$(ADOVMSSBuildAgentPoolName)]

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