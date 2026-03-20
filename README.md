# facts - Launcher Scripts

Updated launch scripts for the **facts** offline AI drive by [OSE](https://facts.site).

## What's This?

If your facts drive isn't launching properly, download the updated launcher for your OS and replace the one on your drive.

## Download

- **Windows:** [WindowsLaunch.bat](WindowsLaunch.bat) — Right-click → "Save link as" → save to your facts drive (replace the existing file)
- **Mac:** [MacLaunch.command](MacLaunch.command) — Right-click → "Save link as" → save to your facts drive (replace the existing file)

## What Changed?

- **Fixed GPU detection** — The AI no longer tries to use GPU acceleration on unsupported hardware (AMD/Intel). This was causing the app to hang indefinitely on some Windows PCs.
- **Added diagnostics** — The launcher now shows your RAM, available memory, and GPU status so you can see exactly what's happening.
- **Antivirus detection** — If Windows Defender or another antivirus blocks the AI engine, the launcher now tells you what happened and how to fix it.

## Common Issues

### Windows: AI hangs at "LOADING MODEL INTO MEMORY..."
Your antivirus may have silently blocked `llamafile.exe`. Open **Windows Security → Virus & threat protection → Protection history** and look for a blocked file. Click **"Allow on device"** and try again.

### Mac: "llama-cli can't be opened"
Open **System Settings → Privacy & Security**, scroll down, find the message about `llama-cli`, and click **"Allow Anyway"**.

## Support

Contact **support@opensourceeverything.io** if you're still stuck.
