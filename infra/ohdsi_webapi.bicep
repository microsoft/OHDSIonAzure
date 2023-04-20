param location string
param suffix string
param appServicePlanId string
param keyVaultName string
param postgresWebApiSchemaName string
param postgresWebapiAppUsername string
param postgresWebapiAdminUsername string
@secure()
param jdbcConnectionStringWebapiAdmin string
@secure()
param postgresWebapiAppSecret string
@secure()
param postgresWebapiAdminSecret string
param logAnalyticsWorkspaceId string

var dockerRegistryServer = 'https://index.docker.io/v1'
var dockerImageName = 'ohdsi/webapi'
var dockerImageTag = '2.12.1'
var flywayBaselineVersion = '2.2.5.20180212152023'
var tenantId = subscription().tenantId
var logCategories = ['AppServiceAppLogs', 'AppServiceConsoleLogs', 'AppServiceHTTPLogs']

// Get the keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource jdbcConnectionStringWebapiAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'jdbc-connectionstring'
  parent: keyVault
  properties: {
    value: jdbcConnectionStringWebapiAdmin
  }
}

// User Assigned Identity
resource ohdsiWebapiIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-ohdsiwebapi-${suffix}'
  location: location
}

resource ohdsiWebapiAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        objectId: ohdsiWebapiIdentity.properties.principalId
        permissions: {
          secrets: [
            'Get'
            'List'
          ]
        }
        tenantId: tenantId
      }
    ]
  }
}

// Create an App Service webapp
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app-ohdsiwebapi-${suffix}'
  location: location
  properties: {
    httpsOnly: true
    clientAffinityEnabled: false
    keyVaultReferenceIdentity: ohdsiWebapiIdentity.id
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerImageName}:${dockerImageTag}'
      alwaysOn: true
      ftpsState: 'Disabled'
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
          value: postgresWebApiSchemaName
        }
        {
          name: 'DATASOURCE_USERNAME'
          value: postgresWebapiAppUsername
        }
        {
          name: 'DATASOURCE_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${postgresWebapiAppSecret})'
        }
        {
          name: 'DATASOURCE_URL'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${jdbcConnectionStringWebapiAdminSecret.name})'
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
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${postgresWebapiAdminSecret})'
        }
        {
          name: 'FLYWAY_DATASOURCE_URL'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${jdbcConnectionStringWebapiAdminSecret.name})'
        }
        {
          name: 'FLYWAY_LOCATIONS'
          value: 'classpath:db/migration/postgresql'
        }
        {
          name: 'FLYWAY_PLACEHOLDERS_OHDSISCHEMA'
          value: postgresWebApiSchemaName
        }
        {
          name: 'FLYWAY_SCHEMAS'
          value: postgresWebApiSchemaName
        }
        {
          name: 'FLYWAY_TABLE'
          value: 'schema_history'
        }
        {
          name: 'SECURITY_SSL_ENABLED'
          value: 'false'
        }
        {
          name: 'SECURITY_CORS_ENABLED'
          value: 'true'
        }
        {
          name: 'SECURITY_DB_DATASOURCE_AUTHENTICATIONQUERY'
          value: 'select password from webapi_security.security where email = ?'
        }
        {
          name: 'SECURITY_DB_DATASOURCE_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${postgresWebapiAdminSecret})'
        }
        {
          name: 'SECURITY_DB_DATASOURCE_SCHEMA'
          value: 'webapi_security'
        }
        {
          name: 'SECURITY_DB_DATASOURCE_URL'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${jdbcConnectionStringWebapiAdminSecret.name})'
        }
        {
          name: 'SECURITY_DB_DATASOURCE_USERNAME'
          value: postgresWebapiAdminUsername
        }
        {
          name: 'SECURITY_DURATION_INCREMENT'
          value: '10'
        }
        {
          name: 'SECURITY_DURATION_INITIAL'
          value: '10'
        }
        {
          name: 'SECURITY_MAXLOGINATTEMPTS'
          value: '3'
        }
        {
          name: 'SECURITY_ORIGIN'
          value: '*'
        }
        {
          name: 'SECURITY_PROVIDER'
          value: 'AtlasRegularSecurity'
        }
        {
          name: 'SPRING_BATCH_REPOSITORY_TABLEPREFIX'
          value: 'webapi.BATCH_'
        }
        {
          name: 'SPRING_JPA_PROPERTIES_HIBERNATE_DEFAULT_SCHEMA'
          value: postgresWebApiSchemaName
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
      '${ohdsiWebapiIdentity.id}': {}
    }
  }
}

resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: webApp.name
  scope: webApp
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [for logCategory in logCategories: {
      category: logCategory
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }]
  }
}

output ohdsiWebapiUrl string = 'https://${webApp.properties.defaultHostName}/WebAPI/'
