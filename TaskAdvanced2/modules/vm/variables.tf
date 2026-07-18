variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
  default     = "default-vm"
}

variable "cores" {
  description = "Количество ядер CPU"
  type        = number
  default     = 2
  validation {
    condition     = var.cores > 0 && var.cores <= 128
    error_message = "Количество ядер должно быть от 1 до 128."
  }
}

variable "memory" {
  description = "Объём RAM в байтах (например, 2147483648 = 2 GB)"
  type        = number
  default     = 2147483648
}

variable "disk_size" {
  description = "Размер подключаемого диска в байтах"
  type        = number
  default     = 10737418240
}

variable "disk_type" {
  description = "Тип диска: network-hdd, network-ssd, network-ssd-nonreplicated"
  type        = string
  default     = "network-hdd"
  validation {
    condition     = contains(["network-hdd", "network-ssd", "network-ssd-nonreplicated"], var.disk_type)
    error_message = "Допустимые типы диска: network-hdd, network-ssd, network-ssd-nonreplicated."
  }
}

variable "subnet_id" {
  description = "ID подсети, в которую будет подключена ВМ"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH публичный ключ для доступа к ВМ"
  type        = string
  sensitive   = true
}

variable "image_id" {
  description = "ID образа ОС для загрузочного диска"
  type        = string
  default     = "fd8kdq6d0p8sij7h5qe3" # Ubuntu 20.04 LTS
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "platform_id" {
  description = "Платформа ВМ (standard-v1, standard-v2, standard-v3)"
  type        = string
  default     = "standard-v3"
}