targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of webapi CDM database')
param postgresAtlasDatabaseName string

@description('The name of the postgres server')
param postgresServerName string

@description('The URL of the container where the CDM data is stored')
param cdmContainerUrl string

@secure()
@description('The SAS token to access the CDM data')
param cdmSasToken string

@description('The name of the OMOP CDM database')
param postgresOMOPCDMDatabaseName string

@secure()
@description('Admin password for the postgres server')
param postgresAdminPassword string

@secure()
@description('Admin password for the webapi database')
param postgresWebapiAdminPassword string

@secure()
@description('Password for the cdm user')
param postgresOMOPCDMPassword string

@description('The name of the keyvault')
param keyVaultName string

@description('The URL of the OHDSI WebAPI')
param ohdsiWebapiUrl string

var postgresOMOPCDMSchemaName = 'cdm'
var postgresOMOPResultsSchemaName = 'cdm_results'
var postgresOMOPTempSchemaName = 'temp'
var postgresOMOPCDMRole = 'cdm_reader'
var postgresOMOPCDMUsername = 'cdm_user'
var postgresOMOPCDMUserSecretName = '${postgresOMOPCDMDatabaseName}-cdm-user-password'
var postgresOMOPCDMJDBCConnectionStringSecretName = '${postgresOMOPCDMDatabaseName}-cdm-jdbc-connection-string'
var postgresWebAPISchemaName = 'webapi'
var postgresWebapiAdminUsername = 'ohdsi_admin_user'
var postgresAdminUsername = 'postgres_admin'
var postgresOMOPCDMJDBCConnectionString = 'jdbc:postgresql://${postgresServer.properties.fullyQualifiedDomainName}:5432/${postgresOMOPCDMDatabaseName}?user=${postgresOMOPCDMUsername}&password=${postgresOMOPCDMPassword}&sslmode=require'


// Get the postgres server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' existing = {
  name: postgresServerName
}

// Get the keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

// Store OMOM CDM user password in keyvault
resource postgresAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: postgresOMOPCDMUserSecretName
  parent: keyVault
  properties: {
    value: postgresOMOPCDMPassword
  }
}

// Store the OMOP CDM JDBC connection string in keyvault
resource postgresOMOPCDMJDBCConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: postgresOMOPCDMJDBCConnectionStringSecretName
  parent: keyVault
  properties: {
    value: postgresOMOPCDMJDBCConnectionString
  }
}

// Create a new PostgreSQL database for the OMOP CDM
resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  name: postgresOMOPCDMDatabaseName
  parent: postgresServer
  properties: {
    charset: 'utf8'
    collation: 'en_US.utf8'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployment-omop-cdm'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT60M'
    forceUpdateTag: '1'
    environmentVariables: [
      {
        name: 'WEBAPI_SCHEMA_NAME'
        value: postgresWebAPISchemaName
      }
      {
        name: 'ATLAS_DB_CONNECTION_STRING'
        secureValue: 'host=${postgresServer.properties.fullyQualifiedDomainName} port=5432 dbname=${postgresAtlasDatabaseName} user=${postgresWebapiAdminUsername} password=${postgresWebapiAdminPassword} sslmode=require'
      }
      {
        name: 'OMOP_CONNECTION_STRING'
        secureValue: 'host=${postgresServer.properties.fullyQualifiedDomainName} port=5432 dbname=${postgresOMOPCDMDatabaseName} user=${postgresAdminUsername} password=${postgresAdminPassword} sslmode=require'
      }
      {
        name: 'OMOP_JDBC_CONNECTION_STRING'
        secureValue: postgresOMOPCDMJDBCConnectionString
      }
      {
        name: 'OMOP_CDM_DATABASE_NAME'
        value: postgresOMOPCDMDatabaseName
      }
      {
        name: 'OMOP_CDM_CONTAINER_URL'
        value: cdmContainerUrl
      }
      {
        name: 'POSTGRES_ADMIN_USERNAME'
        value: postgresAdminUsername
      }
      {
        name: 'POSTGRES_CDM_USERNAME'
        value: postgresOMOPCDMUsername
      }
      {
        name: 'POSTGRES_OMOP_CDM_ROLE'
        value: postgresOMOPCDMRole
      }
      {
        name: 'POSTGRES_OMOP_CDM_PASSWORD'
        secureValue: postgresOMOPCDMPassword
      }
      {
        name: 'OMOP_CDM_SAS_TOKEN'
        value: cdmSasToken
      }
      {
        name: 'POSTGRES_OMOP_CDM_SCHEMA_NAME'
        value: postgresOMOPCDMSchemaName
      }
      {
        name: 'POSTGRES_OMOP_RESULTS_SCHEMA_NAME'
        value: postgresOMOPResultsSchemaName
      }
      {
        name: 'POSTGRES_OMOP_TEMP_SCHEMA_NAME'
        value: postgresOMOPTempSchemaName
      }
      {
        name: 'OHDSI_WEBAPI_URL'
        value: ohdsiWebapiUrl
      }
      {
        name: 'SQL_create_omop_schemas'
        value: loadTextContent('sql/create_omop_schemas_postgres.sql')
      }
      {
        name: 'SQL_create_achilles_tables'
        value: loadTextContent('sql/create_achilles_tables_postgres.sql')
      }
    ]
    scriptContent: loadTextContent('scripts/create_omop_cdm_postgres.sh')
    supportingScriptUris: [
      'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_ddl.sql'
      'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_constraints.sql'
      'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_primary_keys.sql'
      'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_indices.sql'
    ]
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'PT1H'
    containerSettings: {
      containerGroupName: 'deployment-omop-cdm'
    }
  }
}

output OmopCdmJdbcConnectionString string = postgresOMOPCDMJDBCConnectionString
