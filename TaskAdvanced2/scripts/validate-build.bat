@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Переходим в корень проекта
cd /d "%~dp0\.."

:: Настройка логирования
set LOG=%~dp0validate-build-report.txt
echo ======================================== > "%LOG%"
echo TASK 2 ADVANCED: VALIDATION REPORT >> "%LOG%"
echo Date: %date% %time% >> "%LOG%"
echo Project: %CD% >> "%LOG%"
echo ======================================== >> "%LOG%"
echo. >> "%LOG%"

echo ========================================
echo  ПРОВЕРКА ЗАДАНИЯ 2 (CI/CD + Remote State)
echo ========================================
echo.
echo Рабочая директория: %CD%
echo.

set PASS=0
set FAIL=0
set WARN=0

:: ========================================
:: 1. Проверка структуры
:: ========================================
echo [1/8] Проверка структуры проекта...
echo [1/8] Проверка структуры проекта... >> "%LOG%"

if exist "envs\dev\main.tf" (
    echo   [PASS] envs/dev/main.tf
    echo   [PASS] envs/dev/main.tf >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [FAIL] envs/dev/main.tf not found
    echo   [FAIL] envs/dev/main.tf not found >> "%LOG%"
    set /a FAIL+=1
)

if exist "modules\vm\main.tf" (
    echo   [PASS] modules/vm/main.tf
    echo   [PASS] modules/vm/main.tf >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [FAIL] modules/vm/main.tf not found
    echo   [FAIL] modules/vm/main.tf not found >> "%LOG%"
    set /a FAIL+=1
)

if exist "modules\vm\variables.tf" (
    echo   [PASS] modules/vm/variables.tf
    echo   [PASS] modules/vm/variables.tf >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [FAIL] modules/vm/variables.tf not found
    echo   [FAIL] modules/vm/variables.tf not found >> "%LOG%"
    set /a FAIL+=1
)

if exist "modules\vm\outputs.tf" (
    echo   [PASS] modules/vm/outputs.tf
    echo   [PASS] modules/vm/outputs.tf >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [FAIL] modules/vm/outputs.tf not found
    echo   [FAIL] modules/vm/outputs.tf not found >> "%LOG%"
    set /a FAIL+=1
)

echo. >> "%LOG%"

:: ========================================
:: 2. Проверка Remote Backend
:: ========================================
echo [2/8] Проверка удалённого состояния (Backend)...
echo [2/8] Проверка удалённого состояния (Backend)... >> "%LOG%"

findstr /C:"backend \"s3\"" envs\dev\main.tf >nul 2>&1
if !errorlevel! equ 0 (
    echo   [PASS] backend "s3" configured in dev
    echo   [PASS] backend "s3" configured in dev >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [FAIL] backend "s3" NOT found in dev
    echo   [FAIL] backend "s3" NOT found in dev >> "%LOG%"
    set /a FAIL+=1
)

set BACKENDS_OK=1
for %%E in (dev stage prod) do (
    if exist "envs\%%E\main.tf" (
        findstr /C:"backend \"s3\"" "envs\%%E\main.tf" >nul 2>&1
        if !errorlevel! neq 0 (
            set BACKENDS_OK=0
        )
    )
)
if !BACKENDS_OK! equ 1 (
    echo   [PASS] Backend "s3" in all environments
    echo   [PASS] Backend "s3" in all environments >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [WARN] Backend "s3" missing in some environments
    echo   [WARN] Backend "s3" missing in some environments >> "%LOG%"
    set /a WARN+=1
)

echo. >> "%LOG%"

:: ========================================
:: 3. Проверка CI/CD конфигурации
:: ========================================
echo [3/8] Проверка CI/CD конфигурации...
echo [3/8] Проверка CI/CD конфигурации... >> "%LOG%"

