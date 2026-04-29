# facts. Changelog

Public version history for the facts. AI flash drive launchers and engine.

For setup help see [README.md](README.md).

---

## Build 5 — April 25, 2026 *(current)*

### Fixed
- **Acer Nitro 5 / RTX 3050 Laptop 4GB GPU crash on Windows.** The previous launcher hardcoded full-GPU offload (`-ngl 99`) regardless of how much VRAM the card had. On laptops with NVIDIA GPUs ≤4 GB VRAM, this caused `ErrorOutOfDeviceMemory: failed to allocate Vulkan1 buffer of size ~1 GB` and the AI never loaded. Affects RTX 3050 Laptop, RTX 4050 Laptop, GTX 1650 Mobile, and similar low-VRAM NVIDIA laptops.
- **Linux launcher trying to run a Mac binary.** The Linux launcher was pointing at `.system/llama-cli` (a Mac ARM64 binary). On Linux x86_64 this produced "cannot execute binary file: format error" — the launcher silently failed.
- **`-ngl auto` causing system freezes.** During investigation we discovered that `-ngl auto` (which is supposed to gracefully partial-offload) actively freezes systems with hybrid GPUs (NVIDIA + Intel iGPU on the same machine). This was never used in shipping launchers but documenting so we never try it again.

### Added
- **VRAM-aware GPU detection (Windows).** The launcher now queries actual VRAM via `nvidia-smi` and only enables `-ngl 99` if the card has enough VRAM for the selected model (5500 MiB for Q8, 3500 MiB for Q4). Otherwise it silently uses CPU mode — the AI loads correctly, just slower.
- **Native Linux engine.** New `.system/linux/` folder with native llama.cpp x86_64 binaries + Vulkan support. Replaces the legacy llamafile fallback path which didn't work with the current model architecture anyway.
- **Linux smart benchmark (GPU vs CPU).** First launch runs a ~30-second hidden benchmark that measures token throughput on BOTH the GPU (Vulkan, `-ngl 99`) and the CPU (`-ngl 0`), then picks the faster path. GPU only wins if it's at least 10% faster than CPU — this catches weak iGPUs (Intel UHD 6xx/7xx, low-end AMD Vega APUs) where Vulkan loads but the CPU is actually faster due to memory bandwidth and setup overhead. Result is cached in `.system/.gpu_verified` or `.system/.cpu_mode` so every subsequent launch is instant.
- **Aesthetic suppression markers.** New drives include `.metadata_never_index` (stops macOS from creating `.Spotlight-V100`) and a zero-byte `.fseventsd` file (stops macOS from creating the `.fseventsd` directory). Drives stay clean across mount/unmount cycles.

### Changed
- **Linux RAM threshold dropped from 16 GB → 15 GB** so that "16 GB" laptops (which Linux reports as 15.x GB after firmware reservations) now correctly select the Q8 model. Windows still uses 16 GB threshold (Windows reports raw installed RAM).
- **Engine version bumped to llama.cpp build b8783** on Windows + Linux (Mac stays on previous build for stability — if it ain't broke, don't fix it).

### Removed
- llamafile fallback in the Linux launcher. The bundled llamafile.exe v0.9.2 doesn't recognize the qwen3 model architecture — falling back to it just produced "unknown model architecture" errors. Native llama.cpp is the only Linux path now.

---

## Build 4 — April 9, 2026

### Changed
- **Windows engine swapped from llamafile.exe to native `llama-cli.exe` + Vulkan.** Adds a new `.system/windows/` folder containing the native Windows binary plus all required DLLs (Vulkan, CPU-architecture-specific optimizations). Vulkan support means GPU acceleration for NVIDIA, AMD, and Intel cards (previously llamafile only supported NVIDIA via CUDA on Windows).
- **Pinned llamafile.exe to v0.9.2.** Newer llamafile versions (0.9.3+) had broken GPU support on Windows. Pinned for safety as a fallback engine. (Note: in Build 5 this fallback was retired entirely — see above.)

### Added
- **`LinuxLaunch.sh`** for Linux users. Same features as the Mac/Windows launchers (zero-log, smart model selection, NVIDIA GPU detection).

### Known issues at the time
- Windows: `-ngl 99` hardcoded for any detected GPU. This caused the Nitro 5 / RTX 3050 4GB crash that wasn't caught until Build 5. ~40 drives shipped with this issue. If you have a Build 4 drive and hit this on a low-VRAM NVIDIA laptop, just download the Build 5 launchers from this repo and replace the files on your drive.

---

## Build 3 — March 26, 2026 *(reverted)*

A brief experiment switching Windows from llamafile to native llama-cli + Vulkan. Reverted within hours — `-ngl 99` on Vulkan tries to force ALL layers into VRAM (unlike CUDA which gracefully partial-offloads), and laptops with tight VRAM crashed immediately. The Vulkan approach was eventually shipped successfully in Build 4 (with NVIDIA-only gating) and Build 5 (with VRAM-aware gating).

---

## Build 2 — March 19, 2026

### Fixed
- **AI hanging forever on AMD / Intel iGPU systems on Windows.** The original launcher set `-ngl 99` (force GPU offload) for any detected GPU. On systems without an NVIDIA driver, llamafile would attempt CUDA initialization on a card that doesn't support it, and hang indefinitely with no error message. Two customer reports confirmed this.

### Changed
- **GPU detection narrowed to NVIDIA-only.** `WindowsLaunch.bat` now only sets `-ngl 99` if `nvidia-smi` is present and responsive. AMD, Intel, and GPU-less systems run on CPU automatically.

### Tradeoff
- AMD users with capable cards lose GPU acceleration → CPU mode. Acceptable because Windows + AMD + llamafile + Vulkan was unreliable at the time. AMD GPU support returned in Build 4 via the native Vulkan engine.

---

## Build 1 — Pre-March 2026 *(original)*

The first shipping build. Single-binary architecture using Mozilla's [llamafile](https://github.com/Mozilla-Ocho/llamafile) (cosmopolitan binary that runs on any OS). Mac used native llama.cpp. Windows + Linux both used llamafile.

| Component | What it was |
|---|---|
| Engine (Mac) | Native llama.cpp ARM64 |
| Engine (Windows + Linux) | llamafile.exe (cosmopolitan) |
| Model | Qwen3-4B-Instruct-2507-abliterated (Q4_K_M and Q8_0) |
| GPU strategy | `-ngl 99` blanket — full GPU offload on any detected GPU |

Worked great on Mac (Metal) and NVIDIA Windows machines. Triggered the issues that led to Builds 2-5 on other hardware.

---

## Update process for existing drives

If you have an older build (1-4) and want the current behavior, you don't need a new drive. Just:

1. Plug in your facts. drive
2. Download these three files from this repo:
   - `WindowsLaunch.bat`
   - `LinuxLaunch.sh`
   - `MacLaunch.command`
3. Drop them onto the drive root, replacing the old ones
4. Done — your drive is now Build 5

If you also want the new native engines (Vulkan support on Windows + Linux), download from [llama.cpp releases](https://github.com/ggml-org/llama.cpp/releases) (build b8783 or newer) and follow the layout in the [README](README.md#whats-in-the-box).
