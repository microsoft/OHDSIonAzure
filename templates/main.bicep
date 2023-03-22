targetScope = 'resourceGroup'

// General parameters
param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param odhsiWebApiName string = 'ohdsi-webapi'
param dockerRegistryServer string = 'https://index.docker.io/v1'
param dockerImageName string = 'ohdsi/webapi'
param dockerImageTag string = '2.12.1'
param keyvaultName string ='keyvault-${uniqueString(resourceGroup().id)}'

// Postgres parameters
param serverEdition string = 'GeneralPurpose'
param skuSizeGB int = 32
param dbInstanceType string = 'Standard_D2s_v3'
param availabilityZone string = '3'
param version string = '14'
param postgresDatabaseName string = 'atlas_db'
param postgresSchemaName string = 'webapi'
param flywayBaselineVersion string = '2.2.5.20180212152023'
// Users and passwords
param postgresAdminUsername string = 'postgres_admin'
param postgresWebapiAdminUsername string = 'ohdsi_admin_user'
param postgresWebapiAppUsername string = 'ohdsi_app_user'
@secure()
param postgresAdminPassword string
@secure()
param postgresWebapiAdminPassword string
@secure()
param postgresWebapiAppPassword string
// Connection strings
var jdbcConnectionStringWebapiAdmin = 'jdbc:postgresql://${postgresServer.properties.fullyQualifiedDomainName}:5432/${postgresDatabaseName}?user=${postgresWebapiAdminUsername}&password=${postgresWebapiAdminPassword}&sslmode=require'

// User Assigned Identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'identity-${odhsiWebApiName}'
  location: location
}

// KeyVault and storing PostgreSql secrets
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyvaultName
  location: location
  properties: {
    accessPolicies:[
      {
        objectId: identity.properties.principalId
        permissions: {
          secrets: [
            'Get'
            'List'
          ]
        }
        tenantId: tenantId
      }
    ]
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource postgresAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'postgres-admin-password'
  parent: keyVault
  properties: {
    value: postgresAdminPassword
  }
}

resource postgresWebapiAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'ohdsi-admin-password'
  parent: keyVault
  properties: {
    value: postgresWebapiAdminPassword
  }
}

resource postgresWebapiAppSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'ohdsi-app-password'
  parent: keyVault
  properties: {
    value: postgresWebapiAppPassword
  }
}

resource jdbcConnectionStringWebapiAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'jdbc-connectionstring'
  parent: keyVault
  properties: {
    value: jdbcConnectionStringWebapiAdmin
  }
}

// Create a PostgreSql server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: 'postgresql-${odhsiWebApiName}'
  location: location
  sku: {
    name: dbInstanceType
    tier: serverEdition
  }
  properties: {
    version: version
    administratorLogin: postgresAdminUsername
    administratorLoginPassword: postgresAdminPassword
    storage: {
      storageSizeGB: skuSizeGB
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    availabilityZone: availabilityZone
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
  name: postgresDatabaseName
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
                name: 'MainConnectionString' 
                secureValue: 'host=${postgresServer.properties.fullyQualifiedDomainName} port=5432 dbname=${postgresDatabaseName} user=${postgresAdminUsername} password=${postgresAdminPassword} sslmode=require'
            }
            { 
              name: 'ODHSIAdminConnectionString' 
              secureValue: 'host=${postgresServer.properties.fullyQualifiedDomainName} port=5432 dbname=${postgresDatabaseName} user=${postgresWebapiAdminUsername} password=${postgresWebapiAdminPassword} sslmode=require'
          }
            {
              name: 'DatabaseName'
              secureValue: postgresDatabaseName
            }
            {
              name: 'OhdsiAdminPassword'
              secureValue: postgresWebapiAdminPassword
            }
            {
              name: 'OhdsiAppPassword'
              secureValue: postgresWebapiAppPassword
            }
        ] 
        scriptContent: ''' 
            apk --update add postgresql-client
            admin_user_pass="$(echo "$OhdsiAdminPassword"ohdsi_admin_user)"
            app_user_pass="$(echo "$OhdsiAppPassword"ohdsi_app_user)"

            admin_md5="'md5$(echo -n $admin_user_pass | md5sum | awk '{ print $1 }')'"
            app_md5="'md5$(echo -n $app_user_pass | md5sum | awk '{ print $1 }')'"

            printf "CREATE ROLE ohdsi_admin CREATEDB REPLICATION VALID UNTIL 'infinity'; COMMENT ON ROLE ohdsi_admin IS 'Administration group for OHDSI applications'; CREATE ROLE ohdsi_app VALID UNTIL 'infinity'; COMMENT ON ROLE ohdsi_app IS 'Application groupfor OHDSI applications'; GRANT ohdsi_admin TO ohdsi_admin_user; COMMENT ON ROLE ohdsi_admin_user IS 'Admin user account for OHDSI applications'; CREATE ROLE ohdsi_admin_user LOGIN ENCRYPTED PASSWORD %s VALID UNTIL 'infinity'; GRANT ohdsi_admin TO ohdsi_admin_user; COMMENT ON ROLE ohdsi_admin_user IS 'Admin user account for OHDSI applications'; CREATE ROLE ohdsi_app_user LOGIN ENCRYPTED PASSWORD %s VALID UNTIL 'infinity'; GRANT ohdsi_app TO ohdsi_app_user; COMMENT ON ROLE ohdsi_app_user IS 'Application user account for OHDSI applications'; GRANT ALL ON DATABASE "atlas_db" TO GROUP ohdsi_admin; GRANT CONNECT, TEMPORARY ON DATABASE "atlas_db" TO GROUP ohdsi_app;"  "$admin_md5"  "$app_md5" > ohdsi-part1.sql
            printf "CREATE SCHEMA webapi AUTHORIZATION ohdsi_admin; COMMENT ON SCHEMA webapi IS 'Schema containing tables to support WebAPI functionality'; GRANT USAGE ON SCHEMA webapi TO PUBLIC; GRANT ALL ON SCHEMA webapi TO GROUP ohdsi_admin; GRANT USAGE ON SCHEMA webapi TO GROUP ohdsi_app; ALTER DEFAULT PRIVILEGES IN SCHEMA webapi GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLES TO ohdsi_app; ALTER DEFAULT PRIVILEGES IN SCHEMA webapi GRANT SELECT, USAGE ON SEQUENCES TO ohdsi_app; ALTER DEFAULT PRIVILEGES IN SCHEMA webapi GRANT EXECUTE ON FUNCTIONS TO ohdsi_app; ALTER DEFAULT PRIVILEGES IN SCHEMA webapi GRANT USAGE ON TYPES TO ohdsi_app;" > ohdsi-part2.sql
            psql "$MainConnectionString" -f ohdsi-part1.sql
            psql "$ODHSIAdminConnectionString" -f ohdsi-part2.sql
            printf 'Done'
            ''' 
        cleanupPreference: 'OnSuccess' 
        retentionInterval: 'P1D' 
        
    } 
    dependsOn: [ 
      postgresDatabase
  ]
}


