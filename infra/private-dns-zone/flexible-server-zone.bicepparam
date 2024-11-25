using './flexible-server-zone.bicep'

param tags = {
  Tier: 'Shared'
  Location: 'global'
  Environment: '#{{ environmentTag }}'
  ServiceCode: '#{{ serviceCodeTag }}'
  ServiceName: '#{{ serviceNameTag }}'
  ServiceType: '#{{ serviceTypeTag }}'
  Repo: '#{{ Build.Repository.Uri }}'
}

param vnet = {
  name: '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
  resourceGroup: '#{{ environment }}#{{ project }}#{{ nc_network }}#{{ nc_resourcegroup }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
}

param privateDnsZonePrefix = '#{{ environment }}#{{ project }}#{{ nc_private_dns_zone }}#{{ nc_resource_dnszone }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
