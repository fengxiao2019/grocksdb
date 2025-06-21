@echo off
setlocal enabledelayedexpansion

if "%1"=="" (
    echo.
    echo Usage: build_windows.bat ^<install_prefix^>
    echo.
    echo Example: build_windows.bat C:\rocksdb
    echo          build_windows.bat %USERPROFILE%\rocksdb
    echo.
    echo This script will build RocksDB and all its dependencies for Windows.
    echo.
    exit /b 1
)

set "INSTALL_PREFIX=%~1"

echo.
echo ==========================================
echo   Building RocksDB for Windows
echo ==========================================
echo Install prefix: %INSTALL_PREFIX%
echo.

REM Check if PowerShell is available
powershell -Command "Write-Host 'PowerShell is available'" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: PowerShell is not available or not in PATH
    echo Please ensure PowerShell is installed and accessible
    exit /b 1
)

REM Execute the PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0build_windows.ps1" -InstallPrefix "%INSTALL_PREFIX%"
set "PS_EXIT_CODE=%ERRORLEVEL%"

if %PS_EXIT_CODE% neq 0 (
    echo.
    echo ❌ Build failed with exit code %PS_EXIT_CODE%
    echo.
    exit /b %PS_EXIT_CODE%
)

echo.
echo ==========================================
echo   Build Completed Successfully!
echo ==========================================
echo.
echo Libraries have been installed to: %INSTALL_PREFIX%
echo.
echo To build your Go application with grocksdb:
echo   1. Open Command Prompt or PowerShell
echo   2. Set environment variables:
echo      set CGO_CFLAGS=-I%INSTALL_PREFIX%\include
echo      set CGO_LDFLAGS=-L%INSTALL_PREFIX%\lib -lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy
echo   3. Run: go build
echo.

endlocal 