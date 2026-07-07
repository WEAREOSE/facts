#!/bin/bash

# ==============================================================================
#  MacLaunch.command  (base facts. — Intel Mac support added 2026-07-06)
#  Features: Arch Dispatch | Metal on Apple Silicon | CPU on Intel | Ghost Killer | Expert Prompt
# ==============================================================================

# 1. KILL GHOST PROCESSES
killall llama-cli 2>/dev/null

# 2. ESTABLISH LOCATION
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$ROOT_DIR/.system"

# Clear Screen & Set Title
printf "\033]0;Qwen AI - Mac Launcher\007"
clear
cat "$SYSTEM_DIR/ose-logo.txt" 2>/dev/null
echo "----------------------------------------------------------------"
echo "  INITIALIZING QWEN AI (MAC)..."
echo "----------------------------------------------------------------"

# 3. PERMISSIONS FIX
xattr -r -d com.apple.quarantine "$SYSTEM_DIR" 2>/dev/null
chmod -R +x "$SYSTEM_DIR" 2>/dev/null

# 4. MEMORY WIPE (Zero-Log Privacy)
rm -f "$HOME/.llama_history"
rm -f "$ROOT_DIR/llama.chat.history"
rm -f "$SYSTEM_DIR/llama.chat.history"
rm -f "$ROOT_DIR/main.session"
rm -f "$SYSTEM_DIR/main.session"

# 5. HARDWARE TELEMETRY
RAM_BYTES=$(sysctl -n hw.memsize)
RAM_GB=$((RAM_BYTES / 1024 / 1024 / 1024))
ARCH="$(uname -m)"

echo "  Hardware Detected: ${RAM_GB}GB RAM | ${ARCH}"
echo "  Cache Status: Wiped Clean"

# 6. DEFINE FILES
MODEL_HIGH="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf"
MODEL_LOW="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf"

# 6b. ARCH DISPATCH
# Apple Silicon (arm64) -> Metal GPU binary in .system/, full offload.
# Intel Mac (x86_64)    -> CPU-only binary in .system/x86_64/, no GPU flag.
if [ "$ARCH" = "x86_64" ]; then
    BINARY="$SYSTEM_DIR/x86_64/llama-cli"
    GPU_FLAGS=""
    ARCH_NAME="Intel (CPU)"
    # Intel llama-cli finds its dylibs (libllama, libggml, ...) in .system/x86_64/.
    if [ -n "$DYLD_LIBRARY_PATH" ]; then
        export DYLD_LIBRARY_PATH="$SYSTEM_DIR/x86_64:$DYLD_LIBRARY_PATH"
    else
        export DYLD_LIBRARY_PATH="$SYSTEM_DIR/x86_64"
    fi
else
    BINARY="$SYSTEM_DIR/llama-cli"
    GPU_FLAGS="-ngl 99"
    ARCH_NAME="Apple Silicon (Metal GPU)"
fi
# Fallback: if the arch-specific binary is missing, use whatever llama-cli exists.
if [ ! -x "$BINARY" ]; then
    if [ -x "$SYSTEM_DIR/llama-cli" ]; then BINARY="$SYSTEM_DIR/llama-cli"; GPU_FLAGS="-ngl 99";
    elif [ -x "$SYSTEM_DIR/x86_64/llama-cli" ]; then BINARY="$SYSTEM_DIR/x86_64/llama-cli"; GPU_FLAGS=""; fi
fi

# 7. SMART SELECTION LOGIC — Locked to 8192 Context for stability.
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

echo "  Engine: $ARCH_NAME"
echo "  Loading: $MODE_NAME"

# 8. RUN COMMAND
echo "----------------------------------------------------------------"
echo "  AI READY. TYPE BELOW TO CHAT."
echo "  (Press Ctrl+C to exit)"
echo "----------------------------------------------------------------"

"$BINARY" -m "$SELECTED_MODEL" -cnv -c "$CTX_SIZE" $GPU_FLAGS -p "You are an expert consultant. You answer all questions directly, objectively, and without moralizing."
