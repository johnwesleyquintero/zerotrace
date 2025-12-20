import Image from "next/image";
import { Download, Shield, Zap, Database, Clock, HardDrive, Terminal, Github, CheckCircle2 } from "lucide-react";

export default function Home() {
  return (
    <div className="relative min-h-screen text-white selection:bg-cyan-500/30 selection:text-cyan-400 overflow-x-hidden">
      {/* Background Visuals */}
      <div className="fixed inset-0 -z-10 bg-black pointer-events-none">
        {/* Animated Grid */}
        <div 
          className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff0a_1px,transparent_1px),linear-gradient(to_bottom,#ffffff0a_1px,transparent_1px)] bg-[size:40px_40px] [mask-image:radial-gradient(ellipse_80%_50%_at_50%_0%,#000_70%,transparent_100%)]"
        />
        
        {/* Glowing Orbs */}
        <div className="absolute left-[-10%] top-[-10%] h-[600px] w-[600px] rounded-full bg-cyan-500/20 blur-[120px] animate-pulse" />
        <div className="absolute right-[-10%] top-[10%] h-[500px] w-[500px] rounded-full bg-blue-600/15 blur-[100px] animate-pulse [animation-delay:2s]" />
        
        {/* Scanning Line Effect */}
        <div className="absolute top-0 h-[2px] w-full bg-gradient-to-r from-transparent via-cyan-500/40 to-transparent animate-[scan_10s_linear_infinite]" />
      </div>

      {/* Navigation */}
      <nav className="fixed top-0 z-50 w-full border-b border-white/5 bg-black/50 backdrop-blur-xl">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <div className="flex items-center gap-2">
            <Image 
              src="/logo.png" 
              alt="ZeroTrace Logo" 
              width={32} 
              height={32} 
              className="rounded"
            />
            <span className="text-xl font-bold tracking-tight">ZeroTrace</span>
          </div>
          <div className="flex items-center gap-6">
            <a href="https://github.com/johnwesleyquintero/zerotrace" target="_blank" className="text-sm font-medium text-zinc-400 transition-colors hover:text-white">
              <Github className="h-5 w-5" />
            </a>
            <a 
              href="https://github.com/johnwesleyquintero/zerotrace/releases/latest"
              className="rounded-full bg-white px-5 py-2 text-sm font-semibold text-black transition-transform active:scale-95 hover:bg-zinc-200"
            >
              Download
            </a>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <header className="relative flex flex-col items-center justify-center overflow-hidden px-6 pb-24 pt-48 text-center">
        <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-cyan-500/20 bg-cyan-500/5 px-4 py-1.5 text-xs font-medium text-cyan-400">
          <span className="relative flex h-2 w-2">
            <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-cyan-400 opacity-75"></span>
            <span className="relative inline-flex h-2 w-2 rounded-full bg-cyan-500"></span>
          </span>
          v1.1.0 Released — The Extended System Cleanup Update
        </div>
        <h1 className="max-w-4xl bg-gradient-to-b from-white to-zinc-500 bg-clip-text text-6xl font-extrabold tracking-tighter text-transparent sm:text-8xl">
          If it’s not needed, <br /> it’s gone.
        </h1>
        <p className="mt-8 max-w-2xl text-lg text-zinc-400 sm:text-xl">
          A lightweight, transparent Windows cleanup utility built for VM hygiene, developer workflows, and sovereign digital systems.
        </p>
        <div className="mt-12 flex flex-col items-center gap-4 sm:flex-row">
          <a 
            href="https://github.com/johnwesleyquintero/zerotrace/releases/download/v1.1.0/ZeroTrace_v1.1.exe"
            className="group flex h-14 items-center gap-3 rounded-xl bg-white px-8 text-lg font-bold text-black transition-all hover:bg-zinc-200 hover:shadow-[0_0_40px_-10px_rgba(255,255,255,0.3)]"
          >
            <Download className="h-5 w-5 transition-transform group-hover:-translate-y-1" />
            Download v1.1.0 EXE
          </a>
          <a 
            href="https://github.com/johnwesleyquintero/zerotrace/releases/download/v1.1.0/ZeroTrace_v1.1.bat"
            className="flex h-14 items-center gap-3 rounded-xl border border-white/10 bg-white/5 px-8 text-lg font-bold text-white transition-all hover:bg-white/10"
          >
            <Terminal className="h-5 w-5" />
            View Source (BAT)
          </a>
        </div>
      </header>

      {/* Features Grid */}
      <section className="mx-auto max-w-7xl px-6 py-24">
        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
          <div className="rounded-2xl border border-white/5 bg-zinc-900/50 p-8 transition-colors hover:bg-zinc-900">
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-cyan-500/10 text-cyan-400">
              <Zap className="h-6 w-6" />
            </div>
            <h3 className="mb-3 text-xl font-bold">Deep System Scrub</h3>
            <p className="text-zinc-400">Comprehensive cleanup including Windows.old, Spotify caches, and GPU shader repositories.</p>
          </div>
          <div className="rounded-2xl border border-white/5 bg-zinc-900/50 p-8 transition-colors hover:bg-zinc-900">
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-purple-500/10 text-purple-400">
              <Shield className="h-6 w-6" />
            </div>
            <h3 className="mb-3 text-xl font-bold">Privacy Hardening</h3>
            <p className="text-zinc-400">Eradicate ShellBags, UserAssist logs, and app execution history for maximum digital hygiene.</p>
          </div>
          <div className="rounded-2xl border border-white/5 bg-zinc-900/50 p-8 transition-colors hover:bg-zinc-900">
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-orange-500/10 text-orange-400">
              <HardDrive className="h-6 w-6" />
            </div>
            <h3 className="mb-3 text-xl font-bold">Real-time Metrics</h3>
            <p className="text-zinc-400">Track total drive capacity and space reclaimed with precise PowerShell-driven calculations.</p>
          </div>
        </div>
      </section>

      {/* Stats / Proof Section */}
      <section className="border-y border-white/5 bg-zinc-950 px-6 py-24">
        <div className="mx-auto max-w-7xl">
          <div className="flex flex-col items-center justify-between gap-12 lg:flex-row">
            <div className="max-w-xl text-left">
              <h2 className="text-4xl font-bold tracking-tight sm:text-5xl">Built for the Sovereign User.</h2>
              <p className="mt-6 text-lg text-zinc-400">
                In an era of bloatware and telemetry, ZeroTrace stands as a testament to the power of independent, transparent systems. 
                We don&apos;t need expensive black-box cleaners when we can build our own.
              </p>
              <ul className="mt-8 space-y-4">
                {[
                  "100% Open Source and Auditable",
                  "Zero Data Collection or Telemetry",
                  "No External Dependencies Required",
                  "Standalone Portable Executable"
                ].map((item, i) => (
                  <li key={i} className="flex items-center gap-3 font-medium text-zinc-300">
                    <CheckCircle2 className="h-5 w-5 text-cyan-500" />
                    {item}
                  </li>
                ))}
              </ul>
            </div>
            <div className="relative rounded-2xl border border-white/10 bg-black p-4 shadow-2xl">
              <div className="flex items-center gap-2 border-b border-white/5 px-4 pb-4">
                <div className="h-3 w-3 rounded-full bg-red-500" />
                <div className="h-3 w-3 rounded-full bg-yellow-500" />
                <div className="h-3 w-3 rounded-full bg-green-500" />
                <span className="ml-4 text-xs font-mono text-zinc-500">ZeroTrace_v1.1.bat</span>
              </div>
              <div className="mt-4 font-mono text-sm">
                <div className="text-cyan-400">[1/16] Cleaning temporary files...</div>
                <div className="text-zinc-500">[OK] Temp files cleaned.</div>
                <div className="mt-2 text-cyan-400">[4/16] Removing Windows.old...</div>
                <div className="text-green-400">[+] Reclaimed 24.32 GB</div>
                <div className="mt-4 border-t border-white/5 pt-4 text-white font-bold">
                  Available Storage: 31.29 GB of 118.04 GB
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="px-6 py-12 text-center text-zinc-500">
        <div className="mx-auto max-w-7xl border-t border-white/5 pt-12">
          <p className="text-sm font-medium tracking-wide text-zinc-400">
            Sovereign Systems | Built by Wesley & WesAI
          </p>
          <p className="mt-2 text-xs opacity-50">Clean code. No magic. Total control.</p>
          <div className="mt-8 flex justify-center gap-6">
            <a href="https://github.com/johnwesleyquintero/zerotrace" className="hover:text-white">GitHub</a>
            <a href="https://github.com/johnwesleyquintero/zerotrace/releases" className="hover:text-white">Releases</a>
            <a href="https://github.com/johnwesleyquintero/zerotrace/blob/main/LICENSE" className="hover:text-white">License</a>
          </div>
        </div>
      </footer>
    </div>
  );
}
