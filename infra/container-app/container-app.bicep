//imports
import * as comTypes from 'br/commonRegistry:commontypes:0-latest'
import * as comFuncs from 'br/commonRegistry:commonfunctions:0-latest'

// General parameters
param name string
param tags comTypes.tagsObject
param location string
param createdDate string = utcNow('yyyy-MM-dd')
param roleAssignments array = []
param managedEnvName string
param managedEnvResourceGroup string
param containerRegistryName string
param miName string
param serviceBusNamespace string

// Tags
param environmentTag string
param serviceCodeTag string
param serviceNameTag string
param serviceTypeTag string

var containerRegistryNameLower = toLower(containerRegistryName)

// Existing Managed Environment (REQUIRED to deploy)
resource managedEnvExisting 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: managedEnvName
  scope: resourceGroup(managedEnvResourceGroup)
}

module managedId 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: '${miName}-${createdDate}'
  params: {
    name: '${miName}-${name}'
    location: location
    tags: comFuncs.tagBuilder(miName, createdDate, tags)
  }
}

// Module definition
module containerApp 'br/public:avm/res/app/container-app:0.11.0' = {
  name: name
  params: {
    name: name
    location: location
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
    roleAssignments: roleAssignments
    containers: [
      {
        image: '${containerRegistryNameLower}.azurecr.io/trade-exportscore-trp:latest'
        name: 'trade-exportscore-trp'
        resources: {
          cpu: '0.25'
          memory: '0.5Gi'
        }
      }
    ]
    environmentResourceId: managedEnvExisting.id
    managedIdentities: {
      userAssignedResourceIds: [
        managedId.outputs.resourceId
      ]
    }
  }
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: serviceBusNamespace
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource serviceBusRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('090c5cfd-751d-490a-894a-3ce6f1109419', serviceBus.id)
  scope: serviceBus
  properties: {
    principalId: managedId.outputs.resourceId
    principalType: 'ServicePrincipal'
    roleDefinitionId: '090c5cfd-751d-490a-894a-3ce6f1109419' // service bus owner
  }
}

resource registryRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('7f951dda-4ed3-4680-a7ca-43fe172d538d', containerRegistry.id)
  scope: containerRegistry
  properties: {
    principalId: managedId.outputs.resourceId
    principalType: 'ServicePrincipal'
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // acr pull
  }
}

