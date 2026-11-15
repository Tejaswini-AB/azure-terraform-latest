# Azure Cache for Redis (classic) is being retired by Microsoft in favor of
# Azure Managed Redis (built on Redis Enterprise architecture). This module
# uses azurerm_managed_redis, which supersedes both azurerm_redis_cache and
# azurerm_redis_enterprise_cluster/database.
# See: https://aka.ms/AzureCacheForRedisRetirement

resource "azurerm_managed_redis" "this" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  sku_name                  = var.sku_name
  high_availability_enabled = var.high_availability_enabled
  # minimum_tls_version       = var.minimum_tls_version
  public_network_access = var.enable_private_endpoint ? "Disabled" : "Enabled"
  tags                  = var.tags

  default_database {
    clustering_policy = var.clustering_policy
    eviction_policy   = var.eviction_policy
  }
}


resource "azurerm_private_endpoint" "this" {
  name                = "pep-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_managed_redis.this.id
    is_manual_connection           = false
    subresource_names              = ["redisEnterprise"]
  }
  private_dns_zone_group {
    name = "private_dns_zone_group"

    private_dns_zone_ids = [
      var.private_dns_zone_id
    ]
  }

  tags = var.tags
}
