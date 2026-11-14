resource "azurerm_storage_account" "this" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = var.storage_account_replication_type
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_storage_container" "this" {
  name                  = var.function_storage_container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_service_plan" "function_plan" {
  name                = var.appservice_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type  = var.os_type
  sku_name = var.service_plan_sku

  tags = var.tags
}

resource "azurerm_function_app_flex_consumption" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id = azurerm_service_plan.function_plan.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.this.primary_blob_endpoint}${var.function_storage_container_name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.this.primary_access_key

  runtime_name    = "node"
  runtime_version = "22"

  https_only = true

  site_config {}
 app_settings = merge(
    {},
    var.app_settings
  )

  tags = var.tags
}


resource "azurerm_private_endpoint" "this" {
  name                = "pep-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_function_app_flex_consumption.this.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
  private_dns_zone_group {
    name = "functionapp-dns-group"

    private_dns_zone_ids = [
      var.private_dns_zone_id
    ]
  }

  tags = var.tags
}