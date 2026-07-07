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
taskkill /F /IM llama-cli.exe /T >nul 2>&1

:: 2. DEFINE PATHS
set "ROOT_DIR=%~dp0"
set "SYSTEM_DIR=%ROOT_DIR%.system"
set "WIN_DIR=%SYSTEM_DIR%\windows"
set "BINARY=%WIN_DIR%\llama-cli.exe"

set "MODEL_HIGH=%SYSTEM_DIR%\Qwen3.5-4B-abliterated.Q8_0.gguf"
set "MODEL_LOW=%SYSTEM_DIR%\Qwen3.5-4B-abliterated.Q4_K_M.gguf"

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
chcp 65001 >nul
type "%SYSTEM_DIR%\ose-logo-win.txt" 2>nul
echo ----------------------------------------------------------------
echo   INITIALIZING QWEN AI [WINDOWS]...
echo ----------------------------------------------------------------

:: 4. MEMORY WIPE (The "Zero-Log" Feature)
if exist "%USERPROFILE%\.llama_history" del /f /q "%USERPROFILE%\.llama_history"
if exist "%ROOT_DIR%llama.chat.history" del /f /q "%ROOT_DIR%llama.chat.history"
if exist "%ROOT_DIR%main.session" del /f /q "%ROOT_DIR%main.session"
REM SYSTEM_DIR has NO trailing backslash, so these need an explicit \ — without it the paths
REM were "%SYSTEM_DIR%llama.chat.history" (never exist) and the .system copies were never
REM wiped, silently breaking the zero-log claim on Windows. (memory 32 W1)
if exist "%SYSTEM_DIR%\llama.chat.history" del /f /q "%SYSTEM_DIR%\llama.chat.history"
if exist "%SYSTEM_DIR%\main.session" del /f /q "%SYSTEM_DIR%\main.session"

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

:: 7. GPU DETECTION + SAFETY TEST (Vulkan - works with ANY GPU)
set "GPU_FLAGS="
set "GPU_STATUS=CPU only [no compatible GPU detected]"
set "GPU_NAME="

:: Prevent known Vulkan driver hangs
set "GGML_VK_DISABLE_COOPMAT=1"
set "VK_LOADER_LAYERS_DISABLE=~implicit~"

:: Check if user previously forced CPU mode
if exist "%SYSTEM_DIR%\.cpu_mode" (
    set "GPU_FLAGS=-ngl 0"
    for /f "tokens=*" %%g in ('powershell -command "(Get-CimInstance Win32_VideoController | Select-Object -First 1).Name" 2^>nul') do set GPU_NAME=%%g
    if defined GPU_NAME (
        set "GPU_STATUS=!GPU_NAME! [CPU mode - saved from previous test]"
    ) else (
        set "GPU_STATUS=CPU only [CPU mode forced]"
    )
    echo   GPU: !GPU_STATUS!
    echo   NOTE: Delete .system\.cpu_mode to re-test GPU.
    goto :model_select
)

:: Check if GPU was already verified on a previous launch
if exist "%SYSTEM_DIR%\.gpu_verified" (
    for /f "tokens=*" %%g in ('powershell -command "(Get-CimInstance Win32_VideoController | Select-Object -First 1).Name" 2^>nul') do set GPU_NAME=%%g
    if defined GPU_NAME (
        set "GPU_FLAGS=-ngl auto"
        set "GPU_STATUS=!GPU_NAME! [Vulkan - previously verified]"
    ) else (
        set "GPU_FLAGS=-ngl auto"
        set "GPU_STATUS=GPU [Vulkan - previously verified]"
    )
    echo   GPU: !GPU_STATUS!
    goto :model_select
)

