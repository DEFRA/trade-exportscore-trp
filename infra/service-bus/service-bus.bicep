// General parameters
param name string
param location string
param createdDate string = utcNow('yyyy-MM-dd')
param roleAssignments array = []
param skuName string

// Tags
param environmentTag string
param serviceCodeTag string
param serviceNameTag string
param serviceTypeTag string

// The following params are for the Private Endpoint
param vnetName string
param subnetName string
param vnetRg string

// Existing networking resources
resource vNet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRg)        // Required as vNet is in another RG
}

resource subNet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  name: subnetName
  parent: vNet
}

// Module definition
module serviceBus 'br/SharedDefraRegistry:service-bus.namespace:0.5.3' = {
  name: name
  params: {
    name: name
    location: location
    roleAssignments: roleAssignments
    tags: {
      Name: name
      Location: location
      Environment: environmentTag
      ServiceCode: serviceCodeTag
      ServiceName: serviceNameTag
      ServiceType: serviceTypeTag
      CreatedDate: createdDate
      Tier: 'Shared'
    }
    authorizationRules: [
      {
        name: 'RootManageSharedAccessKey'
        rights: [
          'Listen'
          'Manage'
          'Send'
        ]
      }
      {
        name: 'AnotherKey'
        rights: [
          'Listen'
          'Send'
        ]
      }
    ]
    enableDefaultTelemetry: true
    queues: [
      {
        authorizationRules: [
          {
            name: 'RootManageSharedAccessKeyQueue'
            rights: [
              'Listen'
              'Manage'
              'Send'
            ]
          }
          {
            name: 'AnotherKeyQueue'
            rights: [
              'Listen'
              'Send'
            ]
          }
        ]
        name: '${name}-sbncomq001'
        roleAssignments: roleAssignments // Reused parent resource roleAssignements for testing, can be split for finer control
      }
    ]
    skuName: skuName
  }
}

// Private Endpoint definition
module privateEndpoint 'br/SharedDefraRegistry:network.private-endpoint:0.5.2' = {
  name: '${name}-PE'
  params: {
    name: '${name}-PE'
    location: location
    tags: {
      Name: '${name}-PE'
      Location: location
      Environment: environmentTag
      ServiceCode: serviceCodeTag
      ServiceName: serviceNameTag
      ServiceType: serviceTypeTag
      CreatedDate: createdDate
      Tier: 'Network'
    }
    roleAssignments: roleAssignments
    groupIds: ['namespace']
    serviceResourceId: serviceBus.outputs.resourceId
    subnetResourceId: subNet.id
  }
}
