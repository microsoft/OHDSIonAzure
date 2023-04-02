param location string
param suffix string
param odhsiWebApiName string
@secure()
param postgresAdminPassword string
@secure()
param postgresWebapiAdminPassword string
@secure()
param postgresWebapiAppPassword string

@description('Enables local access for debugging.')
param localDebug bool = false

var postgresAdminUsername = 'postgres_admin'
var postgresWebapiAdminUsername = 'ohdsi_admin_user'
var postgresWebapiAdminRole = 'ohdsi_admin'
var postgresWebapiAppUsername = 'ohdsi_app_user'
var postgresWebapiAppRole = 'ohdsi_app'
var postgresWebApiDatabaseName = 'atlas_webapi_db'
var postgresSchemaName = 'webapi'
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
  }
}

// Allow public access from any Azure service within Azure to this server
resource allowAccessToAzureServices 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-12-01' = {
  name: 'AllowAllAzureIps' 
  parent: postgresServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }  
}

resource allowAccessToAll 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-12-01' = if (localDebug) {
  name: 'AllowAllIps' 
  parent: postgresServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
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

resource deploymentAtlasInitScripts 'Microsoft.Resources/deploymentScripts@2020-10-01' = { 
    name: 'deployment-atlas-init' 
    location: location 
    kind: 'AzureCLI' 
    properties: {
        azCliVersion: '2.42.0' 
        timeout: 'PT5M'
        containerSettings: {
          containerGroupName: 'deployment-atlas-init'
        }
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
            {
              name: 'SQL_ATLAS_USERS'
              value: loadTextContent('sql/atlas_create_roles_users.sql')
            }
            {
              name: 'SQL_ATLAS_SCHEMA'
              value: loadTextContent('sql/atlas_create_schema.sql')
            }
        ] 
        scriptContent: loadTextContent('scripts/atlas_db_init.sh')
        cleanupPreference: 'OnSuccess' 
        retentionInterval: 'PT1H' 
    } 
    dependsOn: [ 
      postgresDatabase
  ]
}

output postgresServerName string = postgresServer.name
output postgresServerFullyQualifiedDomainName string = postgresServer.properties.fullyQualifiedDomainName
output postgresSchemaName string = postgresSchemaName
output postgresAdminUsername string = postgresAdminUsername
output postgresWebapiAdminUsername string = postgresWebapiAdminUsername
output postgresWebapiAppUsername string = postgresWebapiAppUsername
output postgresWebApiDatabaseName string = postgresWebApiDatabaseName
