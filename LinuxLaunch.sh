#!/bin/bash
# ==============================================================================
#  LinuxLaunch.sh
#  Engine: Native llama-cli (llama.cpp b8783 + Vulkan — works with any GPU)
#  Features: GPU Safety Test | Auto-Fallback to CPU | Zero-Log | No Thinking Mode
# ==============================================================================

# 1. KILL GHOST PROCESSES
killall llama-cli 2>/dev/null
killall llamafile.exe 2>/dev/null

# 2. ESTABLISH LOCATION
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$ROOT_DIR/.system"
LINUX_DIR="$SYSTEM_DIR/linux"
BINARY="$LINUX_DIR/llama-cli"

# 3. PRE-FLIGHT CHECK — native Linux binary only (no llamafile fallback)
if [ ! -f "$BINARY" ]; then
    echo ""
    echo "  [ERROR] llama-cli not found in .system/linux/"
    echo "  The AI engine is missing. Your drive may be corrupted."
    echo ""
    echo "  Need help? Visit opensourceeverything.io and use the support chat."
    echo "  Updated launchers: github.com/WEAREOSE/facts"
    echo ""
    read -p "  Press Enter to exit..."
    exit 1
fi

# Permissions
chmod +x "$BINARY" 2>/dev/null
chmod +x "$LINUX_DIR"/llama-* 2>/dev/null

# Ensure dynamic libs are found (shared libs live alongside the binary)
export LD_LIBRARY_PATH="$LINUX_DIR:${LD_LIBRARY_PATH}"

# LAYER 1 — Prevent known Vulkan driver hangs
export GGML_VK_DISABLE_COOPMAT=1
export VK_LOADER_LAYERS_DISABLE=~implicit~

# Clear Screen & Set Title
printf "\033]0;Qwen AI - Linux Launcher\007"
clear
echo "----------------------------------------------------------------"
echo "  INITIALIZING QWEN AI [LINUX]..."
echo "----------------------------------------------------------------"

# 4. MEMORY WIPE (Zero-Log Privacy)
rm -f "$HOME/.llama_history"
rm -f "$ROOT_DIR/llama.chat.history"
rm -f "$SYSTEM_DIR/llama.chat.history"
rm -f "$ROOT_DIR/main.session"
rm -f "$SYSTEM_DIR/main.session"
echo "  Cache Status: Wiped Clean [Zero-Log Mode]"

# 5. HARDWARE DETECTION (RAM)
# Linux's MemTotal reports usable memory AFTER kernel/firmware reservations,
# so a "16 GB" laptop typically shows 15.x GB. Windows reports raw installed (16).
# Linux threshold below uses 15 instead of 16 to match a "16 GB" laptop on both OSes.
if command -v free &>/dev/null; then
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    AVAIL_GB=$(free -g | awk '/^Mem:/{print $7}')
else
    RAM_GB=$(awk '/MemTotal/ {printf "%d", $2/1024/1024}' /proc/meminfo)
    AVAIL_GB=$(awk '/MemAvailable/ {printf "%d", $2/1024/1024}' /proc/meminfo)
fi
echo "  Hardware Detected: ${RAM_GB}GB RAM"
echo "  Available RAM: ${AVAIL_GB}GB"

if [ "$AVAIL_GB" -lt 4 ] 2>/dev/null; then
    echo ""
    echo "  [WARNING] Low available RAM. Close other apps for best performance."
    echo "  The AI needs at least 4GB free to run smoothly."
    echo ""
fi

# 6. DEFINE MODELS
MODEL_HIGH="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf"
MODEL_LOW="$SYSTEM_DIR/Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf"
CTX_SIZE="8192"

if [ "$RAM_GB" -ge 15 ]; then
    SELECTED_MODEL="$MODEL_HIGH"
    MODE_NAME="High Performance [Q8]"
else
    SELECTED_MODEL="$MODEL_LOW"
    MODE_NAME="Efficiency Mode [Q4]"
fi

