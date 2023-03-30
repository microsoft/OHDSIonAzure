param location string
param odhsiWebApiName string
param suffix string

// Create an App Service plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name:  'appServicePlan-${odhsiWebApiName}-${suffix}'
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

output appServicePlanId string = appServicePlan.id
