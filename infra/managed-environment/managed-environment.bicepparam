using './managed-environment.bicep'

param containerAppEnvName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_managedenvironment }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param logAnalyticsName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_loganalytics }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param vnetResourceGroup = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param vnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param peSubnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}02'
param location = '#{{ location }}'

param environmentTag = '#{{ environmentTag }}'
param serviceCodeTag = '#{{ serviceCodeTag }}'
param serviceNameTag = '#{{ serviceNameTag }}'
param serviceTypeTag = '#{{ serviceTypeTag }}'