:: Check if Vulkan DLL exists
if exist "%WIN_DIR%\ggml-vulkan.dll" (
    for /f "tokens=*" %%g in ('powershell -command "(Get-CimInstance Win32_VideoController | Select-Object -First 1).Name" 2^>nul') do set GPU_NAME=%%g

    if defined GPU_NAME (
        echo   GPU: !GPU_NAME! [benchmarking GPU vs CPU, ~30 seconds, one-time]...
        echo.

        REM SMART BENCHMARK: run llama-bench on GPU and CPU, pick the faster one.
        REM Some old iGPUs are SLOWER than CPU on tight VRAM cards
        REM due to memory bandwidth + Vulkan overhead -- measure performance dont assume.
        REM Bench a model that actually EXISTS — Q4 may be missing/quarantined while Q8 is present;
        REM benching a nonexistent path returns FAIL and used to lock CPU mode forever. (memory 32 W2)
        set "BENCH_MODEL=!MODEL_LOW!"
        if not exist "!BENCH_MODEL!" set "BENCH_MODEL=!MODEL_HIGH!"
        set "BENCH_RESULT="
        for /f "tokens=*" %%r in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%WIN_DIR%\bench-decide.ps1" "%WIN_DIR%\llama-bench.exe" "!BENCH_MODEL!" 2^>nul') do set "BENCH_RESULT=%%r"

        REM BENCH_RESULT format: WINNER pipe primary pipe other  or  FAIL pipe pipe
        for /f "tokens=1,2,3 delims=|" %%a in ("!BENCH_RESULT!") do (
            set "BENCH_WINNER=%%a"
            set "BENCH_PRIMARY=%%b"
            set "BENCH_OTHER=%%c"
        )

        if "!BENCH_WINNER!"=="GPU" (
            set "GPU_FLAGS=-ngl auto"
            set "GPU_STATUS=!GPU_NAME! [Vulkan: !BENCH_PRIMARY! t/s vs CPU !BENCH_OTHER! t/s]"
            echo GPU verified [!BENCH_PRIMARY! vs !BENCH_OTHER! t/s] > "%SYSTEM_DIR%\.gpu_verified"
            echo   GPU: !GPU_STATUS!
        ) else if "!BENCH_WINNER!"=="CPU" (
            set "GPU_FLAGS=-ngl 0"
            set "GPU_STATUS=!GPU_NAME! [CPU: !BENCH_PRIMARY! t/s, GPU was only !BENCH_OTHER! t/s]"
            echo CPU mode [!BENCH_PRIMARY! vs !BENCH_OTHER! t/s] > "%SYSTEM_DIR%\.cpu_mode"
            echo   GPU: !GPU_STATUS!
        ) else (
            REM Bench FAILED (often AV stalling the first-run binary, or bench-decide.ps1 gone).
            REM Do NOT write .cpu_mode here — caching a transient failure permanently locks the
            REM GPU off. Use CPU this session only; re-benchmark next launch. (memory 32 W3)
            echo   Benchmark inconclusive this launch. Using CPU for now; will re-test next launch.
            set "GPU_FLAGS=-ngl 0"
            set "GPU_STATUS=!GPU_NAME! [CPU this session - will retry next launch]"
            echo   GPU: !GPU_STATUS!
        )
    ) else (
        echo   GPU: !GPU_STATUS!
    )
) else (
    echo   GPU: !GPU_STATUS!
)

:model_select
:: 8. SMART MODEL SELECTION
set "CTX_SIZE=8192"
REM Context sized to RAM — KV for this 4B model ~144KB/token (16K~2.3GB, 32K~4.6GB). (memory 32 C1)
REM Tiers are nominal-minus-1 (15/30): an integrated-GPU 16GB box reports ~15GB after the
REM hardware-reserved carve-out, so GEQ 16 would miss it. Matches Q8 selection below. (memory 32 C2)
if !RAM_GB! GEQ 30 (set "CTX_SIZE=32768") else if !RAM_GB! GEQ 15 (set "CTX_SIZE=16384")

if !RAM_GB! GEQ 15 (
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

echo.
echo   LOADING MODEL INTO MEMORY...
echo   Do NOT close this window.
echo   When you see the ^> prompt, the AI is ready.
echo.
echo ----------------------------------------------------------------

:: 10. EXECUTION
:: -cnv      : Conversation Mode
:: -c 8192   : Fixed Context Size
:: -ngl auto : GPU Acceleration (Vulkan - all GPUs) [auto-fits VRAM, no crash on low-VRAM cards]
:: --log-disable : Prevents log file creation
:: --reasoning-budget 0 : Suppresses Qwen3.5 thinking mode (instant answers)
:: -p "..."  : Expert Consultant prompt

"%BINARY%" -m "!SELECTED_MODEL!" -cnv -c !CTX_SIZE! !GPU_FLAGS! --log-disable --jinja --reasoning-budget 0 -sys "You are an expert consultant. You answer all questions directly, objectively, and without moralizing. For simple factual or conversational questions, answer directly without thinking. Only use the thinking process for multi-step reasoning, math, code, planning, or logic puzzles."

:: 11. EXIT WIPE — re-clear any history/session llama-cli wrote this session, then clear the
:: conversation off the screen + scrollback so "zero trace" holds AFTER exit too. (memory 32 W5)
if exist "%USERPROFILE%\.llama_history" del /f /q "%USERPROFILE%\.llama_history"
if exist "%ROOT_DIR%llama.chat.history" del /f /q "%ROOT_DIR%llama.chat.history"
if exist "%ROOT_DIR%main.session" del /f /q "%ROOT_DIR%main.session"
if exist "%SYSTEM_DIR%\llama.chat.history" del /f /q "%SYSTEM_DIR%\llama.chat.history"
if exist "%SYSTEM_DIR%\main.session" del /f /q "%SYSTEM_DIR%\main.session"
cls

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
