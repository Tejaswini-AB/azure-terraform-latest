
output "id" {
  description = "Storage Account ID"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage Account name"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Storage Account Blob endpoint"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "container_name" {
  description = "Blob container name"
  value       = azurerm_storage_container.this.name
}

output "private_endpoint_id" {
  description = "Blob Private Endpoint ID"
  value       = azurerm_private_endpoint.blob.id
}

output "private_endpoint_ip" {
  description = "Blob Private Endpoint private IP"
  value       = azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address
}
