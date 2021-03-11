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