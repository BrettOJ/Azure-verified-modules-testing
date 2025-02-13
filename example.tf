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

