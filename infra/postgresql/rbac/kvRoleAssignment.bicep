param targetResourceName string
param roleId string
param principalId string

resource targetResource 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: targetResourceName
}

resource rbacAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: targetResource
  name: guid(targetResource.id,roleId,principalId)
  properties: {
    principalId: principalId
    roleDefinitionId: roleId
    principalType: 'ServicePrincipal'
  }
}
