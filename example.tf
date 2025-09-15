locals {

  tags = {
    name         = "eg"
    app          = "boj"
    env          = "dev"
    zone         = "z1"
    CreatedDate = formatdate("YYYYMMDD", timestamp())
  }
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = " >= 0.4.0"
  suffix = ["test","dev","mbs"]
  unique-length = 3

}

module "avm-res-resources-resourcegroup" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"
  name    = module.naming.resource_group.name_unique
  location = "southeastasia"
  tags    = local.tags
}

module "avm-res-containerregistry-registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.4.0"
  name    = module.naming.container_registry.name
  location = "southeastasia"
  resource_group_name = module.avm-res-resources-resourcegroup.name

}
module "nsg_spoke_app" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = ">= 0.5.0"

  name                = "${var.name_prefix}-spoke-app-nsg"
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  tags                = var.tags

  security_rules = {
    allow-ssh-from-onprem = {
      name                       = "Allow-SSH-From-OnPrem"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefixes    = var.onprem_address_spaces
      destination_address_prefix = "*"
      destination_port_range     = "22"
      source_port_range          = "*"
      description                = "Allow SSH from on-prem ranges"
    }
    allow-vnet-inbound = {
      name                       = "Allow-VNet-Inbound"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      destination_port_range     = "*"
      source_port_range          = "*"
      description                = "Allow intra-VNet"
    }
    allow-vnet-outbound = {
      name                       = "Allow-VNet-Outbound"
      priority                   = 1001
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "*"
      source_port_range          = "*"
      description                = "Allow intra-VNet"
    }
    allow-internet-outbound = {
      name                       = "Allow-Internet-Outbound"
      priority                   = 1002
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
      destination_port_range     = "*"
      source_port_range          = "*"
      description                = "Allow outbound to Internet (will be routed via VPN by UDR)"
    }
  }
}

############################################
# Route table in Spoke to force all traffic via VPN
############################################
module "rt_spoke_default" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = ">= 0.4.0"

  name                = "${var.name_prefix}-spoke-default-rt"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  location            = var.location
  tags                = var.tags

  # One default route; next hop is the Virtual Network Gateway (in hub via peering)
  routes = {
    default_to_vpn = {
      name           = "default-to-vnet-gw"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "VirtualNetworkGateway"
    }
  }
}

############################################
# SPOKE VNET (with App subnet)
############################################
module "vnet_spoke" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = ">= 0.2.0"

  name                = var.spoke_vnet_name
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  address_space       = var.spoke_address_space
  tags                = var.tags

  subnets = {
    app = {
      name             = var.spoke_app_subnet_name
      address_prefixes = [var.spoke_app_subnet_prefix]
      network_security_group_resource_id = module.nsg_spoke_app.resource_id
      route_table_resource_id            = module.rt_spoke_default.resource_id
    }
  }
}

############################################
# HUB VNET (with GatewaySubnet)
############################################
module "vnet_hub" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = ">= 0.2.0"

  name                = var.hub_vnet_name
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  address_space       = var.hub_address_space
  tags                = var.tags

  subnets = {
    gateway = {
      name             = "GatewaySubnet"              # required literal name
      address_prefixes = [var.hub_gw_subnet_prefix]
    }
  }

  # Create hub->spoke and reverse peering with gateway transit
  peerings = {
    hub_to_spoke = {
      name = "${var.hub_vnet_name}-to-${var.spoke_vnet_name}"
      remote_virtual_network = {
        resource_id = module.vnet_spoke.resource_id
      }
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = true

      create_reverse_peering = true
      reverse_peering = {
        name                          = "${var.spoke_vnet_name}-to-${var.hub_vnet_name}"
        allow_virtual_network_access  = true
        allow_forwarded_traffic       = true
        use_remote_gateways           = true
      }
    }
  }
}

############################################
# VPN GATEWAY (Hub) + Local Network Gateway + S2S Connection
############################################

# Virtual Network Gateway (VPN, route-based)
module "vnet_gateway" {
  source  = "Azure/avm-ptn-vnetgateway/azurerm"
  version = ">= 0.10.0"

  name       = "${var.name_prefix}-vpn-gw"
  location   = var.location
  parent_id  = module.avm-res-resources-resourcegroup.resource_id

  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.vpn_sku
  vpn_active_active_enabled = false

  # Attach to the Hub VNet; create/use GatewaySubnet
  virtual_network_id    = module.vnet_hub.resource_id
  subnet_address_prefix = var.hub_gw_subnet_prefix
}

# Local Network Gateway describing on-prem
module "lng_onprem" {
  source  = "Azure/avm-res-network-localnetworkgateway/azurerm"
  version = ">= 0.1.0"

  name                = "${var.name_prefix}-onprem-lng"
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  tags                = var.tags

  gateway_address = var.onprem_gateway_public_ip
  address_space   = var.onprem_address_spaces

  # Optional BGP configuration (set enable_bgp=true and fill values to use)
  bgp_settings = var.enable_bgp ? {
    asn                     = var.onprem_bgp_asn
    bgp_peering_address     = var.onprem_bgp_peering_address
    peer_weight             = null
  } : null
}

# Site-to-Site IPsec connection between Hub VNG and on-prem LNG
module "s2s_connection" {
  source  = "Azure/avm-res-network-connection/azurerm"
  version = ">= 0.3.0"

  name                = "${var.name_prefix}-s2s-conn"
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  tags                = var.tags

  type                           = "IPsec"
  virtual_network_gateway_id     = module.vnet_gateway.resource_id
  local_network_gateway_id       = module.lng_onprem.resource_id
  shared_key                     = var.ipsec_shared_key
  enable_bgp                     = var.enable_bgp
  connection_protocol            = "IKEv2"

  # Optional: supply an explicit IPsec policy if your on-prem requires it
  ipsec_policy = var.ipsec_policy
}

############################################
# SPOKE LINUX VM
############################################
module "spoke_vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = ">= 0.3.0"

  name                = "${var.name_prefix}-vm01"
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  tags                = var.tags
  zone                = var.location
  os_type             = "Linux"

  admin_username      = var.vm_admin_username
  admin_ssh_keys      = [{
    username   = var.vm_admin_username
    public_key = var.vm_admin_ssh_public_key
  }]
  disable_password_authentication = true

  # Create NIC for the VM and place in the Spoke app subnet
  network_interfaces = {
    nic0 = {
      name = "${var.name_prefix}-vm01-nic0"
      ip_configurations = [{
        name                             = "ipconfig1"
        private_ip_allocation_method     = "Dynamic"
        private_ip_subnet_resource_id    = module.vnet_spoke.subnets["app"].resource_id
      }]
    }
  }

  # Simple Ubuntu image
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
}
