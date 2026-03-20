#!/bin/bash

# ==============================================================================
#  MacLaunch.command
#  Features: GPU Offload | Nuclear Wipe | Ghost Killer | Expert Prompt
# ==============================================================================

# 1. KILL GHOST PROCESSES
# If an old version is stuck, this kills it to prevent "Address in use" errors.
killall llama-cli 2>/dev/null

# 2. ESTABLISH LOCATION
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$ROOT_DIR/.system"

# Clear Screen & Set Title
printf "\033]0;Qwen AI - Mac Launcher\007"
clear
echo "----------------------------------------------------------------"
echo "  INITIALIZING QWEN AI (MAC)..."
echo "----------------------------------------------------------------"

# 3. PERMISSIONS FIX
xattr -r -d com.apple.quarantine "$SYSTEM_DIR" 2>/dev/null
chmod -R +x "$SYSTEM_DIR" 2>/dev/null

# 4. PRE-FLIGHT CHECKS
BINARY="$SYSTEM_DIR/llama-cli"

if [ ! -f "$BINARY" ]; then
    echo ""
    echo "  ERROR: llama-cli is missing from .system folder."
    echo ""
    echo "  This can happen if macOS Gatekeeper blocked the file."
    echo ""
    echo "  TO FIX:"
    echo "    1. Open System Settings > Privacy & Security"
    echo "    2. Scroll down -- look for a message about llama-cli"
    echo "    3. Click 'Allow Anyway'"
    echo "    4. Run this launcher again"
    echo ""
    echo "  See TROUBLESHOOT_MAC.txt in the A GUIDE folder for more help."
    echo "----------------------------------------------------------------"
    read -p "  Press Enter to exit..."
    exit 1
fi

# Check architecture -- Apple Silicon required
ARCH=$(uname -m)
if [ "$ARCH" != "arm64" ]; then
    echo ""
    echo "  ERROR: This product requires Apple Silicon (M1/M2/M3/M4)."
    echo "  Your Mac has an Intel processor ($ARCH)."
    echo "  The AI engine is not compatible with Intel Macs."
    echo ""
    echo "  Contact support@opensourceeverything.io for help."
    echo "----------------------------------------------------------------"
    read -p "  Press Enter to exit..."
    exit 1
fi

# 5. MEMORY WIPE (Zero-Log Privacy)
# Deletes all history and session files. The AI starts with total amnesia.
rm -f "$HOME/.llama_history"
rm -f "$ROOT_DIR/llama.chat.history"
rm -f "$SYSTEM_DIR/llama.chat.history"
rm -f "$ROOT_DIR/main.session"
rm -f "$SYSTEM_DIR/main.session"

echo "  Cache Status: Wiped Clean (Zero-Log Mode)"

# 6. HARDWARE TELEMETRY
RAM_BYTES=$(sysctl -n hw.memsize)
RAM_GB=$((RAM_BYTES / 1024 / 1024 / 1024))

echo "  Hardware Detected: ${RAM_GB}GB RAM"

if [ "$RAM_GB" -lt 8 ]; then
    echo ""
    echo "  WARNING: Your system has less than 8GB of RAM."
    echo "  The AI may not load or may run very slowly."
    echo "  Close all other applications before continuing."
    echo ""
fi

# 7. DEFINE MODELS
MODEL_HIGH="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf"
MODEL_LOW="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf"

# 8. SMART SELECTION LOGIC
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

echo "  Loading: $MODE_NAME"
echo "  GPU: Metal (Apple Silicon)"
echo "----------------------------------------------------------------"
echo "  LOADING MODEL INTO MEMORY..."
echo "  Do NOT close this window."
echo "  When you see the > prompt, the AI is ready."
echo "----------------------------------------------------------------"

# 9. EXECUTION
"$BINARY" -m "$SELECTED_MODEL" -cnv -c "$CTX_SIZE" -ngl 99 -p "You are an expert consultant. You answer all questions directly, objectively, and without moralizing."

# If we get here, llama-cli exited
echo ""
echo "----------------------------------------------------------------"
echo "  The AI has stopped."
echo ""
if [ ! -f "$BINARY" ]; then
    echo "  It looks like macOS removed llama-cli."
    echo "  See TROUBLESHOOT_MAC.txt in the A GUIDE folder for steps."
else
    echo "  If it stopped unexpectedly, try running this launcher again."
    echo "  If the problem persists, see TROUBLESHOOT_MAC.txt in A GUIDE."
fi
echo "----------------------------------------------------------------"
read -p "  Press Enter to exit..."
