# facts. Launcher Scripts

Updated launch scripts for the **facts.** offline AI drive by [Open Source Everything](https://opensourceeverything.io).

## What's This?

If your facts. drive isn't launching properly, download the updated launcher for your OS and replace the one on your drive. These fix the most common issues people run into.

## Download

1. Click the file for your OS below
2. Click the **Download** button (top-right of the file view)
3. Save it to your facts. drive, replacing the existing file

- **Windows:** [WindowsLaunch.bat](WindowsLaunch.bat)
- **Mac:** [MacLaunch.command](MacLaunch.command)
- **Linux:** [LinuxLaunch.sh](LinuxLaunch.sh)

## What Changed (v2 - March 2026)

- **Switched Windows engine from llamafile to native llama-cli.exe** — llamafile is a cosmopolitan binary that some antivirus software silently blocks. The new native build eliminates this issue entirely.
- **Vulkan GPU acceleration (Windows)** — Works with ALL GPUs (NVIDIA, AMD, Intel). No more CUDA-only problems. No more hanging on AMD Ryzen systems.
- **Added Linux support** — LinuxLaunch.sh works on any modern 64-bit distro.
- **Better diagnostics** — Shows RAM, available memory, GPU detection, and post-exit guidance.

### Previous fixes (v1)
- Fixed GPU detection — no longer forces GPU acceleration on unsupported hardware
- Added antivirus detection and guidance
- Added pre-flight binary checks

## Common Issues

### Windows: AI hangs at "LOADING MODEL INTO MEMORY..."
**If you have the OLD launcher (pre-March 2026):** Download the new one above. The old version used `llamafile.exe` which antivirus software silently blocks.

**If you already have the new launcher:** Your antivirus may still be blocking `llama-cli.exe`. Open **Windows Security > Virus & threat protection > Protection history** and look for a blocked file. Click **"Allow on device"** and try again.

### Windows: Terminal opens and closes immediately
Your antivirus deleted the engine binary. Check **Windows Security > Protection history**, restore the file, and add the `.system\windows` folder to your exclusions.

### Mac: "llama-cli can't be opened"
Open **System Settings > Privacy & Security**, scroll down, find the blocked app message, and click **"Allow Anyway"**.

### Linux: Permission denied
Run: `chmod +x /path/to/drive/LinuxLaunch.sh` and try again.

## Model Files

The AI models are not included in this repo (they're 2-4GB each). They come pre-loaded on your drive. If your model files are missing or corrupted, you can re-download them from HuggingFace:

- [Q4_K_M (2.5GB - Efficiency)](https://huggingface.co/prithivMLmods/Qwen3-4B-2507-abliterated-GGUF/resolve/main/Qwen3-4B-Instruct-2507-abliterated-GGUF/Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf?download=true)
- [Q8_0 (4.3GB - High Performance)](https://huggingface.co/prithivMLmods/Qwen3-4B-2507-abliterated-GGUF/resolve/main/Qwen3-4B-Instruct-2507-abliterated-GGUF/Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf?download=true)

Place them in the `.system` folder on your drive.

## Need Help?

Use our AI support chatbot at [opensourceeverything.io](https://opensourceeverything.io) — click the chat button in the bottom-right corner. It can diagnose your issue and walk you through fixes.

Instagram: [@open.source.everything](https://instagram.com/open.source.everything)

---

For the people. By the people.
