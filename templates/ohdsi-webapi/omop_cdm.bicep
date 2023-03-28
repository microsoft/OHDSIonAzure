targetScope = 'resourceGroup'

param utcValue string = utcNow()

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of webapi CDM database')
param postgresAtlasDatabaseName string

@description('Used to download the sql scripts from the GitHub repository, this should point to the branch you want to use')
param branchName string

@description('The name of the postgres server')
param postgresServerName string

@secure()
@description('The URL of the container where the CDM data is stored')
param cdmContainerUrl string

@secure()
@description('The SAS token to access the CDM data')
param cdmSasToken string

@secure()
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
param postgresOMOPCDMpassword string

@secure()
@description('The name of the keyvault')
param keyVaultName string

var postgresOMOPCDMSchemaName = 'cdm'
var postgresOMOPVocabularySchemaName = 'vocabulary'
var postgresOMOPResultsSchemaName = 'cdm_results'
var postgresOMOPTempSchemaName = 'temp'
var postgresOMOPCDMRole = 'cdm_reader'
var postgresOMOPCDMUsername = 'cdm_user'
var postgresOMOPCDMUserSecretName = '${postgresOMOPCDMDatabaseName}-cdm-user-password'
var postgresWebAPISchemaName = 'webapi'
var postgresWebapiAdminUsername = 'ohdsi_admin_user'
var postgresAdminUsername = 'postgres_admin'
var postgresOMOPCDMJDBCConnectionString = 'jdbc:postgresql://${postgresServer.properties.fullyQualifiedDomainName}:5432/${postgresOMOPCDMDatabaseName}?user=${postgresOMOPCDMUsername}&password=${postgresOMOPCDMpassword}&sslmode=require'

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
    value: postgresOMOPCDMpassword
  }
}

// Store the OMOP CDM JDBC connection string in keyvault
resource postgresOMOPCDMJDBCConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: postgresOMOPCDMUserSecretName
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

// Create a managed identity for the deployment script
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'managed-identity-omop-cdm'
  location: location
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployment-script-omop-cdm'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }

  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.42.0'
    timeout: 'PT60M'
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
        secureValue: postgresOMOPCDMpassword
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
        name: 'POSTGRES_OMOP_VOCABULARY_SCHEMA_NAME'
        value: postgresOMOPVocabularySchemaName
      }
      {
        name: 'POSTGRES_OMOP_RESULTS_SCHEMA_NAME'
        value: postgresOMOPResultsSchemaName
      }
      {
        name: 'POSTGRES_OMOP_TEMP_SCHEMA_NAME'
        value: postgresOMOPTempSchemaName
      }

    ]
    scriptContent: loadTextContent('scripts/create_omop_cdm.sh')
    supportingScriptUris: [
      'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_ddl.sql'
      'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_constraints.sql'
      'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_primary_keys.sql'
      'https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/postgresql/OMOPCDM_postgresql_5.4_indices.sql'
      'https://raw.githubusercontent.com/microsoft/OHDSIonAzure/${branchName}/templates/ohdsi-webapi/sql/create_omop_schemas.sql'
      'https://raw.githubusercontent.com/microsoft/OHDSIonAzure/${branchName}/templates/ohdsi-webapi/sql/add_omop_source.sql'
    ]
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT1H'
  }
}
