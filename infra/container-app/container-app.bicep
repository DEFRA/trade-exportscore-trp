// General parameters
param name string
param location string
param createdDate string = utcNow('yyyy-MM-dd')
param roleAssignments array = []
param managedEnvName string
param managedEnvResourceGroup string

// Tags
param environmentTag string
param serviceCodeTag string
param serviceNameTag string
param serviceTypeTag string

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
        image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: 'simple-hello-world-container'
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
