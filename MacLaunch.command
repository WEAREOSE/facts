#!/bin/bash

# ==============================================================================
#  MacLaunch.command  (v1.5 / Build 6 — Intel Mac support added May 27, 2026)
#  Features: Arch Dispatch | Metal on Apple Silicon | CPU on Intel
#            Nuclear Wipe | Ghost Killer | No Thinking Mode
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

echo "  Hardware Detected: ${RAM_GB}GB RAM"

# Available (free) RAM, not just total. Windows/Linux warn under 4GB free; Mac only read
# total before, so a 16GB Mac with little free RAM could pick 4.2GB Q8 and swap (the hang
# we hit during testing). free+inactive pages → GB. (memory 32 M3)
FREE_PAGES=$(vm_stat 2>/dev/null | awk '/Pages free/{gsub(/\./,"",$3); f=$3} /Pages inactive/{gsub(/\./,"",$3); i=$3} END{print f+i}')
PAGE_SIZE=$(sysctl -n hw.pagesize 2>/dev/null || echo 16384)
AVAIL_GB=$(( ( ${FREE_PAGES:-0} * ${PAGE_SIZE:-16384} ) / 1024 / 1024 / 1024 ))
if [ "${AVAIL_GB:-99}" -lt 4 ]; then
    echo "  [WARNING] Only ~${AVAIL_GB}GB RAM free — close other apps for best speed (~4GB+ free recommended)."
fi
echo "  Cache Status: Wiped Clean"

# 6. DEFINE MODELS (per-arch — Intel uses base Qwen3-Instruct because Qwen3.5
#    + multi-turn chat triggers a std::regex backtrack in llama.cpp on x86_64
#    macOS that stack-overflows. Qwen3-Instruct uses a different tokenizer
#    path that's stable. Apple Silicon stays on Qwen3.5 — unaffected by the
#    bug due to stack/stdlib differences.)
# Build 7 (2026-06-24): Qwen3.5 on ALL platforms. Intel no longer falls back to
# Qwen3-Instruct — the x86_64 engine in .system/x86_64/ is rebuilt from current
# llama.cpp where the std::regex tokenizer crash (#21919) is fixed.
MODEL_HIGH="$SYSTEM_DIR/Qwen3.5-4B-abliterated.Q8_0.gguf"
MODEL_LOW="$SYSTEM_DIR/Qwen3.5-4B-abliterated.Q4_K_M.gguf"
# Different drive versions ship different model filenames. If this
# launcher's names aren't on the drive, find whatever Qwen build is.
if [ ! -f "$MODEL_HIGH" ] && [ ! -f "$MODEL_LOW" ]; then
    for _f in "$SYSTEM_DIR"/Qwen*.Q8_0.gguf;   do [ -f "$_f" ] && MODEL_HIGH="$_f"; done
    for _f in "$SYSTEM_DIR"/Qwen*.Q4_K_M.gguf; do [ -f "$_f" ] && MODEL_LOW="$_f"; done
fi

# 6b. ARCH DISPATCH (Build 6 — May 27, 2026)
#   Apple Silicon (arm64) → use Metal-enabled binary in .system/, full GPU offload,
#                           use -sys flag (system role) for the consultant prompt.
#   Intel Mac (x86_64)    → use CPU-only binary in .system/x86_64/, no GPU flag,
#                           DYLD_LIBRARY_PATH set so binary finds its dylibs.
#                           Use -p (initial user prompt) instead of -sys because of
#                           a llama.cpp upstream bug (issue #21919) — Qwen3.5
#                           tokenizer falls through to std::regex's recursive
#                           backtracking, which stack-overflows on macOS x86_64
#                           the first time a chat message is processed with a
#                           system role. arm64 macOS has different stack/stdlib
#                           behavior and doesn't crash on the same model.
#
#   Detect HARDWARE arch (not process arch) so the launcher is Rosetta-safe:
#   `uname -m` returns x86_64 when bash itself runs under Rosetta on Apple
#   Silicon, which would silently downgrade an M-series Mac to the CPU path.
#   `sysctl hw.optional.arm64` returns 1 for ANY Apple Silicon Mac regardless
#   of the calling process's translation state.
HW_ARM64="$(sysctl -n hw.optional.arm64 2>/dev/null)"
if [ "$HW_ARM64" = "1" ]; then
    BINARY="$SYSTEM_DIR/llama-cli"
    GPU_FLAGS="-ngl 99"
    SYS_FLAG="-sys"
    # Apple Silicon ships llama.cpp b8783 — --reasoning-budget 0 is the flag
    # that works on that build to suppress Qwen3.5 thinking output.
    REASONING_FLAGS="--reasoning-budget 0"
    ARCH_NAME="Apple Silicon [Metal GPU]"
