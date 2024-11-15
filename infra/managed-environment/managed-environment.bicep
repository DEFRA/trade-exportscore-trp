param containerAppEnvName string
param location string
param logAnalyticsName string
param vnetName string
param infrastructureSubnetName string
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

var infrastructureSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, infrastructureSubnetName)

module managedEnvironment 'br/public:avm/res/app/managed-environment:0.8.1' = {
  name: '${containerAppEnvName}-${date}'
  params: {
    name: containerAppEnvName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.id
    internal: true
    zoneRedundant: false
    infrastructureSubnetId: infrastructureSubnetId
    infrastructureResourceGroupName: infraResourceGroup
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
