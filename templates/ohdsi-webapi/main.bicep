targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The tenant id of the subscription')
param tenantId string = subscription().tenantId

@description('The name of the ohdsi webapi webapp')
param odhsiWebApiName string = 'ohdsi-webapi'
@description('Unique string to be used as a suffix for all resources')
param suffix string = uniqueString(utcNow())
@description('The name of the branch to use for downloading sql scripts')
param branchName string = 'v2'
@description('The url of the container where the cdm is stored')
param cdmContainerUrl string
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

@description('Creates OMOP CDM database')
module omopCDM 'omop_cdm.bicep' = {
  name: 'omopCDM'
  params: {
    branchName: branchName
    location: location
    keyVaultName: keyvault.outputs.keyVaultName
    cdmContainerUrl: cdmContainerUrl
    cdmSasToken: cdmSasToken
    postgresAtlasDatabaseName: atlasDatabase.outputs.postgresWebApiDatabaseName
    postgresOMOPCDMDatabaseName: postgresOMOPCDMDatabaseName
    postgresAdminPassword: postgresAdminPassword
    postgresWebapiAdminPassword: postgresWebapiAdminPassword
    postgresOMOPCDMpassword: postgresOMOPCDMpassword
    postgresServerName: atlasDatabase.outputs.postgresServerName
  }
}
