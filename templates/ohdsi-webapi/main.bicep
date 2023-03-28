targetScope = 'resourceGroup'

param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param utc string = utcNow()
param odhsiWebApiName string = 'ohdsi-webapi'
param suffix string = uniqueString(utc)
param branchName string = 'v2'

@secure()
param postgresAdminPassword string = uniqueString(newGuid())
@secure()
param postgresWebapiAdminPassword string = uniqueString(newGuid())
@secure()
param postgresWebapiAppPassword string = uniqueString(newGuid())

@description('Creates the database server, users and groups required for ohdsi webapi')
module atlasDatabase 'atlas_database.bicep' = {
  name: 'atlasDatabase'
  params: {
    location: location
    suffix: suffix
    branchName: branchName
    odhsiWebApiName: odhsiWebApiName
    postgresAdminPassword: postgresAdminPassword
    postgresWebapiAdminPassword: postgresWebapiAdminPassword
    postgresWebapiAppPassword: postgresWebapiAppPassword
  }
}

@description('Creates the app service plan')
module appServicePlan 'app_plan.bicep' = {
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
    postgresAdminPassword: postgresAdminPassword
    postgresWebapiAdminPassword: postgresWebapiAdminPassword
    postgresWebapiAppPassword: postgresWebapiAppPassword
    jdbcConnectionStringWebapiAdmin: 'jdbc:postgresql://${atlasDatabase.outputs.postgresServerFullyQualifiedDomainName}:5432/${atlasDatabase.outputs.postgresWebApiDatabaseName}?user=${atlasDatabase.outputs.postgresWebapiAdminUsername}&password=${postgresWebapiAdminPassword}&sslmode=require'
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
    postgresWebapiAdminSecret: keyvault.outputs.postgresWebapiAdminSecretName
    postgresWebapiAppSecret: keyvault.outputs.postgresWebapiAppSecretName
    postgresWebapiAdminUsername: atlasDatabase.outputs.postgresWebapiAdminUsername
    postgresWebapiAppUsername: atlasDatabase.outputs.postgresWebapiAppUsername
    postgresWebApiSchemaName: atlasDatabase.outputs.postgresSchemaName
  }
  dependsOn: [
    appServicePlan
    keyvault
    atlasDatabase
  ]
}
