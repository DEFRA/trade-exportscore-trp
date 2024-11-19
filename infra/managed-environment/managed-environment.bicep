param containerAppEnvName string
param location string
param logAnalyticsName string
param vnetName string
param vnetResourceGroup string
param peSubnetName string
param infraResourceGroup string

param environmentTag string
param serviceCodeTag string
param serviceNameTag string
param serviceTypeTag string
param date string = utcNow('yyyyMMdd')

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsName
  scope: resourceGroup()
}

//Existing Resource Data Sources
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  scope: resourceGroup(vnetResourceGroup)
  name: vnetName
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: peSubnetName
}

module managedEnvironment 'br/SharedDefraRegistry:app.managed-environment:0.4.2' = {
  name: '${containerAppEnvName}-${date}'
  params: {
    name: containerAppEnvName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.id
    internal: true
    zoneRedundant: false
    infrastructureSubnetId: peSubnet.id
    enableDefaultTelemetry: true
    tags: {
      Name: containerAppEnvName
      Tier: 'Shared'
      Location: location
      Environment: environmentTag
      ServiceCode: serviceCodeTag
      ServiceName: serviceNameTag
      ServiceType: serviceTypeTag
      CreatedDate: date
    }
  }
}
