@echo off
setlocal EnableDelayedExpansion

:: ── Antigravity Global Skill Installer Launcher ──────────────────────────
:: Fungsi:
::   Menjalankan installer otomatis untuk memasang skill ke Google Antigravity.
::   - Jika folder repositori lokal ada: langsung menyalin secara offline & instan.
::   - Jika folder repositori lokal belum ada: otomatis mengunduh seluruh skill
::     dari GitHub ke direktori konfigurasi Antigravity (Auto-Download).
::
:: Penggunaan:
::   install-skills.bat             -> Pasang / update seluruh skill (auto-download jika folder lokal belum ada)
::   install-skills.bat -Force      -> Pasang ulang seluruh skill secara paksa
::   install-skills.bat -CloneLocal -> Download & clone seluruh repo ke folder kerja ini lalu pasang
::   install-skills.bat clone       -> Sama dengan -CloneLocal
::   install-skills.bat force       -> Sama dengan -Force

set "SCRIPT=%~dp0install-global-skills.ps1"

if not exist "%SCRIPT%" (
    echo [ERROR] File install-global-skills.ps1 tidak ditemukan di:
    echo         "%SCRIPT%"
    pause
    exit /b 1
)

set "EXTRA_ARGS=%*"
if /i "%~1"=="clone"      set "EXTRA_ARGS=-CloneLocal %~2 %~3 %~4"
if /i "%~1"=="clonelocal" set "EXTRA_ARGS=-CloneLocal %~2 %~3 %~4"
if /i "%~1"=="force"      set "EXTRA_ARGS=-Force %~2 %~3 %~4"

echo ====================================================================
echo       ANTIGRAVITY GLOBAL SKILL INSTALLER LAUNCHER
echo ====================================================================
echo Direktori Workspace: %~dp0
echo Target Instalasi   : %%USERPROFILE%%\.gemini\config\skills
echo.
echo Menjalankan proses instalasi skill (auto-detect lokal ^& auto-download remote)...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %EXTRA_ARGS%
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
