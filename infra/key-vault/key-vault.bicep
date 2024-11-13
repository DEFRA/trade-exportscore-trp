//imports
import * as comTypes from 'br/commonRegistry:commontypes:0-latest'
import * as comFuncs from 'br/commonRegistry:commonfunctions:0-latest'

//Generic Params
param location string
param tags comTypes.tagsObject
param date string = utcNow('yyyyMMdd')
param accessPolicies array

//Keyvault Params
param name string

// Private Endpoint params
param vnetResourceGroup string
param vnetName string
param peSubnetName string
param peArray comTypes.privateEndpointArrayType

//Existing Resource Data Sources
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  scope: resourceGroup(vnetResourceGroup)
  name: vnetName
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: peSubnetName
}

// Resources

module vault 'br/public:avm/res/key-vault/vault:0.10.2' = {
  name: name
  params: {
    name: name
    location: location
    tags: comFuncs.tagBuilder(name, date, tags)
    sku: 'standard'
    privateEndpoints: comFuncs.buildPrivateEndpointArray(peArray, name, peSubnet.id)
    enableVaultForTemplateDeployment: true
    publicNetworkAccess: 'Disabled'
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    enableRbacAuthorization: false
    accessPolicies: accessPolicies
  }
}
