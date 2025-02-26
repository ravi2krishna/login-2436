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

# API Subnet
resource "azurerm_subnet" "lms-api-sn" {
  name                 = "lms-api-subnet"
  resource_group_name  = azurerm_resource_group.lms-rg.name
  virtual_network_name = azurerm_virtual_network.lms-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# DB Subnet
resource "azurerm_subnet" "lms-db-sn" {
  name                 = "lms-db-subnet"
  resource_group_name  = azurerm_resource_group.lms-rg.name
  virtual_network_name = azurerm_virtual_network.lms-vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Web Public IP
resource "azurerm_public_ip" "lms-web-pip" {
  name                = "lms-web-pip"
  resource_group_name = azurerm_resource_group.lms-rg.name
  location            = azurerm_resource_group.lms-rg.location
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}

# API Public IP
resource "azurerm_public_ip" "lms-api-pip" {
  name                = "lms-api-pip"
  resource_group_name = azurerm_resource_group.lms-rg.name
  location            = azurerm_resource_group.lms-rg.location
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}

# Web Network Security Group - NSG
resource "azurerm_network_security_group" "lms-web-nsg" {
  name                = "lms-web-nsg"
  location            = azurerm_resource_group.lms-rg.location
  resource_group_name = azurerm_resource_group.lms-rg.name
}
