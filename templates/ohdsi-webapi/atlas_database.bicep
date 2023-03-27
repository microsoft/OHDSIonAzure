param location string
param suffix string
param odhsiWebApiName string

var postgresAdminUsername = 'postgres_admin'
var postgresWebapiAdminUsername = 'ohdsi_admin_user'
var postgresWebapiAdminRole = 'ohdsi_admin'
var postgresWebapiAppUsername = 'ohdsi_app_user'
var postgresWebapiAppRole = 'ohdsi_app'
var postgresWebApiDatabaseName = 'atlas_webapi_db'
var postgresSchemaName = 'webapi'

@secure()
param postgresAdminPassword string
@secure()
param postgresWebapiAdminPassword string
@secure()
param postgresWebapiAppPassword string

var postgresVersion = '14'


// Create a PostgreSQL server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: 'postgresql-${odhsiWebApiName}-${suffix}'
  location: location
  sku: {
    name: 'Standard_D2s_v3'
    tier: 'GeneralPurpose'
  }
  properties: {
    version: postgresVersion
    administratorLogin: postgresAdminUsername
    administratorLoginPassword: postgresAdminPassword
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    availabilityZone: '3'
  }
}

// Allow public access from any Azure service within Azure to this server
resource allowAccessToAzureServices 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2021-06-01' = {
  name: 'AllowAllWindowsAzureIps' 
  parent: postgresServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Create a new PostgreSQL database
resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  name: postgresWebApiDatabaseName
  parent: postgresServer
  properties: {
    charset: 'utf8'
    collation: 'en_US.utf8'
  }
}

// Create a OHDSI users and groupss
param utcValue string = utcNow()
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = { 
    name: 'deploy-script-identity' 
    location: location 
} 
resource runSQLscriptsWithOutputs 'Microsoft.Resources/deploymentScripts@2020-10-01' = { 
    name: 'runSQLscriptsWithOutputs' 
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
        timeout: 'PT30M'
         environmentVariables: [ 
            { 
                name: 'MAIN_CONNECTION_STRING' 
                secureValue: 'host=${postgresServer.properties.fullyQualifiedDomainName} port=5432 dbname=${postgresWebApiDatabaseName} user=${postgresAdminUsername} password=${postgresAdminPassword} sslmode=require'
            }
            { 
              name: 'OHDSI_ADMIN_CONNECTION_STRING' 
              secureValue: 'host=${postgresServer.properties.fullyQualifiedDomainName} port=5432 dbname=${postgresWebApiDatabaseName} user=${postgresWebapiAdminUsername} password=${postgresWebapiAdminPassword} sslmode=require'
            }
            {
              name: 'DATABASE_NAME'
              value: postgresWebApiDatabaseName
            }
            {
              name: 'SCHEMA_NAME'
              value: postgresSchemaName
            }
            {
              name: 'OHDSI_ADMIN_PASSWORD'
              secureValue: postgresWebapiAdminPassword
            }
            {
              name: 'OHDSI_APP_PASSWORD'
              secureValue: postgresWebapiAppPassword
            }
            {
              name: 'OHDSI_APP_USERNAME'
              value: postgresWebapiAppUsername
            }
            {
              name: 'OHDSI_ADMIN_USERNAME'
              value: postgresWebapiAdminUsername
            }
            {
              name: 'OHDSI_ADMIN_ROLE'
              value: postgresWebapiAdminRole

            }
            {
              name: 'OHDSI_APP_ROLE'
              value: postgresWebapiAppRole
            }
        ] 
        scriptContent: loadTextContent('scripts/atlas-db-init.sh')
        supportingScriptUris: [
          
        ]
        cleanupPreference: 'OnSuccess' 
        retentionInterval: 'P1D' 
        
    } 
    dependsOn: [ 
      postgresDatabase
  ]
}

output postgresServerFullyQualifiedDomainName string = postgresServer.properties.fullyQualifiedDomainName
output postgresSchemaName string = postgresSchemaName
output postgresAdminUsername string = postgresAdminUsername
output postgresWebapiAdminUsername string = postgresWebapiAdminUsername
output postgresWebapiAppUsername string = postgresWebapiAppUsername
output postgresWebApiDatabaseName string = postgresWebApiDatabaseName
