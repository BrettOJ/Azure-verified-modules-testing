output "hub_vnet_id"    { value = module.vnet_hub.resource_id }
output "spoke_vnet_id"  { value = module.vnet_spoke.resource_id }
output "spoke_subnet_app_id" { value = module.vnet_spoke.subnets["app"].resource_id }
output "vpn_gateway_id" { value = module.vnet_gateway.resource_id }
output "lng_onprem_id"  { value = module.lng_onprem.resource_id }
output "s2s_connection_id" { value = module.s2s_connection.resource_id }
output "vm_id"          { value = module.spoke_vm.resource_id }
