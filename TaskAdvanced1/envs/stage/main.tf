terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.90"
    }
  }
}

provider "yandex" {
  zone                      = var.zone
  folder_id                 = var.folder_id
  cloud_id                  = var.cloud_id
  service_account_key_file  = "../../key.json"
}

module "dev_vm" {
  source         = "../../modules/vm"
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