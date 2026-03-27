# facts.

**Offline, uncensored, zero-log AI on a flash drive.**

No internet. No installation. No accounts. Plug in, double-click, ask anything.

Built by [Open Source Everything](https://opensourceeverything.io) — *for the people, by the people.*

---

## What Is This?

This is the complete, open-source build for the **facts.** AI flash drive. Everything you need to build your own is right here — the launcher scripts, the guide files, the licenses, and the folder structure. Download the model files and engine separately (links below), drop them in `.system/`, and you've got the same product we sell.

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

These go in the `.system/` folder:

| File | Size | Source |
|------|------|--------|
| `llamafile.exe` | ~294MB | [Mozilla llamafile releases](https://github.com/Mozilla-Ocho/llamafile/releases) |
| `Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf` | ~4.0GB | [HuggingFace](https://huggingface.co/prithivMLmods/Qwen3-4B-2507-abliterated-GGUF/tree/main/Qwen3-4B-Instruct-2507-abliterated-GGUF) |
| `Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf` | ~2.3GB | [HuggingFace](https://huggingface.co/prithivMLmods/Qwen3-4B-2507-abliterated-GGUF/tree/main/Qwen3-4B-Instruct-2507-abliterated-GGUF) |

**Mac users** also need the llama.cpp ARM64 binaries (included in the repo under `.system/`):
- Download from [llama.cpp releases](https://github.com/ggerganov/llama.cpp/releases) → `llama-<version>-bin-macos-arm64.tar.gz`
- Extract into `.system/`

## Hardware Requirements

| | Minimum | Recommended |
|---|---------|-------------|
| **RAM** | 8GB | 16GB+ |
| **Windows** | 64-bit Windows 10/11, any CPU | NVIDIA GPU for acceleration |
| **Mac** | Apple Silicon (M1/M2/M3/M4) | Any Apple Silicon Mac |
| **Linux** | Any modern x86_64 or ARM64 | NVIDIA GPU for acceleration |
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
6. GPU is detected (NVIDIA on Windows/Linux, Metal on Mac)
7. Model loads into memory (10-60 seconds)
8. `>` prompt appears — start asking questions

## What's In the Box

```
facts/
├── WindowsLaunch.bat          # Windows launcher
├── MacLaunch.command           # Mac launcher
├── LinuxLaunch.sh              # Linux launcher
├── A GUIDE/
│   ├── READ_ME_FIRST.txt       # Product guide & legal
│   ├── TROUBLESHOOT_WIN.txt    # Windows troubleshooting
│   └── TROUBLESHOOT_MAC.txt    # Mac troubleshooting
├── LICENSES/
│   ├── LLAMA_CPP_LICENSE.txt   # MIT License (llama.cpp)
│   └── MODEL LICENSES/
│       └── QWEN_LICENSE.txt    # Apache 2.0 (Qwen)
└── .system/                    # Hidden folder
    ├── llamafile.exe           # Cosmopolitan binary (Win/Linux)
    ├── llama-cli               # Native Mac binary (ARM64)
    ├── lib*.dylib              # Mac shared libraries
    ├── llama-server            # Web server (bonus tool)
    ├── llama-quantize          # Model quantization tool
    ├── llama-tts               # Text-to-speech tool
    ├── [other llama.cpp tools] # Full toolkit included
    ├── *.Q8_0.gguf             # High performance model (~4GB)
    └── *.Q4_K_M.gguf           # Efficiency model (~2.3GB)
```

## Troubleshooting

### Windows
| Problem | Fix |
|---------|-----|
| Hangs at "LOADING MODEL" | Download [updated launcher](https://github.com/WEAREOSE/facts). Old versions forced GPU offload on non-NVIDIA systems. |
| Terminal opens and closes instantly | Antivirus quarantined `llamafile.exe`. Windows Security → Protection History → Allow on device. |
| SmartScreen warning | Click "More info" → "Run anyway" |
| Slow performance | Close other apps. Check Task Manager → Memory. Need 4GB+ free. |

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
| "Permission denied" | `chmod +x /path/to/drive/.system/llamafile.exe` |
| Hangs forever | Check `free -m` — need 4GB+ available. Close browsers. |
| Slow performance | Normal without NVIDIA GPU. CPU inference works but is slower. |

### All Platforms
- **AI crashes mid-conversation:** Context window full. Close and relaunch.
- **AI refuses to answer:** Close and relaunch. Rephrase the question.

## Tech Stack

| Component | Technology | License |
|-----------|-----------|---------|
| AI Engine (Win/Linux) | [llamafile](https://github.com/Mozilla-Ocho/llamafile) (cosmopolitan binary) | MIT |
| AI Engine (Mac) | [llama.cpp](https://github.com/ggerganov/llama.cpp) (native ARM64) | MIT |
| Model | [Qwen3-4B-Instruct abliterated](https://huggingface.co/prithivMLmods/Qwen3-4B-Instruct-2507-abliterated-GGUF) | Apache 2.0 |
| Context Window | 8192 tokens | — |

## Support

- **Email:** support@opensourceeverything.io
- **Instagram:** [@open.source.everything](https://instagram.com/open.source.everything)
- **Website:** [opensourceeverything.io](https://opensourceeverything.io)
- **GitHub:** [github.com/WEAREOSE](https://github.com/WEAREOSE)

## License

The launcher scripts and guide files in this repo are released under the [MIT License](LICENSES/LLAMA_CPP_LICENSE.txt).

The AI model (Qwen3-4B) is licensed under [Apache 2.0](LICENSES/MODEL%20LICENSES/QWEN_LICENSE.txt).

llamafile and llama.cpp are licensed under MIT by their respective authors.

---

*Privacy is urgency. It is more possible today than it will be tomorrow.*
