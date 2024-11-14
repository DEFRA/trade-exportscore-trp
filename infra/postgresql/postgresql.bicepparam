using './postgresql.bicep'

param location = '#{{ location }}'
param tags = {
  Tier: 'Storage'
  Location: '#{{ location }}'
  Environment: '#{{ environment }}'
  ServiceCode: '#{{ serviceCodeTag }}'
  ServiceName: '#{{ serviceNameTag }}'
  ServiceType: '#{{ serviceTypeTag }}'
  Repo: '#{{ Build.Repository.Uri }}'
}

param server = {
  name: '#{{ environment }}#{{ project }}#{{ nc_infrastructure }}#{{ nc-resource-sqlserver }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
  storageSizeGB: '#{{ postgreSqlStorageSizeGB }}'
  highAvailability: '#{{ postgreSqlHighAvailability }}' 
  availabilityZone: '#{{ postgreSqlAvailabilityZone }}'
  tier: '#{{ postgreSqlTier }}'
  skuName: '#{{ postgreSqlSkuName }}'
}

param resourceLockEnabled = '#{{ resourceLockEnabled }}' == 'true' ? true : false

param miName = '#{{ environment }}#{{ project }}#{{ nc_infrastructure }}#{{ nc_identity }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param adminLoginKeyvaultName = '#{{ environment }}#{{ project }}#{{ nc_infrastructure }}#{{ nc_keyvault }}#{{ subscriptionNumber }}#{{ regionNumber }}02'
param adminLoginKevaultSecretName = 'sqlAdminPassword'

param cmkName = 'sqlCmk'
param vnetResourceGroup = '#{{ environment }}#{{ projectName }}#{{ nc_network }}#{{ nc_resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param vnetName = '#{{ environment }}#{{ projectName }}#{{ nc_network }}#{{ nc_virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}#{{ vnet01id }}'
param peSubnetName = '#{{ environment }}#{{ projectName }}#{{ nc_network }}#{{ nc_subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}#{{ subnet01id }}'
param peArray = [
  {
    groupId: 'sqlServer'
  }
]

param databases = [
  {
    name: 'eutd-trade-exports-core-trade-exportscore-trp'
  }
]

param laWorkspaceName = '#{{ environment }}#{{ project }}#{{ nc_infrastructure }}#{{ nc_loganalytics }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
