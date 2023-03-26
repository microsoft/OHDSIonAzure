param location string
param suffix string
param userAssignedIdentityId string
param odhsiWebApiName string
param appServicePlanId string 
param keyVaultName string
param databaseWebApiSchemaName string
param databaseWebapiAppUsername string
param databaseWebapiAdminUsername string
@secure()
param jdbcConnectionStringWebapiAdminSecret string
@secure()
param databaseWebapiAppSecret string
@secure()
param databaseWebapiAdminSecret string


var dockerRegistryServer = 'https://index.docker.io/v1'
var dockerImageName = 'ohdsi/webapi'
var dockerImageTag = '2.12.1'
var flywayBaselineVersion = '2.2.5.20180212152023'

// Create an App Service webapp
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'webapp-${odhsiWebApiName}-${suffix}'
  location: location
  properties: {
    httpsOnly: true
    keyVaultReferenceIdentity: userAssignedIdentityId
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerImageName}:${dockerImageTag}'
      appSettings: [
      {
        name: 'DOCKER_REGISTRY_SERVER_URL'
        value: dockerRegistryServer
      }
      {
        name: 'DATASOURCE_DRIVERCLASSNAME'
        value: 'org.databaseql.Driver'
      }
      {
        name: 'DATASOURCE_OHDSI_SCHEMA'
        value: databaseWebApiSchemaName
      }
      {
        name: 'DATASOURCE_USERNAME'
        value: databaseWebapiAppUsername
      }
      {
        name: 'DATASOURCE_PASSWORD'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${databaseWebapiAppSecret})'
      }
      {
        name: 'DATASOURCE_URL'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${jdbcConnectionStringWebapiAdminSecret})'
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
        value: 'org.databaseql.Driver'
      }
      {
        name: 'FLYWAY_DATASOURCE_USERNAME'
        value: databaseWebapiAdminUsername
      }
      {
       name: 'FLYWAY_DATASOURCE_PASSWORD'
       value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${databaseWebapiAdminSecret})'
      }
      {
        name: 'FLYWAY_DATASOURCE_URL'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${jdbcConnectionStringWebapiAdminSecret})'
      }
      {
        name: 'FLYWAY_LOCATIONS'
        value: 'classpath:db/migration/databaseql'
      }
      {
        name: 'FLYWAY_PLACEHOLDERS_OHDSISCHEMA'
        value: databaseWebApiSchemaName
      }
      {
        name: 'FLYWAY_SCHEMAS'
        value: databaseWebApiSchemaName
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
        value: databaseWebApiSchemaName
      }
      {
        name: 'SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT'
        value: 'org.hibernate.dialect.databaseQLDialect'
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
      '${userAssignedIdentityId}': {}
    }
  }
}


output webAppUrl string = webApp.properties.defaultHostName
