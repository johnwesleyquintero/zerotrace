# ZeroTrace

<img width="200" height="200" alt="zero-trace-icon" src="https://github.com/user-attachments/assets/16f5b14f-a347-4880-b0be-eedfcb50e277" />

A lightweight, transparent Windows cleanup utility that leaves **zero trace** behind.  
Deletes temp files, caches, logs, update junk, and more — with real-time feedback and no telemetry.

Built for **VM hygiene**, **developer workflows**, and **ops teams** who demand repeatability, clarity, and control.

---

### 📥 [**Download Latest Release (v1.1.0)**](https://github.com/johnwesleyquintero/zerotrace/releases/tag/v1.1.0)

---

> *"If it’s not needed — it’s gone."*

---

## ✅ Features (v1.1)

- 🧹 **Deep Temporary Cleanup**: `%TEMP%`, system temp, and local app data debris.
- 🌐 **Expanded Browser Support**: Clears caches for Chrome, Firefox, Edge, Brave, and Opera.
- 🛠️ **Windows Update Scrubbing**: DISM component store cleanup and SoftwareDistribution removal.
- 📜 **Log Eradication**: Wipes system event logs and Windows diagnostic logs.
- ⚡ **Prefetch & ShellBags**: Removes app execution history and folder view history for maximum privacy.
- 🗑️ **Recycle Bin & Store**: Empties bin and resets Microsoft Store/Network caches.
- 🖥️ **App-Specific Cleaning**: **New in v1.1!** Cleans caches for VS Code, Discord, and Spotify.
- 🛠️ **Extended System Cleanup**: **New!** Removes `Windows.old`, and GPU Shader Caches (NVIDIA/AMD).
- 📊 **Real-Time Storage Metrics**: Displays total disk space, space freed, and cleanup duration.
- 🎨 **Modern Terminal UI**: Color-coded status updates and a dynamic progress bar.
- 🔍 **100% Open Source**: Inspect every line. No magic.

---

## ⚙️ Usage

### Option 1: The Portable Executable (Recommended)
The standalone binary automatically requests Administrator privileges.

1. Download the version you need from the [**Releases Page**](https://github.com/johnwesleyquintero/zerotrace/releases/latest):
   - [**ZeroTrace_v1.1.exe** (Recommended)](https://github.com/johnwesleyquintero/zerotrace/releases/latest/download/ZeroTrace_v1.1.exe)
   - [**ZeroTrace.exe** (Legacy v1.0)](https://github.com/johnwesleyquintero/zerotrace/releases/download/v1.0.0/ZeroTrace.exe)
2. **Double-click to run.**

### Option 2: Run the Batch Script
1. Download [`ZeroTrace_v1.1.bat`](https://github.com/johnwesleyquintero/zerotrace/releases/latest/download/ZeroTrace_v1.1.bat)
2. **Right-click → Run as administrator**

---

## 📦 Releases

**ZeroTrace v1.1.0**
- **Official Release**: [**View v1.1.0 on GitHub**](https://github.com/johnwesleyquintero/zerotrace/releases/tag/v1.1.0)
- **Portable EXE**: Standalone, admin-enabled. [**Download v1.1.0 EXE**](https://github.com/johnwesleyquintero/zerotrace/releases/download/v1.1.0/ZeroTrace_v1.1.exe)
- **Key Features**: Windows.old removal, Spotify/GPU cache cleanup, storage metrics, and UI overhaul.

---

## 🔒 Trust & Transparency

- **No network calls** — offline by design  
- **No data collection** — zero telemetry, ever  
- **No external dependencies** — runs on vanilla Windows 10/11  
- **Fully auditable** — pure batch script logic wrapped in a transparent C# binary  

This tool was born in the trenches of VM operations — built to be **trusted, not just used**.

---

## 📜 License

MIT License — free to use, modify, and distribute.

**Made with clarity by Wesley & WesAI**  
Sovereign systems. Clean code. No magic.

---

> 💡 **Pro Tip**: Use `ZeroTrace` in VM snapshot cleanup, dev environment resets, or before imaging machines. One click. Zero trace.
