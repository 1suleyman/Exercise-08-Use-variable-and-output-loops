@description('The Azure regions into which the resources should be deployed.')
param locations array = [
  'westus'
  'eastus2'
  'eastasia'
]

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorLoginPassword string

@description('The IP address range for all virtual networks to use.')
param virtualNetworkAddressPrefix string = '10.10.0.0/16'

@description('The name and IP address range for each subnet in the virtual networks.')
param subnets array = [
  {
    name: 'frontend'
    ipAddressRange: '10.10.5.0/24'
  }
  {
    name: 'backend'
    ipAddressRange: '10.10.10.0/24'
  }
]

var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }
}] // creates i.e subnet called frontend with an addpressPrefix: subnet.10.10.5.0/24 

module databases 'modules/database.bicep' = [for location in locations: { // for each location in the locations array
  name: 'database-${location}'
  params: {
    location: location
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}]

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2024-05-01' = [for location in locations: {
  name: 'teddybear-${location}'
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        virtualNetworkAddressPrefix
      ]
    }
    subnets: subnetProperties
  }
}]
//  This example uses the same address space for all the virtual networks. Ordinarily, when you create multiple virtual networks, you would give them different address spaces in the event that you need to connect them together, (e.g., via peering or VPN). Overlapping address spaces can cause routing conflicts. It's a best practice to assign unique, non-overlapping address spaces to each virtual network.

output serverInfo array = [for i in range(0, length(locations)): { // for each location in the locations array 
  name: databases[i].outputs.serverName // iterates over the databases array and gets the server name of each database
  location: databases[i].outputs.location // iterates over the databases array and gets the location of each database
  fullyQualifiedDomainName: databases[i].outputs.serverFullyQualifiedDomainName // iterates over the databases array and gets the fully qualified domain name of each database
}]
