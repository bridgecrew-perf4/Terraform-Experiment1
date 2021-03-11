resource azurerm_resource_group "marg" {
  name = "${var.inv}-${var.resource_group_name}"
  location = var.location

  tags = {
    environment = var.inv
  }
}