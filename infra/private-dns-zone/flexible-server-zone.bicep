//imports
import * as comTypes from 'br/commonRegistry:commontypes:0-latest'
import * as comFuncs from 'br/commonRegistry:commonfunctions:0-latest'
param tags comTypes.tagsObject

@description('Required. The parameter object for the virtual network. The object must contain the name and resourceGroup values.')
param vnet object

@description('Required. The prefix for the private DNS zone.')
param privateDnsZonePrefix string


@description('Optional. Date in the format yyyyMMdd-HHmmss.')
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')

var privateDnsZoneName = toLower('${privateDnsZonePrefix}.private.postgres.database.azure.com')

module privateDnsZoneModule 'br/SharedDefraRegistry:network.private-dns-zone:0.5.2' = {
  name: 'postgresql-private-dns-zone-${deploymentDate}'
  params: {
   name: privateDnsZoneName 
   tags: comFuncs.tagBuilder(privateDnsZoneName, deploymentDate, tags)
   virtualNetworkLinks: [
    {
      name: vnet.name
      virtualNetworkResourceId: resourceId(vnet.resourceGroup, 'Microsoft.Network/virtualNetworks', vnet.name)
      registrationEnabled: false
      tags: comFuncs.tagBuilder(vnet.name, deploymentDate, tags)
    }
   ]
  }
}
