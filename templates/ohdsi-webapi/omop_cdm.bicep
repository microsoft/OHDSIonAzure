targetScope = 'resourceGroup'

param utcValue string = utcNow()
param location string = resourceGroup().location

@description('Used to download the sql scripts from the GitHub repository, this should point to the branch you want to use')
param branchName string = 'v2'

@secure()
@description('The URL of the container where the CDM data is stored')
param cdmContainerUrl string

@secure()
@description('The SAS token to access the CDM data')
param cdmSasToken string

@secure()
@description('The name of webapi CDM database')
param pgAtlasDatabaseName string

@secure()
@description('The name of the OMOP CDM database')
param pgCDMDatabaseName string

@secure()
@description('Admin password for the postgres server')
param pgAdminPassword string

@secure()
@description('Admin password for the webapi database')
param pgWebapiAdminPassword string

@secure()
@description('Password for the cdm user')
param pgCDMpassword string = newGuid()

@secure()
param pgServerName string

@secure()
param keyvaultName string

var pgOMOPCDMSchemaName = 'cdm'
var pgOMOPVocabularySchemaName = 'vocabulary'
var pgOMOPResultsSchemaName = 'results'
var pgOMOPTempSchemaName = 'temp'
var pgOMOPCDMRole = 'cdm_reader'
var pgCDMUsername = 'cdm_user'
var pgCDMUserSecretName = '${pgCDMDatabaseName}-cdm-user-password'
var pgWebAPISchemaName = 'webapi'
var pgWebapiAdminUsername = 'ohdsi_admin_user'
var pgAdminUsername = 'postgres_admin'

resource pgServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' existing = {
  name: pgServerName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvaultName
}

// Store cdm user password in keyvault
resource postgresAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: pgCDMUserSecretName
  parent: keyVault
  properties: {
    value: pgCDMpassword
  }
}
// Create a new PostgreSQL database for the OMOP CDM
resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  name: pgCDMDatabaseName
  parent: pgServer
  properties: {
    charset: 'utf8'
    collation: 'en_US.utf8'
  }
}

// Create a managed identity for the deployment script
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-deploy-script'
  location: location
}

resource runBashWithOutputs 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runBashWithOutputs'
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
        name: 'ATLAS_DB_CONNECTION_STRING'
        secureValue: 'host=${pgServer.properties.fullyQualifiedDomainName} port=5432 dbname=${pgAtlasDatabaseName} user=${pgWebapiAdminUsername} password=${pgWebapiAdminPassword} sslmode=require'
      }
      {
        name: 'OMOP_CONNECTION_STRING'
        secureValue: 'host=${pgServer.properties.fullyQualifiedDomainName} port=5432 dbname=${pgCDMDatabaseName} user=${pgAdminUsername} password=${pgAdminPassword} sslmode=require'
      }
      {
        name: 'ATLAS_DATABASE_NAME'
        value: pgAtlasDatabaseName
      }
      {
        name: 'CDM_DATABASE_NAME'
        value: pgCDMDatabaseName
      }
      {
        name: 'PG_ADMIN_USERNAME'
        value: pgAdminUsername
      }
      {
        name: 'PG_ADMIN_PASSWORD'
        secureValue: pgAdminPassword
      }
      {
        name: 'PG_CDM_USERNAME'
        value: pgCDMUsername
      }
      {
        name: 'PG_CDM_PASSWORD'
        secureValue: pgCDMpassword
      }
      {
        name: 'CDM_CONTAINER_URL'
        value: cdmContainerUrl
      }
      {
        name: 'CDM_SAS_TOKEN'
        value: cdmSasToken
      }
      {
        name: 'WEBAPI_SCHEMA_NAME'
        value: pgWebAPISchemaName
      }
      {
        name: 'OMOP_CDM_SCHEMA_NAME'
        value: pgOMOPCDMSchemaName
      }
      {
        name: 'OMOP_VOCABULARY_SCHEMA_NAME'
        value: pgOMOPVocabularySchemaName
      }
      {
        name: 'OMOP_RESULTS_SCHEMA_NAME'
        value: pgOMOPResultsSchemaName
      }
      {
        name: 'OMOP_TEMP_SCHEMA_NAME'
        value: pgOMOPTempSchemaName
      }
      {
        name: 'OMOP_CDM_ROLE'
        value: pgOMOPCDMRole
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
    retentionInterval: 'P10M'
  }
}
