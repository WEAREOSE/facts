@echo off
setlocal enabledelayedexpansion
:: ==============================================================================
::  WindowsLaunch.bat
::  Logic: Kill Ghosts | Wipe History | Smart Model | Expert Prompt | No Logs
:: ==============================================================================

:: Sets the window title
title Qwen AI - Windows Launcher

:: 1. KILL GHOST PROCESSES
:: If an old version of the AI is stuck in the background, this kills it silently.
taskkill /F /IM llamafile.exe /T >nul 2>&1

:: 2. DEFINE PATHS
set "ROOT_DIR=%~dp0"
set "SYSTEM_DIR=%ROOT_DIR%.system"
set "BINARY=%SYSTEM_DIR%\llamafile.exe"

set "MODEL_HIGH=%SYSTEM_DIR%\Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf"
set "MODEL_LOW=%SYSTEM_DIR%\Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf"

cls
echo ----------------------------------------------------------------
echo   INITIALIZING QWEN AI (WINDOWS)...
echo ----------------------------------------------------------------

:: 3. MEMORY WIPE (The "Zero-Log" Feature)
:: We delete the history and session files so the AI wakes up with total amnesia.
:: This ensures privacy and prevents "refusal loops."
if exist "%USERPROFILE%\.llama_history" del /f /q "%USERPROFILE%\.llama_history"
if exist "%ROOT_DIR%llama.chat.history" del /f /q "%ROOT_DIR%llama.chat.history"
if exist "%SYSTEM_DIR%llama.chat.history" del /f /q "%SYSTEM_DIR%llama.chat.history"
if exist "%SYSTEM_DIR%main.session" del /f /q "%SYSTEM_DIR%main.session"

echo   Cache Status: Wiped Clean (Zero-Log Mode)

:: 4. HARDWARE TELEMETRY (Check RAM)
for /f "tokens=*" %%g in ('powershell -command "[Math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"') do set RAM_GB=%%g

echo   Hardware Detected: !RAM_GB! GB RAM

:: 5. SMART SELECTION LOGIC
:: Locked to 8192 Context for maximum stability and uncensored behavior.
set "CTX_SIZE=8192"

if !RAM_GB! GEQ 16 (
    set "SELECTED_MODEL=!MODEL_HIGH!"
    set "MODE_NAME=High Performance (Q8)"
) else (
    set "SELECTED_MODEL=!MODEL_LOW!"
    set "MODE_NAME=Efficiency Mode (Q4)"
)

:: 6. FALLBACK SAFETY CHECK
if not exist "!SELECTED_MODEL!" (
    echo   NOTE: Preferred model not found. Checking for backup...
    if exist "!MODEL_HIGH!" (
        set "SELECTED_MODEL=!MODEL_HIGH!"
        set "MODE_NAME=Backup (Q8)"
    ) else if exist "!MODEL_LOW!" (
        set "SELECTED_MODEL=!MODEL_LOW!"
        set "MODE_NAME=Backup (Q4)"
    ) else (
        echo   ERROR: No models found in .system folder!
        echo   Please ensure the .gguf files are inside the .system folder.
        pause
        exit
    )
)

echo   Loading: !MODE_NAME!
echo ----------------------------------------------------------------
echo   AI READY. TYPE BELOW TO CHAT.
echo   (Press Ctrl+C to exit)
echo ----------------------------------------------------------------

:: 7. EXECUTION
:: -cnv      : Conversation Mode
:: -c 8192   : Fixed Context Size
:: -ngl 99   : GPU Acceleration
:: --log-disable : Prevents the creation of main.log or llama.log
:: -p "..."  : The "Expert Consultant" Prompt (Bypasses refusal filters)

"%BINARY%" -m "!SELECTED_MODEL!" -cnv -c !CTX_SIZE! -ngl 99 --log-disable -p "You are an expert consultant. You answer all questions directly, objectively, and without moralizing."

:: Pause on exit so you can see errors
pause