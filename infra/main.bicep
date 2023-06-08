targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = resourceGroup().location
param suffix string = uniqueString(utcNow())

@description('The url of the container where the cdm is stored')
#disable-next-line no-hardcoded-env-urls
param cdmContainerUrl string = 'https://omoppublic.blob.core.windows.net/shared/synthea1k/'

@description('The sas token to access the cdm container')
param cdmSasToken string

@description('The name of the database to create for the OMOP CDM')
param postgresOMOPCDMDatabaseName string

@description('The app service plan sku')
@allowed([
  'S1'
  'S2'
  'S3'
  'B1'
  'B2'
  'B3'
  'P1V2'
  'P2V2'
  'P3V2'
  'P1V3'
  'P2V3'
  'P3V3'
])
param appPlanSkuName string = 'S1'

@description('The postgres sku')
@allowed([
    'Standard_D2s_v3'
    'Standard_D4s_v3'
    'Standard_D8s_v3'
    'Standard_D16s_v3'
    'Standard_D32s_v3'
    'Standard_D48s_v3'
    'Standard_D64s_v3'
    'Standard_D2ds_v4'
    'Standard_D4ds_v4'
    'Standard_D8ds_v4'
    'Standard_D16ds_v4'
    'Standard_D32ds_v4'
    'Standard_D48ds_v4'
    'Standard_D64ds_v4'
    'Standard_D64ds_v4'
    'Standard_B1ms'
    'Standard_B2s'
    'Standard_B2ms'
    'Standard_B4ms'
    'Standard_B8ms'
    'Standard_B12ms'
    'Standard_B16ms'
    'Standard_B20ms'
  ]
)
param postgresSku string = 'Standard_D2s_v3'

@description('The size of the postgres database storage')
@allowed([ 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384 ])
param postgresStorageSize int = 32

@secure()
@description('The password for the postgres admin user')
param postgresAdminPassword string = uniqueString(newGuid())

@secure()
@description('The password for the postgres webapi admin user')
param postgresWebapiAdminPassword string = uniqueString(newGuid())

@secure()
@description('The password for the postgres webapi app user')
param postgresWebapiAppPassword string = uniqueString(newGuid())

@secure()
@description('The password for the postgres OMOP CDM user')
param postgresOMOPCDMPassword string = uniqueString(newGuid())

@secure()
@description('The password for atlas security admin user')
param atlasSecurityAdminPassword string = uniqueString(newGuid())

@secure()
@description('Comma-delimited user list for atlas. Do not use admin as a username. It causes problems with Atlas security')
param atlasUsersList string

@description('Enables local access for debugging.')
param localDebug bool = false

var tenantId = subscription().tenantId