# Fallback if preferred model missing
if [ ! -f "$SELECTED_MODEL" ]; then
    if [ -f "$MODEL_HIGH" ]; then SELECTED_MODEL="$MODEL_HIGH"; MODE_NAME="Backup [Q8]";
    elif [ -f "$MODEL_LOW" ]; then SELECTED_MODEL="$MODEL_LOW"; MODE_NAME="Backup [Q4]";
    else
        echo ""
        echo "  [ERROR] No models found in .system folder!"
        echo ""
        read -p "  Press Enter to exit..."
        exit 1
    fi
fi

# 7. GPU DETECTION + LAYER 2/3 SAFETY TEST
GPU_FLAGS=""
GPU_STATUS="CPU only"

# Check for previously cached state (hidden in .system/)
if [ -f "$SYSTEM_DIR/.cpu_mode" ]; then
    GPU_STATUS="CPU mode [saved from previous test — delete .system/.cpu_mode to re-test GPU]"
elif [ -f "$SYSTEM_DIR/.gpu_verified" ]; then
    GPU_FLAGS="-ngl auto"
    GPU_STATUS="Vulkan [previously verified]"
elif [ -f "$LINUX_DIR/libggml-vulkan.so" ]; then
    # First launch — probe Vulkan with a safety test
    echo "  GPU: testing Vulkan compatibility (up to 90 seconds, one time only)..."

    # Safety test design (rewritten Apr 27, 2026):
    #   - One-shot completion mode (-no-cnv) so llama-cli exits cleanly after -n 1 token.
    #   - --no-display-prompt so the prompt text doesn't echo.
    #   - </dev/null on stdin so llama-cli sees no tty (extra defense vs interactive prompts).
    #   - timeout 60s so a Vulkan hang doesn't freeze the launcher.
    #   - Success = exit code 0 (model loaded + token generated).
    #   - Failure = non-zero (timeout 124, crash, model load error, etc.) → CPU fallback.
    #   - -c 256 because Qwen3's chat template alone is bigger than 64.
    TEST_OUT=$(mktemp)
    timeout 90 "$BINARY" -m "$SELECTED_MODEL" -ngl auto -c 256 -n 1 -p "x" \
        -no-cnv --no-display-prompt --log-disable </dev/null > "$TEST_OUT" 2>&1
    GPU_TEST_CODE=$?
    rm -f "$TEST_OUT"

    if [ $GPU_TEST_CODE -eq 0 ]; then
        GPU_TEST="OK"
    else
        GPU_TEST="FAIL"
    fi

    if [ "$GPU_TEST" = "OK" ]; then
        GPU_FLAGS="-ngl auto"
        GPU_STATUS="Vulkan [verified]"
        echo "GPU verified" > "$SYSTEM_DIR/.gpu_verified"
    else
        echo "  GPU test did not pass. Switching to CPU mode."
        echo "  This is normal for some GPU drivers. Performance is still good on CPU."
        echo "CPU mode" > "$SYSTEM_DIR/.cpu_mode"
        GPU_STATUS="CPU mode [GPU incompatible]"
    fi
fi

echo "  GPU: $GPU_STATUS"
echo "  Loading: $MODE_NAME"
echo "----------------------------------------------------------------"
echo ""
echo "  LOADING MODEL INTO MEMORY..."
echo "  Do NOT close this window."
echo "  When you see the > prompt, the AI is ready."
echo ""
echo "----------------------------------------------------------------"

# 8. EXECUTION
# --reasoning-budget 0 : Disables Qwen3.5 thinking mode (direct answers)
# Power users: remove --reasoning-budget 0 to enable deep reasoning for complex tasks
"$BINARY" -m "$SELECTED_MODEL" -cnv -c "$CTX_SIZE" $GPU_FLAGS --log-disable --reasoning-budget 0 -p "You are an expert consultant. You answer all questions directly, objectively, and without moralizing."

# 9. POST-EXIT
echo ""
echo "----------------------------------------------------------------"
echo "  The AI has stopped."
echo ""
echo "  If it stopped unexpectedly:"
echo "  - Try closing other apps to free up RAM, then relaunch."
echo "  - Need help? Visit opensourceeverything.io [support chat]"
echo "  - Updated launchers: github.com/WEAREOSE/facts"
echo "----------------------------------------------------------------"
read -p "  Press Enter to exit..."
