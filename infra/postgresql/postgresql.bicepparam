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

param miName = '#{{ environment }}#{{ project }}#{{ nc_infrastructure }}#{{ nc_identity }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param keyVaultName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_keyvault }}#{{ subscriptionNumber }}#{{ regionNumber }}02'

param vnetResourceGroup = '#{{ environment }}#{{ project }}#{{ nc_network }}#{{ nc_resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param vnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param peSubnetName = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
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
