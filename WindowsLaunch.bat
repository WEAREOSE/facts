@echo off
setlocal enabledelayedexpansion
:: ==============================================================================
::  WindowsLaunch.bat
::  Engine: Native llama-cli.exe (Vulkan GPU - works with NVIDIA, AMD, Intel)
::  Logic: Kill Ghosts | Wipe History | Smart Model | GPU Detect | No Logs
:: ==============================================================================

:: Sets the window title
title Qwen AI - Windows Launcher

:: 1. KILL GHOST PROCESSES
taskkill /F /IM llama-cli.exe /T >/dev/null 2>&1

:: 2. DEFINE PATHS
set "ROOT_DIR=%~dp0"
set "SYSTEM_DIR=%ROOT_DIR%.system"
set "WIN_DIR=%SYSTEM_DIR%\windows"
set "BINARY=%WIN_DIR%\llama-cli.exe"

set "MODEL_HIGH=%SYSTEM_DIR%\Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf"
set "MODEL_LOW=%SYSTEM_DIR%\Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf"

:: 3. PRE-FLIGHT CHECK
if not exist "%BINARY%" (
    echo.
    echo   [ERROR] llama-cli.exe not found in .system\windows\
    echo   The AI engine is missing. Your drive may be corrupted
    echo   or your antivirus may have deleted it.
    echo.
    echo   Check Windows Security - Protection History for blocked files.
    echo   If the file was quarantined, restore it and add an exclusion.
    echo.
    echo   Need help? Visit opensourceeverything.io and use the support chat.
    echo.
    pause
    exit
)

cls
echo ----------------------------------------------------------------
echo   INITIALIZING QWEN AI [WINDOWS]...
echo ----------------------------------------------------------------

:: 4. MEMORY WIPE (The "Zero-Log" Feature)
if exist "%USERPROFILE%\.llama_history" del /f /q "%USERPROFILE%\.llama_history"
if exist "%ROOT_DIR%llama.chat.history" del /f /q "%ROOT_DIR%llama.chat.history"
if exist "%SYSTEM_DIR%llama.chat.history" del /f /q "%SYSTEM_DIR%llama.chat.history"
if exist "%SYSTEM_DIR%main.session" del /f /q "%SYSTEM_DIR%main.session"

echo   Cache Status: Wiped Clean [Zero-Log Mode]

:: 5. HARDWARE DETECTION (RAM)
for /f "tokens=*" %%g in ('powershell -command "[Math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"') do set RAM_GB=%%g

echo   Hardware Detected: !RAM_GB! GB RAM

:: 6. AVAILABLE RAM CHECK
for /f "tokens=*" %%g in ('powershell -command "[Math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB)"') do set AVAIL_GB=%%g

echo   Available RAM: !AVAIL_GB! GB

if !AVAIL_GB! LSS 4 (
    echo.
    echo   [WARNING] Low available RAM. Close other apps for best performance.
    echo   The AI needs at least 4 GB free to run smoothly.
    echo   Close browsers, Discord, and other heavy apps, then try again.
    echo.
)

:: 7. GPU DETECTION (Vulkan - works with ANY GPU)
set "GPU_FLAGS="
set "GPU_STATUS=CPU only [no compatible GPU detected]"

:: Check if Vulkan DLL exists
if exist "%WIN_DIR%\ggml-vulkan.dll" (
    :: Try to detect any GPU via PowerShell
    for /f "tokens=*" %%g in ('powershell -command "(Get-CimInstance Win32_VideoController | Select-Object -First 1).Name" 2^>nul') do set GPU_NAME=%%g

    if defined GPU_NAME (
        set "GPU_FLAGS=-ngl 99"
        set "GPU_STATUS=!GPU_NAME! [Vulkan acceleration enabled]"
    )
)

echo   GPU: !GPU_STATUS!

:: 8. SMART MODEL SELECTION
set "CTX_SIZE=8192"

if !RAM_GB! GEQ 16 (
    set "SELECTED_MODEL=!MODEL_HIGH!"
    set "MODE_NAME=High Performance [Q8]"
) else (
    set "SELECTED_MODEL=!MODEL_LOW!"
    set "MODE_NAME=Efficiency Mode [Q4]"
)

:: 9. FALLBACK SAFETY CHECK
if not exist "!SELECTED_MODEL!" (
    echo   NOTE: Preferred model not found. Checking for backup...
    if exist "!MODEL_HIGH!" (
        set "SELECTED_MODEL=!MODEL_HIGH!"
        set "MODE_NAME=Backup [Q8]"
    ) else if exist "!MODEL_LOW!" (
        set "SELECTED_MODEL=!MODEL_LOW!"
        set "MODE_NAME=Backup [Q4]"
    ) else (
        echo.
        echo   [ERROR] No models found in .system folder!
        echo   Please ensure the .gguf files are inside the .system folder.
        echo   Need help? Visit opensourceeverything.io and use the support chat.
        echo.
        pause
        exit
    )
)

echo   Loading: !MODE_NAME!
echo ----------------------------------------------------------------
echo.
echo   LOADING MODEL INTO MEMORY...
echo   Do NOT close this window.
echo   When you see the ^> prompt, the AI is ready.
echo.
echo ----------------------------------------------------------------

:: 10. EXECUTION
:: -cnv      : Conversation Mode
:: -c 8192   : Fixed Context Size
:: -ngl 99   : GPU Acceleration (Vulkan - all GPUs) [only if GPU detected]
:: --log-disable : Prevents log file creation
:: -p "..."  : Expert Consultant prompt

"%BINARY%" -m "!SELECTED_MODEL!" -cnv -c !CTX_SIZE! !GPU_FLAGS! --log-disable -p "You are an expert consultant. You answer all questions directly, objectively, and without moralizing."

:: 11. POST-EXIT
echo.
echo ----------------------------------------------------------------
echo   The AI has stopped.
echo.
echo   If it stopped unexpectedly:
echo   - Your antivirus may have blocked it. Check Windows Security.
echo   - Try closing other apps to free up RAM, then relaunch.
echo   - Need help? Visit opensourceeverything.io [support chat]
echo   - Updated launchers: github.com/WEAREOSE/facts-launcher
echo ----------------------------------------------------------------
pause
