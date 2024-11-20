using './service-bus.bicep'

param name = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_servicebus }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param location = '#{{ location }}'

param skuName = 'Premium'

param vnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param subnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param vnetRg = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'

param environmentTag = '#{{ environmentTag }}'
param serviceCodeTag = '#{{ serviceCodeTag }}'
param serviceNameTag = '#{{ serviceNameTag }}'
param serviceTypeTag = '#{{ serviceTypeTag }}'
