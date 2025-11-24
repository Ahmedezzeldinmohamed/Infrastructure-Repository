variable "location" {
  description = "Azure region to deploy resources"
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "Obelion-Assessment-RG"
}

variable "admin_username" {
  description = "Username for the Virtual Machines"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Password for the Virtual Machines (Complex password required)"
  default     = "Ana@7med#zz"
  sensitive   = true
}

variable "db_password" {
  description = "Password for MySQL Database"
  default     = "Ana@7med#zz123" 
  sensitive   = true
}
