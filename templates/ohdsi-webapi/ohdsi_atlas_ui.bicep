param location string
param suffix string
param appServicePlanId string
param ohdsiWebApiUrl string


var dockerRegistryServer = 'https://index.docker.io/v1'
var dockerImageName = 'ohdsi/atlas'
var dockerImageTag = 'latest'
var shareName = 'atlas'
var mountPath = '/etc/atlas'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'atlasui${suffix}'
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

resource deploymentAtlasUiConfigScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployment-atlas-ui-scripts-config-file '
  location: location
  kind: 'AzureCLI'
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
        name: 'AZURE_STORAGE_KEY'
        secureValue: storageAccount.listKeys().keys[0].value
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
}

resource storageSetting 'Microsoft.Web/sites/config@2021-01-15' = {
  name: 'azurestorageaccounts'
  parent: uiWebApp
  properties: {
    '${shareName}': {
      type: 'AzureFiles'
      shareName: shareName
      mountPath: mountPath
      accountName: storageAccount.name      
      accessKey: storageAccount.listKeys().keys[0].value
    }
  }
  dependsOn: [
    deploymentAtlasUiConfigScript
  ]
}
