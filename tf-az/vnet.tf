# Resource Group
resource "azurerm_resource_group" "lms-rg" {
  name     = "lms-rg"
  location = "East US"
}

# VNET
resource "azurerm_virtual_network" "lms-vnet" {
  name                = "lms"
  location            = azurerm_resource_group.lms-rg.location
  resource_group_name = azurerm_resource_group.lms-rg.name
  address_space       = ["10.0.0.0/16"]
    tags = {
    environment = "dev"
  }
}

# WEB Subnet
resource "azurerm_subnet" "lms-web-sn" {
  name                 = "lms-web-subnet"
  resource_group_name  = azurerm_resource_group.lms-rg.name
  virtual_network_name = azurerm_virtual_network.lms-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}