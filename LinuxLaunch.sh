#!/bin/bash

# ==============================================================================
#  LinuxLaunch.sh
#  Features: GPU Offload | Nuclear Wipe | Ghost Killer | Expert Prompt
# ==============================================================================

# 1. KILL GHOST PROCESSES
killall llamafile.exe 2>/dev/null
pkill -f llamafile 2>/dev/null

# 2. ESTABLISH LOCATION
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$ROOT_DIR/.system"

# Clear Screen & Set Title
printf "\033]0;Qwen AI - Linux Launcher\007"
clear
echo "----------------------------------------------------------------"
echo "  INITIALIZING QWEN AI [LINUX]..."
echo "----------------------------------------------------------------"

# 3. PRE-FLIGHT CHECKS
BINARY="$SYSTEM_DIR/llamafile.exe"

if [ ! -f "$BINARY" ]; then
    echo ""
    echo "  ERROR: llamafile.exe is missing from .system folder."
    echo ""
    echo "  This can happen if the file was deleted or the drive is corrupted."
    echo ""
    echo "  Check that the .system folder exists on the drive and contains"
    echo "  llamafile.exe. If the file is missing, contact:"
    echo "  support@opensourceeverything.io"
    echo "----------------------------------------------------------------"
    read -p "  Press Enter to exit..."
    exit 1
fi

# Make sure the binary is executable
chmod +x "$BINARY" 2>/dev/null

# 4. MEMORY WIPE (Zero-Log Privacy)
rm -f "$HOME/.llama_history"
rm -f "$ROOT_DIR/llama.chat.history"
rm -f "$SYSTEM_DIR/llama.chat.history"
rm -f "$ROOT_DIR/main.session"
rm -f "$SYSTEM_DIR/main.session"

echo "  Cache Status: Wiped Clean (Zero-Log Mode)"

# 5. HARDWARE TELEMETRY
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_GB=$((RAM_KB / 1024 / 1024))
FREE_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
FREE_GB=$((FREE_KB / 1024 / 1024))

echo "  Hardware Detected: ${RAM_GB}GB RAM"
echo "  Available RAM: ${FREE_GB}GB"

if [ "$RAM_GB" -lt 8 ]; then
    echo ""
    echo "  WARNING: Your system has less than 8GB of RAM."
    echo "  The AI may not load or may run very slowly."
    echo "  Close all other applications before continuing."
    echo ""
fi

# 6. DEFINE MODELS
MODEL_HIGH="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf"
MODEL_LOW="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf"

# 7. SMART SELECTION LOGIC
CTX_SIZE="8192"

if [ "$RAM_GB" -ge 16 ]; then
    SELECTED_MODEL="$MODEL_HIGH"
    MODE_NAME="High Performance (Q8)"
else
    SELECTED_MODEL="$MODEL_LOW"
    MODE_NAME="Efficiency Mode (Q4)"
fi

# Fallback Check
if [ ! -f "$SELECTED_MODEL" ]; then
    if [ -f "$MODEL_HIGH" ]; then SELECTED_MODEL="$MODEL_HIGH"; MODE_NAME="Backup (Q8)";
    elif [ -f "$MODEL_LOW" ]; then SELECTED_MODEL="$MODEL_LOW"; MODE_NAME="Backup (Q4)";
    else
        echo ""
        echo "  ERROR: No model files found in .system folder."
        echo "  The .gguf files may have been deleted or corrupted."
        echo "  Contact support@opensourceeverything.io for help."
        echo "----------------------------------------------------------------"
        read -p "  Press Enter to exit..."
        exit 1
    fi
fi

# 8. GPU DETECTION (NVIDIA only)
GPU_FLAG=""
if command -v nvidia-smi &>/dev/null; then
    if nvidia-smi &>/dev/null; then
        GPU_FLAG="-ngl 99"
        echo "  GPU: NVIDIA detected - GPU acceleration enabled"
    fi
fi

if [ -z "$GPU_FLAG" ]; then
    echo "  GPU: System RAM (CPU mode)"
fi

echo "  Loading: $MODE_NAME"
echo "----------------------------------------------------------------"
echo "  LOADING MODEL INTO MEMORY..."
echo "  Do NOT close this window."
echo "  When you see the > prompt, the AI is ready."
echo "----------------------------------------------------------------"

# 9. EXECUTION
"$BINARY" -m "$SELECTED_MODEL" -cnv -c "$CTX_SIZE" $GPU_FLAG --log-disable -p "You are an expert consultant. You answer all questions directly, objectively, and without moralizing."

# If we get here, llamafile exited
echo ""
echo "----------------------------------------------------------------"
echo "  The AI has stopped."
echo ""
if [ ! -f "$BINARY" ]; then
    echo "  It looks like llamafile.exe was removed while running."
    echo "  Check your drive and try again."
else
    echo "  If it stopped unexpectedly, try running this launcher again."
    echo "  Make sure you have at least 4GB of free RAM."
fi
echo ""
echo "  Need help? support@opensourceeverything.io"
echo "----------------------------------------------------------------"
read -p "  Press Enter to exit..."
