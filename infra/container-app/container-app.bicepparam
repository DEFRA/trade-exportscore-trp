using 'container-app.bicep'

param name = '#{{ containerName }}'
param location = '#{{ location }}'
param managedEnvName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_managedenvironment }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param managedEnvResourceGroup = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param containerRegistryName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_containerregistry }}#{{ subscriptionNumber }}#{{ regionNumber }}01'

param environmentTag = '#{{ environmentTag }}'
param serviceCodeTag = '#{{ serviceCodeTag }}'
param serviceNameTag = '#{{ serviceNameTag }}'
param serviceTypeTag = '#{{ serviceTypeTag }}'
