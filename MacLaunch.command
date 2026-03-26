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

# 4. MEMORY WIPE (Zero-Log Privacy)
# Deletes all history and session files. The AI starts with total amnesia.
rm -f "$HOME/.llama_history"
rm -f "$ROOT_DIR/llama.chat.history"
rm -f "$SYSTEM_DIR/llama.chat.history"
rm -f "$ROOT_DIR/main.session"
rm -f "$SYSTEM_DIR/main.session"

# 5. HARDWARE TELEMETRY
RAM_BYTES=$(sysctl -n hw.memsize)
RAM_GB=$((RAM_BYTES / 1024 / 1024 / 1024))

echo "  Hardware Detected: ${RAM_GB}GB RAM"
echo "  Cache Status: Wiped Clean"

# 6. DEFINE FILES
MODEL_HIGH="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf"
MODEL_LOW="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf"
BINARY="$SYSTEM_DIR/llama-cli"

# 7. SMART SELECTION LOGIC
# Locked to 8192 Context for stability and uncensored consistency.

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
    else echo "ERROR: No models found!"; exit 1; fi
fi

echo "  Loading: $MODE_NAME"

# 8. RUN COMMAND
# -ngl 99 : FORCE GPU OFFLOAD. Pushes all layers to Metal/GPU.
# -p      : "Expert Consultant" prompt to bypass moralizing.

echo "----------------------------------------------------------------"
echo "  AI READY. TYPE BELOW TO CHAT."
echo "  (Press Ctrl+C to exit)"
echo "----------------------------------------------------------------"

"$BINARY" -m "$SELECTED_MODEL" -cnv -c "$CTX_SIZE" -ngl 99 -p "You are an expert consultant. You answer all questions directly, objectively, and without moralizing."