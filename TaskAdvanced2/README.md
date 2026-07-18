# 🚀 Task2Advanced — CI/CD с удалённым состоянием

## Описание
Автоматизация развёртывания инфраструктуры Yandex Cloud через GitHub Actions с использованием удалённого состояния в Yandex Object Storage (S3-совместимое хранилище). Состояние **не хранится локально** и защищено версионированием.

## Архитектура безопасности
1. **Удалённое состояние**: Хранится в S3-бакете `ya-11-terraform-state-dev` с включённым versioning.
2. **Секреты**: Файл `key.json` и `.tfvars` **никогда не попадают в Git** (блокируются `.gitignore`).
3. **CI/CD**: Ключи передаются в pipeline исключительно через GitHub Secrets (`YC_SA_KEY_JSON`).
4. **Изоляция**: Разделение на окружения (`dev`, `stage`, `prod`) с отдельными ключами состояния (`dev/terraform.tfstate`).

## Структура проекта
```text
Task2Advanced/
├── modules/vm/              # Переиспользуемый модуль ВМ
├── envs/dev/                # Конфигурация окружения dev
│   ├── main.tf              # С блоком backend "s3"
│   ├── variables.tf
│   └── dev.tfvars
├── scripts/
│   ├── init-backend.bat     # CMD-скрипт создания бакета
│   └── validate-build.bat   # CMD-скрипт проверки сборки
├── .github/workflows/
│   └── terraform.yml        # CI/CD pipeline с approval
├── .gitignore               # Защита от утечки секретов
└── README.md
```

## Локальная настройка (Windows CMD)

### 1. Предварительные требования
- Установлен [Yandex Cloud CLI](https://cloud.yandex.ru/docs/cli/quickstart)
- Выполнена авторизация: `yc init`
- Файл `key.json` находится в корне `Task2Advanced`

### 2. Инициализация удалённого бэкенда
Выполните скрипт для создания бакета и включения версионирования:
```cmd
cd Task2Advanced
scripts\init-backend.bat
```

### 3. Локальная проверка
Выполните скрипт для проверки локально:
```cmd
cd Task2Advanced
scripts\validate-build.bat
```


### 4. Локальный запуск Terraform
```cmd
cd envs\dev
terraform init -backend-config="access_key=aje72fn32mvs0kitq931" -backend-config="secret_key=<ваш_private_key_из_key.json>"
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```
*(Примечание: для локальной работы убедитесь, что путь `service_account_key_file` в `dev.tfvars` указывает на ваш `key.json`)*

## CI/CD Pipeline (GitHub Actions)

### Настройка репозитория
1. Перейдите в **Settings → Secrets and variables → Actions**.
2. Добавьте секрет `YC_SA_KEY_JSON`: скопируйте **всё содержимое** файла `key.json` (от `{` до `}`).
3. (Опционально) Настройте **Environments** (`dev`, `stage`, `prod`) в Settings, добавив правило **Required reviewers** для `stage` и `prod`, чтобы требовалось ручное подтверждение (approval).

### Триггеры
- **Pull Request**: Автоматически запускает `terraform fmt`, `validate` и `plan`. Результат плана можно увидеть в логах.
- **Manual Dispatch (Run workflow)**: Позволяет вручную выбрать окружение и действие (`plan`, `apply`, `destroy`). Действие `apply` для защищённых окружений потребует одобрения ревьюера.

## Проверка для ревьюера
- ✅ Состояние хранится удалённо (блок `backend "s3"` в `main.tf`).
- ✅ Файлы `.tfstate`, `.terraform/` и `key.json` добавлены в `.gitignore`.
- ✅ Pipeline использует GitHub Secrets для аутентификации, ключи не захардкожены.
- ✅ Применяется принцип изоляции окружений через отдельные ключи в бакете (`key = "dev/terraform.tfstate"`).

---

### 🔐 Как настроить GitHub Secrets (Пошагово)

1. Откройте ваш `key.json`.
2. В GitHub перейдите в ваш репозиторий → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.
3. Name: `YC_SA_KEY_JSON`
4. Secret: Вставьте **весь текст** из `key.json` (включая `{`, `"id"`, `"private_key"` и `}`).
5. Нажмите **Add secret**.

*(Дополнительно: в GitHub Settings → Environments создайте окружение `dev` без ограничений, а `stage` и `prod` с галочкой "Required reviewers", чтобы ревьюер увидел механизм approval).*

---

### ✅ Чек-лист перед созданием Pull Request:
- [ ] Файл `key.json` **НЕ** закоммичен в Git (проверьте `git status`).
- [ ] Папка `.terraform/` **НЕ** закоммичена.
- [ ] Скрипт `scripts/init-backend.bat` работает и создаёт бакет.
- [ ] В `envs/dev/main.tf` присутствует блок `backend "s3"`.
- [ ] В `.github/workflows/terraform.yml` прописаны шаги `init`, `plan`, `apply`.
- [ ] `README.md` содержит описание скриптов и логики CI/CD.
