# facts. v1.5

**Offline, uncensored, zero-log AI on a flash drive. Premium edition.**

No internet. No installation. No accounts. Plug in, double-click, ask anything.

Built by [Open Source Everything](https://opensourceeverything.io), *for the people, by the people.*

> **This is the v1.5 branch.** If you have the original facts. drive (model files named
> `Qwen3-4B-Instruct-2507-*.gguf`), use the [main branch](https://github.com/WEAREOSE/facts)
> instead. Not sure? Open the drive's hidden `.system` folder: v1.5 drives have
> `Qwen3.5-4B-abliterated` model files.

---

## What Is This?

This is the complete, open-source build for the **facts. v1.5** AI flash drive. Everything you need to build your own is right here: the launcher scripts, the guide files, the licenses, and the folder structure. Download the AI engine binaries and model files separately (links below), drop them in `.system/`, and you've got the same product we sell.

We charge for the hardware, the testing, and the convenience. The software is free.

## Quick Start

### Buy One (Pre-Built)
Visit [opensourceeverything.io](https://opensourceeverything.io), plug in and go.

### Build Your Own

1. Get a USB flash drive (16GB minimum, 32GB+ recommended)
2. Format it as exFAT (v1.5 retail drives use 128KB allocation units for faster model loads; on macOS: `newfs_exfat -b 131072`)
3. Clone or download this branch onto the drive
4. Copy `ose-logo.txt` into the `.system/` folder (the launchers print it at boot)
5. Download the required binaries into the `.system/` folder (see below)
6. Double-click the launcher for your OS:
   - **Windows:** `WindowsLaunch.bat`
   - **Mac:** `MacLaunch.command` (Apple Silicon and Intel both supported)
   - **Linux:** `Launch facts (Linux)` (double-click) or `LinuxLaunch.sh` (terminal)

### Required Downloads (Not Included — Too Large for Git)

The model files (~7.2 GB total) go in the `.system/` folder:

| File | Size | Source |
|------|------|--------|
| `Qwen3.5-4B-abliterated.Q8_0.gguf` | ~4.5GB | [HuggingFace](https://huggingface.co/mradermacher/Qwen3.5-4B-abliterated-GGUF) |
| `Qwen3.5-4B-abliterated.Q4_K_M.gguf` | ~2.7GB | [HuggingFace](https://huggingface.co/mradermacher/Qwen3.5-4B-abliterated-GGUF) |

Model credits: base model [Qwen3.5-4B](https://huggingface.co/Qwen/Qwen3.5-4B) by Alibaba Cloud (Qwen Team) · abliteration by [wangzhang](https://huggingface.co/wangzhang/Qwen3.5-4B-abliterated) (made with the Abliterix tool) · GGUF quantization by [mradermacher](https://huggingface.co/mradermacher/Qwen3.5-4B-abliterated-GGUF) · Apache 2.0.

Then the platform-specific AI engines from [llama.cpp releases](https://github.com/ggml-org/llama.cpp/releases) (build b8783 or newer):

| Platform | What you need | Where it goes |
|---|---|---|
| **Windows** | `llama-*-bin-win-vulkan-x64.zip` (extract) | `.system/windows/` (needs `llama-cli.exe`, `llama-bench.exe`, `ggml-vulkan.dll`, all `ggml-cpu-*.dll`, `llama.dll` — plus `bench-decide.ps1` from this repo's `.system/windows/`) |
| **Mac (Apple Silicon)** | `llama-*-bin-macos-arm64.tar.gz` (extract) | `.system/` (needs `llama-cli`, all `lib*.dylib`) |
| **Mac (Intel)** | Build llama.cpp from source for x86_64 (CPU) | `.system/x86_64/` (retail drives ship a custom AVX2 build) |
| **Linux** | `llama-*-bin-ubuntu-vulkan-x64.tar.gz` (extract) | `.system/linux/` (needs `llama-cli`, `llama-bench`, all `lib*.so`) |

## Hardware Requirements

| | Minimum | Recommended |
|---|---------|-------------|
| **RAM** | 8GB | 16GB+ |
| **Windows** | 64-bit Windows 10/11 | Any GPU with a Vulkan driver (NVIDIA / AMD / Intel) |
| **Mac** | Apple Silicon (M1+) or Intel (2013+) | Apple Silicon for full GPU speed; Intel runs CPU mode (slower, fully functional) |
| **Linux** | Any modern x86_64 (glibc 2.32+) | Any GPU with a Vulkan driver (NVIDIA / AMD / Intel) |
| **Drive** | USB 2.0 works | USB 3.0 for faster load times |

## How It Works

1. Plug in the drive
2. Double-click the launcher for your OS
3. The OSE logo prints, ghost processes are killed, and all chat history is wiped (zero-log privacy — history is wiped at every launch AND at exit, and the exit clears the screen)
4. Your RAM is detected and the best model is selected:
   - 16GB+ → Q8 (high quality) — on Apple Silicon this also checks FREE memory, so a busy machine may pick Q4 on purpose
   - 8-15GB → Q4 (efficiency mode)
5. Your context window is sized to your RAM: 8K default, 16K on 16GB machines, 32K on 32GB+
6. The right engine is picked:
   - **Windows + Linux:** a one-time smart benchmark races your GPU against your CPU (30-90 seconds on first launch — it can look frozen, it is not) and the faster one wins. The result is cached in `.system/.gpu_verified` or `.system/.cpu_mode`; delete those files to re-test after a driver update.
   - **Mac:** Apple Silicon uses Metal (no benchmark needed). Intel Macs use the CPU engine in `.system/x86_64/`.
7. Model loads into memory (10-60 seconds)
8. `>` prompt appears — start asking questions

Thinking mode is OFF by default for fast, direct answers. Enabling it (and raising the context size) is documented in `A GUIDE/READ_ME_FIRST.txt` under ADVANCED TWEAKS.

## What's In the Box

```
facts (v1.5)/
├── WindowsLaunch.bat              # Windows launcher (Vulkan smart bench)
├── MacLaunch.command              # Mac launcher (Apple Silicon + Intel dispatch)
├── LinuxLaunch.sh                 # Linux launcher (terminal)
├── Launch facts (Linux)           # Linux launcher (double-click ELF)
├── ose-logo.txt                   # Boot logo — copy into .system/
├── A GUIDE/
│   ├── READ_ME_FIRST.txt          # Product guide, ADVANCED TWEAKS & legal
│   ├── TROUBLESHOOT_WIN.txt       # Windows troubleshooting
│   ├── TROUBLESHOOT_MAC.txt       # Mac troubleshooting
│   └── TROUBLESHOOT_LINUX.txt     # Linux troubleshooting
├── LICENSES/
│   ├── LLAMA_CPP_LICENSE.txt      # MIT License (llama.cpp)
│   └── MODEL LICENSES/
│       └── QWEN_LICENSE.txt       # Apache 2.0 (Qwen)
└── .system/                       # Hidden folder (engines + models)
    ├── llama-cli                  # Mac Apple Silicon binary (ARM64)
    ├── lib*.dylib                 # Mac shared libraries
    ├── ose-logo.txt               # Boot logo (printed by all launchers)
    ├── x86_64/                    # Intel Mac engine (CPU)
    ├── windows/                   # Windows engine (+ llama-bench.exe, bench-decide.ps1)
    ├── linux/                     # Linux engine (+ llama-bench)
    ├── Qwen3.5-4B-abliterated.Q8_0.gguf     # High performance model (~4.5GB)
    └── Qwen3.5-4B-abliterated.Q4_K_M.gguf   # Efficiency model (~2.7GB)
```

## Troubleshooting

Full per-platform guides live in `A GUIDE/`. Quick hits:

| Problem | Fix |
|---------|-----|
| First launch sits at "benchmarking" for a minute (Win/Linux) | Normal. One-time GPU-vs-CPU benchmark; the result is cached and future launches are instant. |
| Want to re-test the GPU after a driver update | Delete `.system/.gpu_verified` and `.system/.cpu_mode`, then relaunch. |
| Terminal opens and closes instantly (Windows) | Antivirus quarantined `llama-cli.exe`. Windows Security → Protection History → restore + allow. |
| "Can't be opened" on double-click (Mac) | Right-click → Open → click "Open" in the dialog. |
| "Permission denied" (Mac/Linux) | `chmod -R +x` the drive's `.system` folder (see the platform guide). |
| Intel Mac | Fully supported: the launcher auto-detects and runs the CPU engine (slower than Apple Silicon, works fine). |
| Slow performance | Close other apps. The AI wants 4GB+ free RAM. |
| AI crashes mid-conversation | Context window full. Close and relaunch. |

## Tech Stack

| Component | Technology | License |
|-----------|-----------|---------|
| AI Engine (all platforms) | [llama.cpp](https://github.com/ggml-org/llama.cpp) (native binaries) | MIT |
| GPU acceleration | Vulkan (Windows / Linux), Metal (Mac Apple Silicon) | — |
| Model | [Qwen3.5-4B abliterated](https://huggingface.co/mradermacher/Qwen3.5-4B-abliterated-GGUF) (wangzhang abliteration of Qwen3.5-4B) | Apache 2.0 |
| Context Window | 8K / 16K / 32K, sized to your RAM | — |

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the full version history.

## Support

- **Email:** support@opensourceeverything.io
- **Instagram:** [@open.source.everything](https://instagram.com/open.source.everything)
- **Website:** [opensourceeverything.io](https://opensourceeverything.io)
- **GitHub:** [github.com/WEAREOSE](https://github.com/WEAREOSE)

## License

The launcher scripts and guide files in this repo are released under the [MIT License](LICENSES/LLAMA_CPP_LICENSE.txt).

The AI model (Qwen3.5-4B) is licensed under [Apache 2.0](LICENSES/MODEL%20LICENSES/QWEN_LICENSE.txt).

llama.cpp is licensed under MIT by ggml-org.

---

*Privacy is urgency. It is more possible today than it will be tomorrow.*
