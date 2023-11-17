###########################################
# Resource Group
###########################################

resource "azurerm_resource_group" "networkhub_rg" {
  name     = var.resource_group_name
  location = var.location
  tags = var.tags

}
###########################################
# Virtual Network and Subnets 
###########################################
resource "azurerm_virtual_network" "poc_vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.networkhub_rg.location
  resource_group_name = azurerm_resource_group.networkhub_rg.name
  address_space       = var.address_space
   
}
###########################################
# Create private subnets
###########################################

resource "azurerm_subnet" "private_subnets" {
  count                    = 4
  name                     = var.subnet_names[count.index]
  resource_group_name      = azurerm_resource_group.networkhub_rg.name
  virtual_network_name     = azurerm_virtual_network.poc_vnet.name
  address_prefixes         = [var.subnet_address_prefixes[count.index]]

}
##########################################
# Create public subnets
###########################################

resource "azurerm_subnet" "public_subnets" {
  count                    = 2
  name                     = var.subnet_names[count.index + 4] # Start from index 4
  resource_group_name      = azurerm_resource_group.networkhub_rg.name
  virtual_network_name     = azurerm_virtual_network.poc_vnet.name
  address_prefixes         = [var.subnet_address_prefixes[count.index + 4]] # Start from index 4
  
}
###########################################
# Create NAT Gateway
###########################################

resource "azurerm_public_ip_prefix" "nat_prefix" {
  name                = "pipp-nat-gateway"
  resource_group_name = azurerm_resource_group.networkhub_rg.name
  location            = azurerm_resource_group.networkhub_rg.location
  ip_version          = "IPv4"
  prefix_length       = 29
  sku                 = "Standard"
  zones               = ["1"]

}

resource "azurerm_nat_gateway" "gw_aks" {
  name                    = "natgw-aks"
  resource_group_name     = azurerm_resource_group.networkhub_rg.name
  location                = azurerm_resource_group.networkhub_rg.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]

}

resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_ips" {
  nat_gateway_id      = azurerm_nat_gateway.gw_aks.id
  public_ip_prefix_id = azurerm_public_ip_prefix.nat_prefix.id

}

resource "azurerm_subnet_nat_gateway_association" "sn_private_nat_gw" {
  count          = 4
  subnet_id      = element(azurerm_subnet.private_subnets, count.index).id
  nat_gateway_id = azurerm_nat_gateway.gw_aks.id
}

output "gateway_ips" {
  value = azurerm_public_ip_prefix.nat_prefix.ip_prefix
}