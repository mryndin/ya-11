## 📖 3. README.md

# Task1Advanced — Модульная инфраструктура Terraform

## Описание

Переиспользуемый модуль Terraform для развёртывания виртуальных машин в Yandex Cloud. 
Модуль поддерживает три окружения: **dev**, **stage**, **prod**, каждое со своей конфигурацией ресурсов.

## Структура

/Task1Advanced/
├── modules/vm/          # Переиспользуемый модуль ВМ
│   ├── main.tf          # Ресурсы: ВМ + диск + сеть
│   ├── variables.tf     # Входные параметры модуля
│   └── outputs.tf       # Выходные значения
├── envs/
│   ├── dev/             # Окружение разработки
│   ├── stage/           # Окружение тестирования
│   └── prod/            # Продуктивное окружение
── README.md

## Параметры модуля `vm_module`

| Параметр | Тип | Описание | Значение по умолчанию |
|----------|-----|----------|----------------------|
| `vm_name` | string | Имя виртуальной машины | `default-vm` |
| `cores` | number | Количество ядер CPU | `2` |
| `memory` | number | Объём RAM в байтах | `2147483648` (2 GB) |
| `disk_size` | number | Размер диска в байтах | `10737418240` (10 GB) |
| `disk_type` | string | Тип диска | `network-hdd` |
| `subnet_id` | string | ID подсети | — (обязательный) |
| `ssh_public_key` | string | SSH публичный ключ | — (обязательный) |
| `image_id` | string | ID образа ОС | Ubuntu 20.04 LTS |
| `zone` | string | Зона доступности | `ru-central1-a` |
| `platform_id` | string | Платформа ВМ | `standard-v3` |

## Выходы (Outputs)

| Выход | Описание |
|-------|----------|
| `vm_id` | ID виртуальной машины |
| `vm_name` | Имя ВМ |
| `vm_ip_internal` | Внутренний IP-адрес |
| `vm_ip_external` | Публичный IP-адрес |
| `disk_id` | ID подключённого диска |
| `disk_name` | Имя диска |
| `fqdn` | FQDN ВМ |
| `platform_id` | Платформа ВМ |
| `zone` | Зона доступности |

## Различия окружений

| Параметр | dev | stage | prod |
|----------|-----|-------|------|
| CPU (cores) | 2 | 4 | 8 |
| RAM | 2 GB | 4 GB | 8 GB |
| Диск | 10 GB HDD | 20 GB SSD | 50 GB SSD-nonreplicated |
| Зона | ru-central1-a | ru-central1-b | ru-central1-a |

## Как запустить

### Предварительные требования

1. Установить [Terraform](https://terraform.io/downloads) >= 1.0
2. Настроить [Yandex Cloud CLI](https://cloud.yandex.ru/docs/cli/quickstart)
3. Авторизоваться: `yc init`
4. Создать сервисный аккаунт с ролью `compute.admin`
5. Получить `cloud_id`, `folder_id`, `subnet_id`

### Запуск для окружения dev

```bash
cd envs/dev
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### Запуск для окружения stage

```bash
cd envs/stage
terraform init
terraform plan -var-file="stage.tfvars"
terraform apply -var-file="stage.tfvars"
```

### Запуск для окружения prod

```bash
cd envs/prod
terraform init
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

### Удаление ресурсов

```bash
terraform destroy -var-file="<окружение>.tfvars"
```

## Безопасность

- SSH-ключи помечены как `sensitive` и не выводятся в логах
- Не храните `.tfvars` файлы с секретами в публичном репозитории — добавьте их в `.gitignore`
- Для prod-окружения рекомендуется использовать remote state и backend с шифрованием

## Особенности

- **Переиспользуемость**: модуль `vm_module` не содержит захардкоженных значений окружений
- **Валидация**: параметры `cores` и `disk_type` валидируются на уровне модуля
- **Масштабируемость**: модуль можно использовать для развёртывания множества ВМ через `for_each`
```

---
