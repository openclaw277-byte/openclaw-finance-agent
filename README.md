# OpenClaw Finance Agent + Ollama Cloud (Pro)

Complete deployment package for OpenClaw finance agent using GitHub source + **Ollama Cloud API** with kimi-k2.5.

**Requires:** Ollama Pro account and API key

## What Gets Installed

- ✅ Node.js 20.x
- ✅ Python 3.11
- ✅ Git
- ✅ OpenClaw (from GitHub) → `D:\openclaw-source\`
- ✅ **Ollama Cloud API** with kimi-k2.5
- ✅ Finance agent with memory systems → `D:\openclaw\workspace-finance\`

**NO LOCAL MODEL DOWNLOAD** - Uses Ollama Cloud API!

---

## Prerequisites

Before running the script, you need:

1. **Ollama Pro account** - Sign up at https://ollama.com
2. **API key** - Get from https://ollama.com/settings/api-keys

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
- Clone OpenClaw from GitHub
- Build OpenClaw from source
- Configure Ollama Cloud API
- Create finance agent workspace
- Install all dependencies

**Total Time:** 10-15 minutes

---

## Step 3: Set Your Ollama Cloud API Key

After installation:

```powershell
cd D:\openclaw\workspace-finance
.\set-api-key.ps1
```

Or manually:
```powershell
[Environment]::SetEnvironmentVariable('OLLAMA_API_KEY', 'your-api-key-here', 'User')
```

**Get your API key from:** https://ollama.com/settings/api-keys

---

## Step 4: Restart PowerShell

Close and reopen PowerShell as Administrator.

---

## Step 5: Start the Agent

```powershell
cd D:\openclaw\workspace-finance
.\start-agent.ps1
```

---

## Files in This Repo

| File | Description |
|------|-------------|
| `deploy.ps1` | Main deployment script (Ollama Cloud) |
| `set-api-key.ps1` | Set Ollama Cloud API key |
| `start-agent.ps1` | Start OpenClaw with Ollama Cloud |
| `verify.py` | Verify installation |
| `README.md` | This file |
| `config.yaml` | Ollama Cloud configuration |

---

## Managing Ollama Cloud

### Check your API usage:
Go to: https://ollama.com/settings/usage

### Available models on Ollama Cloud:
- `kimi-k2.5` (recommended)
- `llama3.2`
- `mistral`
- `qwen2.5`
- `deepseek-coder`

### Switch models:
Edit `D:\openclaw\config\config.yaml`:
```yaml
llm:
  provider: ollama
  api:
    base_url: https://api.ollama.com/v1
    api_key: ${OLLAMA_API_KEY}
  model: llama3.2  # Change to any model above
```

---

## File Locations

| Item | Location |
|------|----------|
| OpenClaw source | `D:\openclaw-source\` |
| Config file | `D:\openclaw\config\config.yaml` |
| Finance agent | `D:\openclaw\workspace-finance\` |
| ByteRover memory | `D:\openclaw\workspace-finance\.brv\` |
| QMD database | `C:\Users\%USERNAME%\.config\qmd\qmd.db` |

---

## Verification

```powershell
cd D:\openclaw\workspace-finance
python verify.py
```

---

## Troubleshooting

### "OLLAMA_API_KEY not set"
**Fix:**
```powershell
[Environment]::SetEnvironmentVariable('OLLAMA_API_KEY', 'your-key', 'User')
# Then restart PowerShell
```

### "API connection failed"
**Check:**
- Is your API key correct?
- Do you have Ollama Pro subscription?
- Check status: https://ollama.com/status

### "Out of API credits"
**Check usage:** https://ollama.com/settings/usage

---

## Links

- OpenClaw: https://github.com/openclaw/openclaw
- Ollama: https://ollama.com
- Ollama API Keys: https://ollama.com/settings/api-keys
- Ollama Models: https://ollama.com/library

---

## Summary

**One command to install:**
```powershell
mkdir D:\temp\deploy -Force; cd D:\temp\deploy; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/openclaw277-byte/openclaw-finance-agent/main/deploy.ps1" -OutFile "deploy.ps1"; Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force; .\deploy.ps1
```

**Then set API key and start:**
```powershell
cd D:\openclaw\workspace-finance
.\set-api-key.ps1
# Restart PowerShell
.\start-agent.ps1
```

**Done!** Your finance agent is running with **Ollama Cloud (kimi-k2.5)** - fast, no local GPU needed!
