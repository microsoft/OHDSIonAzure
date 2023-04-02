param location string
param odhsiWebApiName string
param suffix string
@secure()
param postgresAdminPassword string
@secure()
param postgresWebapiAdminPassword string
@secure()
param postgresWebapiAppPassword string
@secure()
param jdbcConnectionStringWebapiAdmin string

var tenantId = subscription().tenantId

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
    accessPolicies: [
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

output keyVaultName string = keyVault.name
output keyVaultResourceId string = keyVault.id
output userAssignedIdentityId string = identity.id
output postgresAdminSecretName string = postgresAdminSecret.name
output postgresWebapiAdminSecretName string = postgresWebapiAdminSecret.name
output postgresWebapiAppSecretName string = postgresWebapiAppSecret.name
output jdbcConnectionStringWebapiAdminSecretName string = jdbcConnectionStringWebapiAdminSecret.name
