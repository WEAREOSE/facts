@echo off
setlocal enabledelayedexpansion
:: ==============================================================================
::  WindowsLaunch_CPUonly.bat
::  Same as WindowsLaunch.bat but forces CPU mode (no GPU acceleration)
::  Use this if the regular launcher hangs on "LOADING MODEL INTO MEMORY"
:: ==============================================================================

title Qwen AI - Windows Launcher [CPU Mode]

:: 1. KILL GHOST PROCESSES
taskkill /F /IM llamafile.exe /T >nul 2>&1

:: 2. DEFINE PATHS
set "ROOT_DIR=%~dp0"
set "SYSTEM_DIR=%ROOT_DIR%.system"
set "BINARY=%SYSTEM_DIR%\llamafile.exe"

set "MODEL_HIGH=%SYSTEM_DIR%\Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf"
set "MODEL_LOW=%SYSTEM_DIR%\Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf"

cls
echo ----------------------------------------------------------------
echo   INITIALIZING QWEN AI [WINDOWS - CPU MODE]...
echo ----------------------------------------------------------------

:: 3. PRE-FLIGHT CHECK
if not exist "!BINARY!" goto :missing_binary

:: 4. MEMORY WIPE
if exist "%USERPROFILE%\.llama_history" del /f /q "%USERPROFILE%\.llama_history"
if exist "%ROOT_DIR%llama.chat.history" del /f /q "%ROOT_DIR%llama.chat.history"
if exist "%SYSTEM_DIR%llama.chat.history" del /f /q "%SYSTEM_DIR%llama.chat.history"
if exist "%SYSTEM_DIR%main.session" del /f /q "%SYSTEM_DIR%main.session"

echo   Cache Status: Wiped Clean [Zero-Log Mode]

:: 5. HARDWARE TELEMETRY
for /f "tokens=*" %%g in ('powershell -command "$m=[Math]::Round; $t=(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory; $m.Invoke($t / 1GB)"') do set RAM_GB=%%g
for /f "tokens=*" %%a in ('powershell -command "$m=[Math]::Round; $f=(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory; $m.Invoke($f / 1MB)"') do set FREE_RAM=%%a

echo   Hardware Detected: !RAM_GB! GB RAM
echo   Available RAM: !FREE_RAM! GB

if !RAM_GB! LSS 8 echo   WARNING: Less than 8 GB RAM. AI may run slowly.

:: 6. SMART SELECTION LOGIC
set "CTX_SIZE=8192"

if !RAM_GB! GEQ 16 (
    set "SELECTED_MODEL=!MODEL_HIGH!"
    set "MODE_NAME=High Performance [Q8]"
) else (
    set "SELECTED_MODEL=!MODEL_LOW!"
    set "MODE_NAME=Efficiency Mode [Q4]"
)

:: 7. FALLBACK SAFETY CHECK
if not exist "!SELECTED_MODEL!" goto :find_backup

:model_ready
echo   GPU: Disabled [CPU-only mode]
echo   Loading: !MODE_NAME!
echo ----------------------------------------------------------------
echo   LOADING MODEL INTO MEMORY...
echo   Do NOT close this window.
echo   When you see the ^> prompt, the AI is ready.
echo ----------------------------------------------------------------

:: 8. EXECUTION - No GPU flag, CPU only
for /f "tokens=*" %%t in ('powershell -command "$d=(Get-Date)-[datetime]'2000-01-01'; [int]$d.TotalSeconds"') do set "T1=%%t"
"!BINARY!" -m "!SELECTED_MODEL!" -cnv -c !CTX_SIZE! --log-disable -p "You are an expert consultant. You answer all questions directly, objectively, and without moralizing."
for /f "tokens=*" %%t in ('powershell -command "$d=(Get-Date)-[datetime]'2000-01-01'; [int]$d.TotalSeconds"') do set "T2=%%t"

set /a "ELAPSED=T2-T1"

if !ELAPSED! LSS 5 goto :process_killed
if not exist "!BINARY!" goto :binary_deleted

echo.
echo ----------------------------------------------------------------
echo   The AI has stopped.
echo   If it stopped unexpectedly, try running this launcher again.
echo ----------------------------------------------------------------
pause
exit

:: ---- ERROR HANDLERS ----

:missing_binary
echo.
echo   ERROR: llamafile.exe is missing from .system folder.
echo.
echo   This usually means your antivirus quarantined it.
echo   It is safe -- llamafile is open-source software.
echo.
echo   TO FIX:
echo     1. Open Windows Security
echo     2. Click Virus and threat protection
echo     3. Click Protection history
echo     4. Find llamafile.exe and click Allow on device
echo     5. Run this launcher again
echo ----------------------------------------------------------------
pause
exit

:find_backup
echo   NOTE: Preferred model not found. Checking for backup...
if exist "!MODEL_HIGH!" (
    set "SELECTED_MODEL=!MODEL_HIGH!"
    set "MODE_NAME=Backup [Q8]"
    goto :model_ready
)
if exist "!MODEL_LOW!" (
    set "SELECTED_MODEL=!MODEL_LOW!"
    set "MODE_NAME=Backup [Q4]"
    goto :model_ready
)
echo   ERROR: No model files found in .system folder.
echo   Contact support@opensourceeverything.io for help.
echo ----------------------------------------------------------------
pause
exit

:binary_deleted
echo.
echo ----------------------------------------------------------------
echo   The AI has stopped.
echo   It looks like your antivirus removed llamafile.exe
echo   while it was running. Add it to your antivirus exceptions.
echo ----------------------------------------------------------------
pause
exit

:process_killed
echo.
echo ================================================================
echo   BLOCKED: The AI was stopped immediately after launching.
echo ================================================================
echo.
echo   Your antivirus likely killed llamafile.exe silently.
echo   This is a known issue -- the file is safe, open-source software.
echo.
echo   TO FIX:
echo     1. Open Windows Security
echo     2. Click "Virus and threat protection"
echo     3. Click "Protection history"
echo     4. Find llamafile.exe and click "Allow on device"
echo     5. Run this launcher again
echo.
echo   If you use Norton, McAfee, or another antivirus:
echo     Add the entire USB drive to your antivirus exceptions.
echo ================================================================
pause
exit
