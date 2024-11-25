using './postgresql.bicep'

param tags = {
  Tier: 'Key Vault'
  Location: '#{{ location }}'
  Environment: '#{{ environmentTag }}'
  ServiceCode: '#{{ serviceCodeTag }}'
  ServiceName: '#{{ serviceNameTag }}'
  ServiceType: '#{{ serviceTypeTag }}'
  Repo: '#{{ Build.Repository.Uri }}'
}

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

param keyvaultName = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_keyvault }}#{{ subscriptionNumber }}#{{ regionNumber }}03'

param diagnostics = {
  diagnosticLogCategoriesToEnable: [
    'allLogs'
  ]
  diagnosticMetricsToEnable: [
    'AllMetrics'
  ]
}

param location = '#{{ location }}'

param managedIdentityName = '#{{ environment }}#{{ project }}#{{ nc-function-database }}#{{ nc_identity }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
