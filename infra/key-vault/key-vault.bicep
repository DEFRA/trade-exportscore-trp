param keyVault object
param vnet object
param location string = resourceGroup().location

param accessPolicies array = []
param environmentTag string
param serviceCodeTag string
param serviceNameTag string
param serviceTypeTag string
param createdDateTag string

module vault 'br/public:avm/res/key-vault/vault:0.9.0' = {
  name: 'vaultDeployment'
  params: {
    name: keyVault.name
    tags: {
      Name: keyVault.name
      Tier: 'Key Vault'
      Location: location
      Environment: environmentTag
      ServiceCode: serviceCodeTag
      ServiceName: serviceNameTag
      ServiceType: serviceTypeTag
      CreatedDate: createdDateTag
    }
    sku: keyVault.sku
    location: location
    accessPolicies: accessPolicies
    privateEndpoints: [{
      name: keyVault.privateEndpointName
      service: 'vault'
      subnetResourceId: resourceId(vnet.resourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vnet.name, vnet.subnetPrivateEndpoints)
      privateLinkServiceConnectionName: keyVault.privateEndpointName
      tags: {
        Name: keyVault.privateEndpointName
        Tier: 'NETWORK'
        Location: location
        Environment: environmentTag
        ServiceCode: serviceCodeTag
        ServiceName: serviceNameTag
        ServiceType: serviceTypeTag
        CreatedDate: createdDateTag
      }
    }]
  }
}
