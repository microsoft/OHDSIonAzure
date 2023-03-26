param location string
param suffix string
param odhsiWebApiName string

var databaseAdminUsername = 'postgres_admin'
var databaseWebapiAdminUsername = 'ohdsi_admin_user'
var databaseWebapiAdminRole = 'ohdsi_admin'
var databaseWebapiAppUsername = 'ohdsi_app_user'
var databaseWebapiAppRole = 'ohdsi_app'
var databaseWebApiDatabaseName = 'atlas_webapi_db'
var databaseSchemaName = 'webapi'

@secure()
param databaseAdminPassword string
@secure()
param databaseWebapiAdminPassword string
@secure()
param databaseWebapiAppPassword string

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
    administratorLogin: databaseAdminUsername
    administratorLoginPassword: databaseAdminPassword
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
  name: databaseWebApiDatabaseName
  parent: postgresServer
  properties: {
    charset: 'utf8'
    collation: 'en_US.utf8'
  }
}

// Create a OHDSI users and groupss
param utcValue string = utcNow()
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
        timeout: 'PT30M'
         environmentVariables: [ 
            { 
                name: 'MAIN_CONNECTION_STRING' 
                secureValue: 'host=${postgresServer.properties.fullyQualifiedDomainName} port=5432 dbname=${databaseWebApiDatabaseName} user=${databaseAdminUsername} password=${databaseAdminPassword} sslmode=require'
            }
            { 
              name: 'OHDSI_ADMIN_CONNECTION_STRING' 
              secureValue: 'host=${postgresServer.properties.fullyQualifiedDomainName} port=5432 dbname=${databaseWebApiDatabaseName} user=${databaseWebapiAdminUsername} password=${databaseWebapiAdminPassword} sslmode=require'
            }
            {
              name: 'DATABASE_NAME'
              value: databaseWebApiDatabaseName
            }
            {
              name: 'SCHEMA_NAME'
              value: databaseSchemaName
            }
            {
              name: 'OHDSI_ADMIN_PASSWORD'
              secureValue: databaseWebapiAdminPassword
            }
            {
              name: 'OHDSI_APP_PASSWORD'
              secureValue: databaseWebapiAppPassword
            }
            {
              name: 'OHDSI_APP_USERNAME'
              value: databaseWebapiAppUsername
            }
            {
              name: 'OHDSI_ADMIN_USERNAME'
              value: databaseWebapiAdminUsername
            }
            {
              name: 'OHDSI_ADMIN_ROLE'
              value: databaseWebapiAdminRole

            }
            {
              name: 'OHDSI_APP_ROLE'
              value: databaseWebapiAppRole
            }
        ] 
        scriptContent: ''' 
            apk --update add postgresql-client
            ADMIN_USER_PASSWORD="${OHDSI_ADMIN_PASSWORD}${OHDSI_ADMIN_USERNAME}"
            APP_USER_PASSWORD="${OHDSI_APP_PASSWORD}${OHDSI_APP_USERNAME}"
            ADMIN_MD5="'md5$(echo -n $ADMIN_USER_PASSWORD | md5sum | awk '{ print $1 }')'"
            APP_MD5="'md5$(echo -n $APP_USER_PASSWORD | md5sum | awk '{ print $1 }')'"
    
            echo "CREATE ROLE ${OHDSI_ADMIN_ROLE} CREATEDB REPLICATION VALID UNTIL 'infinity'; COMMENT ON ROLE ${OHDSI_ADMIN_ROLE} IS 'Administration group for OHDSI applications'; CREATE ROLE ${OHDSI_APP_ROLE} VALID UNTIL 'infinity'; COMMENT ON ROLE ${OHDSI_APP_ROLE} IS 'Application groupfor OHDSI applications'; GRANT ${OHDSI_ADMIN_ROLE} TO ${OHDSI_ADMIN_USERNAME}; COMMENT ON ROLE ${OHDSI_ADMIN_ROLE} IS 'Admin user account for OHDSI applications'; CREATE ROLE ${OHDSI_ADMIN_USERNAME} LOGIN ENCRYPTED PASSWORD ${ADMIN_MD5} VALID UNTIL 'infinity'; GRANT ${OHDSI_ADMIN_ROLE} TO ${OHDSI_ADMIN_USERNAME}; COMMENT ON ROLE ${OHDSI_ADMIN_USERNAME} IS 'Admin user account for OHDSI applications'; CREATE ROLE ${OHDSI_APP_USERNAME} LOGIN ENCRYPTED PASSWORD ${APP_MD5} VALID UNTIL 'infinity'; GRANT ${OHDSI_APP_ROLE} TO ${OHDSI_APP_USERNAME}; COMMENT ON ROLE ${OHDSI_APP_USERNAME} IS 'Application user account for OHDSI applications'; GRANT ALL ON DATABASE ${DATABASE_NAME} TO GROUP ${OHDSI_ADMIN_ROLE}; GRANT CONNECT, TEMPORARY ON DATABASE ${DATABASE_NAME} TO GROUP ${OHDSI_APP_ROLE};" > ohdsi-part1.sql
            echo "CREATE SCHEMA ${SCHEMA_NAME} AUTHORIZATION ${OHDSI_ADMIN_ROLE}; COMMENT ON SCHEMA ${SCHEMA_NAME} IS 'Schema containing tables to support WebAPI functionality'; GRANT USAGE ON SCHEMA ${SCHEMA_NAME} TO PUBLIC; GRANT ALL ON SCHEMA ${SCHEMA_NAME} TO GROUP ${OHDSI_ADMIN_ROLE}; GRANT USAGE ON SCHEMA ${SCHEMA_NAME} TO GROUP ${OHDSI_APP_ROLE}; ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA_NAME} GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLES TO ${OHDSI_APP_ROLE}; ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA_NAME} GRANT SELECT, USAGE ON SEQUENCES TO ${OHDSI_APP_ROLE}; ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA_NAME} GRANT EXECUTE ON FUNCTIONS TO ${OHDSI_APP_ROLE}; ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA_NAME} GRANT USAGE ON TYPES TO ${OHDSI_APP_ROLE};" > ohdsi-part2.sql
            psql "$MAIN_CONNECTION_STRING" -f ohdsi-part1.sql
            psql "$OHDSI_ADMIN_CONNECTION_STRING" -f ohdsi-part2.sql
            printf 'Done'
            ''' 
        cleanupPreference: 'OnSuccess' 
        retentionInterval: 'P1D' 
        
    } 
    dependsOn: [ 
      postgresDatabase
  ]
}

output databaseServerFullyQualifiedDomainName string = postgresServer.properties.fullyQualifiedDomainName
output databaseSchemaName string = databaseSchemaName
output databaseAdminUsername string = databaseAdminUsername
output databaseWebapiAdminUsername string = databaseWebapiAdminUsername
output databaseWebapiAppUsername string = databaseWebapiAppUsername
output databaseWebApiDatabaseName string = databaseWebApiDatabaseName
