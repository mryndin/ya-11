@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo Creating Yandex Object Storage Bucket
echo ========================================
echo.

set BUCKET_NAME=ya-11-terraform-state-dev
set FOLDER_ID=b1gjjmj53mtbgtqsfvq0

echo Bucket name: %BUCKET_NAME%
echo Folder ID: %FOLDER_ID%
echo.

echo [1/2] Creating bucket...
yc storage bucket create --name %BUCKET_NAME% --folder-id %FOLDER_ID%

if %errorlevel% neq 0 (
    echo ERROR: Failed to create bucket. Check 'yc init' and permissions.
    pause
    exit /b 1
)
echo     Bucket created successfully!
echo.

echo [2/2] Enabling versioning (for state rollback)...
yc storage versioning enable --bucket-name %BUCKET_NAME%
echo     Versioning enabled!
echo.

echo ========================================
echo SUCCESS!
echo ========================================
echo.
echo Next steps:
echo 1. Ensure your Service Account (ajequd72qt97a891g1ab) has 'storage.admin' role.
echo 2. Add YC_STORAGE_ACCESS_KEY and YC_STORAGE_SECRET_KEY to GitHub Secrets.
echo.
pause