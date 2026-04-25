# facts.

**Offline, uncensored, zero-log AI on a flash drive.**

No internet. No installation. No accounts. Plug in, double-click, ask anything.

Built by [Open Source Everything](https://opensourceeverything.io) — *for the people, by the people.*

---

## What Is This?

This is the complete, open-source build for the **facts.** AI flash drive. Everything you need to build your own is right here — the launcher scripts, the guide files, the licenses, and the folder structure. Download the AI engine binaries and model files separately (links below), drop them in `.system/`, and you've got the same product we sell.

We charge for the hardware, the testing, and the convenience. The software is free.

## Quick Start

### Buy One (Pre-Built)
Visit [opensourceeverything.io](https://opensourceeverything.io) — plug in and go.

### Build Your Own

1. Get a USB flash drive (16GB minimum, 32GB+ recommended)
2. Format it as exFAT
3. Clone or download this repo onto the drive
4. Download the required binaries into the `.system/` folder (see below)
5. Double-click the launcher for your OS:
   - **Windows:** `WindowsLaunch.bat`
   - **Mac:** `MacLaunch.command`
   - **Linux:** `LinuxLaunch.sh`

### Required Downloads (Not Included — Too Large for Git)

The model files (~6.3 GB total) go in the `.system/` folder:

| File | Size | Source |
|------|------|--------|
| `Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf` | ~4.0GB | [HuggingFace](https://huggingface.co/prithivMLmods/Qwen3-4B-2507-abliterated-GGUF/tree/main/Qwen3-4B-Instruct-2507-abliterated-GGUF) |
| `Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf` | ~2.3GB | [HuggingFace](https://huggingface.co/prithivMLmods/Qwen3-4B-2507-abliterated-GGUF/tree/main/Qwen3-4B-Instruct-2507-abliterated-GGUF) |

Then the platform-specific AI engines from [llama.cpp releases](https://github.com/ggml-org/llama.cpp/releases) (build b8783 or newer):

| Platform | What you need | Where it goes |
|---|---|---|
| **Windows** | `llama-b8783-bin-win-vulkan-x64.zip` (extract) | `.system/windows/` (must contain `llama-cli.exe`, `ggml-vulkan.dll`, all `ggml-cpu-*.dll`, `llama.dll`) |
| **Mac (Apple Silicon)** | `llama-b8783-bin-macos-arm64.tar.gz` (extract) | `.system/` (must contain `llama-cli`, all `lib*.dylib`) |
| **Linux** | `llama-b8783-bin-ubuntu-vulkan-x64.tar.gz` (extract) | `.system/linux/` (must contain `llama-cli`, all `lib*.so`) |

## Hardware Requirements

| | Minimum | Recommended |
|---|---------|-------------|
| **RAM** | 8GB | 16GB+ |
| **Windows** | 64-bit Windows 10/11 | NVIDIA GPU with ≥6GB VRAM for full GPU acceleration |
| **Mac** | Apple Silicon (M1/M2/M3/M4) | Any Apple Silicon Mac |
| **Linux** | Any modern x86_64 (glibc 2.32+) | Any GPU with Vulkan driver (NVIDIA / AMD / Intel) |
| **Drive** | USB 2.0 works | USB 3.0 for faster load times |

**Note:** Intel Macs are NOT supported. The Mac binary is ARM64 only.

## How It Works

1. Plug in the drive
2. Double-click the launcher for your OS
3. The launcher kills any ghost processes from previous sessions
4. All chat history is wiped (zero-log privacy — nothing is ever saved)
5. Your RAM is detected and the best model is selected:
   - 16GB+ → Q8 (high quality)
   - 8-15GB → Q4 (efficiency mode)
6. GPU is detected and tested for compatibility:
   - **Windows:** NVIDIA VRAM is checked. If VRAM is large enough for the selected model, full GPU offload is used. Otherwise CPU mode (no crash, no hang).
   - **Linux:** A 90-second compatibility test runs once on first launch. Result is cached so future launches are instant.
   - **Mac:** Apple Silicon Metal is unified memory — always works, no checks needed.
7. Model loads into memory (10-60 seconds, longer on first GPU test)
8. `>` prompt appears — start asking questions

## What's In the Box

```
facts/
├── WindowsLaunch.bat              # Windows launcher (VRAM-aware GPU detection)
├── MacLaunch.command              # Mac launcher (Apple Silicon)
├── LinuxLaunch.sh                 # Linux launcher (GPU safety test + auto-fallback)
├── A GUIDE/
│   ├── READ_ME_FIRST.txt          # Product guide & legal
│   ├── TROUBLESHOOT_WIN.txt       # Windows troubleshooting
│   └── TROUBLESHOOT_MAC.txt       # Mac troubleshooting
├── LICENSES/
│   ├── LLAMA_CPP_LICENSE.txt      # MIT License (llama.cpp)
│   └── MODEL LICENSES/
│       └── QWEN_LICENSE.txt       # Apache 2.0 (Qwen)
└── .system/                       # Hidden folder (engines + models)
    ├── llama-cli                  # Mac native binary (ARM64)
    ├── lib*.dylib                 # Mac shared libraries
    ├── windows/                   # Windows engine
    │   ├── llama-cli.exe          # Native Windows binary
    │   ├── ggml-vulkan.dll        # Vulkan support (any GPU vendor)
    │   ├── ggml-cpu-*.dll         # CPU optimizations per architecture
    │   └── llama.dll              # Core library
    ├── linux/                     # Linux engine
    │   ├── llama-cli              # Native Linux binary (ELF x86_64)
    │   ├── libggml-vulkan.so      # Vulkan support (any GPU vendor)
    │   └── lib*.so                # Shared libraries
    ├── *.Q8_0.gguf                # High performance model (~4GB)
    └── *.Q4_K_M.gguf              # Efficiency model (~2.3GB)
```

## Troubleshooting

### Windows
| Problem | Fix |
|---------|-----|
| `Failed to load model` / Vulkan ErrorOutOfDeviceMemory | Your NVIDIA card has too little VRAM for the selected model. **Update the launcher** by downloading the latest `WindowsLaunch.bat` from this repo — it has VRAM-aware GPU detection and will fall back to CPU mode automatically on cards <6GB VRAM. |
| Terminal opens and closes instantly | Antivirus quarantined `llama-cli.exe`. Windows Security → Protection History → Allow on device. |
| SmartScreen warning | Click "More info" → "Run anyway" |
| Slow performance | Close other apps. Check Task Manager → Memory. Need 4GB+ free. |
| GPU shows `[CPU mode - VRAM insufficient]` | Working as designed. Your GPU's VRAM is too small for full model offload, so CPU is being used for safety. Performance will be slower than GPU but the AI works correctly. |

### Mac
| Problem | Fix |
|---------|-----|
| "Can't be opened" on double-click | Right-click → Open → click "Open" in the dialog |
| "Permission denied" | Terminal: `xattr -r -d com.apple.quarantine /Volumes/facts/.system && chmod +x /Volumes/facts/.system/llama-cli` |
| Intel Mac error | Not supported. ARM64 binary only (M1/M2/M3/M4). |
| "Killed" or crash | Out of RAM. Close all other apps. |

### Linux
| Problem | Fix |
|---------|-----|
| "Permission denied" | `chmod +x /path/to/drive/.system/linux/llama-cli` |
| Hangs forever | Check `free -m` — need 4GB+ available. Close browsers. |
| GPU test takes ~90 seconds on first launch | Normal — it's verifying Vulkan works on your GPU. Result is cached, future launches are instant. |
| Want to re-run GPU test (e.g. after driver update) | Delete `.system/.cpu_mode` (if present) and `.system/.gpu_verified` (if present), then relaunch |

### All Platforms
- **AI crashes mid-conversation:** Context window full. Close and relaunch.
- **AI refuses to answer:** Close and relaunch. Rephrase the question.

## Tech Stack

| Component | Technology | License |
|-----------|-----------|---------|
| AI Engine (all platforms) | [llama.cpp](https://github.com/ggml-org/llama.cpp) (native binaries, build b8783) | MIT |
| GPU acceleration | Vulkan (Windows / Linux), Metal (Mac) | — |
| Model | [Qwen3-4B-Instruct abliterated](https://huggingface.co/prithivMLmods/Qwen3-4B-2507-abliterated-GGUF) | Apache 2.0 |
| Context Window | 8192 tokens | — |

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the full version history.

## Support

- **Email:** support@opensourceeverything.io
- **Instagram:** [@open.source.everything](https://instagram.com/open.source.everything)
- **Website:** [opensourceeverything.io](https://opensourceeverything.io)
- **GitHub:** [github.com/WEAREOSE](https://github.com/WEAREOSE)

## License

The launcher scripts and guide files in this repo are released under the [MIT License](LICENSES/LLAMA_CPP_LICENSE.txt).

The AI model (Qwen3-4B) is licensed under [Apache 2.0](LICENSES/MODEL%20LICENSES/QWEN_LICENSE.txt).

llama.cpp is licensed under MIT by ggml-org.

---

*Privacy is urgency. It is more possible today than it will be tomorrow.*