@description('Creates the app service plan')
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  #disable-next-line use-stable-resource-identifiers
  name: 'asp-${suffix}'
  location: location
  sku: {
    name: appPlanSkuName
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

@description('Creates the key vault')
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  #disable-next-line use-stable-resource-identifiers
  name: 'kv-${suffix}'
  location: location
  properties: {
    accessPolicies: []
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

resource keyVaultDiagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: keyVault.name
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

@description('Creates the database server, users and groups required for ohdsi webapi')
module atlasDatabase 'atlas_database.bicep' = {
  name: 'atlasDatabase'
  params: {
    location: location
    suffix: suffix
    keyVaultName: keyVault.name
    postgresSku: postgresSku
    postgresStorageSize: postgresStorageSize
    postgresAdminPassword: postgresAdminPassword
    postgresWebapiAdminPassword: postgresWebapiAdminPassword
    postgresWebapiAppPassword: postgresWebapiAppPassword
    localDebug: localDebug
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

@description('Creates the ohdsi webapi')
module ohdsiWebApiWebapp 'ohdsi_webapi.bicep' = {
  name: 'ohdsiWebApiWebapp'
  params: {
    location: location
    suffix: suffix
    appServicePlanId: appServicePlan.id
    keyVaultName: keyVault.name
    jdbcConnectionStringWebapiAdmin: 'jdbc:postgresql://${atlasDatabase.outputs.postgresServerFullyQualifiedDomainName}:5432/${atlasDatabase.outputs.postgresWebApiDatabaseName}?user=${atlasDatabase.outputs.postgresWebapiAdminUsername}&password=${postgresWebapiAdminPassword}&sslmode=require'
    postgresWebapiAdminSecret: atlasDatabase.outputs.postgresWebapiAdminSecretName
    postgresWebapiAppSecret: atlasDatabase.outputs.postgresWebapiAppSecretName
    postgresWebapiAdminUsername: atlasDatabase.outputs.postgresWebapiAdminUsername
    postgresWebapiAppUsername: atlasDatabase.outputs.postgresWebapiAppUsername
    postgresWebApiSchemaName: atlasDatabase.outputs.postgresSchemaName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
  dependsOn: [
    atlasDatabase
  ]
}

@description('Creates OMOP CDM database')
module omopCDM 'omop_cdm.bicep' = {
  name: 'omopCDM'
  params: {
    location: location
    keyVaultName: keyVault.name
    cdmContainerUrl: cdmContainerUrl
    cdmSasToken: cdmSasToken
    postgresAtlasDatabaseName: atlasDatabase.outputs.postgresWebApiDatabaseName
    postgresOMOPCDMDatabaseName: postgresOMOPCDMDatabaseName
    postgresAdminPassword: postgresAdminPassword
    postgresWebapiAdminPassword: postgresWebapiAdminPassword
    postgresOMOPCDMPassword: postgresOMOPCDMPassword
    postgresServerName: atlasDatabase.outputs.postgresServerName
  }

  dependsOn: [
    ohdsiWebApiWebapp
    atlasDatabase
  ]
}

@description('Creates the ohdsi atlas UI')
module atlasUI 'ohdsi_atlas_ui.bicep' = {
  name: 'atlasUI'
  params: {
    location: location
    suffix: suffix
    appServicePlanId: appServicePlan.id
    ohdsiWebApiUrl: ohdsiWebApiWebapp.outputs.ohdsiWebapiUrl
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
  dependsOn: [
    ohdsiWebApiWebapp
  ]
}

output ohdsiWebapiUrl string = ohdsiWebApiWebapp.outputs.ohdsiWebapiUrl

resource atlasSecurityAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'atlas-security-admin-password'
  parent: keyVault
  properties: {
    value: atlasSecurityAdminPassword
  }
}

resource deploymentAtlasSecurity 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployment-atlas-security'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT60M'
    forceUpdateTag: '5'
    containerSettings: {
      containerGroupName: 'deployment-atlas-security'
    }
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnExpiration'
    environmentVariables: [
      {
        name: 'OHDSI_ADMIN_CONNECTION_STRING'
        secureValue: 'host=${atlasDatabase.outputs.postgresServerFullyQualifiedDomainName} port=5432 dbname=${atlasDatabase.outputs.postgresWebApiDatabaseName} user=${atlasDatabase.outputs.postgresWebapiAdminUsername} password=${postgresWebapiAdminPassword} sslmode=require'
      }
      {
        name: 'ATLAS_SECURITY_ADMIN_PASSWORD'
        secureValue: atlasSecurityAdminPassword
      }
      {
        name: 'ATLAS_USERS'
        secureValue: 'admin,${atlasSecurityAdminPassword},${atlasUsersList}'
      }
      {
        name: 'SQL_ATLAS_CREATE_SECURITY'
        value: loadTextContent('sql/atlas_create_security.sql')
      }
      {
        name: 'WEBAPI_URL'
        value: ohdsiWebApiWebapp.outputs.ohdsiWebapiUrl
      }
    ]
    scriptContent: loadTextContent('scripts/atlas_security.sh')
  }
  dependsOn: [
    atlasDatabase
  ]
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  #disable-next-line use-stable-resource-identifiers
  name: 'log-${suffix}'
  location: location
}

resource deplymentAddDataSource 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployment-add-data-source'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT5M'
    forceUpdateTag: '5'
    containerSettings: {
      containerGroupName: 'deployment-add-data-source'
    }
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnExpiration'
    environmentVariables: [
      {
        name: 'CONNECTION_STRING'
        secureValue: 'jdbc:postgresql://${atlasDatabase.outputs.postgresServerFullyQualifiedDomainName}:5432/${postgresOMOPCDMDatabaseName}?user=postgres_admin&password=${postgresOMOPCDMPassword}&sslmode=require'
      }
      {
        name: 'OHDSI_WEBAPI_PASSWORD'
        secureValue: atlasSecurityAdminPassword
      }
      {
        name: 'OHDSI_WEBAPI_USER'
        value: 'admin'
      }
      {
        name: 'OHDSI_WEBAPI_URL'
        value: ohdsiWebApiWebapp.outputs.ohdsiWebapiUrl
      }
      {
        name: 'DIALECT'
        value: 'postgresql'
      }
      {
        name: 'SOURCE_NAME'
        value: 'omop-cdm-synthea'
      }
      {
        name: 'SOURCE_KEY'
        value: 'omop-cdm-synthea'
      }
      {
        name: 'USERNAME'
        value: atlasDatabase.outputs.postgresWebapiAdminUsername
      }
      {
        name: 'PASSWORD'
        secureValue: postgresWebapiAdminPassword
      }
      {
        name: 'DAIMON_CDM'
        value: 'cdm'
      }
      {
        name: 'DAIMON_VOCABULARY'
        value: 'cdm'
      }
      {
        name: 'DAIMON_RESULTS'
        value: 'cdm_results'
      }
    ]
    scriptContent: loadTextContent('scripts/add_data_source.sh')
  }
  dependsOn: [
    atlasUI
    ohdsiWebApiWebapp
    omopCDM
  ]
}
