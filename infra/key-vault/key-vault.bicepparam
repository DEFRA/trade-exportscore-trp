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
param name = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_keyvault }}#{{ subscriptionNumber }}#{{ regionNumber }}02'
param vnetResourceGroup = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param vnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param peSubnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
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