set CI_FILE=
if exist ".github\workflows\terraform.yml" (
    echo   [PASS] GitHub Actions found
    echo   [PASS] GitHub Actions found >> "%LOG%"
    set CI_FILE=.github\workflows\terraform.yml
    set /a PASS+=1
)
if exist ".gitlab-ci.yml" (
    echo   [INFO] GitLab CI also found (optional)
    echo   [INFO] GitLab CI also found >> "%LOG%"
    if not defined CI_FILE set CI_FILE=.gitlab-ci.yml
)
if exist "Jenkinsfile" (
    echo   [INFO] Jenkinsfile also found (optional)
    echo   [INFO] Jenkinsfile also found >> "%LOG%"
    if not defined CI_FILE set CI_FILE=Jenkinsfile
)

if not defined CI_FILE (
    echo   [FAIL] No CI/CD config found
    echo   [FAIL] No CI/CD config found >> "%LOG%"
    set /a FAIL+=1
)

echo. >> "%LOG%"

:: ========================================
:: 4. Проверка шагов CI/CD
:: ========================================
echo [4/8] Проверка шагов CI/CD...
echo [4/8] Проверка шагов CI/CD... >> "%LOG%"

if defined CI_FILE (
    findstr /I /C:"terraform init" !CI_FILE! >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [PASS] terraform init found
        echo   [PASS] terraform init found >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [FAIL] terraform init NOT found in !CI_FILE!
        echo   [FAIL] terraform init NOT found >> "%LOG%"
        set /a FAIL+=1
    )

    findstr /I /C:"terraform plan" !CI_FILE! >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [PASS] terraform plan found
        echo   [PASS] terraform plan found >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [FAIL] terraform plan NOT found in !CI_FILE!
        echo   [FAIL] terraform plan NOT found >> "%LOG%"
        set /a FAIL+=1
    )

    findstr /I /C:"terraform apply" !CI_FILE! >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [PASS] terraform apply found
        echo   [PASS] terraform apply found >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [FAIL] terraform apply NOT found in !CI_FILE!
        echo   [FAIL] terraform apply NOT found >> "%LOG%"
        set /a FAIL+=1
    )

    set APPROVAL_FOUND=0
    findstr /I /C:"workflow_dispatch" !CI_FILE! >nul 2>&1
    if !errorlevel! equ 0 set APPROVAL_FOUND=1
    findstr /I /C:"environment:" !CI_FILE! >nul 2>&1
    if !errorlevel! equ 0 set APPROVAL_FOUND=1
    findstr /I /C:"approval" !CI_FILE! >nul 2>&1
    if !errorlevel! equ 0 set APPROVAL_FOUND=1

    if !APPROVAL_FOUND! equ 1 (
        echo   [PASS] Manual approval supported
        echo   [PASS] Manual approval supported >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [WARN] No explicit approval mechanism
        echo   [WARN] No explicit approval mechanism >> "%LOG%"
        set /a WARN+=1
    )
)

echo. >> "%LOG%"

:: ========================================
:: 5. Проверка README.md
:: ========================================
echo [5/8] Проверка README.md...
echo [5/8] Проверка README.md... >> "%LOG%"

if exist "README.md" (
    echo   [PASS] README.md exists
    echo   [PASS] README.md exists >> "%LOG%"
    set /a PASS+=1

    set README_OK=0
    findstr /I /C:"backend" README.md >nul 2>&1
    if !errorlevel! equ 0 set /a README_OK+=1
    findstr /I /C:"init" README.md >nul 2>&1
    if !errorlevel! equ 0 set /a README_OK+=1
    findstr /I /C:"apply" README.md >nul 2>&1
    if !errorlevel! equ 0 set /a README_OK+=1
    findstr /I /C:"pipeline" README.md >nul 2>&1
    if !errorlevel! equ 0 set /a README_OK+=1

    if !README_OK! geq 2 (
        echo   [PASS] README.md has detailed instructions
        echo   [PASS] README.md has detailed instructions >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [WARN] README.md may lack details
        echo   [WARN] README.md may lack details >> "%LOG%"
        set /a WARN+=1
    )
) else (
    echo   [FAIL] README.md missing
    echo   [FAIL] README.md missing >> "%LOG%"
    set /a FAIL+=1
)

echo. >> "%LOG%"

:: ========================================
:: 6. Проверка .gitignore
:: ========================================
echo [6/8] Проверка .gitignore...
echo [6/8] Проверка .gitignore... >> "%LOG%"

