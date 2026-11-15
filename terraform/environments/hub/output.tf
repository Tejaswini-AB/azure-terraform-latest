output "private_dns_zone_ids" {
  value = { for k, z in azurerm_private_dns_zone.this : k => z.id }
}

output "private_dns_zone_names" {
  value = { for k, z in azurerm_private_dns_zone.this : k => z.name }
}

output "private_dns_resource_group_name" {
  value = module.rg_hub.name
}
