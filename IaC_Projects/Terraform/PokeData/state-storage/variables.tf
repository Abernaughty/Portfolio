variable "location" {
  description = "Azure region for the state storage resources"
  type        = string
  default     = "centralus"
}

variable "enable_public_access" {
  description = "Enable public access to storage account (set to false for production)"
  type        = bool
  default     = true
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the storage account"
  type        = list(string)
  default     = []
}
