:: Переходим в папку envs/dev (если ещё не там)
cd E:\work\Yandex\Sprints\ya-11\TaskAdvanced1\envs\dev

:: Инициализация Terraform (скачает провайдер Yandex Cloud)
terraform init

:: Просмотр плана (что будет создано)
terraform plan -var-file="dev.tfvars"

:: Создание ресурсов (введите "yes" когда спросит)
terraform apply -var-file="dev.tfvars"