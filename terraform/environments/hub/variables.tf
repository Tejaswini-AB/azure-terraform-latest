variable "subscription_id" {
  description = "Azure subscription ID for the hub"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uaenorth"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)

  default = {
    environment = "hub"
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------
# Resource Groups
# ---------------------------------------------------------
variable "global_rg_name" {
  description = "Global Resource Group Name"
  type        = string
  default     = "rg-viwell-global-uaen-01"
}

variable "hub_rg_name" {
  description = "Hub Resource Group Name"
  type        = string
  default     = "rg-viwell-hub-uaen-01"
}

# ---------------------------------------------------------
# Front Door
# ---------------------------------------------------------
variable "front_door_profile_name" {
  description = "Front Door Profile Name"
  type        = string
  default     = "fd-viwell-uaen-01"
}

variable "front_door_endpoint_name" {
  description = "Front Door Endpoint Name"
  type        = string
  default     = "viwell"
}

variable "front_door_sku_name" {
  description = "Front Door SKU"
  type        = string
  default     = "Premium_AzureFrontDoor"
}

# ---------------------------------------------------------
# VNET
# ---------------------------------------------------------
variable "hub_vnet_name" {
  description = "Hub VNET Name"
  type        = string
  default     = "vnet-hub-uaen-01"
}

variable "hub_vnet_address_space" {
  description = "Hub VNET Address Space"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

# ---------------------------------------------------------
# Subnets
# ---------------------------------------------------------
variable "external_subnet_name" {
  description = "External Subnet Name"
  type        = string
  default     = "snet-ext-hub-uaen-01"
}

variable "external_subnet_cidr" {
  description = "External Subnet CIDR"
  type        = list(string)
  default     = ["10.10.0.64/26"]
}

variable "internal_subnet_name" {
  description = "Internal Subnet Name"
  type        = string
  default     = "snet-int-hub-uaen-01"
}

variable "internal_subnet_cidr" {
  description = "Internal Subnet CIDR"
  type        = list(string)
  default     = ["10.10.0.128/26"]
}

variable "app_gateway_subnet_name" {
  description = "Application Gateway Subnet Name"
  type        = string
  default     = "snet-appgtw-uaen-01"
}

variable "app_gateway_subnet_cidr" {
  description = "Application Gateway Subnet CIDR"
  type        = list(string)
  default     = ["10.10.0.192/27"]
}