using 'container-app.bicep'

param name = '#{{ containerName }}'
param location = '#{{ location }}'
param env = '#{{ environment }}'
param project = '#{{ project }}'
param managedEnvName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_managedenvironment }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param managedEnvResourceGroup = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
