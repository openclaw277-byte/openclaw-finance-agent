# OpenClaw + Ollama Complete Deployment Guide

## Overview
This guide installs OpenClaw with **Ollama running locally** (not cloud API). Everything runs on your machine - no API keys needed!

## What Gets Installed

1. ✅ **Node.js 20.x** - Runtime for OpenClaw
2. ✅ **Python 3.11** - For agent tools
3. ✅ **Git** - To clone OpenClaw
4. ✅ **Ollama** - Local LLM server
5. ✅ **kimi-k2.5 model** - ~5GB download
6. ✅ **OpenClaw** - From GitHub source
7. ✅ **Finance Agent** - With memory systems

## Installation Steps

### Step 1: Open PowerShell as Administrator
1. Press `Windows Key + X`
2. Click **"Windows PowerShell (Admin)"** or **"Terminal (Admin)"**
3. Click **"Yes"** on UAC prompt

### Step 2: Download and Run the Script

**One-Liner (Copy and paste entire line):**

```powershell
mkdir D:\temp\deploy -Force; cd D:\temp\deploy; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/openclaw277-byte/openclaw-finance-agent/main/deploy-with-ollama.ps1" -OutFile "deploy.ps1"; Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force; .\deploy.ps1
```

**What happens:**
- Downloads Node.js installer (~30MB)
- Downloads Python installer (~25MB)
- Downloads Git installer (~50MB)
- Downloads Ollama installer (~200MB)
- Downloads kimi-k2.5 model (~5GB) ⬅️ **This takes time!**
- Clones OpenClaw from GitHub
- Builds OpenClaw from source
- Creates finance agent workspace
- Installs all dependencies

**Total time:** 15-30 minutes (depending on internet speed)

### Step 3: Wait for Installation

The script will show progress:
```
[1/10] Installing Prerequisites...
[2/10] Installing Ollama...
[3/10] Downloading kimi-k2.5 model...  ⬅️ Longest step (~5GB)
[4/10] Starting Ollama service...
[5/10] Cloning OpenClaw from GitHub...
[6/10] Building OpenClaw...
[7/10] Configuring OpenClaw for Ollama...
[8/10] Creating Finance Agent...
[9/10] Installing Python dependencies...
[10/10] Creating startup scripts...
```

### Step 4: Start the Agent

After installation completes:

```powershell
# Navigate to workspace
cd D:\openclaw\workspace-finance

# Start the agent (this also starts Ollama if not running)
.\start-agent.ps1
```

### Step 5: Verify Everything Works

```powershell
# Check Ollama
ollama list

# Should show:
# NAME            ID              SIZE    MODIFIED
# kimi-k2.5       xxxxxx          5.0 GB  10 minutes ago

# Check OpenClaw
openclaw status

# Run verification
python verify.py
```

## Managing Ollama

### Check Available Models
```powershell
ollama list
```

### Download Additional Models
```powershell
# Llama 3.2 (smaller, faster)
ollama pull llama3.2

# Mistral (good for coding)
ollama pull mistral

# Qwen 2.5 (multilingual)
ollama pull qwen2.5

# DeepSeek Coder (best for code)
ollama pull deepseek-coder
```

### Switch Models in OpenClaw
Edit the config file:
```powershell
notepad D:\openclaw\config\config.yaml
```

Change the model line:
```yaml
llm:
  provider: ollama
  api:
    base_url: http://localhost:11434/api
  model: llama3.2  # Change this to any model you pulled
```

### Stop/Start Ollama
```powershell
# Stop Ollama
Get-Process ollama | Stop-Process

# Start Ollama
ollama serve

# Or run in background
Start-Process ollama -ArgumentList "serve" -WindowStyle Hidden
```

## File Locations

| Item | Location |
|------|----------|
| Ollama executable | `C:\Users\%USERNAME%\AppData\Local\Programs\Ollama\ollama.exe` |
| Ollama models | `C:\Users\%USERNAME%\.ollama\models\` |
| OpenClaw source | `D:\openclaw-source\` |
| Agent workspace | `D:\openclaw\workspace-finance\` |
| Config file | `D:\openclaw\config\config.yaml` |
| ByteRover memory | `D:\openclaw\workspace-finance\.brv\` |
| QMD database | `C:\Users\%USERNAME%\.config\qmd\qmd.db` |

## Troubleshooting

### "Ollama not found"
```powershell
# Add to PATH manually
$env:Path += ";C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama"
[Environment]::SetEnvironmentVariable("Path", $env:Path, "User")
```

### "Model download failed"
```powershell
# Try downloading again
ollama pull kimi-k2.5
```

### "Ollama service not running"
```powershell
# Start Ollama
ollama serve

# Check if running
Get-Process ollama
```

### "Out of disk space"
- Ollama models need ~5GB each
- Make sure you have 10GB+ free on C:\ drive

### "Slow responses"
- First response may be slow (model loading)
- Subsequent responses are faster
- GPU acceleration helps (if you have NVIDIA GPU)

## System Requirements

- **OS:** Windows 10/11 (64-bit)
- **RAM:** 8GB minimum, 16GB recommended
- **Disk:** 20GB free space
- **Internet:** For downloading models
- **GPU:** Optional (CPU works fine, GPU is faster)

## Advantages of Local Ollama

✅ **No API keys needed** - Runs entirely locally  
✅ **No internet required** - After initial download  
✅ **Private** - Your data never leaves your machine  
✅ **Unlimited usage** - No rate limits or quotas  
✅ **Customizable** - Use any model you want  

## Links

- Ollama: https://ollama.com
- OpenClaw: https://github.com/openclaw/openclaw
- Ollama Models: https://ollama.com/library

## Summary

**One command to install everything:**
```powershell
mkdir D:\temp\deploy -Force; cd D:\temp\deploy; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/openclaw277-byte/openclaw-finance-agent/main/deploy-with-ollama.ps1" -OutFile "deploy.ps1"; Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force; .\deploy.ps1
```

**Then start the agent:**
```powershell
cd D:\openclaw\workspace-finance
.\start-agent.ps1
```

**Done!** Your finance agent is running with local Ollama LLM.
