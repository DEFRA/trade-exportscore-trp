param keyVault object
param vnet object
param location string = resourceGroup().location
param databaseAdmin string

param accessPolicies array = []
param environmentTag string
param serviceCodeTag string
param serviceNameTag string
param serviceTypeTag string
param createdDateTag string

resource network 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: vnet.name
  resource privateEndpointsSubnet 'subnets' existing = {
    name: vnet.peSubnet
  }
}

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
      subnetResourceId: network::privateEndpointsSubnet.id
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
    secrets: [
      {
        name: databaseAdmin
        value: uniqueString(resourceGroup().id)
      }
    ]
  }
}
