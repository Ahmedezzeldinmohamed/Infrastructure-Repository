terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Subscription ID from az login
  subscription_id = "0c715351-6aa6-4120-8278-de8e44dbc314" 
}
