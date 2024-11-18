// General parameters
param name string
param location string
param env string
param project string
param createdDate string = utcNow('yyyy-MM-dd')
param publicNetworkAccess string
param acrAdminUserEnabled bool = false  // Non-string parameters don't seem to work when they're declared in the vars file and implemented via the JSON params file
param acrSku string
param azureADAuthenticationAsArmPolicyStatus string
param exportPolicyStatus string
param softDeletePolicyDays int = 7
param softDeletePolicyStatus string
param trustPolicyStatus string
param containerAppMiName string

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

resource containerAppMi 'Microsoft.ManagedIdentity/identities@2023-07-31-preview' existing = {
  name: containerAppMiName
}

// Module definition
module registry 'br/public:avm/res/container-registry/registry:0.6.0' = {
  name: '${name}-${createdDate}'
  params: {
    name: name
    location: location
    publicNetworkAccess: publicNetworkAccess
    acrAdminUserEnabled: acrAdminUserEnabled
    acrSku: acrSku
    roleAssignments: [
      {
        principalId: containerAppMi.id
        roleDefinitionIdOrName: 'AcrPull'
      }
    ]
    azureADAuthenticationAsArmPolicyStatus: azureADAuthenticationAsArmPolicyStatus
    enableTelemetry: true
    exportPolicyStatus: exportPolicyStatus
    quarantinePolicyStatus: 'enabled'
    tags: {
      Name: name
      Location: location
      Environment: environmentTag
      ServiceCode: serviceCodeTag
      ServiceName: serviceNameTag
      ServiceType: serviceTypeTag
      CreatedDate: createdDate
      Tier: 'Application'
    }
    softDeletePolicyDays: softDeletePolicyDays
    softDeletePolicyStatus: softDeletePolicyStatus
    managedIdentities: {
      systemAssigned: true
    }
    trustPolicyStatus: trustPolicyStatus
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
      Environment: env
      ServiceCode: project
      CreatedDate: createdDate
    }
    groupIds: ['registry']
    serviceResourceId: registry.outputs.resourceId
    subnetResourceId: subNet.id
  }
}

