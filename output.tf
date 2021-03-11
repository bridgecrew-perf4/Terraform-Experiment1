output "resource_group_name" {
  value = azurerm_resource_group.marg.name
}

output "app_service_def_hn" {
    value = "https://${azurerm_app_service.webapp.default_site_hostname}"
}