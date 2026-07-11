variable "cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "vm_name" {
  description = "Имя ВМ"
  type        = string
}

variable "cores" {
  description = "Количество ядер CPU"
  type        = number
}

variable "memory" {
  description = "Объём RAM в байтах"
  type        = number
}

variable "disk_size" {
  description = "Размер диска в байтах"
  type        = number
}

variable "disk_type" {
  description = "Тип диска"
  type        = string
}

variable "subnet_id" {
  description = "ID подсети"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH публичный ключ"
  type        = string
  sensitive   = true
}

variable "image_id" {
  description = "ID образа ОС"
  type        = string
}

variable "platform_id" {
  description = "Платформа ВМ"
  type        = string
}