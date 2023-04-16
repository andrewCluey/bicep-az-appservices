@description('Azure region that new resources will be deployed into. Defaults to the same as the Resource group.')
param location string = resourceGroup().location

@description('Name of the environment the resources are part of')
param environment string

@description('Name that will be used to build associated artifacts')
param appName string = uniqueString(resourceGroup().id)

param appServicePlanId string

param logAnalyticsWorkspaceId string

param tags object = {}


// Variables
var webSiteName = toLower('wapp-${appName}')
var appInsightName = toLower('appi-${appName}')
var assignedTags = union(tags, standardTags)
var standardTags = {
  Application: appName
  Environment: environment
}


// Resources
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: webSiteName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: assignedTags
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
    }
  }

  resource appServiceSiteExtension 'siteExtensions' = {
    name: 'Microsoft.ApplicationInsights.AzureWebSites'
    dependsOn: [
      appInsights
    ]
  }
  
  resource appServiceLogging 'config' = {
    name: 'appsettings'
    properties: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
    }
    dependsOn: [
      appServiceSiteExtension
    ]
  }
}


resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: 'string'
  tags: assignedTags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}


// resource appServiceSiteExtension 'Microsoft.Web/sites/siteextensions@2020-06-01' = {
//   parent: appService
//   name: 'Microsoft.ApplicationInsights.AzureWebSites'
//   dependsOn: [
//     appInsights
//   ]
// }

