using './postgresql.bicep'

param tags = {
  Tier: 'Storage'
  Location: '#{{ location }}'
  Environment: '#{{ environmentTag }}'
  ServiceCode: '#{{ serviceCodeTag }}'
  ServiceName: '#{{ serviceNameTag }}'
  ServiceType: '#{{ serviceTypeTag }}'
  Repo: '#{{ Build.Repository.Uri }}'
}

param laWorkspaceName = '#{{ environment }}#{{ project }}#{{ nc_infrastructure }}#{{ nc_loganalytics }}#{{ subscriptionNumber }}#{{ regionNumber }}01'

param server = {
  storageSizeGB: '#{{ postgreSqlStorageSizeGB }}'
  tier: '#{{ postgreSqlTier }}'
  skuName: '#{{ postgreSqlSkuName }}'
  highAvailability: '#{{ postgreSqlHighAvailability }}'
  availabilityZone: '#{{ postgreSqlAvailabilityZone }}'
  name: '#{{ environmentLower }}#{{ project-lower }}#{{ nc-function-database-lower }}#{{ nc-resource-postgres }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
}

param vnet = {
  name: '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
  resourceGroup: '#{{ environment }}#{{ project }}#{{ nc_network }}#{{ nc_resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
  subnetPostgreSql: '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
}

param peArray = [
  {
    groupId: 'postgresqlServer'
  }
]

param databases = [
  {
    name: 'eutd-trade-exports-core-trade-exportscore-trp'
  }
]

param location = '#{{ location }}'
param managedIdentityName = '#{{ environment }}#{{ project }}#{{ nc-function-database }}#{{ nc_identity }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param servicePrincipalName = 'ADO-DefraGovUK-#{{ azureResourceManagerConnection }}'
param servicePrincipalObjectId = '#{{ servicePrincipalObjectId }}'
