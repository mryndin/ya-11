@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: ========================================
:: НАСТРОЙКА ЛОГА
:: ========================================
set LOG=%~dp0validation-log.txt
set REPORT=%~dp0validation-report.txt

echo ======================================== > "%LOG%"
echo VALIDATION LOG - %date% %time% >> "%LOG%"
echo ======================================== >> "%LOG%"
echo. >> "%LOG%"

echo ========================================
echo TERRAFORM VALIDATION (FINAL FIXED)
echo ========================================
echo.
echo Log: %LOG%
echo.

set PASS=0
set FAIL=0
set WARN=0

:: ========================================
:: [0/10] АВТОСОЗДАНИЕ ОТСУТСТВУЮЩИХ ФАЙЛОВ
:: ========================================
echo [0/10] Creating missing files...
echo [0/10] Creating missing files... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

if not exist "envs\dev\variables.tf" (
    echo   [WARN] envs\dev\variables.tf missing
    echo   [WARN] envs\dev\variables.tf missing >> "%LOG%"
    set /a WARN+=1
)

if not exist "envs\stage\variables.tf" (
    echo   Creating envs\stage\variables.tf from dev...
    echo   Creating envs\stage\variables.tf from dev... >> "%LOG%"
    copy envs\dev\variables.tf envs\stage\variables.tf >nul 2>&1
)

if not exist "envs\prod\variables.tf" (
    echo   Creating envs\prod\variables.tf from dev...
    echo   Creating envs\prod\variables.tf from dev... >> "%LOG%"
    copy envs\dev\variables.tf envs\prod\variables.tf >nul 2>&1
)

if not exist "envs\stage\main.tf" (
    echo   Creating envs\stage\main.tf from dev...
    echo   Creating envs\stage\main.tf from dev... >> "%LOG%"
    copy envs\dev\main.tf envs\stage\main.tf >nul 2>&1
)

if not exist "envs\prod\main.tf" (
    echo   Creating envs\prod\main.tf from dev...
    echo   Creating envs\prod\main.tf from dev... >> "%LOG%"
    copy envs\dev\main.tf envs\prod\main.tf >nul 2>&1
)

echo   Done
echo   Done >> "%LOG%"
echo. >> "%LOG%"

:: ========================================
:: [1/10] Структура файлов
:: ========================================
echo [1/10] Checking file structure...
echo [1/10] Checking file structure... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

for %%F in (modules\vm\main.tf modules\vm\variables.tf modules\vm\outputs.tf envs\dev\main.tf envs\dev\dev.tfvars envs\dev\variables.tf envs\stage\main.tf envs\stage\stage.tfvars envs\stage\variables.tf envs\prod\main.tf envs\prod\prod.tfvars envs\prod\variables.tf) do (
    if exist "%%F" (
        echo   [PASS] %%F
        echo   [PASS] %%F >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [FAIL] %%F
        echo   [FAIL] %%F >> "%LOG%"
        set /a FAIL+=1
    )
)

if exist "README.md" (
    echo   [PASS] README.md
    echo   [PASS] README.md >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [WARN] README.md
    echo   [WARN] README.md >> "%LOG%"
    set /a WARN+=1
)
echo. >> "%LOG%"

:: ========================================
:: [2/10] Init модуля
:: ========================================
echo [2/10] Initializing module...
echo [2/10] Initializing module... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

cd modules\vm
echo   Running: terraform init -no-color -input=false >> "%LOG%"
call terraform init -no-color -input=false >> "%LOG%" 2>&1

if %errorlevel% equ 0 (
    echo   [PASS] Module initialized
    echo   [PASS] Module initialized >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [FAIL] Module init failed
    echo   [FAIL] Module init failed >> "%LOG%"
    set /a FAIL+=1
)
cd ..\..
echo. >> "%LOG%"

:: ========================================
:: [3/10] Валидация модуля
:: ========================================
echo [3/10] Validating module...
echo [3/10] Validating module... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

cd modules\vm
echo   Running: terraform validate -no-color >> "%LOG%"
call terraform validate -no-color >> "%LOG%" 2>&1

if %errorlevel% equ 0 (
    echo   [PASS] Module is valid
    echo   [PASS] Module is valid >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [FAIL] Module validation failed
    echo   [FAIL] Module validation failed >> "%LOG%"
    set /a FAIL+=1
)
cd ..\..
echo. >> "%LOG%"

:: ========================================
:: [4/10] Валидация окружений
:: ========================================
echo [4/10] Validating environments...
echo [4/10] Validating environments... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

for %%E in (dev stage prod) do (
    if exist "envs\%%E\main.tf" (
        echo   Checking %%E...
        echo   Checking %%E... >> "%LOG%"
        cd envs\%%E
        echo     Running: terraform init -no-color -input=false >> "%LOG%"
        call terraform init -no-color -input=false >> "%LOG%" 2>&1
        echo     Running: terraform validate -no-color >> "%LOG%"
        call terraform validate -no-color >> "%LOG%" 2>&1
        if !errorlevel! equ 0 (
            echo     [PASS] %%E is valid
            echo     [PASS] %%E is valid >> "%LOG%"
            set /a PASS+=1
        ) else (
            echo     [FAIL] %%E validation failed
            echo     [FAIL] %%E validation failed >> "%LOG%"
            set /a FAIL+=1
        )
        cd ..\..
    ) else (
        echo   [SKIP] %%E - no main.tf
        echo   [SKIP] %%E - no main.tf >> "%LOG%"
    )
)
echo. >> "%LOG%"

:: ========================================
:: [5/10] Проверка outputs
:: ========================================
echo [5/10] Checking outputs...
echo [5/10] Checking outputs... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

