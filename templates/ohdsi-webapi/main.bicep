targetScope = 'resourceGroup'

param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param utc string = utcNow()
param odhsiWebApiName string = 'ohdsi-webapi'
param suffix string = uniqueString(utc)
@secure()
param databaseAdminPassword string
@secure()
param databaseWebapiAdminPassword string
@secure()
param databaseWebapiAppPassword string

@description('Creates the databases server, users and groups required for ohdsi webapi')
module atlasDatabase 'atlas_database.bicep' = {
  name: 'atlasDatabase'
  params: {
    location: location
    suffix: suffix
    odhsiWebApiName: odhsiWebApiName
    databaseAdminPassword: databaseAdminPassword
    databaseWebapiAdminPassword: databaseWebapiAdminPassword
    databaseWebapiAppPassword: databaseWebapiAppPassword
  }
}

@description('Creates the app service plan')
module appServicePlan 'appplan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    suffix: suffix
    odhsiWebApiName: odhsiWebApiName
  }
}

@description('Creates the key vault')
module keyvault 'keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    suffix: suffix
    tenantId: tenantId
    odhsiWebApiName: odhsiWebApiName
    databaseAdminPassword: databaseAdminPassword
    databaseWebapiAdminPassword: databaseWebapiAdminPassword
    databaseWebapiAppPassword: databaseWebapiAppPassword
    jdbcConnectionStringWebapiAdmin: 'jdbc:databaseql://${atlasDatabase.outputs.databaseServerFullyQualifiedDomainName}:5432/${atlasDatabase.outputs.databaseWebApiDatabaseName}?user=${atlasDatabase.outputs.databaseWebapiAdminUsername}&password=${databaseWebapiAdminPassword}&sslmode=require'
  }
  dependsOn: [
    atlasDatabase
  ]
}

@description('Creates the ohdsi webapi')
module ohdsiWebApiWebapp 'ohdsi-webapi.bicep' = {
  name: 'ohdsiWebApiWebapp'
  params: {
    location: location
    suffix: suffix
    odhsiWebApiName: odhsiWebApiName
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    keyVaultName: keyvault.outputs.keyVaultName
    userAssignedIdentityId: keyvault.outputs.userAssignedIdentityId
    jdbcConnectionStringWebapiAdminSecret: keyvault.outputs.jdbcConnectionStringWebapiAdminSecretName
    databaseWebapiAdminSecret: keyvault.outputs.databaseWebapiAdminSecretName
    databaseWebapiAppSecret: keyvault.outputs.databaseWebapiAppSecretName
    databaseWebapiAdminUsername: atlasDatabase.outputs.databaseWebapiAdminUsername
    databaseWebapiAppUsername: atlasDatabase.outputs.databaseWebapiAppUsername
    databaseWebApiSchemaName: atlasDatabase.outputs.databaseSchemaName
  }
  dependsOn: [
    appServicePlan
    keyvault
    atlasDatabase
  ]
}
