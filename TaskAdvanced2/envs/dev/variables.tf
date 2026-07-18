variable "zone" {
  description = "Zone of availability"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "vm_name" {
  description = "VM name"
  type        = string
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
}

variable "memory" {
  description = "RAM in bytes"
  type        = number
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
}

variable "disk_type" {
  description = "Disk type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  sensitive   = true
}

variable "image_id" {
  description = "OS image ID"
  type        = string
}

variable "platform_id" {
  description = "VM platform"
  type        = string
}

variable "service_account_key_file" {
  description = "Path to service account key file"
  type        = string
  default     = ""
}