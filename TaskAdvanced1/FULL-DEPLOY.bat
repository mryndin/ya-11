@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo FULL AUTOMATIC DEPLOYMENT
echo ========================================
echo.

:: ========================================
:: ЧАСТЬ 1: ПОЛНАЯ ОЧИСТКА
:: ========================================
echo === PART 1: COMPLETE CLEANUP ===
echo.

echo [1/10] Destroying Terraform resources...
cd envs\dev 2>nul
call terraform destroy -var-file="dev.tfvars" -auto-approve >nul 2>&1
cd ..\.. 2>nul

echo [2/10] Removing all local files...
del /q envs\dev\terraform.tfstate >nul 2>&1
del /q envs\dev\terraform.tfstate.backup >nul 2>&1
del /q envs\dev\.terraform.lock.hcl >nul 2>&1
rmdir /s /q envs\dev\.terraform >nul 2>&1
del /q key.json >nul 2>&1
del /q .terraformrc >nul 2>&1

echo [3/10] Deleting Yandex Cloud resources...
yc iam service-account delete --name terraform-sa >nul 2>&1
yc vpc subnet delete --name future20-subnet >nul 2>&1
timeout /t 2 >nul
yc vpc network delete --name future20-network >nul 2>&1
timeout /t 2 >nul
echo     Cleanup complete
echo.

:: ========================================
:: ЧАСТЬ 2: СОЗДАНИЕ ИНФРАСТРУКТУРЫ
:: ========================================
echo === PART 2: CREATE INFRASTRUCTURE ===
echo.

echo [4/10] Creating network...
yc vpc network create --name future20-network
yc vpc subnet create --name future20-subnet --zone ru-central1-a --range 10.0.1.0/24 --network-name future20-network
echo     Network created
echo.

echo [5/10] Creating service account...
yc iam service-account create --name terraform-sa --description "Terraform SA"
timeout /t 3 >nul
echo.

echo [6/10] Getting service account ID...
:: Получаем ID сервисного аккаунта через get
for /f "tokens=2 delims= " %%i in ('yc iam service-account get --name terraform-sa 2^>nul ^| findstr "^id:"') do (
    set SA_ID=%%i
)

:: Если не получилось, пробуем через list
if "!SA_ID!"=="" (
    echo     Trying alternative method...
    for /f "tokens=1 delims= " %%i in ('yc iam service-account list --folder-name default 2^>nul ^| findstr "terraform-sa"') do (
        set SA_ID=%%i
    )
)

if "!SA_ID!"=="" (
    echo     ERROR: Could not get SA_ID automatically
    echo.
    echo     Please run manually:
    echo     yc iam service-account list
    echo.
    set /p SA_ID=Enter SA_ID manually: 
) else (
    echo     Service Account ID: !SA_ID!
)
echo.

echo [7/10] Adding admin role...
yc resource-manager folder add-access-binding b1gjjmj53mtbgtqsfvq0 --role admin --subject serviceAccount:!SA_ID!
timeout /t 2 >nul
echo     Role added
echo.

echo [8/10] Creating service account key...
yc iam key create --service-account-id !SA_ID! --output key.json
if not exist key.json (
    echo     ERROR: Key not created!
    pause
    exit /b 1
)
echo     Key created: key.json
echo.

:: ========================================
:: ЧАСТЬ 3: TERRAFORM
:: ========================================
echo === PART 3: TERRAFORM DEPLOYMENT ===
echo.

echo [9/10] Initializing Terraform...
cd envs\dev

:: Создаем временный файл для проверки
if not exist ..\..\key.json (
    echo     ERROR: key.json not found!
    cd ..\..
    pause
    exit /b 1
)

:: Инициализация
call terraform init -upgrade

if %errorlevel% neq 0 (
    echo     ERROR: Terraform init failed
    cd ..\..
    pause
    exit /b 1
)
echo     Terraform initialized
echo.

echo [10/10] Deploying infrastructure...
echo     This will take 3-5 minutes...
echo.

:: Устанавливаем переменную окружения
set GOOGLE_APPLICATION_CREDENTIALS=..\..\key.json

:: Запуск apply
call terraform apply -var-file="dev.tfvars" -auto-approve

cd ..\..

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo SUCCESS!
    echo ========================================
    echo.
    echo Infrastructure deployed successfully!
    echo.
    echo To connect to VM:
    echo   ssh -i C:\Users\micha\.ssh\future20_vm ubuntu@^<EXTERNAL_IP^>
    echo.
) else (
    echo.
    echo ========================================
    echo DEPLOYMENT FAILED
    echo ========================================
    echo.
    echo Check error messages above.
    echo.
    echo Common issues:
    echo   1. Check permissions: yc resource-manager folder list-access-bindings b1gjjmj53mtbgtqsfvq0
    echo   2. Check quota in Yandex Cloud console
    echo   3. Try again with: terraform apply -var-file="dev.tfvars"
)

echo.
pause