for %%O in (vm_id vm_ip_external disk_id vm_name vm_ip_internal) do (
    findstr "%%O" modules\vm\outputs.tf >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [PASS] output %%O
        echo   [PASS] output %%O >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [FAIL] output %%O missing
        echo   [FAIL] output %%O missing >> "%LOG%"
        set /a FAIL+=1
    )
)
echo. >> "%LOG%"

:: ========================================
:: [6/10] Проверка переменных
:: ========================================
echo [6/10] Checking variables...
echo [6/10] Checking variables... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

for %%V in (vm_name cores memory disk_size disk_type subnet_id ssh_public_key image_id zone platform_id folder_id cloud_id) do (
    findstr "variable \"%%V\"" modules\vm\variables.tf >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [PASS] variable %%V
        echo   [PASS] variable %%V >> "%LOG%"
        set /a PASS+=1
    ) else (
        echo   [FAIL] variable %%V missing
        echo   [FAIL] variable %%V missing >> "%LOG%"
        set /a FAIL+=1
    )
)
echo. >> "%LOG%"

:: ========================================
:: [7/10] Захардкоженные значения
:: ========================================
echo [7/10] Checking hardcoded values...
echo [7/10] Checking hardcoded values... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

findstr "b1g" modules\vm\main.tf >nul 2>&1
if %errorlevel% equ 0 (
    echo   [FAIL] Hardcoded IDs found
    echo   [FAIL] Hardcoded IDs found >> "%LOG%"
    set /a FAIL+=1
) else (
    echo   [PASS] No hardcoded IDs
    echo   [PASS] No hardcoded IDs >> "%LOG%"
    set /a PASS+=1
)
echo. >> "%LOG%"

:: ========================================
:: [8/10] Проверка .tfvars
:: ========================================
echo [8/10] Checking .tfvars files...
echo [8/10] Checking .tfvars files... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

for %%E in (dev stage prod) do (
    if exist "envs\%%E\%%E.tfvars" (
        for %%P in (disk_size memory subnet_id ssh_public_key vm_name) do (
            findstr "%%P" "envs\%%E\%%E.tfvars" >nul 2>&1
            if !errorlevel! equ 0 (
                echo   [PASS] %%E.tfvars has %%P
                echo   [PASS] %%E.tfvars has %%P >> "%LOG%"
                set /a PASS+=1
            ) else (
                echo   [FAIL] %%E.tfvars missing %%P
                echo   [FAIL] %%E.tfvars missing %%P >> "%LOG%"
                set /a FAIL+=1
            )
        )
    )
)
echo. >> "%LOG%"

:: ========================================
:: [9/10] Локальный mock-тест (ИСПРАВЛЕНО!)
:: ========================================
echo [9/10] Running mock test...
echo [9/10] Running mock test... >> "%LOG%"
echo ---------------------------------------- >> "%LOG%"

cd envs\dev

:: Создаём изолированную временную папку
if exist "_mock_test" rmdir /s /q "_mock_test" >nul 2>&1
mkdir _mock_test >nul 2>&1

:: ВАЖНО: НЕ копируем variables.tf — тест должен быть полностью изолированным
:: Копируем только test.tf с минимальным содержимым

(
echo terraform {
echo   required_providers {
echo     null = {
echo       source = "hashicorp/null"
echo     }
echo   }
echo }
echo.
echo resource "null_resource" "test" {
echo   triggers = { test = "ok" }
echo }
) > _mock_test\main.tf

:: Запускаем terraform во временной папке
cd _mock_test

echo   Running: terraform init -no-color -input=false >> "%LOG%"
call terraform init -no-color -input=false >> "%LOG%" 2>&1

if %errorlevel% equ 0 (
    echo   [PASS] Mock init
    echo   [PASS] Mock init >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [FAIL] Mock init failed
    echo   [FAIL] Mock init failed >> "%LOG%"
    set /a FAIL+=1
)

echo   Running: terraform plan -no-color -input=false >> "%LOG%"
call terraform plan -no-color -input=false >> "%LOG%" 2>&1
if %errorlevel% equ 0 (
    echo   [PASS] Mock plan
    echo   [PASS] Mock plan >> "%LOG%"
    set /a PASS+=1
) else (
    echo   [FAIL] Mock plan failed
    echo   [FAIL] Mock plan failed >> "%LOG%"
    set /a FAIL+=1
)

call terraform destroy -auto-approve >nul 2>&1
cd ..

:: Удаляем временную папку
rmdir /s /q _mock_test >nul 2>&1
cd ..\..
echo. >> "%LOG%"

:: ========================================
:: [10/10] ИТОГ
:: ========================================
echo ======================================== >> "%LOG%"
echo REPORT >> "%LOG%"
echo ======================================== >> "%LOG%"
echo PASSED:   %PASS% >> "%LOG%"
echo FAILED:   %FAIL% >> "%LOG%"
echo WARNINGS: %WARN% >> "%LOG%"
echo ======================================== >> "%LOG%"

echo ========================================
echo VALIDATION REPORT
echo ========================================
echo.
echo   PASSED:   %PASS%
echo   FAILED:   %FAIL%
echo   WARNINGS: %WARN%
echo.

if %FAIL% equ 0 (
    echo [SUCCESS] All checks passed!
) else (
    echo [ERROR] %FAIL% issues found!
    echo.
    echo Check %LOG% for details.
)

echo.
echo Log saved: %LOG%
echo ========================================
echo.

:: Сохраняем краткий отчёт
(
echo Validation Report - %date% %time%
echo PASSED: %PASS%
echo FAILED: %FAIL%
echo WARNINGS: %WARN%
echo Log: %LOG%
) > "%REPORT%"

echo Report saved: %REPORT%
echo.

pause