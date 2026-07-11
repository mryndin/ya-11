output "vm_id" {
  description = "ID виртуальной машины"
  value       = yandex_compute_instance.this.id
}

output "vm_name" {
  description = "Имя виртуальной машины"
  value       = yandex_compute_instance.this.name
}

output "vm_ip_internal" {
  description = "Внутренний IP-адрес ВМ"
  value       = yandex_compute_instance.this.network_interface[0].ip_address
}

output "vm_ip_external" {
  description = "Внешний (публичный) IP-адрес ВМ"
  value       = yandex_compute_instance.this.network_interface[0].nat_ip_address
}

output "disk_id" {
  description = "ID подключённого диска"
  value       = yandex_compute_disk.this.id
}

output "disk_name" {
  description = "Имя диска"
  value       = yandex_compute_disk.this.name
}

output "fqdn" {
  description = "FQDN виртуальной машины"
  value       = yandex_compute_instance.this.fqdn
}

output "platform_id" {
  description = "Платформа ВМ"
  value       = yandex_compute_instance.this.platform_id
}

output "zone" {
  description = "Зона доступности"
  value       = yandex_compute_instance.this.zone
}