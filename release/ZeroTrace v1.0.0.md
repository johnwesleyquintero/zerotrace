## ZeroTrace v1.0.0 – Portable Windows Cleanup Utility

<img width="200" height="200" alt="zero-trace-icon" src="https://github.com/user-attachments/assets/16f5b14f-a347-4880-b0be-eedfcb50e277" />

A lightweight, transparent, and **open-source** Windows cleanup tool that leaves **zero trace** behind. Built for **VM hygiene**, **developer workflows**, and **ops teams** who demand repeatability, clarity, and control.

> *"If it’s not needed — it’s gone."*

---

### ✅ What’s Included
- `ZeroTrace.exe` — Portable, admin-enabled executable (no install required)  
- `ZeroTrace.bat` — Full source script (100% auditable)  
- MIT License — free to use, modify, and distribute

---

### 🧹 Cleanup Coverage
- Temp files (`%TEMP%`, system temp)  
- Browser caches (Chrome, Firefox, Edge)  
- Windows Update debris (`SoftwareDistribution`, Component Store)  
- Event Logs & Windows Logs  
- Prefetch files  
- Recycle Bin  
- DNS, Winsock, and proxy reset  
- Windows Store cache (`wsreset`)

---

### ⚙️ How to Use
1. **Download `ZeroTrace.exe`** (from assets below)  
2. **Right-click → Run as administrator**  
3. Watch it clean — and pause at the end so you can see your **space freed summary** ✅

Or run via PowerShell (ideal for VMs):
```powershell
$z = "$env:TEMP\zt.exe"; irm https://github.com/johnwesleyquintero/zerotrace/releases/latest/download/ZeroTrace.exe -OutFile $z; Start-Process -Wait $z -Verb RunAs; Remove-Item $z
```

---

### 🔒 Trust Principles
- **No telemetry** — zero data collection  
- **No network calls** — fully offline  
- **No external dependencies** — runs on vanilla Windows 10/11  
- **100% open source** — inspect every line  
- **Sovereign by design** — built for control, not convenience

---

### 🙏 Made with clarity by Wesley & WesAI
Part of the toolchain for sovereign digital systems.

**MIT Licensed** • **Zero Trace. Full Trust.**

---

✅ **Pro Tip**: Use `ZeroTrace` before VM snapshotting, dev environment resets, or machine handoffs.  
One click. Clean state. Zero trace.

**Full Changelog**: https://github.com/johnwesleyquintero/zerotrace/commits/v1.0.0