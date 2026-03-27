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

## What Changed

- **Fixed GPU detection (Windows)** — No longer forces GPU acceleration on systems that don't support it. This was the #1 cause of the drive hanging forever on AMD Ryzen and Intel systems.
- **Added Linux support** — LinuxLaunch.sh works on any modern 64-bit distro (Ubuntu, Fedora, Arch, Debian, Mint, Pop!_OS, etc).
- **Better diagnostics** — Shows RAM, available memory, GPU detection, and post-exit guidance.
- **Antivirus detection** — Warns you if Windows Defender or other antivirus may have blocked the AI engine.
- **Pre-flight checks** — Verifies the AI binary exists before trying to launch.

## Common Issues

### Windows: AI hangs at "LOADING MODEL INTO MEMORY..."
Download the updated launcher above — the old version had a GPU bug that caused infinite hangs on non-NVIDIA systems.

If it still hangs with the new launcher, your antivirus may be silently blocking `llamafile.exe`. Open **Windows Security > Virus & threat protection > Protection history** and look for a blocked file. Click **"Allow on device"** and try again.

### Windows: Terminal opens and closes immediately
Your antivirus likely deleted the engine binary. Check **Windows Security > Protection history**, restore the file, and add the drive to your exclusions.

### Mac: "can't be opened" or nothing happens
Right-click (Control-click) the launcher > Open > click "Open" in the dialog. Or go to **System Settings > Privacy & Security**, scroll down, and click **"Allow Anyway"**.

### Linux: Permission denied
Run: `chmod +x /path/to/drive/LinuxLaunch.sh` and try again.

## Model Files

The AI models are not included in this repo (they're 2-4GB each). They come pre-loaded on your drive. If your model files are missing or corrupted, you can re-download them from HuggingFace:

- [Q4_K_M (2.5GB - Efficiency)](https://huggingface.co/prithivMLmods/Qwen3-4B-2507-abliterated-GGUF/resolve/main/Qwen3-4B-Instruct-2507-abliterated-GGUF/Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf?download=true)
- [Q8_0 (4.3GB - High Performance)](https://huggingface.co/prithivMLmods/Qwen3-4B-2507-abliterated-GGUF/resolve/main/Qwen3-4B-Instruct-2507-abliterated-GGUF/Qwen3-4B-Instruct-2507-abliterated.Q8_0.gguf?download=true)

Place them in the `.system` folder on your drive.

## Need Help?

Visit [opensourceeverything.io](https://opensourceeverything.io) and click the wrench icon in the bottom-right corner — our LLM Engineer can diagnose your setup, write custom fixes, and rebuild your launcher on the spot.

Instagram: [@open.source.everything](https://instagram.com/open.source.everything)

---

For the people. By the people.
