//imports
import * as comTypes from 'br/commonRegistry:commontypes:0-latest'
import * as comFuncs from 'br/commonRegistry:commonfunctions:0-latest'

//Generic Params
param location string
param tags comTypes.tagsObject
param date string = utcNow('yyyyMMdd')

//vnet Params
param vnetObject comTypes.vnetObject

//NSG params
param nsgPrefix string
param defaultNsgRules comTypes.nsgRulesArrayType
param additionalNsgRules comTypes.nsgRulesArrayType

//routetable params
param routeTableName string

//variables
var nsgRules = union(defaultNsgRules, additionalNsgRules)
var subnets = [
  for (sub, i) in vnetObject.subnetsArray: {
    name: sub.name
    addressPrefix: sub.?addressPrefix
    addressPrefixes: sub.?addressPrefixes
    networkSecurityGroupResourceId: nsg[i].id
    privateEndpointNetworkPolicies: !empty(sub.?privateEndpointNetworkPolicies) && sub.?privateEndpointNetworkPolicies == 'Enabled'
      ? 'Enabled'
      : 'Disabled'
    privateLinkServiceNetworkPolicies: !empty(sub.?privateLinkServiceNetworkPolicies) && sub.?privateLinkServiceNetworkPolicies == 'Enabled'
      ? 'Enabled'
      : 'Disabled'
    delegations: !empty(sub.?delegations)
      ? map(sub.?delegations!, delegation => {
          name: delegation
          type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
          properties: { serviceName: delegation }
        })
      : null
    routeTableResourceId: routeTable.id
    serviceEndpoints: sub.?serviceEndpoints
  }
]

//module definitions
module network 'br/public:avm/res/network/virtual-network:0.1.8' = {
  name: '${vnetObject.name}-${date}'
  params: {
    name: vnetObject.name
    tags: comFuncs.tagBuilder(vnetObject.name, date, tags)
    location: location
    addressPrefixes: vnetObject.addressPrefixes
    subnets: subnets
    ddosProtectionPlanResourceId: vnetObject.?ddosProtectionPlanId
    dnsServers: comFuncs.getDnsServerArrayDefra()[?location] ?? ['10.178.0.4', '10.178.0.5']
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-06-01' = [
  for (subnet, i) in vnetObject.subnetsArray: {
    name: comFuncs.nameBuilder(nsgPrefix, i + 1)
    location: location
    tags: comFuncs.tagBuilder(comFuncs.nameBuilder(nsgPrefix, i + 1), date, tags)
    properties: {
      securityRules: nsgRules
    }
  }
]

resource routeTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: routeTableName
  location: location
  tags: comFuncs.tagBuilder(routeTableName, date, tags)
  properties: {
    disableBgpRoutePropagation: true
    routes: comFuncs.getAzureRouteTableDefaultEntries(location)
  }
}
