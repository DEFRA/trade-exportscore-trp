@description('Name of the Key Vault')
param keyVaultName string

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'standard'
  'premium'
])
param vaultSku string
param accessPolicies array = []
param enabledForDeployment bool
param enabledForTemplateDeployment bool
param enabledForDiskEncryption bool
param environmentTag string
param serviceCodeTag string
param serviceNameTag string
param serviceTypeTag string
param createdDateTag string

module vault 'br/public:avm/res/key-vault/vault:0.9.0' = {
  name: 'vaultDeployment'
  params: {
    name: keyVaultName
    tags: {
      Name: keyVaultName
      Tier: 'Key Vault'
      Location: location
      Environment: environmentTag
      ServiceCode: serviceCodeTag
      ServiceName: serviceNameTag
      ServiceType: serviceTypeTag
      CreatedDate: createdDateTag
    }
    enablePurgeProtection: false
    enableRbacAuthorization: false
    enableVaultForDiskEncryption: enabledForDiskEncryption
    enableVaultForDeployment: enabledForDeployment
    enableVaultForTemplateDeployment: enabledForTemplateDeployment
    sku: vaultSku
    location: location
    accessPolicies: accessPolicies
  }
}