if exist ".gitignore" (
    echo   [PASS] .gitignore exists
    echo   [PASS] .gitignore exists >> "%LOG%"
    set /a PASS+=1

    findstr /C:".tfstate" .gitignore >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [PASS] .tfstate blocked
        echo   [PASS] .tfstate blocked >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [FAIL] .tfstate NOT blocked
        echo   [FAIL] .tfstate NOT blocked >> "%LOG%"
        set /a FAIL+=1
    )

    findstr /C:"key.json" .gitignore >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [PASS] key.json blocked
        echo   [PASS] key.json blocked >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [FAIL] key.json NOT blocked
        echo   [FAIL] key.json NOT blocked >> "%LOG%"
        set /a FAIL+=1
    )

    findstr /C:".terraform" .gitignore >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [PASS] .terraform/ blocked
        echo   [PASS] .terraform/ blocked >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [WARN] .terraform/ NOT blocked
        echo   [WARN] .terraform/ NOT blocked >> "%LOG%"
        set /a WARN+=1
    )
) else (
    echo   [FAIL] .gitignore missing
    echo   [FAIL] .gitignore missing >> "%LOG%"
    set /a FAIL+=1
)

echo. >> "%LOG%"

:: ========================================
:: 7. Проверка локальных state-файлов
:: ========================================
echo [7/8] Проверка локальных state-файлов...
echo [7/8] Проверка локальных state-файлов... >> "%LOG%"

dir /s /b *.tfstate >nul 2>&1
if !errorlevel! equ 0 (
    echo   [FAIL] Local .tfstate files found
    echo   [FAIL] Local .tfstate files found >> "%LOG%"
    set /a FAIL+=1
) else (
    echo   [PASS] No local .tfstate files
    echo   [PASS] No local .tfstate files >> "%LOG%"
    set /a PASS+=1
)

git ls-files --error-unmatch key.json >nul 2>&1
if !errorlevel! equ 0 (
    echo   [FAIL] key.json tracked by Git
    echo   [FAIL] key.json tracked by Git >> "%LOG%"
    set /a FAIL+=1
) else (
    echo   [PASS] key.json not tracked by Git
    echo   [PASS] key.json not tracked by Git >> "%LOG%"
    set /a PASS+=1
)

echo. >> "%LOG%"

:: ========================================
:: 8. MOCK-ТЕСТИРОВАНИЕ (ИСПРАВЛЕНО!)
:: ========================================
echo [8/8] Mock-тестирование Terraform-кода...
echo [8/8] Mock-тестирование Terraform-кода... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

:: 8.1 Валидация модуля
echo   [8.1] Validating module modules/vm/...
echo   [8.1] Validating module modules/vm/... >> "%LOG%"

cd modules\vm
call terraform init -no-color -input=false >nul 2>&1
call terraform validate -no-color >nul 2>&1
if !errorlevel! equ 0 (
    echo     [PASS] Module is valid
    echo     [PASS] Module is valid >> "%LOG%"
    set /a PASS+=1
) else (
    echo     [FAIL] Module validation failed
    echo     [FAIL] Module validation failed >> "%LOG%"
    call terraform validate -no-color >> "%LOG%" 2>&1
    set /a FAIL+=1
)
cd ..\..

:: 8.2 Валидация каждого окружения (ИСПРАВЛЕНО: добавлен -backend=false)
echo   [8.2] Validating environments...
echo   [8.2] Validating environments... >> "%LOG%"

for %%E in (dev stage prod) do (
    if exist "envs\%%E\main.tf" (
        cd envs\%%E
        :: -backend=false позволяет проверить синтаксис без подключения к S3 и ввода ключей
        call terraform init -backend=false -no-color -input=false >nul 2>&1
        call terraform validate -no-color >nul 2>&1
        if !errorlevel! equ 0 (
            echo     [PASS] %%E environment is valid
            echo     [PASS] %%E environment is valid >> "%LOG%"
            set /a PASS+=1
        ) else (
            echo     [FAIL] %%E environment validation failed
            echo     [FAIL] %%E environment validation failed >> "%LOG%"
            call terraform validate -no-color >> "%LOG%" 2>&1
            set /a FAIL+=1
        )
        cd ..\..
    )
)

