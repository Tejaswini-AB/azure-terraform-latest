terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Partial backend config: resource_group_name, storage_account_name and
  # container_name are supplied at `terraform init` time via -backend-config
  # (see .github/workflows/terraform-stg.yml, or backend-config.hcl for local use).
  backend "azurerm" {
    key = "stg.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id  
}

# Hub subscription - aliased provider
provider "azurerm" {
  alias           = "hub"
  features        {}
  subscription_id = var.hub_subscription_id
}

# ---------------------------------------------------------
# Read hub outputs (hub's own tfstate)
# ---------------------------------------------------------
data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_rg
    storage_account_name = var.tfstate_sa
    container_name       = var.tfstate_container
    key                  = var.tfstate_key
    subscription_id      = var.hub_subscription_id
    use_azuread_auth     = true
  }
}

# ---------------------------------------------------------
# Resource Group
# ---------------------------------------------------------
module "rg_network_stg" {
  source   = "../../modules/resource-group"
  name     = var.network_rg_name
  location = var.location
  tags     = var.tags
}

module "rg_stg" {
  source   = "../../modules/resource-group"
  name     = var.app_rg_name
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------
module "vnet_stg" {
  source              = "../../modules/vnet"
  name                = var.vnet_name
  resource_group_name = module.rg_network_stg.name
  location            = var.location
  address_space       = var.vnet_address_space

  subnets = {
    (var.app_subnet_name) = {
      address_prefixes =var.app_subnet_cidr

      nsg_name = "nsg-app-stg-uaen-01"

      nsg_rules = [
        {
          name                       = "Allow-HTTPS"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Allow HTTPS inbound"
        }
      ]
    }
    (var.function_subnet_name) = {
      address_prefixes   = var.function_subnet_cidr
      delegation_name    = "flex-consumption-delegation"
      delegation_service = "Microsoft.App/environments"

      nsg_name = "nsg-fun-stg-uaen-01"

      nsg_rules = [
        {
          name                       = "Allow-HTTPS"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Allow HTTPS inbound"
        }
      ]
    }
    (var.private_endpoint_subnet_name) = {
      address_prefixes = var.private_endpoint_subnet_cidr
    }
    (var.database_subnet_name) = {
      address_prefixes   = var.database_subnet_cidr
      delegation_name    = "postgres-delegation"
      delegation_service = "Microsoft.DBforPostgreSQL/flexibleServers"

      nsg_name = "nsg-db-stg-uaen-01"

      nsg_rules = [
        {
          name                       = "Allow-PostgreSQL-Outbound"
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "5432"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Allow outbound PostgreSQL connectivity for migration"
        }
      ]
    }
  }

