variable "subscription_id" {
  description = "Azure subscription ID for staging/non-prod"
  type        = string
}

variable "hub_subscription_id" {
  description = "Hub Azure subscription ID"
  type        = string
}

variable "tfstate_rg"              { type = string }
variable "tfstate_storage_account" { type = string }
variable "tfstate_container"       { type = string }
variable "tfstate_key"             { type = string }

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uaenorth"
}

variable "postgres_administrator_login" {
  description = "PostgreSQL administrator login"
  type        = string
  default     = "psqladmin"
}

variable "postgres_administrator_password" {
  description = "PostgreSQL administrator password (pass via TF_VAR_ or a gitignored *.tfvars, never hardcoded)"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)

  default = {
    environment = "staging"
    managed_by  = "terraform"
  }
}

variable "tenant_id" {
  type = string
}

# ---------------------------------------------------------
# Resource Groups
# ---------------------------------------------------------
variable "network_rg_name" {
  description = "Network Resource Group Name"
  type        = string
  default     = "rg-network-stg-uaen-01"
}

variable "app_rg_name" {
  description = "Application Resource Group Name"
  type        = string
  default     = "rg-viwell-stg-uaen-01"
}

# ---------------------------------------------------------
# VNET
# ---------------------------------------------------------
variable "vnet_name" {
  description = "VNET Name"
  type        = string
  default     = "vnet-viwell-stg-uaen-01"
}

variable "vnet_address_space" {
  description = "VNET Address Space"
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "app_subnet_name" {
  type    = string
  default = "snet-app-stg-uaen-01"
}

variable "app_subnet_cidr" {
  type    = list(string)
  default = ["10.20.0.64/26"]
}

variable "function_subnet_name" {
  type    = string
  default = "snet-func-stg-uaen-01"
}

variable "function_subnet_cidr" {
  type    = list(string)
  default = ["10.20.2.0/26"]
}

variable "private_endpoint_subnet_name" {
  type    = string
  default = "snet-pep-stg-uaen-01"
}

variable "private_endpoint_subnet_cidr" {
  type    = list(string)
  default = ["10.20.0.128/26"]
}

variable "database_subnet_name" {
  type    = string
  default = "snet-db-stg-uaen-01"
}
variable "database_subnet_cidr" {
  type        = list(string)
  default     =["10.20.0.192/27"]
}

# ---------------------------------------------------------
# ACR
# ---------------------------------------------------------
variable "acr_name" {
  description = "Azure Container Registry Name"
  type        = string
  default     = "acrviwellstguaen001"
}

variable "acr_sku" {
  description = "Azure Container Registry SKU"
  type        = string
  default     = "Basic"
}

# ---------------------------------------------------------
# AKS
# ---------------------------------------------------------
variable "aks_name" {
  description = "AKS Cluster Name"
  type        = string
  default     = "aks-viwell-stg-uaen-01"
}

variable "aks_dns_prefix" {
  description = "AKS DNS Prefix"
  type        = string
  default     = "aksviwellstg"
}

variable "aks_node_count" {
  default = 1
}

variable "aks_min_node_count" {
  default = 3
}

variable "aks_max_node_count" {
  default = 7
}

variable "aks_vm_size" {
  default = "Standard_D4as_v5"
}

variable "aks_user_vm_size" {
  default = "Standard_D4as_v5"
}

variable "aks_backup_storage_account_name" {
  description = "AKS Backup Storage Account"
  type        = string
  default     = "stviwellbkupaen01"
}


# ---------------------------------------------------------
# PostgreSQL
# ---------------------------------------------------------
variable "postgres_name" {
  description = "PostgreSQL Server Name"
  type        = string
  default     = "psql-viwell-stg-uaen-01"
}

variable "postgres_sku_name" {
  description = "PostgreSQL SKU"
  type        = string
  default     = "GP_Standard_D2ds_v5"
}

# ---------------------------------------------------------
# Function App
# ---------------------------------------------------------
variable "function_app_name" {
  description = "Function App Name"
  type        = string
  default     = "func-viwell-stg-uaen-001"
}

variable "function_storage_account_name" {
  description = "Function Storage Account"
  type        = string
  default     = "stviwellfunuaen001"
}

variable "function_app_service_plan_name" {
  description = "Function App Service Plan"
  type        = string
  default     = "asp-viwell-stg-uaen-01"
}

# ---------------------------------------------------------
# Redis
# ---------------------------------------------------------
variable "redis_name" {
  description = "Redis Name"
  type        = string
  default     = "redis-viwell-stg-uaen-01"
}

variable "redis_sku_name" {
  description = "Redis SKU"
  type        = string
  default     = "Balanced_B0"
}

# ---------------------------------------------------------
# Key Vault
# ---------------------------------------------------------
variable "keyvault_name" {
  description = "Key Vault Name"
  type        = string
  default     = "kv-viwell-stg-uaen-001"
}
