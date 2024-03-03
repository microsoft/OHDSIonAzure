param location string = resourceGroup().location
param suffix string

@description('The SQL Logical Server name.')
param sqlServerName string = 'sql${suffix}'

@description('The administrator username of the SQL Server.')
param sqlAdminLogin string = 'sqladmin'

@description('The administrator password of the SQL Server.')
@secure()
param sqlAdminPassword string

@description('The name of the Database.')
param databaseName string

@description('Enable/Disable Transparent Data Encryption')
@allowed([
  'Enabled'
  'Disabled'
])
param transparentDataEncryption string = 'Enabled'

@description('DW Performance level expressed in DTU (i.e. 900 DTU = DW100c)')
@minValue(900)
@maxValue(54000)
param capacity int = 900

@description('The SQL Database collation.')
param databaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Enables local access for debugging.')
param localDebug bool = false

@description('The name of the keyvault')
param keyVaultName string

@description('The URL of the OHDSI WebAPI')
param ohdsiWebapiUrl string

var OMOPCDMSchemaName = 'cdm'
var OMOPResultsSchemaName = 'cdm_results'
var OMOPTempSchemaName = 'temp'

var OMOPCDMJDBCConnectionStringSecretName = '${databaseName}-cdm-jdbc-connection-string'
var OMOPCDMJDBCConnectionString = 'jdbc:sqlserver://${sqlServer.properties.fullyQualifiedDomainName}:1433;database=${databaseName};user=${sqlAdminLogin}@${sqlServerName};password=${sqlAdminPassword};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;'


resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: 'DataWarehouse'
    tier: 'DataWarehouse'
    capacity: capacity
  }
  properties: {
    collation: databaseCollation
    catalogCollation: databaseCollation
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Geo'
    isLedgerOn: false
  }
}

resource encryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2023-05-01-preview' = {
  parent: sqlServerDatabase
  name: 'current'
  properties: {
    state: transparentDataEncryption
  }
}

resource allowAccessToAzureServices 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  name: 'AllowAllAzureIps'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource allowAccessToAll 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = if (localDebug) {
  name: 'AllowAllIps'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}


@description('The URL of the container where the CDM data is stored')
param cdmContainerUrl string

@secure()
@description('The SAS token to access the CDM data')
param cdmSasToken string


resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'deployment-omop-cdm-synapse'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.48.0'
    timeout: 'PT60M'
    forceUpdateTag: '2'
    environmentVariables: [
      {
        name: 'SQLCMDSERVER'
        value: sqlServer.properties.fullyQualifiedDomainName
      }
      {
        name: 'SQLCMDDBNAME'
        value: sqlServerDatabase.name
      }
      {
        name: 'SQLCMDUSER'
        secureValue: sqlAdminLogin
      }
      {
        name: 'SQLCMDPASSWORD'
        secureValue: sqlAdminPassword
      }
      {
        name: 'OMOP_CDM_CONTAINER_URL'
        value: cdmContainerUrl
      }
      {
        name: 'OMOP_CDM_SAS_TOKEN'
        value: cdmSasToken
      }
      {
        name: 'OMOP_CDM_SCHEMA_NAME'
        value: OMOPCDMSchemaName
      }
      {
        name: 'OMOP_RESULTS_SCHEMA_NAME'
        value: OMOPResultsSchemaName
      }
      {
        name: 'OMOP_TEMP_SCHEMA_NAME'
        value: OMOPTempSchemaName
      }
      {
        name: 'OHDSI_WEBAPI_URL'
        value: ohdsiWebapiUrl
      }
      {
        name: 'SQL_create_omop_schemas'
        value: loadTextContent('sql/create_omop_schemas_synapse.sql')
      }
      {
        name: 'SQL_create_achilles_tables'
        value: loadTextContent('sql/create_achilles_tables_synapse.sql')
      }
    ]
    scriptContent: loadTextContent('scripts/create_omop_cdm_synapse.sh')
    supportingScriptUris: [
      'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/synapse/OMOPCDM_synapse_5.4_ddl.sql'
      // 'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_constraints.sql'
      // 'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_primary_keys.sql'
      // 'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_indices.sql'
    ]
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'PT1H'
    containerSettings: {
      containerGroupName: 'deployment-omop-cdm-synapse'
    }
  }
}

// Get the keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource dbAdminUser 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: '${databaseName}-admin-user'
  parent: keyVault
  properties: {
    value: sqlAdminLogin
  }
}

resource dbAdminPassword 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: '${databaseName}-admin-password'
  parent: keyVault
  properties: {
    value: sqlAdminPassword
  }
}

// Store the OMOP CDM JDBC connection string in keyvault
resource omopCdmConnectionString 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: OMOPCDMJDBCConnectionStringSecretName
  parent: keyVault
  properties: {
    value: OMOPCDMJDBCConnectionString
  }
}

output OmopCdmJdbcConnectionString string = OMOPCDMJDBCConnectionString
output OmopCdmUser string = sqlAdminLogin
