#############################################################################
# VARIABLES
############################################################################

variable "resource_group_name" {
  type = string
  default = "__resource_group_name__"
}

variable "location" {
  type    = string
  default = "__location__"
}


variable "vnet_cidr_range" {
  type = list(string)
  default = ["10.2.0.0/16"]
}

variable "subnet_names" {
  type    = list(string)
  default = ["web", "database", "app"]
}

variable "inv" {
  type = "string"
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24" ]
}

variable "appserviceplan_name" {
  type = "string"
  default = "__appserviceplan_name__"
}

variable "webappname" {
  type = "string"
  default = "__webappname__"
}


#############################################################################
# PROVIDERS
#############################################################################

provider "azurerm" {
  version = "= 2.0.0"
  features {}
}

#############################################################################
# RESOURCES
#############################################################################

#resource "random_integer" "suffix" {
#  min = 1000
#  max = 9999
#}

resource azurerm_resource_group "marg" {
  name = "${var.inv}-${var.resource_group_name}"
  location = var.location

  tags = {
    environment = var.inv
  }
}

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


resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "${var.inv}-${var.appserviceplan_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.marg.name

  sku {
    tier = "__tier__"
    size = "__size__"
  }

  tags = {
    environment = var.inv
  }
}

resource "azurerm_app_service" "webapp" {
  #name                = "${var.inv}-${var.webappname}-${random_integer.suffix.result}"
  name                = "${var.inv}-${var.webappname}"
  location            = var.location
  resource_group_name = azurerm_resource_group.marg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  site_config {
    dotnet_framework_version = "v4.0"
  }

  tags = {
    environment = var.inv
  }
}

locals {
  azurerm_subnets = {
    for index, subnet in azurerm_subnet.subnet :
    subnet.name => subnet.id
  }
}


resource "azurerm_public_ip" "example" {
  name                    = "linux-pip"
  location                = var.location
  resource_group_name     = azurerm_resource_group.marg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "test"
  }
}

resource "azurerm_network_interface" "example" {
  name                = "linux-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.marg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}


resource "azurerm_virtual_machine" "main" {
  name                  = "linux-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.marg.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_B1ms"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "linux-vm"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}



#############################################################################
# OUTPUTS
#############################################################################


output "resource_group_name" {
  value = azurerm_resource_group.marg.name
}
