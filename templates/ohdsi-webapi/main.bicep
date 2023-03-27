targetScope = 'resourceGroup'

param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param utc string = utcNow()
param odhsiWebApiName string = 'ohdsi-webapi'
param suffix string = uniqueString(utc)
param branchName string = 'v2'
param cdmContainerUrl string
param cdmSasToken string
param pgCDMDatabaseName string

@secure()
param postgresAdminPassword string
@secure()
param postgresWebapiAdminPassword string
@secure()
param postgresWebapiAppPassword string
@secure()
param pgCDMpassword string

@description('Creates the database server, users and groups required for ohdsi webapi')
module atlasDatabase 'atlas_database.bicep' = {
  name: 'atlasDatabase'
  params: {
    location: location
    suffix: suffix
    odhsiWebApiName: odhsiWebApiName
    postgresAdminPassword: postgresAdminPassword
    postgresWebapiAdminPassword: postgresWebapiAdminPassword
    postgresWebapiAppPassword: postgresWebapiAppPassword
    branchName: branchName
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

@description('Creates OMOP CDM database')
module omopCDM 'omop_cdm.bicep' = {
  name: 'omopCDM'
  params: {
    branchName: branchName
    location: location
    keyVaultName: keyvault.outputs.keyVaultName
    cdmContainerUrl: cdmContainerUrl
    cdmSasToken: cdmSasToken
    pgAtlasDatabaseName: atlasDatabase.outputs.postgresWebApiDatabaseName
    pgCDMDatabaseName: pgCDMDatabaseName
    pgAdminPassword: postgresAdminPassword
    pgWebapiAdminPassword: postgresWebapiAdminPassword
    pgCDMpassword: pgCDMpassword
    pgServerName: atlasDatabase.outputs.postgresServerName

  }
}
