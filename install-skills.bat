@echo off
setlocal

:: ── Antigravity Global Skill Installer Launcher ──────────────────────────
:: Fungsi:
::   Menjalankan installer otomatis untuk memindai seluruh folder repositori lokal
::   (agent-skills, anti-slop, caveman, engineering-skills, ponytail-bara, rea, rtk, dll.)
::   dan memasangnya ke direktori konfigurasi global Antigravity (%USERPROFILE%\.gemini\config\skills).
::
:: Penggunaan:
::   install-skills.bat          -> Pasang / update seluruh skill lokal ke Antigravity
::   install-skills.bat -Force   -> Pasang ulang seluruh skill secara paksa

set "SCRIPT=%~dp0install-global-skills.ps1"

if not exist "%SCRIPT%" (
    echo [ERROR] File install-global-skills.ps1 tidak ditemukan di:
    echo         "%SCRIPT%"
    pause
    exit /b 1
)

echo ====================================================================
echo       ANTIGRAVITY GLOBAL SKILL INSTALLER LAUNCHER
echo ====================================================================
echo Direktori Workspace: %~dp0
echo Target Instalasi   : %%USERPROFILE%%\.gemini\config\skills
echo.
echo Menjalankan proses pemindaian dan instalasi skill...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
echo ====================================================================
if %EXIT_CODE% EQU 0 goto :on_success

echo [GAGAL] Terjadi kesalahan saat instalasi skill. Kode error: %EXIT_CODE%
goto :after_result

:on_success
echo [SUKSES] Seluruh skill berhasil dipasang ke Google Antigravity!

:after_result
echo ====================================================================
echo.
pause
exit /b %EXIT_CODE%
