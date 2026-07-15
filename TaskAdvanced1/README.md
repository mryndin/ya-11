
#  TaskAdvanced1 — Модульная инфраструктура Terraform

## Описание

Переиспользуемый модуль Terraform для развёртывания виртуальных машин в Yandex Cloud.
Модуль поддерживает три окружения: **dev**, **stage**, **prod**, каждое со своей конфигурацией ресурсов.

## Структура проекта

```
TaskAdvanced1/
├── modules/
│   └── vm/                    # Переиспользуемый модуль ВМ
│       ├── main.tf            # Ресурсы: ВМ + диск + сеть
│       ├── variables.tf       # Входные параметры модуля
│       └── outputs.tf         # Выходные значения
── envs/
│   ├── dev/                   # Окружение разработки
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── dev.tfvars
│   ├── stage/                 # Окружение тестирования
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── stage.tfvars
│   └── prod/                  # Продуктовое окружение
│       ├── main.tf
│       ├── variables.tf
│       └── prod.tfvars
├── validate-all.bat           # Скрипт автоматической валидации
├── validation-log.txt         # Лог последней проверки
├── validation-report.txt      # Краткий отчёт о проверке
└── README.md
```

## Параметры модуля `vm_module`

| Параметр | Тип | Описание | Значение по умолчанию |
|----------|-----|----------|----------------------|
| `vm_name` | string | Имя виртуальной машины | `default-vm` |
| `cores` | number | Количество ядер CPU | `2` |
| `memory` | number | Объём RAM в байтах | `2147483648` (2 GB) |
| `disk_size` | number | Размер диска в **GB** | `10` |
| `disk_type` | string | Тип диска (`network-hdd`, `network-ssd`, `network-ssd-nonreplicated`) | `network-hdd` |
| `subnet_id` | string | ID подсети | — (обязательный) |
| `ssh_public_key` | string | SSH публичный ключ | — (обязательный, sensitive) |
| `image_id` | string | ID образа ОС | Ubuntu 20.04 LTS |
| `zone` | string | Зона доступности | `ru-central1-a` |
| `platform_id` | string | Платформа ВМ | `standard-v3` |
| `folder_id` | string | ID каталога Yandex Cloud | — (обязательный) |
| `cloud_id` | string | ID облака Yandex Cloud | — (обязательный) |

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

## Предварительные требования

1. Установить [Terraform](https://terraform.io/downloads) >= 1.0
2. Настроить [Yandex Cloud CLI](https://cloud.yandex.ru/docs/cli/quickstart)
3. Авторизоваться: `yc init`
4. Активировать промокод на 4000₽ в [Billing](https://console.cloud.yandex.ru/billing)
5. Создать сервисный аккаунт с ролью `admin`:
   ```bash
   yc iam service-account create --name terraform-sa
   yc resource-manager folder add-access-binding <FOLDER_ID> --role admin --subject serviceAccount:<SA_ID>
   yc iam key create --service-account-id <SA_ID> --output key.json
   ```
6. Получить `cloud_id`, `folder_id`, `subnet_id` через CLI или консоль

## Запуск

### Для окружения dev
```bash
cd envs/dev
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### Для окружения stage
```bash
cd envs/stage
terraform init
terraform plan -var-file="stage.tfvars"
terraform apply -var-file="stage.tfvars"
```

### Для окружения prod
```bash
cd envs/prod
terraform init
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

## Удаление ресурсов

```bash
terraform destroy -var-file="<окружение>.tfvars"
```

## Аутентификация

Есть два способа аутентификации:

### Способ 1: Через переменную окружения (временный токен)
```bash
yc iam create-token
set YC_TOKEN=<полученный_токен>
terraform apply -var-file="dev.tfvars"
```
⚠️ Токен действует 1 час.

### Способ 2: Через ключ сервисного аккаунта (рекомендуется)
```bash
set GOOGLE_APPLICATION_CREDENTIALS=%CD%\key.json
terraform apply -var-file="dev.tfvars"
```
Или указать в `main.tf`:
```hcl
provider "yandex" {
  service_account_key_file = "../../key.json"
}
```

## Автоматическая валидация

Проект включает скрипт **`validate-all.bat`**, который проверяет:

- ✅ Структуру файлов (модуль, окружения, README)
- ✅ Инициализацию и валидацию модуля
- ✅ Валидацию всех трёх окружений (dev, stage, prod)
- ✅ Наличие всех outputs (vm_id, vm_ip_external, disk_id и др.)
- ✅ Определение всех переменных в module
- ✅ Отсутствие захардкоженных значений
- ✅ Наличие обязательных параметров в .tfvars
- ✅ Локальный mock-тест с null_resource

### Запуск валидации
```cmd
validate-all.bat
```

Результаты сохраняются в:
- `validation-log.txt` — детальный лог всех проверок
- `validation-report.txt` — краткий отчёт (PASSED/FAILED/WARNINGS)

## Безопасность

- SSH-ключи помечены как `sensitive` и не выводятся в логах
- Не храните `.tfvars` файлы с секретами в публичном репозитории — добавьте их в `.gitignore`
- Для prod-окружения рекомендуется использовать remote state и backend с шифрованием
- Используйте сервисный аккаунт вместо IAM-токена для долгосрочной работы

## Troubleshooting

### Ошибка "PermissionDenied"
```bash
yc resource-manager folder add-access-binding <FOLDER_ID> --role admin --subject serviceAccount:<SA_ID>
```

### Ошибка "Authentication failed"
Токен истёк. Получите новый:
```bash
yc iam create-token
set YC_TOKEN=<новый_токен>
```

### Ошибка "Reference to undeclared input variable"
Убедитесь, что в папке окружения есть файл `variables.tf` с объявлением всех переменных.

### Ошибка "disk size must be in range"
Размер диска указывается в **GB**, а не в байтах:
```hcl
disk_size = 10   # ✅ Правильно (10 GB)
disk_size = 10737418240  # ❌ Неправильно
```

## Особенности

- **Переиспользуемость**: модуль `vm_module` не содержит захардкоженных значений окружений
- **Валидация**: параметры `cores` и `disk_type` валидируются на уровне модуля
- **Масштабируемость**: модуль можно использовать для развёртывания множества ВМ через `for_each`
- **Изоляция окружений**: каждое окружение имеет свой `main.tf`, `variables.tf` и `.tfvars`

## Лицензия

MIT