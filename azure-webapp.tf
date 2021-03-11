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
  name                = var.webappname
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