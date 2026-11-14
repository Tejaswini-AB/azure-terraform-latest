resource "azurerm_storage_account" "this" {
  name = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = var.storage_account_replication_type
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  private_cluster_enabled = true
  sku_tier                = "Standard"

  tags = var.tags

  default_node_pool {
    name           = var.node_pool_name
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = var.vnet_subnet_id

    zones = length(var.availability_zones) > 0 ? var.availability_zones : null
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "aksstgpool01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

  vm_size        = var.user_vm_size
  vnet_subnet_id = var.vnet_subnet_id

  auto_scaling_enabled = true
  min_count            = var.user_min_node_count
  max_count            = var.user_max_node_count

  zones = length(var.availability_zones) > 0 ? var.availability_zones : null

  tags = var.tags
}


