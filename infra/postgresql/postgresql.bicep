//imports
import * as comTypes from 'br/commonRegistry:commontypes:0-latest'
import * as comFuncs from 'br/commonRegistry:commonfunctions:0-latest'
param tags comTypes.tagsObject

@description('Required. The object of the PostgreSQL Flexible Server. The object must contain name,storageSizeGB and highAvailability properties.')
param server object
param intStorageSize int = int(server.storageSizeGB)

@description('Required. The parameter object for the virtual network. The object must contain the name,skuName,resourceGroup and subnetPostgreSql values.')
param vnet object

@description('Required. The name of the AAD admin managed identity.')
param managedIdentityName string

@description('Required. The parameter object for the private Dns zone. The object must contain the name and resourceGroup values')
param privateDnsZone object

@description('Required. The diagnostic object. The object must contain diagnosticLogCategoriesToEnable and diagnosticMetricsToEnable properties.')
param diagnostics object

@description('Required. The Azure region where the resources will be deployed.')
param location string
@description('Optional. Date in the format yyyyMMdd-HHmmss.')
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')

resource virtual_network 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnet.name
  scope: resourceGroup(vnet.resourceGroup)
  resource subnet 'subnets@2023-05-01' existing = {
    name: vnet.subnetPostgreSql
  }
}

resource private_dns_zone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZone.name
  scope: resourceGroup(privateDnsZone.resourceGroup)
}

module aadAdminUserMi 'br/SharedDefraRegistry:managed-identity.user-assigned-identity:0.4.3' = {
  name: 'managed-identity-${deploymentDate}'
  params: {
    name: toLower(managedIdentityName)
    tags: comFuncs.tagBuilder(managedIdentityName, deploymentDate, tags)
  }
}

module flexibleServerDeployment 'br/SharedDefraRegistry:db-for-postgre-sql.flexible-server:0.4.4' = {
  name: 'postgre-sql-flexible-server-${deploymentDate}'
  params: {
    name: toLower(server.name)
    storageSizeGB: intStorageSize
    highAvailability: server.highAvailability
    availabilityZone: server.availabilityZone
    version:'15'
    location: location
    tags: comFuncs.tagBuilder(server.name, deploymentDate, tags)
    tier: server.tier
    skuName: server.skuName
    activeDirectoryAuth:'Enabled'
    passwordAuth: 'Disabled'
    enableDefaultTelemetry:false
    privateDnsZoneArmResourceId: private_dns_zone.id
    backupRetentionDays:14
    createMode: 'Default' 
    diagnosticLogCategoriesToEnable: diagnostics.diagnosticLogCategoriesToEnable
    diagnosticMetricsToEnable: diagnostics.diagnosticMetricsToEnable
    diagnosticSettingsName:''
    administrators: [
      {
        objectId: aadAdminUserMi.outputs.clientId
        principalName: aadAdminUserMi.outputs.name
        principalType: 'ServicePrincipal'
      }
    ]
    configurations:[]
    delegatedSubnetResourceId : virtual_network::subnet.id
    diagnosticWorkspaceId: ''
  }
}
