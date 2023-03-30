param location string
param suffix string
param appServicePlanId string
param ohdsiWebApiUrl string


var dockerRegistryServer = 'https://index.docker.io/v1'
var dockerImageName = 'ohdsi/atlas'
var dockerImageTag = '2.13.0'
var shareName = 'atlas'
var mountPath = '/etc/atlas'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'ohdsisa${suffix}'
  location: location
  kind:'StorageV2'
  sku:{
    name:'Standard_LRS'
  }

  resource fileService 'fileServices' = {
    name: 'default'

    resource share 'shares' = {
      name: shareName
    }
  }
}

resource saManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = { 
  name: 'sa-upload-mount-identity' 
  location: location 
} 


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.id)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb') // Storage File Data SMB Share Contributor
    principalId: saManagedIdentity.properties.principalId
  }
}

resource deploymentAtlasUiConfigScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployment-atlas-ui-scripts-config-file'
  location: location
  kind: 'AzureCLI'
  identity: { 
    type: 'UserAssigned' 
    userAssignedIdentities: { 
        '${saManagedIdentity.id}': {} 
    } 
} 
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storageAccount.name
      }
      {
        name: 'OHDSI_WEBAPI_URL'
        value: ohdsiWebApiUrl
      }
      {
        name: 'CONTENT'
        value: loadTextContent('scripts/config-local.js')
      }
      {
        name: 'SHARE_NAME'
        value: shareName
      }
    ]
    scriptContent: '''
     apk --update add gettext
     echo "$CONTENT" > config-local-temp.js
     envsubst < config-local-temp.js > config-local.js
     az storage file upload --source config-local.js -s $SHARE_NAME
     '''
  }
}

resource uiWebApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'atlas-ui-${suffix}'
  location: location
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlanId
    siteConfig: {
      azureStorageAccounts: {
        '${shareName}': {
          type: 'AzureFiles'
          shareName: shareName
          mountPath: mountPath
          accountName: storageAccount.name      
          accessKey: ''
        }
      }
      linuxFxVersion: 'DOCKER|${dockerImageName}:${dockerImageTag}'
      appSettings: [
      {
        name: 'DOCKER_REGISTRY_SERVER_URL'
        value: dockerRegistryServer
      }
      {
        name: 'WEBSITE_HEALTHCHECK_MAXPINGFAILURES'
        value: '10'
      }
      {
        name: 'WEBAPI_URL'
        value: ohdsiWebApiUrl
      }
      {
        name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
        value: '30'
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
      '${saManagedIdentity.id}': {}
    }
  }
  dependsOn: [
    deploymentAtlasUiConfigScript
  ]
}


