using './service-bus.bicep'

param name = '#{{ containerName }}'
param location = '#{{ location }}'

param skuName = 'Premium'

param vnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param subnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param vnetRg = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'

param environmentTag = '#{{ environmentTag }}'
param serviceCodeTag = '#{{ serviceCodeTag }}'
param serviceNameTag = '#{{ serviceNameTag }}'
param serviceTypeTag = '#{{ serviceTypeTag }}'
