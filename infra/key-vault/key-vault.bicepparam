using './key-vault.bicep'

param keyVault = {
  name: '#{{ keyVaultName }}'
  sku: '#{{ keyVaultSku }}'
  privateEndpointName: '#{{ keyVaultPrivateEndpointName }}'
}

param vnet = {
  name: '#{{ vnetName }}'
  resourceGroup: '#{{ vnetResourceGroup }}'
  peSubnet: '#{{ subnetPrivateEndpoints }}'
}

param accessPolicies = [
  {
    tenantId: '#{{ tenantId }}'
    objectId: '#{{ servicePrincipalObjectId }}'
    permissions: {
      keys: [
        'get'
        'list'
        'update'
        'create'
        'import'
        'delete'
        'recover'
        'backup'
        'restore'
      ]
      secrets: [
        'get'
        'list'
        'set'
        'delete'
        'recover'
        'backup'
        'restore'
      ]
      certificates: [
        'get'
        'list'
        'update'
        'create'
        'import'
        'delete'
        'recover'
        'backup'
        'restore'
        'managecontacts'
        'manageissuers'
        'getissuers'
        'listissuers'
        'setissuers'
        'deleteissuers'
      ]
    }
  }
]

param environmentTag = '#{{ environment }}'

param serviceCodeTag = '#{{ serviceCodeTag }}'

param serviceNameTag = '#{{ serviceNameTag }}'

param serviceTypeTag = '#{{ serviceTypeTag }}'

param createdDateTag = '#{{ createdDateTag }}'