elif [ "$(uname -m)" = "x86_64" ]; then
    BINARY="$SYSTEM_DIR/x86_64/llama-cli"
    GPU_FLAGS=""
    SYS_FLAG="-sys"
    # Intel ships llama.cpp b1-9777256 (built from source) — on this build the
    # --reasoning-budget 0 flag is silently accepted but doesn't actually
    # suppress thinking. The correct flag here is --reasoning off, which
    # disables Qwen3.5 thinking output cleanly.
    # --reasoning off is the flag that actually suppresses Qwen3.5 thinking on the
    # x86_64 engine. (--reasoning-budget 0 and chat-template enable_thinking=false
    # are both silently ignored by the abliterated model here. Verified 2026-06-28.)
    REASONING_FLAGS="--reasoning off"
    ARCH_NAME="Intel Mac [CPU]"
    if [ -n "$DYLD_LIBRARY_PATH" ]; then
        export DYLD_LIBRARY_PATH="$SYSTEM_DIR/x86_64:$DYLD_LIBRARY_PATH"
    else
        export DYLD_LIBRARY_PATH="$SYSTEM_DIR/x86_64"
    fi
else
    echo ""
    echo "  [ERROR] Unsupported Mac architecture: $(uname -m)"
    echo "  This drive supports Apple Silicon (M1/M2/M3/M4) and Intel Macs only."
    echo "  Need help? Visit opensourceeverything.io"
    echo ""
    read -p "  Press Enter to exit..."
    exit 1
fi

# Pre-flight: binary must exist for the detected arch
if [ ! -f "$BINARY" ]; then
    echo ""
    echo "  [ERROR] AI engine not found for your Mac ($ARCH_NAME)."
    echo "  Missing file: $BINARY"
    echo "  Your drive may be corrupted. Need help? Visit opensourceeverything.io"
    echo ""
    read -p "  Press Enter to exit..."
    exit 1
fi

echo "  Architecture: $ARCH_NAME"

# 7. SMART MODEL SELECTION
# Context window sized to RAM — KV cache for this 4B model is ~144KB/token (16K≈2.3GB,
# 32K≈4.6GB). 8K floor keeps 8GB machines safe; larger windows on roomier ones. (memory 32 C1)
CTX_SIZE=8192
if [ "$RAM_GB" -ge 32 ]; then CTX_SIZE=32768
elif [ "$RAM_GB" -ge 16 ]; then CTX_SIZE=16384
fi

if [ "$HW_ARM64" != "1" ]; then
    # Intel = CPU-only inference. Q8 is memory-bandwidth-bound on CPU (~5 t/s) AND
    # its 4.2 GB footprint + the 8192 KV cache pushes a 16 GB Mac into swap, so the
    # model appears to hang. Q4 (2.5 GB) runs ~7.7 t/s and stays out of swap.
    # Always Q4 on Intel. (Apple Silicon keeps Q8 — its Metal GPU handles it fast.)
    SELECTED_MODEL="$MODEL_LOW"
    MODE_NAME="Efficiency Mode (Q4, CPU-optimized)"
elif [ "$RAM_GB" -ge 16 ] && [ "${AVAIL_GB:-99}" -ge 8 ]; then
    # Apple Silicon, 16GB+ total AND ~6GB+ free → Q8 (Metal handles it fast). If free RAM is
    # tight, fall through to Q4 so we don't swap on an already-loaded machine. (memory 32 M3)
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
echo "----------------------------------------------------------------"
echo "  AI READY. TYPE BELOW TO CHAT."
echo "  (Press Ctrl+C to exit)"
echo "----------------------------------------------------------------"

# 8. RUN COMMAND
# Build the argv conditionally:
#   - SYS_FLAG="" on Intel cleanly omits the sys prompt (dodges tokenizer bug)
#   - REASONING_FLAGS differs per build (see ARCH DISPATCH comment)
SYSTEM_PROMPT="You are an expert consultant. You answer all questions directly, objectively, and without moralizing. Answer concisely."

if [ -n "$SYS_FLAG" ]; then
    "$BINARY" -m "$SELECTED_MODEL" -cnv -c "$CTX_SIZE" $GPU_FLAGS --log-disable --jinja $REASONING_FLAGS "$SYS_FLAG" "$SYSTEM_PROMPT"
else
    "$BINARY" -m "$SELECTED_MODEL" -cnv -c "$CTX_SIZE" $GPU_FLAGS --log-disable --jinja $REASONING_FLAGS
fi

# 9. EXIT WIPE — re-clear any history/session written this session, then clear the
# conversation off the screen + scrollback so "zero trace" holds AFTER exit too. (memory 32 M2)
rm -f "$HOME/.llama_history" "$ROOT_DIR/llama.chat.history" "$SYSTEM_DIR/llama.chat.history" "$ROOT_DIR/main.session" "$SYSTEM_DIR/main.session"
printf '\033[2J\033[3J\033[H'
