
data "azurerm_client_config" "current" {}
/*
module "avm-res-operationalinsights-workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.2"
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  name                = module.naming.log_analytics_workspace.name
  log_analytics_workspace_internet_ingestion_enabled = true
  log_analytics_workspace_internet_query_enabled     = true
}


module "avm-res-containerinstance-containergroup" {
  source  = "Azure/avm-res-containerinstance-containergroup/azurerm"
  version = "0.2.0"
  location            = var.location
  name                = module.naming.container_group.name
  os_type             = "Linux"
  resource_group_name = module.avm-res-resources-resourcegroup.name
  restart_policy      = "Always"
  containers = {
    azure-mcp = {
      name   = "azure-mcp"
      image  = "mcr.microsoft.com/azure-sdk/azure-mcp:latest"
        command = [
            "dotnet", "azmcp.dll", "server", "start",
            "--enable-insecure-transports",
            "--transport", "http",
            "--namespace", "bestpractices"
            ]

        cpu    = 1
        memory = 2
        ports = [
            {
                port     = 80
                protocol = "TCP"
            }
        ]
        volumes = {}
        }
  }
  diagnostics_log_analytics = {
    workspace_id = module.avm-res-operationalinsights-workspace.resource.workspace_id
    workspace_key = module.avm-res-operationalinsights-workspace.resource.primary_shared_key
  }

  enable_telemetry = false
  exposed_ports = [
    {
      port     = 80
      protocol = "TCP"
    }
  ]
  priority = "Regular"
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = "Contributor"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    }
  }
  tags = {
    clustertype = "public"
  }
  zones = ["1"]
  depends_on = [module.avm-res-operationalinsights-workspace]
}*/