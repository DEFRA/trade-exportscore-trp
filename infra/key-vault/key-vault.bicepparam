using './key-vault.bicep'

param keyVaultName = '#{{ keyVaultName }}'

param vaultSku = '#{{ vaultSku }}'

param accessPolicies = [
  {
    tenantId: '#{{ tenantId }}'
    objectId: '#{{ cscKeyvaultAdminsObjectId }}'
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
        'decrypt'
        'encrypt'
        'unwrapKey'
        'wrapKey'
        'verify'
        'sign'
        'purge'
      ]
      secrets: [
        'get'
        'list'
        'set'
        'delete'
        'recover'
        'backup'
        'restore'
        'purge'
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
        'purge'
      ]
    }
  }
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

param enabledForDeployment = false

param enabledForTemplateDeployment = true

param enabledForDiskEncryption = false

param environmentTag = '#{{ secEnvironment }}'

param serviceCodeTag = '#{{ serviceCodeTag }}'

param serviceNameTag = '#{{ serviceNameTag }}'

param serviceTypeTag = '#{{ serviceTypeTag }}'

param createdDateTag = '#{{ createdDateTag }}'
