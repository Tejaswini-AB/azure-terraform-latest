
variable "storage_account_name" {
  description = "Globally unique Azure Storage Account name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the storage account"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
}

variable "container_name" {
  description = "Private Blob Container name"
  type        = string
  default     = "assets"
}

variable "private_endpoint_subnet_id" {
  description = "Private Endpoint subnet ID"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Hub Blob Private DNS Zone ID"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
