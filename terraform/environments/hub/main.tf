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
  # (see .github/workflows/*.yml, or backend-config.hcl for local use).
  backend "azurerm" {
    key = "hub.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}


# ---------------------------------------------------------
# Resource Group for global/shared resources
# ---------------------------------------------------------
module "rg_global" {
  source   = "../../modules/resource-group"
  name     = var.global_rg_name
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------
# Azure Front Door (Premium) — fronts the Function Apps in both
# ---------------------------------------------------------
module "front_door" {
  source              = "../../modules/front-door"
  profile_name        = var.front_door_profile_name
  resource_group_name = module.rg_global.name
  endpoint_name       = var.front_door_endpoint_name
  sku_name            = var.front_door_sku_name
  tags                = var.tags
}


# ---------------------------------------------------------
# Resource Group
# ---------------------------------------------------------
module "rg_hub" {
  source   = "../../modules/resource-group"
  name     = var.hub_rg_name
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------
# Hub Virtual Network
# ---------------------------------------------------------
module "vnet_hub" {
  source              = "../../modules/vnet"
  name                = var.hub_vnet_name
  resource_group_name = module.rg_hub.name
  location            = var.location
  address_space       = var.hub_vnet_address_space

  subnets = {
    (var.external_subnet_name) = {
      address_prefixes = var.external_subnet_cidr
    }
    (var.internal_subnet_name) = {
      address_prefixes = var.internal_subnet_cidr
    }
    (var.app_gateway_subnet_name) = {
      address_prefixes = var.app_gateway_subnet_cidr
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------
# Private DNS Zones (shared, owned by hub)
# ---------------------------------------------------------
locals {
  private_dns_zones = {
    acr      = "privatelink.azurecr.io"
    postgres = "privatelink.postgres.database.azure.com"
    funcapp  = "privatelink.azurewebsites.net"
    redis    = "privatelink.redis.cache.windows.net"
    kv       = "privatelink.vaultcore.azure.net"
  }
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = module.rg_hub.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each              = local.private_dns_zones
  name                  = "link-${var.hub_vnet_name}"
  resource_group_name   = module.rg_hub.name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = module.vnet_hub.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}


locals {
  private_dns_zones = {
    acr      = "privatelink.azurecr.io"
    postgres = "privatelink.postgres.database.azure.com"
    funcapp  = "privatelink.azurewebsites.net"
    redis    = "privatelink.redis.cache.windows.net"
    kv       = "privatelink.vaultcore.azure.net"

    # Storage Account Blob Private Endpoint
    blob     = "privatelink.blob.core.windows.net"
  }
}

