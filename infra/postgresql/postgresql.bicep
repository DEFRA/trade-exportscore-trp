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

@description('Required. The Azure region where the resources will be deployed.')
param location string
@description('Optional. Date in the format yyyyMMdd-HHmmss.')
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')

param servicePrincipalObjectId string
param servicePrincipalName string
param peArray comTypes.privateEndpointArrayType
param laWorkspaceName string

param databases {
  name: string
}[]

resource virtual_network 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnet.name
  scope: resourceGroup(vnet.resourceGroup)
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: virtual_network
  name: vnet.subnetPostgreSql
}

resource la 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: laWorkspaceName
}

module aadAdminUserMi 'br/SharedDefraRegistry:managed-identity.user-assigned-identity:0.4.3' = {
  name: 'managed-identity-${deploymentDate}'
  params: {
    name: toLower(managedIdentityName)
    tags: comFuncs.tagBuilder(managedIdentityName, deploymentDate, tags)
  }
}

module flexibleServerDeployment 'br/public:avm/res/db-for-postgre-sql/flexible-server:0.6.0' = {
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
    enableTelemetry: true
    privateEndpoints: comFuncs.buildPrivateEndpointArray(peArray, server.name, peSubnet.id)
    backupRetentionDays:14
    createMode: 'Default' 
    administrators: [
      {
        objectId: aadAdminUserMi.outputs.clientId
        principalName: aadAdminUserMi.outputs.name
        principalType: 'ServicePrincipal'
      }
      {
        objectId: servicePrincipalObjectId
        principalName: servicePrincipalName
        principalType: 'ServicePrincipal'
      }
    ]
    diagnosticSettings: [{
      workspaceResourceId: la.id
    }]
    managedIdentities: {
      userAssignedResourceIds: [
        aadAdminUserMi.outputs.resourceId
      ]
    }
    databases: [
      for db in databases: {
        name: db.name
      }
    ]
  }
}
