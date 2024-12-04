# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.114.0"
    }
  }
  
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example1" {
  name     = "example-resources1"
  location = "West Europe"
}

resource "azurerm_storage_account" "example1" {
  name                = "testarcsub65jdrfnew"
  resource_group_name = azurerm_resource_group.example1.name

  location                 = azurerm_resource_group.example1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    change_feed_enabled           = "true"
    change_feed_retention_in_days = 7
    versioning_enabled            = "true"
    delete_retention_policy {
      days = 7
    }
    restore_policy {
      days = 6 # Retain point-in-time restore capability for 6 days
    }
    container_delete_retention_policy {
      days = "14"
    }
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_management_policy" "example1" {
  storage_account_id = azurerm_storage_account.example1.id
  rule {
    name    = "versiondelete"
    enabled = true
    filters {
      prefix_match = ["activedata/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      version {
        delete_after_days_since_creation = 7
      }
    }
  }
}

resource "azurerm_storage_container" "statefile" {
  name                  = "statefiles"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}
