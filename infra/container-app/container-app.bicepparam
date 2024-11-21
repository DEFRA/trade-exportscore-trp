using 'container-app.bicep'

param name = '#{{ containerName }}'
param location = '#{{ location }}'
param managedEnvName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_managedenvironment }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param managedEnvResourceGroup = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param containerRegistryName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_containerregistry }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param miName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_identity }}#{{ subscriptionNumber }}#{{ regionNumber }}01'

param tags = {
  Tier: 'Storage'
  Location: '#{{ location }}'
  Environment: '#{{ environment }}'
  ServiceCode: '#{{ serviceCodeTag }}'
  ServiceName: '#{{ serviceNameTag }}'
  ServiceType: '#{{ serviceTypeTag }}'
  Repo: '#{{ Build.Repository.Uri }}'
}

param environmentTag = '#{{ environmentTag }}'
param serviceCodeTag = '#{{ serviceCodeTag }}'
param serviceNameTag = '#{{ serviceNameTag }}'
param serviceTypeTag = '#{{ serviceTypeTag }}'
