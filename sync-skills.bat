@echo off
setlocal EnableDelayedExpansion

:: ── Skill Sync Launcher ────────────────────────────────────────────────
:: Usage:
::   sync-skills.bat              -> sync semua skill (otomatis cek repo baru)
::   sync-skills.bat check        -> hanya cek repo baru di agent-bara & update script
::   sync-skills.bat caveman      -> hanya caveman
::   sync-skills.bat dry          -> dry run semua
::   sync-skills.bat dry caveman  -> dry run caveman saja
::   sync-skills.bat nopush       -> merge lokal saja, tidak push
::   sync-skills.bat force        -> paksa sync ulang semua (abaikan status up-to-date)

set SCRIPT=%~dp0sync-skills.ps1
set FILTER=all
set DRYRUN=
set SKIPPUSH=
set CHECKONLY=
set FORCE=

:: Parse args
:parse
if "%~1"=="" goto run
if /i "%~1"=="check"  set CHECKONLY=-CheckOnly & shift & goto parse
if /i "%~1"=="dry"    set DRYRUN=-DryRun       & shift & goto parse
if /i "%~1"=="nopush" set SKIPPUSH=-SkipPush   & shift & goto parse
if /i "%~1"=="force"  set FORCE=-Force         & shift & goto parse
set FILTER=%~1
shift
goto parse

:run
if defined DRYRUN goto :skip_token
if defined SKIPPUSH goto :skip_token
if defined CHECKONLY goto :skip_token
if defined GITHUB_TOKEN goto :skip_token

call :ask_token
if not defined GITHUB_TOKEN exit /b 1

:skip_token
powershell -ExecutionPolicy Bypass -File "%SCRIPT%" -SkillFilter "%FILTER%" %DRYRUN% %SKIPPUSH% %CHECKONLY% %FORCE%
pause
exit /b 0

:: ── Token Prompt Subroutine ──────────────────────────────────────────
:ask_token
echo ====================================================================
echo [PERHATIAN] GITHUB_TOKEN belum di-set.
echo Token diperlukan untuk push ke backup repo dan akses GitHub API.
echo.
echo Langkah membuat token di GitHub:
echo   1. Buka: https://github.com/settings/tokens/new
echo   2. Isi Note (agent-bara-sync)
echo   3. Centang scope: [x] repo (Full control of private repositories)
echo   4. Klik 'Generate token' di bagian bawah, lalu copy token (ghp_...)
echo.
echo Tips permanen: setx GITHUB_TOKEN "ghp_xxxxxxxxxxxx"
echo ====================================================================
echo.
set "INPUT_TOKEN="
set /p "INPUT_TOKEN=Masukkan GitHub Token Anda (atau tekan Enter untuk batal): "
if not defined INPUT_TOKEN goto :token_cancelled
if "!INPUT_TOKEN!"=="" goto :token_cancelled
if "!INPUT_TOKEN:~9!"=="" goto :token_invalid

set "GITHUB_TOKEN=!INPUT_TOKEN!"
echo [OK] Token berhasil dipasang untuk sesi ini.
echo.
exit /b 0

:token_invalid
echo.
echo [BATAL] Token tidak valid (terlalu pendek). Format token GitHub: ghp_...
pause
exit /b 1

:token_cancelled
echo.
echo [BATAL] Token tidak dimasukkan. Proses dibatalkan.
pause
exit /b 1
