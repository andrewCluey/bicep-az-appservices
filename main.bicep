@description('Azure region that new resources will be deployed into. Defaults to the same as the Resource group.')
param location string = resourceGroup().location

@description('Name of the environment the resources are part of')
param environment string

@description('Name that will be used to build associated artifacts')
param appName string = uniqueString(resourceGroup().id)

param appServicePlanId string

param appInsightsConnectionString string

param tags object = {}

// Variables
var webSiteName = toLower('wapp-${appName}')
var assignedTags = union(tags, standardTags)
var standardTags = {
  Application: appName
  Environment: environment
}

// Resources
resource mainWebApp 'Microsoft.Web/sites@2022-09-01' = {
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
  }
  
  // application settings for configuring a dotNet app with App Insights.
  // Future enhancement to provide settings for different app types based on conditional input.
  resource appServiceLogging 'config' = {
    name: 'appsettings'
    properties: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
      APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
      APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
      ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
      DiagnosticServices_EXTENSION_VERSION: '~3'
      InstrumentationEngine_EXTENSION_VERSION: '~1'
      SnapshotDebugger_EXTENSION_VERSION: '~1'
      XDT_MicrosoftApplicationInsights_BaseExten: '~1'
      XDT_MicrosoftApplicationInsights_Java: '1'
      XDT_MicrosoftApplicationInsights_Mode: 'recommended'
      XDT_MicrosoftApplicationInsights_NodeJS: '1'
      XDT_MicrosoftApplicationInsights_Preempt_Sdk: 'disabled'
    }
    dependsOn: [
      appServiceSiteExtension
    ]
  }
}
