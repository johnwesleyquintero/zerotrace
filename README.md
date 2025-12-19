# ZeroTrace

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
1. Download [`ZeroTrace.bat`](link-to-raw-file)
2. **Right-click → Run as administrator**

> ⚠️ Administrator rights are required for system-level cleanup.

### Option 2: Use the Portable EXE (from Releases)
Perfect for VMs or automated environments:
```powershell
# Download and run (requires PowerShell)
$Url = "https://github.com/johnwesleyquintero/ZeroTrace/releases/latest/download/ZeroTrace.exe"
$OutFile = "$env:TEMP\ZeroTrace.exe"
Invoke-WebRequest -Uri $Url -OutFile $OutFile
Start-Process -Wait -FilePath $OutFile -Verb RunAs
