terraform {
  required_version = ">= 1.9.7"
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }
}

provider "azurerm" {
  storage_use_azuread = false
  use_msi             = false
  tenant_id           = "f3c9952d-3ea5-4539-bd9a-7e1093f8a1b6" #konjur tenant id
  subscription_id     = "95328200-66a3-438f-9641-aeeb101e5e37"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}



