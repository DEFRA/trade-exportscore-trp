using './container-registry.bicep'

param name = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_containerregistry }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param project = '#{{ project }}'
param env = '#{{ environment }}'
param location = '#{{ location }}'
param publicNetworkAccess = 'Disabled'
param acrSku = '#{{ acrSku }}'
param azureADAuthenticationAsArmPolicyStatus = '#{{ azureADAuthenticationAsArmPolicyStatus }}'
param exportPolicyStatus = '#{{ exportPolicyStatus }}'
param softDeletePolicyStatus = '#{{ softDeletePolicyStatus }}'
param trustPolicyStatus = '#{{ trustPolicyStatus }}'

param vnetRg = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param vnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param subnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
//param containerAppMiName = '#{{ containerName }}'

param environmentTag = '#{{ environmentTag }}'
param serviceCodeTag = '#{{ serviceCodeTag }}'
param serviceNameTag = '#{{ serviceNameTag }}'
param serviceTypeTag = '#{{ serviceTypeTag }}'
