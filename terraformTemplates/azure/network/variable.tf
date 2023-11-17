variable "resource_group_name" {
  description = "Azure Resource Group name"
}

variable "location" {
  description = "Azure region"
}

variable "vnet_name" {
  description = "VNET name"
}

variable "address_space" {
  description = "Address space for the VNET"
  type        = list(string)
}

variable "subnet_names" {
  description = "Names of the subnets"
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnets"
  type        = list(string)
}

variable "tags" {
  type = map(string)
}

variable "nat_gateway_name" {
  description = "NAT Gateway name"
}

variable "poc-pip" {
  description = "Ip name"
  
}