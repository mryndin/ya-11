terraform {
  required_version = ">= 1.0"
  
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.90"
    }
  }
  
  # Удалённое состояние в Yandex Object Storage (S3-совместимое)
  backend "s3" {
    endpoint          = "https://storage.yandexcloud.net"
    bucket            = "ya-11-terraform-state-dev"
    key               = "dev/terraform.tfstate"
    region            = "ru-central1"
    
    # Обязательно для Yandex Object Storage
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

provider "yandex" {
  zone                     = var.zone
  folder_id                = var.folder_id
  cloud_id                 = var.cloud_id
  service_account_key_file = var.service_account_key_file
}

module "dev_vm" {
  source = "../../modules/vm"
  
  vm_name        = var.vm_name
  cores          = var.cores
  memory         = var.memory
  disk_size      = var.disk_size
  disk_type      = var.disk_type
  subnet_id      = var.subnet_id
  ssh_public_key = var.ssh_public_key
  image_id       = var.image_id
  zone           = var.zone
  platform_id    = var.platform_id
}

output "vm_id" {
  value = module.dev_vm.vm_id
}

output "vm_ip_external" {
  value = module.dev_vm.vm_ip_external
}

output "vm_ip_internal" {
  value = module.dev_vm.vm_ip_internal
}

output "disk_id" {
  value = module.dev_vm.disk_id
}