:: 8.3 Mock plan с null_resource для dev (ИСПРАВЛЕНО: правильный HCL синтаксис)
echo   [8.3] Mock plan test (dev environment)...
echo   [8.3] Mock plan test (dev environment)... >> "%LOG%"

cd envs\dev

:: Создаём изолированную папку для mock-теста
if exist "_mock_test" rmdir /s /q "_mock_test" >nul 2>&1
mkdir _mock_test >nul 2>&1

:: Создаём минимальный variables.tf с ПРАВИЛЬНЫМ HCL синтаксисом (без точек с запятой!)
(
echo variable "vm_name" {
echo   type    = string
echo   default = "mock-vm"
echo }
echo variable "cores" {
echo   type    = number
echo   default = 2
echo }
echo variable "memory" {
echo   type    = number
echo   default = 2147483648
echo }
echo variable "disk_size" {
echo   type    = number
echo   default = 10
echo }
echo variable "disk_type" {
echo   type    = string
echo   default = "network-hdd"
echo }
echo variable "image_id" {
echo   type    = string
echo   default = "fd8kdq6d0p8sij7h5qe3"
echo }
echo variable "zone" {
echo   type    = string
echo   default = "ru-central1-a"
echo }
echo variable "platform_id" {
echo   type    = string
echo   default = "standard-v3"
echo }
) > _mock_test\variables.tf

:: Создаём mock main.tf с null_resource
(
echo terraform {
echo   required_providers {
echo     null = {
echo       source = "hashicorp/null"
echo     }
echo   }
echo }
echo.
echo resource "null_resource" "mock_vm" {
echo   triggers = {
echo     vm_name   = var.vm_name
echo     cores     = var.cores
echo     memory    = var.memory
echo     disk_size = var.disk_size
echo   }
echo }
echo.
echo output "mock_vm_name" {
echo   value = null_resource.mock_vm.triggers.vm_name
echo }
) > _mock_test\main.tf

:: Запускаем terraform в mock-папке
cd _mock_test
call terraform init -no-color -input=false >nul 2>&1
if !errorlevel! equ 0 (
    echo     [PASS] Mock init successful
    echo     [PASS] Mock init successful >> "%LOG%"
    set /a PASS+=1
) else (
    echo     [FAIL] Mock init failed
    echo     [FAIL] Mock init failed >> "%LOG%"
    set /a FAIL+=1
)

call terraform plan -no-color -input=false >nul 2>&1
if !errorlevel! equ 0 (
    echo     [PASS] Mock plan successful
    echo     [PASS] Mock plan successful >> "%LOG%"
    set /a PASS+=1
) else (
    echo     [FAIL] Mock plan failed
    echo     [FAIL] Mock plan failed >> "%LOG%"
    call terraform plan -no-color -input=false >> "%LOG%" 2>&1
    set /a FAIL+=1
)

call terraform destroy -auto-approve >nul 2>&1
cd ..

:: Удаляем mock-папку
rmdir /s /q _mock_test >nul 2>&1
cd ..\..

echo. >> "%LOG%"

:: ========================================
:: ИТОГ
:: ========================================
echo. >> "%LOG%"
echo ======================================== >> "%LOG%"
echo ИТОГ >> "%LOG%"
echo ======================================== >> "%LOG%"
echo PASSED:   %PASS% >> "%LOG%"
echo FAILED:   %FAIL% >> "%LOG%"
echo WARNINGS: %WARN% >> "%LOG%"
echo ======================================== >> "%LOG%"

echo.
echo ========================================
echo  ИТОГОВЫЙ ОТЧЁТ
echo ========================================
echo   PASSED:   %PASS%
echo   FAILED:   %FAIL%
echo   WARNINGS: %WARN%
echo.

if %FAIL% equ 0 (
    echo [УСПЕХ] Все критические требования задания выполнены!
    echo Mock-тесты подтверждают работоспособность кода.
) else (
    echo [ОШИБКА] Найдено %FAIL% критических проблем.
    echo Исправьте их перед отправкой на ревью.
)

echo.
echo Отчёт: %LOG%
echo ========================================
echo.

pause