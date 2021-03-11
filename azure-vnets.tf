resource azurerm_virtual_network "vnet" {
  name                = azurerm_resource_group.marg.name
  resource_group_name = azurerm_resource_group.marg.name
  location            = var.location
  address_space       = var.vnet_cidr_range

  tags = {
    environment = var.inv
  }
}

resource "azurerm_subnet" "subnet" {
  count                                          = length(var.subnet_names)
  name                                           = var.subnet_names[count.index]
  resource_group_name                            = azurerm_resource_group.marg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefix                                 = var.subnet_prefixes[count.index]
}

locals {
  azurerm_subnets = {
    for index, subnet in azurerm_subnet.subnet :
    subnet.name => subnet.id
  }
}