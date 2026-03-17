# OpenClaw Finance Agent Deployment

Complete deployment package for OpenClaw finance agent using GitHub source + Ollama API.

## Quick Start

Open PowerShell as Administrator and run:

```powershell
mkdir C:\temp\deploy -Force; cd C:\temp\deploy; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AliTahtawy/openclaw-finance-agent/main/deploy.ps1" -OutFile "deploy.ps1"; Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force; .\deploy.ps1
```

## What Gets Installed

- ✅ Node.js 20.x
- ✅ Python 3.11
- ✅ Git
- ✅ OpenClaw (from GitHub)
- ✅ Ollama API (cloud LLM)
- ✅ Finance agent with memory systems

## Files in This Repo

| File | Description |
|------|-------------|
| `deploy.ps1` | Main deployment script |
| `README.md` | This file |
| `config.yaml` | Ollama API configuration |

## After Installation

1. Configure Ollama API:
   ```powershell
   notepad $env:USERPROFILE\.openclaw\config\config.yaml
   ```

2. Set API key (if required):
   ```powershell
   [Environment]::SetEnvironmentVariable('OLLAMA_API_KEY', 'your-key', 'User')
   ```

3. Restart PowerShell

4. Start agent:
   ```powershell
   cd $env:USERPROFILE\.openclaw\workspace-finance
   .\start-agent.ps1
   ```

## Links

- OpenClaw: https://github.com/openclaw/openclaw
- Ollama API: https://api.ollama.com
