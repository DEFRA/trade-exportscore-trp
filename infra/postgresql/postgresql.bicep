//imports
import * as comTypes from 'br/commonRegistry:commontypes:0-latest'
import * as comFuncs from 'br/commonRegistry:commonfunctions:0-latest'

//Generic Params
param location string
param tags comTypes.tagsObject
param date string = utcNow('yyyyMMdd')

//Managed ID params
param miName string

//database Params
param server object
param adminLoginKeyvaultName string
param adminLoginKevaultSecretName string
param cmkName string

// param cmkVersion string
param databases {
  name: string
}[]

// Private Endpoint params
param vnetResourceGroup string
param vnetName string
param peSubnetName string
param peArray comTypes.privateEndpointArrayType

// Log Analytics params
param laWorkspaceName string

//Existing Resource Data Sources
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  scope: resourceGroup(vnetResourceGroup)
  name: vnetName
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: peSubnetName
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: adminLoginKeyvaultName
}

resource key 'Microsoft.KeyVault/vaults/keys@2023-07-01' existing = {
  parent: keyvault
  name: cmkName
}

resource cryptoUser 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
}

module managedId 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: '${miName}-${date}'
  params: {
    name: miName
    location: location
    tags: comFuncs.tagBuilder(miName, date, tags)
  }
}

module kvRoleAssignment './rbac/kvRoleAssignment.bicep' = {
  name: '${miName}-CryptoUser-${date}'
  params: {
    principalId: managedId.outputs.principalId
    roleId: cryptoUser.id
    targetResourceName: keyvault.name
  }
}

module database 'br/avm:db-for-postgre-sql/flexible-server:0.5.0' = {
  name: '${server.name}-${date}'
  dependsOn: [
    kvRoleAssignment
  ]
  params: {
    name: server.name
    tags: comFuncs.tagBuilder(server.name, date, tags)
    location: location
    firewallRules: [
      {
        name: 'WokingAllow'
        startIpAddress: '148.252.0.0'
        endIpAddress: '148.253.255.255'
      }
    ]
    skuName: server.skuName
    tier: server.tier
    storageSizeGB: server.storageSizeGB
    highAvailability: server.highAvailability
    availabilityZone: server.availabilityZone
    version:'15'
    backupRetentionDays:14
    createMode: 'Default' 
    administratorLogin: 'adminuser'
    administratorLoginPassword: keyvault.getSecret(adminLoginKevaultSecretName)
    privateEndpoints: comFuncs.buildPrivateEndpointArray(peArray, server.name, peSubnet.id)
    administrators: [
      {
        objectId: managedId.outputs.clientId
        principalName: managedId.outputs.name
        principalType: 'ServicePrincipal'
      }
    ]
    managedIdentities: {
      userAssignedResourceIds: [
        managedId.outputs.resourceId
      ]
    }
    customerManagedKey: {
      keyName: '${keyvault.name}_${key.name}_${last(split(key.properties.keyUriWithVersion,'/'))}'
      keyVaultResourceId: keyvault.id
      userAssignedIdentityResourceId: managedId.outputs.resourceId
    }
    databases: [
      for db in databases: {
        name: db.name
      }
    ]
    diagnosticSettings: [{
      workspaceResourceId: resourceId('Microsoft.OperationalInsights/workspaces@2023-09-01', laWorkspaceName)
    }]
  }
}
