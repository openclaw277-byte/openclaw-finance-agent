# OpenClaw Finance Agent + Ollama (Local)

Complete deployment package for OpenClaw finance agent using GitHub source + **Ollama running locally** (no API key needed).

## What Gets Installed

- ✅ Node.js 20.x
- ✅ Python 3.11
- ✅ Git
- ✅ OpenClaw (from GitHub) → `D:\openclaw-source\`
- ✅ **Ollama (local)** with kimi-k2.5 model (~5GB download)
- ✅ Finance agent with memory systems → `D:\openclaw\workspace-finance\`

**NO API KEY REQUIRED** - Everything runs locally on your machine!

---

## Quick Start

### Step 1: Open PowerShell as Administrator
Press `Windows Key + X` → Click **"Windows PowerShell (Admin)"** → Click **"Yes"**

### Step 2: Run the One-Liner

```powershell
mkdir D:\temp\deploy -Force; cd D:\temp\deploy; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/openclaw277-byte/openclaw-finance-agent/main/deploy.ps1" -OutFile "deploy.ps1"; Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force; .\deploy.ps1
```

**This will:**
- Download and install Node.js, Python, Git
- Download and install Ollama (~200MB)
- Download kimi-k2.5 model (~5GB) ⬅️ **This takes time!**
- Start Ollama service automatically
- Clone OpenClaw from GitHub
- Build OpenClaw from source
- Create finance agent workspace
- Install all dependencies

**Total Time:** 15-30 minutes (mostly downloading the 5GB model)

---

## Step 3: Start the Agent (After Installation)

```powershell
cd D:\openclaw\workspace-finance
.\start-agent.ps1
```

That's it! No API key needed - Ollama runs locally on `http://localhost:11434`

---

## Files in This Repo

| File | Description |
|------|-------------|
| `deploy.ps1` | Main deployment script (installs Ollama locally) |
| `start-agent.ps1` | Start OpenClaw with local Ollama |
| `verify.py` | Verify installation |
| `README.md` | This file |
| `config.yaml` | Ollama local configuration |

---

## Managing Ollama

### Check installed models:
```powershell
ollama list
```

### Download additional models:
```powershell
ollama pull llama3.2      # Smaller, faster
ollama pull mistral         # Good for coding
ollama pull qwen2.5         # Multilingual
ollama pull deepseek-coder  # Best for code
```

### Switch models:
Edit `D:\openclaw\config\config.yaml`:
```yaml
llm:
  provider: ollama
  api:
    base_url: http://localhost:11434/api
  model: llama3.2  # Change this to any model you pulled
```

### Stop/Start Ollama:
```powershell
# Stop Ollama
Get-Process ollama | Stop-Process

# Start Ollama
ollama serve
```

---

## File Locations

| Item | Location |
|------|----------|
| OpenClaw source | `D:\openclaw-source\` |
| Config file | `D:\openclaw\config\config.yaml` |
| Finance agent | `D:\openclaw\workspace-finance\` |
| ByteRover memory | `D:\openclaw\workspace-finance\.brv\` |
| Ollama models | `C:\Users\%USERNAME%\.ollama\models\` |
| QMD database | `C:\Users\%USERNAME%\.config\qmd\qmd.db` |

---

## Verification

```powershell
cd D:\openclaw\workspace-finance
python verify.py
```

---

## Troubleshooting

### "Ollama not found"
```powershell
# Add to PATH
$env:Path += ";C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama"
[Environment]::SetEnvironmentVariable("Path", $env:Path, "User")
```

### "Model download failed"
```powershell
# Try again
ollama pull kimi-k2.5
```

### "Out of disk space"
- Ollama models need ~5GB each
- Make sure you have 10GB+ free on C:\ drive

---

## Links

- OpenClaw: https://github.com/openclaw/openclaw
- Ollama: https://ollama.com
- Ollama Models: https://ollama.com/library

---

## Summary

**One command to install:**
```powershell
mkdir D:\temp\deploy -Force; cd D:\temp\deploy; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/openclaw277-byte/openclaw-finance-agent/main/deploy.ps1" -OutFile "deploy.ps1"; Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force; .\deploy.ps1
```

**Then start:**
```powershell
cd D:\openclaw\workspace-finance
.\start-agent.ps1
```

**Done!** Your finance agent is running with **local Ollama** - no API keys, no internet needed after setup, completely private!
