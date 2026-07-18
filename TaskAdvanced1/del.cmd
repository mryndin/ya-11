:: 1. Удаляем всё, что создал Terraform
terraform destroy -var-file="dev.tfvars"

:: 2. Если не сработало, удаляем вручную через yc
yc compute instance delete --name dev-future20-vm
yc compute disk delete --name dev-future20-vm-disk

:: 3. Очищаем состояние
del terraform.tfstate
del -Force .terraform.lock.hcl

:: 4. Инициализируем заново
terraform init

:: 5. Запускаем заново
terraform apply -var-file="dev.tfvars"