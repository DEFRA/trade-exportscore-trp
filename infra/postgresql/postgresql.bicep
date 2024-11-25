//imports
import * as comTypes from 'br/commonRegistry:commontypes:0-latest'
import * as comFuncs from 'br/commonRegistry:commonfunctions:0-latest'
param tags comTypes.tagsObject

@description('Required. The object of the PostgreSQL Flexible Server. The object must contain name,storageSizeGB and highAvailability properties.')
param server object

@description('Required. The parameter object for the virtual network. The object must contain the name,skuName,resourceGroup and subnetPostgreSql values.')
param vnet object

@description('Required. The name of the AAD admin managed identity.')
param managedIdentityName string

@description('Required. The diagnostic object. The object must contain diagnosticLogCategoriesToEnable and diagnosticMetricsToEnable properties.')
param diagnostics object

@description('Required. The Azure region where the resources will be deployed.')
param location string
@description('Optional. Date in the format yyyyMMdd-HHmmss.')
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')

@description('Required. The name of the key vault where the secrets will be stored.')
param keyvaultName string 

@description('Optional. The administrator login name of a server. Can only be specified when the PostgreSQL server is being created.')
param administratorLogin string = 'solemnapple5'

param guidValue string = guid(deploymentDate)
var administratorLoginPassword  = substring(replace(replace(guidValue, '.', '-'), '-', ''), 0, 20)

resource virtual_network 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnet.name
  scope: resourceGroup(vnet.resourceGroup)
  resource subnet 'subnets@2023-05-01' existing = {
    name: vnet.subnetPostgreSql
  }
}

module aadAdminUserMi 'br/SharedDefraRegistry:managed-identity.user-assigned-identity:0.4.3' = {
  name: 'managed-identity-${deploymentDate}'
  params: {
    name: toLower(managedIdentityName)
    tags: comFuncs.tagBuilder(managedIdentityName, deploymentDate, tags)
  }
}

module flexibleServerDeployment 'br/SharedDefraRegistry:db-for-postgre-sql.flexible-server:0.4.4' = {
  name: 'postgre-sql-flexible-server-${deploymentDate}'
  params: {
    name: toLower(server.name)
    administratorLogin: administratorLogin
    administratorLoginPassword : administratorLoginPassword
    storageSizeGB: server.storageSizeGB
    highAvailability: server.highAvailability
    availabilityZone: server.availabilityZone
    version:'15'
    location: location
    tags: comFuncs.tagBuilder(server.name, deploymentDate, tags)
    tier: server.tier
    skuName: server.skuName
    activeDirectoryAuth:'Enabled'
    passwordAuth: 'Enabled'
    enableDefaultTelemetry:false
    lock: 'CanNotDelete'
    backupRetentionDays:14
    createMode: 'Default' 
    diagnosticLogCategoriesToEnable: diagnostics.diagnosticLogCategoriesToEnable
    diagnosticMetricsToEnable: diagnostics.diagnosticMetricsToEnable
    diagnosticSettingsName:''
    administrators: [
      {
        objectId: aadAdminUserMi.outputs.clientId
        principalName: aadAdminUserMi.outputs.name
        principalType: 'ServicePrincipal'
      }
    ]
    configurations:[]
    delegatedSubnetResourceId : virtual_network::subnet.id
    diagnosticWorkspaceId: ''
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvaultName
}

resource secretdbhost 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'POSTGRES-HOST'
  parent: keyVault 
  properties: {
    value: '${flexibleServerDeployment.outputs.name}.postgres.database.azure.com'
  }
}

resource secretdbuser 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'POSTGRES-USER'
  parent: keyVault 
  properties: {
    value: administratorLogin
  }
}

resource secretdbpassword 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'POSTGRES-PASSWORD'
  parent: keyVault 
  properties: {
    value: administratorLoginPassword
  }
}
