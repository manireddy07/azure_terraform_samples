terraform {
  //required_version = ">= 0.12"
  backend "azurerm"{
      resource_group_name  ="remote-rg"
      storage_account_name = "remotetfstorage"
      container_name       =  "tfstatecontainer"
      key                  = "myweb.tfstate"
  }
}