// Create an App Service plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name:  'appServicePlan-${odhsiWebApiName}'
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Create an App Service webapp
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'webapp-${odhsiWebApiName}'
  location: location
  properties: {
    httpsOnly: true
    keyVaultReferenceIdentity: identity.id
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerImageName}:${dockerImageTag}'
      appSettings: [
      {
        name: 'DOCKER_REGISTRY_SERVER_URL'
        value: dockerRegistryServer
      }
      {
        name: 'DATASOURCE_DRIVERCLASSNAME'
        value: 'org.postgresql.Driver'
      }
      {
        name: 'DATASOURCE_OHDSI_SCHEMA'
        value: postgresSchemaName
      }
      {
        name: 'DATASOURCE_USERNAME'
        value: postgresWebapiAppUsername
      }
      {
        name: 'DATASOURCE_PASSWORD'
        value: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=${postgresWebapiAppSecret.name})'
      }
      {
        name: 'DATASOURCE_URL'
        value: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=${jdbcConnectionStringWebapiAdminSecret.name})'
      }
      {
        name: 'FLYWAY_BASELINEDESCRIPTION'
        value: 'Base Migration'
      }
      {
        name: 'FLYWAY_BASELINEONMIGRATE'
        value: 'true'
      }
      {
        name: 'flyway_baselineVersionAsString'
        value: flywayBaselineVersion
      }
      {
        name: 'FLYWAY_DATASOURCE_DRIVERCLASSNAME'
        value: 'org.postgresql.Driver'
      }
      {
        name: 'FLYWAY_DATASOURCE_USERNAME'
        value: postgresWebapiAdminUsername
      }
      {
       name: 'FLYWAY_DATASOURCE_PASSWORD'
       value: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=${postgresWebapiAdminSecret.name})'
      }
      {
        name: 'FLYWAY_DATASOURCE_URL'
        value: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=${jdbcConnectionStringWebapiAdminSecret.name})'
      }
      {
        name: 'FLYWAY_LOCATIONS'
        value: 'classpath:db/migration/postgresql'
      }
      {
        name: 'FLYWAY_PLACEHOLDERS_OHDSISCHEMA'
        value: postgresSchemaName
      }
      {
        name: 'FLYWAY_SCHEMAS'
        value: postgresSchemaName
      }
      {
        name: 'FLYWAY_TABLE'
        value: 'schema_history'
      }
      {
        name: 'SECURITY_SSL_ENABLED'
        value: 'false'
      }
      // TODO: Add security app settings
      {
        name: 'SPRING_BATCH_REPOSITORY_TABLEPREFIX'
        value: 'webapi.BATCH_'
      }
      {
        name: 'SPRING_JPA_PROPERTIES_HIBERNATE_DEFAULT_SCHEMA'
        value: postgresSchemaName
      }
      {
        name: 'SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT'
        value: 'org.hibernate.dialect.PostgreSQLDialect'
      }
      {
        name: 'WEBSITE_HEALTHCHECK_MAXPINGFAILURES'
        value: '10'
      }
      {
        name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
        value: '30'
      }
      {
        name: 'WEBSITES_CONTAINER_START_TIME_LIMIT'
        value: '1800'
      }
      {
        name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
        value: 'false'
      }
      {
        name: 'WEBSITES_PORT'
        value: '8080'
      }

    ] 
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  dependsOn: [
    postgresServer
    postgresDatabase
  ]
}