  tags = var.tags
}
# ---------------------------------------------------------
# ACR
# ---------------------------------------------------------
module "acr_stg" {
  source                     = "../../modules/acr"
  name                       = var.acr_name
  resource_group_name        = module.rg_stg.name
  private_endpoint_subnet_id = module.vnet_stg.subnet_ids[var.private_endpoint_subnet_name]
  location                   = var.location
  zone_redundancy_enabled    = false
  sku                        = var.acr_sku
  private_dns_zone_id        = local.dns_zone_ids["acr"]#module.acr_dns_zone_stg.id
  tags                       = var.tags
}

# ---------------------------------------------------------
# AKS
# ---------------------------------------------------------
module "aks_stg" {
  source               = "../../modules/aks"
  name                 = var.aks_name
  resource_group_name  = module.rg_stg.name
  location             = var.location
  dns_prefix           = var.aks_dns_prefix
  vnet_subnet_id       = module.vnet_stg.subnet_ids[var.app_subnet_name]
  storage_account_name = var.aks_backup_storage_account_name
  acr_id               = module.acr_stg.id
  node_count           = var.aks_node_count
  user_min_node_count  = var.aks_min_node_count
  user_max_node_count  = var.aks_max_node_count
  vm_size              = var.aks_vm_size
  user_vm_size         = var.aks_user_vm_size
  tags                 = var.tags
}

# ---------------------------------------------------------
# PostgreSQL Flexible Server
# ---------------------------------------------------------
module "postgresql_stg" {
  source                 = "../../modules/postgresql"
  name                   = var.postgres_name
  resource_group_name    = module.rg_stg.name
  location               = var.location
  administrator_login    = var.postgres_administrator_login
  administrator_password = var.postgres_administrator_password
  delegated_subnet_id    = module.vnet_stg.subnet_ids[var.database_subnet_name]
  private_dns_zone_id    =  local.dns_zone_ids["postgres"]#module.postgres_dns_zone_stg.id
  sku_name               = var.postgres_sku_name
  tags                   = var.tags
}

# ---------------------------------------------------------
# Function App
# ---------------------------------------------------------
module "function_app_stg" {
  source                     = "../../modules/function-app"
  name                       = var.function_app_name
  resource_group_name        = module.rg_stg.name
  location                   = var.location
  storage_account_name       = var.function_storage_account_name
  appservice_plan_name       = var.function_app_service_plan_name
  vnet_subnet_id             = module.vnet_stg.subnet_ids[var.function_subnet_name]
  private_endpoint_subnet_id = module.vnet_stg.subnet_ids[var.function_subnet_name]
  private_dns_zone_id        = local.dns_zone_ids["funcapp"]#module.funcapp_dns_zone_stg.id
  tags                       = var.tags
}

# ---------------------------------------------------------
# Redis Cache
# ---------------------------------------------------------
module "redis_stg" {
  source                     = "../../modules/redis"
  name                       = var.redis_name
  resource_group_name        = module.rg_stg.name
  location                   = var.location
  sku_name                   = var.redis_sku_name
  high_availability_enabled  = false
  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.vnet_stg.subnet_ids[var.private_endpoint_subnet_name]
  private_dns_zone_id        = local.dns_zone_ids["redis"]#module.redis_dns_zone_stg.id
  tags                       = var.tags
}

# ---------------------------------------------------------
# KeyVault
# ---------------------------------------------------------
module "keyvault_stg" {
  source                     = "../../modules/keyvault"
  name                       = var.keyvault_name
  resource_group_name        = module.rg_stg.name
  location                   = var.location
  private_endpoint_subnet_id = module.vnet_stg.subnet_ids[var.private_endpoint_subnet_name]
  private_dns_zone_id        = local.dns_zone_ids["kv"]#module.kv_dns_zone_stg.id
  sku_name                   = "standard"
  tenant_id                  = var.tenant_id
  tags                       = var.tags
}


# ---------------------------------------------------------
# staging Assets Storage Account
# ---------------------------------------------------------
module "storage_preprod_assets" {
  source = "../../modules/storage-account"

  storage_account_name = var.preprod_assets_storage_account_name
  resource_group_name  = module.rg_stg.name
  location             = var.location

  container_name = var.preprod_assets_container_name

  private_endpoint_subnet_id = module.vnet_stg.subnet_ids[
    var.private_endpoint_subnet_name
  ]

  private_dns_zone_id = local.dns_zone_ids["blob"]

  replication_type = var.assets_storage_replication_type

  tags = tags
}


locals {
  dns_zone_ids    = data.terraform_remote_state.hub.outputs.private_dns_zone_ids
  dns_zone_names  = data.terraform_remote_state.hub.outputs.private_dns_zone_names
  hub_dns_rg_name = data.terraform_remote_state.hub.outputs.private_dns_resource_group_name
}

# ---------------------------------------------------------
# Link hub DNS zones to the staging VNet
# ---------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "stg" {
  provider              = azurerm.hub
  for_each              = local.dns_zone_names
  name                  = "link-${var.vnet_name}"
  resource_group_name   = local.hub_dns_rg_name
  private_dns_zone_name = each.value
  virtual_network_id    = module.vnet_stg.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}
