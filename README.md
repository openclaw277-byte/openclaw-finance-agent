# OpenClaw Finance Agent + Ollama API

Complete deployment package for OpenClaw finance agent using GitHub source + Ollama API (cloud) with kimi-k2.5 model.

## What Gets Installed

- ✅ Node.js 20.x
- ✅ Python 3.11
- ✅ Git
- ✅ OpenClaw (from GitHub) → `D:\openclaw-source\`
- ✅ Ollama API (cloud) with kimi-k2.5
- ✅ Finance agent with memory systems → `D:\openclaw\workspace-finance\`

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
- Configure Ollama API with kimi-k2.5
- Create finance agent workspace
- Install all dependencies

**Time:** 10-15 minutes

### Step 3: Set Your Ollama API Key

After installation:

```powershell
cd D:\openclaw\workspace-finance
.\set-api-key.ps1
```

Or manually:
```powershell
[Environment]::SetEnvironmentVariable('OLLAMA_API_KEY', 'your-api-key-here', 'User')
```

### Step 4: Restart PowerShell
Close and reopen PowerShell as Administrator.

### Step 5: Start the Agent

```powershell
cd D:\openclaw\workspace-finance
.\start-agent.ps1
```

## Files in This Repo

| File | Description |
|------|-------------|
| `deploy.ps1` | Main deployment script (D:\ drive) |
| `set-api-key.ps1` | Set Ollama API key interactively |
| `start-agent.ps1` | Start OpenClaw with Ollama API |
| `verify.py` | Verify installation |
| `README.md` | This file |
| `config.yaml` | Ollama API configuration template |

## Configuration

### Ollama API Key
The script expects `OLLAMA_API_KEY` environment variable. Set it using:

```powershell
# Interactive (recommended)
.\set-api-key.ps1

# Manual
[Environment]::SetEnvironmentVariable('OLLAMA_API_KEY', 'your-key', 'User')
```

### Change Model
Edit `D:\openclaw\config\config.yaml`:

```yaml
llm:
  provider: ollama
  api:
    base_url: https://api.ollama.com/v1
  model: kimi-k2.5  # Change to: llama3.2, mistral, qwen2.5, etc.
```

## File Locations

| Item | Location |
|------|----------|
| OpenClaw source | `D:\openclaw-source\` |
| Config file | `D:\openclaw\config\config.yaml` |
| Finance agent | `D:\openclaw\workspace-finance\` |
| ByteRover memory | `D:\openclaw\workspace-finance\.brv\` |
| QMD database | `C:\Users\%USERNAME%\.config\qmd\qmd.db` |

## Verification

```powershell
cd D:\openclaw\workspace-finance
python verify.py
```

## Links

- OpenClaw: https://github.com/openclaw/openclaw
- Ollama API: https://api.ollama.com
- Ollama Models: https://ollama.com/library

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

**Done!** Your finance agent is running with Ollama API (kimi-k2.5).
