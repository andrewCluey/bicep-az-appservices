param location string = resourceGroup().location
param appServicePlanName string
param tags object
param environment string

@description('Which Pricing tier our App Service Plan to')
param skuName string = 'S1'

@description('How many instances of our app service will be scaled out to')
param skuCapacity int = 1


module appservice '../../main.bicep' = {
  name: 'appServiceDeploy'
  params: {
    location: location
    environment: environment
    appName: 'exampleapp1'
    appServicePlanId: appServicePlan.id
    logAnalyticsWorkspaceId: 'kjhkjhk'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  tags: tags
}
