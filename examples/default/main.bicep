param location string = resourceGroup().location
param appServicePlanName string
param tags object = {}
param environment string = 'dev'

@description('Which Pricing tier our App Service Plan to')
param skuName string = 'S1'

@description('How many instances of our app service will be scaled out to')
param skuCapacity int = 1


// Deploy Module
module appservice '../../main.bicep' = {
  name: 'app-dev-asc-001'
  params: {
    location: location
    environment: environment
    appName: 'ascdevapp'
    appServicePlanId: appServicePlan.id
    appInsightsConnectionString: appInsights.properties.ConnectionString
  }
}


// Required resources for demo.
resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  tags: tags
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'law${appServicePlanName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-app-dev-asc-001'
  location: location
  kind: 'string'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
