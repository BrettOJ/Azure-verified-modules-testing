variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "southeastasia"

}

variable "bypass_ip_cidr" {
  description = "The CIDR IP range to be allowed to bypass network rules."
  type        = string
  default     = ""
}
