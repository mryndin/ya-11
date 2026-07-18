variable "zone" {
  description = "Zone of availability"
  type        = string
  default     = "ru-central1-a"
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
  default     = "default-vm"
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "RAM in bytes"
  type        = number
  default     = 2147483648
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Disk type"
  type        = string
  default     = "network-hdd"
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
  default     = "fd8kdq6d0p8sij7h5qe3"
}

variable "platform_id" {
  description = "VM platform"
  type        = string
  default     = "standard-v3"
}