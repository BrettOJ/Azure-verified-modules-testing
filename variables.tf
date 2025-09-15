variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "s2s-demo"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "southeastasia"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# Resource group names
variable "hub_rg_name"   { 
  type = string 
  default = "rg-s2s-hub" 
}
variable "spoke_rg_name" { 
  type = string 
  default = "rg-s2s-spoke" 
}

# Address spaces
variable "hub_vnet_name"       { 
  type = string 
  default = "vnet-s2s-hub" 
}
variable "hub_address_space"   { 
  type = set(string) 
  default = ["10.10.0.0/16"] 
}
variable "hub_gw_subnet_prefix"{ 
  type = string 
  default = "10.10.255.0/27" 
}

variable "spoke_vnet_name"     { 
  type = string 
  default = "vnet-s2s-spoke" 
}
variable "spoke_address_space" { 
  type = set(string) 
  default = ["10.20.0.0/16"] 
}
variable "spoke_app_subnet_name"   { 
  type = string 
  default = "subnet-app" 
}
variable "spoke_app_subnet_prefix" { 
  type = string 
  default = "10.20.1.0/24" 
}

# On‑prem settings
variable "onprem_gateway_public_ip" {
  description = "Public IP of your on‑prem VPN device"
  type        = string
}

variable "onprem_address_spaces" {
  description = "On‑prem address spaces reachable over the VPN (e.g., your LAN prefixes)"
  type        = list(string)
}

variable "ipsec_shared_key" {
  description = "Pre‑shared key for the S2S VPN connection"
  type        = string
  sensitive   = true
}

variable "enable_bgp" {
  description = "Enable BGP between Azure and on‑prem"
  type        = bool
  default     = false
}

variable "onprem_bgp_asn" {
  description = "On‑prem BGP ASN (required if enable_bgp=true)"
  type        = number
  default     = 65010
}

variable "onprem_bgp_peering_address" {
  description = "On‑prem BGP peering IP (required if enable_bgp=true)"
  type        = string
  default     = null
}

variable "ipsec_policy" {
  description = "Optional IPsec policy block if your on‑prem requires specific crypto (pass null to use Azure defaults)"
  type = object({
    dh_group               = string
    ike_encryption         = string
    ike_integrity          = string
    ipsec_encryption       = string
    ipsec_integrity        = string
    pfs_group              = string
    sa_data_size_in_kilobytes = optional(number)
    sa_lifetime_in_seconds    = optional(number)
  })
  default = null
}

variable "vpn_sku" {
  description = "VPN Gateway SKU (e.g., VpnGw1, VpnGw2, VpnGw1AZ)"
  type        = string
  default     = "VpnGw1"
}

# VM settings
variable "vm_size" { 
  type = string 
  default = "Standard_B2s" 
}
variable "vm_admin_username" { 
  type = string 
  default = "azureuser" 
}
variable "vm_admin_ssh_public_key" {
  description = "SSH public key for the VM (ssh-rsa/ecdsa...)"
  type        = string
}
