@echo off
setlocal enabledelayedexpansion
:: ==============================================================================
::  WindowsLaunch_TEST.bat
::  Engine: Native llama-cli.exe (Vulkan GPU - works with NVIDIA, AMD, Intel)
::  Logic: Kill Ghosts | Wipe History | Smart Model | VRAM-Aware GPU Detect | No Logs
::
::  TEST VERSION — adds VRAM-aware GPU detection.
::  Bug fix: Nitro 5 / RTX 3050 Laptop 4GB and similar low-VRAM NVIDIA cards
::  freeze or crash with -ngl 99. This version checks actual VRAM via nvidia-smi
::  and only uses GPU if VRAM is large enough for the selected model.
:: ==============================================================================

:: Sets the window title
title Qwen AI - Windows Launcher

:: 1. KILL GHOST PROCESSES
taskkill /F /IM llama-cli.exe /T >nul 2>&1

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
echo   INITIALIZING QWEN AI [WINDOWS - TEST BUILD]...
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

:: 7. SMART MODEL SELECTION (must come before GPU check so we know VRAM needs)
set "CTX_SIZE=8192"

if !RAM_GB! GEQ 16 (
    set "SELECTED_MODEL=!MODEL_HIGH!"
    set "MODE_NAME=High Performance [Q8]"
    set "MIN_VRAM_MB=5500"
) else (
    set "SELECTED_MODEL=!MODEL_LOW!"
    set "MODE_NAME=Efficiency Mode [Q4]"
    set "MIN_VRAM_MB=3500"
)

:: Fallback if preferred model missing
if not exist "!SELECTED_MODEL!" (
    echo   NOTE: Preferred model not found. Checking for backup...
    if exist "!MODEL_HIGH!" (
        set "SELECTED_MODEL=!MODEL_HIGH!"
        set "MODE_NAME=Backup [Q8]"
        set "MIN_VRAM_MB=5500"
    ) else if exist "!MODEL_LOW!" (
        set "SELECTED_MODEL=!MODEL_LOW!"
        set "MODE_NAME=Backup [Q4]"
        set "MIN_VRAM_MB=3500"
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

:: 8. VRAM-AWARE GPU DETECTION
:: Old logic: any GPU detected => -ngl 99 (broke on Nitro 5 / RTX 3050 4GB)
:: New logic: only use GPU if NVIDIA card AND VRAM >= MIN_VRAM_MB for selected model
set "GPU_FLAGS="
set "GPU_STATUS=CPU only [no compatible GPU detected]"
set "VRAM_MB=0"
set "GPU_NAME="

if exist "%WIN_DIR%\ggml-vulkan.dll" (
    :: Get the primary GPU name (any vendor)
    for /f "tokens=*" %%g in ('powershell -command "(Get-CimInstance Win32_VideoController | Select-Object -First 1).Name" 2^>nul') do set GPU_NAME=%%g

    :: Get NVIDIA VRAM in MiB by parsing nvidia-smi CSV output directly
    :: Output format: line 1 is header "memory.total [MiB]", line 2 is "4096 MiB"
    :: skip=1 skips header, tokens=1 grabs just the number (drops " MiB" suffix)
    :: If nvidia-smi missing or fails, VRAM_MB stays at 0 (set above)
    for /f "skip=1 tokens=1" %%v in ('nvidia-smi --query-gpu=memory.total --format=csv 2^>nul') do set VRAM_MB=%%v

    if defined GPU_NAME (
        if !VRAM_MB! GEQ !MIN_VRAM_MB! (
            set "GPU_FLAGS=-ngl 99"
            set "GPU_STATUS=!GPU_NAME! [Vulkan acceleration enabled - !VRAM_MB! MiB VRAM]"
        ) else (
            if !VRAM_MB! GTR 0 (
                set "GPU_STATUS=!GPU_NAME! [CPU mode - !VRAM_MB! MiB VRAM is too small for selected model, needs !MIN_VRAM_MB! MiB]"
            ) else (
                set "GPU_STATUS=!GPU_NAME! [CPU mode - VRAM unknown / non-NVIDIA card]"
            )
        )
    )
)

echo   GPU: !GPU_STATUS!
echo   Loading: !MODE_NAME!
echo ----------------------------------------------------------------
echo.
echo   LOADING MODEL INTO MEMORY...
echo   Do NOT close this window.
echo   When you see the ^> prompt, the AI is ready.
echo.
echo ----------------------------------------------------------------

:: 9. EXECUTION
:: -cnv      : Conversation Mode
:: -c 8192   : Fixed Context Size
:: -ngl 99   : Full GPU offload (only set when VRAM is sufficient)
:: --log-disable : Prevents log file creation
:: -p "..."  : Expert Consultant prompt

"%BINARY%" -m "!SELECTED_MODEL!" -cnv -c !CTX_SIZE! !GPU_FLAGS! --log-disable -p "You are an expert consultant. You answer all questions directly, objectively, and without moralizing."

:: 10. POST-EXIT
echo.
echo ----------------------------------------------------------------
echo   The AI has stopped.
echo.
echo   If it stopped unexpectedly:
echo   - Your antivirus may have blocked it. Check Windows Security.
echo   - Try closing other apps to free up RAM, then relaunch.
echo   - Need help? Visit opensourceeverything.io [support chat]
echo   - Updated launchers: github.com/WEAREOSE/facts
echo ----------------------------------------------------------------
pause
