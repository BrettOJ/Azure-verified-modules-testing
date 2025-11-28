module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = ["boj", "test", "001"]
}

module "avm-res-resources-resourcegroup" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  location = var.location
  name     = module.naming.resource_group.name
}
/*
module "avm-res-resources-virtualnetwork-001" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.12.0"

  parent_id           = module.avm-res-resources-resourcegroup.resource_id
  location            = var.location
  name                = "${module.naming.virtual_network.name}-001"
  address_space       = ["10.20.0.0/16"]
  enable_telemetry    = false
  subnets = {
    subnet1 = {
      name             = "${module.naming.subnet.name}-1-1"
      address_prefixes = ["10.20.1.0/24"]
    }
    subnet2 = {
      name             = "${module.naming.subnet.name}-1-2"
      address_prefixes = ["10.20.2.0/24"]
    }
  }
} 
module "avm-res-resources-virtualnetwork-002" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.10.0"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  location            = var.location
  name                = "${module.naming.virtual_network.name}-002"
  address_space       = ["10.30.0.0/16"]
  subnets = {
    subnet1 = {
      name             = "GatewaySubnet"
      address_prefixes = ["10.30.1.0/24"]
    }
  }
}*/