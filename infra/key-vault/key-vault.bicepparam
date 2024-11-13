using './key-vault.bicep'

param location = '#{{ location }}'
param tags = {
  Tier: 'Key Vault'
  Location: '#{{ location }}'
  Environment: '#{{ environmentTag }}'
  ServiceCode: '#{{ serviceCodeTag }}'
  ServiceName: '#{{ serviceNameTag }}'
  ServiceType: '#{{ serviceTypeTag }}'
  Repo: '#{{ Build.Repository.Uri }}'
}
param name = '#{{ keyVaultName }}'
param vnetResourceGroup = '#{{ vnetResourceGroup }}'
param vnetName = '#{{ vnetName }}'
param peSubnetName = '#{{ subnetPrivateEndpoints }}'
param peArray = [
  {
    groupId: 'vault'
    staticIpAddress: '#{{ lower(peStaticIp) }}' == 'true' ? '#{{ keyvaultPeStaticIp }}' : null // this is optional and the whole line can be removed if you don't require static IP
  }
]

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
