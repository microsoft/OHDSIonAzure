param location string
param odhsiWebApiName string
param tenantId string
param suffix string
@secure()
param databaseAdminPassword string
@secure()
param databaseWebapiAdminPassword string
@secure()
param databaseWebapiAppPassword string
@secure()
param jdbcConnectionStringWebapiAdmin string

// User Assigned Identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'kv-identity-${odhsiWebApiName}-${suffix}'
  location: location
}

// KeyVault and storing PostgreSql secrets
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kv-${suffix}'
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

resource databaseAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'database-admin-password'
  parent: keyVault
  properties: {
    value: databaseAdminPassword
  }
}

resource databaseWebapiAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'ohdsi-admin-password'
  parent: keyVault
  properties: {
    value: databaseWebapiAdminPassword
  }
}

resource databaseWebapiAppSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'ohdsi-app-password'
  parent: keyVault
  properties: {
    value: databaseWebapiAppPassword
  }
}

resource jdbcConnectionStringWebapiAdminSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'jdbc-connectionstring'
  parent: keyVault
  properties: {
    value: jdbcConnectionStringWebapiAdmin
  }
}

output keyVaultName string = keyVault.name
output keyVaultResourceId string = keyVault.id
output userAssignedIdentityId string = identity.id
output databaseAdminSecretName string = databaseAdminSecret.name
output databaseWebapiAdminSecretName string = databaseWebapiAdminSecret.name
output databaseWebapiAppSecretName string = databaseWebapiAppSecret.name
output jdbcConnectionStringWebapiAdminSecretName string = jdbcConnectionStringWebapiAdminSecret.name
