variable "name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
}

variable "user_min_node_count" {
  type = number
  default=1
}

variable "enable_auto_scaling" {
  description = "Enable autoscaling for the AKS user node pool"
  type        = bool
  default     = true
}

variable "user_max_node_count" {
  type    = number
  default = 7
}


variable "vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "user_node_pool_name" {
  description = "Name of the user node pool"
  type        = string
  default     = "user"
}

variable "user_node_count" {
  description = "Number of user nodes"
  type        = number
  default     = 1
}

variable "user_vm_size" {
  description = "VM size for the user node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vnet_subnet_id" {
  description = "Subnet ID for the AKS default node pool"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for the default node pool, e.g. [\"1\",\"2\",\"3\"]. Empty list disables zone pinning."
  type        = list(string)
  default     = ["1"]
}

variable "storage_account_name" {
  description = "Name of the storage account backing the Function App (must be globally unique, lowercase alphanumeric)"
  type        = string
}

variable "storage_account_replication_type" {
  description = "Replication type for the backing storage account: LRS, ZRS, GRS, GZRS, etc."
  type        = string
  default     = "LRS"
}

variable "acr_id" {
  description = "ACR resource ID to grant AcrPull to the AKS kubelet identity (leave null to skip)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
