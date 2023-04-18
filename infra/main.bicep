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
param postgresOMOPCDMpassword string = uniqueString(newGuid())

@description('Enables local access for debugging.')
param localDebug bool = false

var tenantId = subscription().tenantId

@description('Creates the app service plan')
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
#disable-next-line use-stable-resource-identifiers
  name: 'asp-${suffix}'
  location: location
  sku: {
    name: 'S1'
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

@description('Creates the database server, users and groups required for ohdsi webapi')
module atlasDatabase 'atlas_database.bicep' = {
  name: 'atlasDatabase'
  params: {
    location: location
    suffix: suffix
    keyVaultName: keyVault.name
    postgresAdminPassword: postgresAdminPassword
    postgresWebapiAdminPassword: postgresWebapiAdminPassword
    postgresWebapiAppPassword: postgresWebapiAppPassword
    localDebug: localDebug
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
    postgresOMOPCDMpassword: postgresOMOPCDMpassword
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
  }
  dependsOn: [
    ohdsiWebApiWebapp
  ]
}

output ohdsiWebapiUrl string = ohdsiWebApiWebapp.outputs.ohdsiWebapiUrl

resource deploymentAtlasSecurity 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployment-atlas-security'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT5M'
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
        name: 'SQL'
        value: loadTextContent('sql/atlas_security.sql')
      }
    ]
    scriptContent: '''
      #!/bin/bash
      set -o errexit
      set -o pipefail
      set -o nounset

      LOG_FILE=/mnt/azscripts/azscriptoutput/all.log
      exec >  >(tee -ia ${LOG_FILE})
      exec 2> >(tee -ia ${LOG_FILE} >&2)

      apk --update add postgresql-client
      psql -v ON_ERROR_STOP=1 -e "$OHDSI_ADMIN_CONNECTION_STRING" -c "$SQL"
    '''
  }
  dependsOn: [
    atlasDatabase
  ]
}
