using './network.bicep'
//imports

param location = '#{{ location }}'
param tags = {
  Tier: 'Storage'
  Location: '#{{ location }}'
  Environment: '#{{ environmentTag }}'
  ServiceCode: '#{{ serviceCodeTag }}'
  ServiceName: '#{{ serviceNameTag }}'
  ServiceType: '#{{ serviceTypeTag }}'
  Repo: '#{{ Build.Repository.Uri }}'
}

param additionalNsgRules = []

param nsgPrefix = '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc_nsg }}#{{ subscriptionNumber }}#{{ regionNumber }}'

param routeTableName = 'UDR-Spoke-Route-From-#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc_virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'

param vnetObject = {
  name: '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
  addressPrefixes: ['#{{ vnet01AddressPrefix }}', '#{{ vnet02AddressPrefix }}']
  subnetsArray: [
    {
      name: '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
      addressPrefix: '#{{ vnet01Subnet1Address }}'
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
    {
      name: '#{{ environment }}#{{ project }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ subscriptionNumber }}#{{ regionNumber }}02'
      addressPrefix: '#{{ vnet01Subnet2Address }}' // Replace with actual address prefix
      privateEndpointNetworkPolicies: 'Enabled' // Set as needed
      privateLinkServiceNetworkPolicies: 'Enabled' // Set as needed
    }
  ]
}

param defaultNsgRules = [
  {
    name: 'allow-active-directory-inbound-neu'
    properties: {
      access: 'Allow'
      description: 'Default CSC Ruleset'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
      direction: 'Inbound'
      priority: 103
      protocol: '*'
      sourceAddressPrefixes: [
        '10.205.0.4'
        '10.205.0.5'
        '10.205.0.20'
        '10.206.64.116'
        '10.206.64.117'
        '10.206.66.116'
        '10.206.66.117'
        '10.176.0.4'
        '10.176.0.5'
        '10.184.0.4'
        '10.184.0.5'
      ]
      sourcePortRange: '*'
    }
  }
  {
    name: 'allow-rdp-avd-csc-prd'
    properties: {
      access: 'Allow'
      description: 'Allow RDP AVD CSC PRD'
      destinationAddressPrefix: '*'
      destinationPortRange: '3389'
      direction: 'Inbound'
      priority: 202
      protocol: 'Tcp'
      sourceAddressPrefixes: [
        '10.202.130.0/28'
      ]
      sourcePortRange: '*'
    }
  }
  {
    name: 'allow-ssh-inbound-CSC-OPS'
    properties: {
      access: 'Allow'
      description: 'Allow SSH inbound CSC OPS'
      destinationAddressPrefix: '*'
      destinationPortRange: '22'
      direction: 'Inbound'
      priority: 203
      protocol: 'Tcp'
      sourceAddressPrefixes: [
        '10.204.0.0/26'
        '10.202.128.0/19'
      ]
      sourcePortRange: '*'
    }
  }
  {
    name: 'allow-rdp-inbound-CSC-OPS'
    properties: {
      access: 'Allow'
      description: 'Allow RDP inbound CSC OPS'
      destinationAddressPrefix: '*'
      destinationPortRange: '3389'
      direction: 'Inbound'
      priority: 305
      protocol: 'Tcp'
      sourceAddressPrefixes: [
        '10.204.0.0/26'
      ]
      sourcePortRange: '*'
    }
  }
  {
    name: 'allow-all-LogicMonitor-inbound'
    properties: {
      access: 'Allow'
      description: 'Default CSC Ruleset'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
      direction: 'Inbound'
      priority: 306
      protocol: '*'
      sourceAddressPrefixes: [
        '10.204.0.136'
        '10.204.0.137'
        '10.204.2.136'
        '10.204.2.137'
        '10.176.14.136'
        '10.176.14.137'
        '10.184.14.136'
        '10.184.14.137'
        '10.205.165.0/26'
      ]
      sourcePortRange: '*'
    }
  }
  {
    name: 'CSC-Allow_LogicMonitor_Public_Check-inbound'
    properties: {
      access: 'Allow'
      description: 'Default CSC Ruleset'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
      direction: 'Inbound'
      priority: 316
      protocol: 'Tcp'
      sourceAddressPrefixes: [
        '52.169.155.125'
        '52.164.227.127'
        '13.95.143.135'
        '52.233.139.63'
        '51.132.12.126'
        '51.132.12.247'
        '51.141.50.174'
        '51.141.51.22'
      ]
      sourcePortRange: '443'
    }
  }
]
