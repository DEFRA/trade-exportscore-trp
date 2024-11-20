// General parameters
param name string
param location string
param createdDate string = utcNow('yyyy-MM-dd')
param roleAssignments array = []
param managedEnvName string
param managedEnvResourceGroup string
param containerRegistryName string

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
      systemAssigned: true
    }
  }
}
