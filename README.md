# ZeroTrace

<img width="200" height="200" alt="zero-trace-icon" src="https://github.com/user-attachments/assets/16f5b14f-a347-4880-b0be-eedfcb50e277" />

A lightweight, transparent Windows cleanup utility that leaves **zero trace** behind.  
Deletes temp files, caches, logs, update junk, and more — with real-time feedback and no telemetry.

Built for **VM hygiene**, **developer workflows**, and **ops teams** who demand repeatability, clarity, and control.

> *"If it’s not needed — it’s gone."*

---

## ✅ Features

- 🧹 **Cleans temporary files** (`%TEMP%`, system temp)
- 🌐 **Clears browser caches** (Chrome, Firefox, Edge)
- 🛠️ **Removes Windows Update debris** (SoftwareDistribution, component store)
- 📜 **Wipes event logs & Windows logs**
- ⚡ **Deletes Prefetch files**
- 🗑️ **Empties Recycle Bin**
- 🌐 **Resets DNS, Winsock, and proxy settings**
- 💾 **Shows space freed** before/after
- 📊 **Progress indicator** for visibility
- 🖥️ **Portable** — runs from USB, cloud, or script
- 🔍 **100% open source** — inspect every line

---

## ⚙️ Usage

### Option 1: Run the Batch Script
1. Download [`ZeroTrace.bat`](https://github.com/johnwesleyquintero/zerotrace/blob/main/ZeroTrace.bat)
2. **Right-click → Run as administrator**

> ⚠️ Administrator rights are required for system-level cleanup.

### Option 2: Use the Portable EXE (from GitHub Releases)
Perfect for VMs or automated environments. For `v1.0.0`:
```powershell
# Run in one go
$z = "$env:TEMP\zt.exe"; irm https://github.com/johnwesleyquintero/zerotrace/releases/latest/download/ZeroTrace.exe -OutFile $z; Start-Process -Wait $z -Verb RunAs; Remove-Item $z
```

The tool **pauses at the end** so you can review the cleanup summary — your victory lap. ✅

---

## 📦 Releases

**ZeroTrace v1.0.0** is available now!
- **[Download v1.0.0](https://github.com/johnwesleyquintero/zerotrace/releases/tag/v1.0.0)**
- `ZeroTrace.exe` (portable, admin-enabled executable)
- `ZeroTrace.bat` (full source script, 100% auditable)
- `MIT License` (free to use, modify, and distribute)

Each release includes:
- `ZeroTrace.exe` (signed, admin-enabled, branded)
- `ZeroTrace.bat` (source script)
- `SHA256SUMS` (for integrity verification)

---

## 🔒 Trust & Transparency

- **No network calls** — offline by design  
- **No data collection** — zero telemetry, ever  
- **No external dependencies** — runs on vanilla Windows 10/11  
- **Fully auditable** — pure batch script  

This tool was born in the trenches of VM operations — built to be **trusted, not just used**.

---

## 📜 License

MIT License — free to use, modify, and distribute.

**Made with clarity by [John Wesley Quintero](https://github.com/johnwesleyquintero) / WesAI Systems**  
Sovereign systems. Clean code. No magic.

---

> 💡 **Pro Tip**: Use `ZeroTrace` in VM snapshot cleanup, dev environment resets, or before imaging machines. One click. Zero trace.
