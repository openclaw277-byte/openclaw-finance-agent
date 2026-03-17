#!/usr/bin/env pwsh
# OpenClaw + Ollama API Deployment via GitHub
# This installs OpenClaw from GitHub and configures Ollama API
# Run as Administrator

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw (GitHub) + Ollama API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Please run as Administrator!" -ForegroundColor Red
    exit 1
}

$START_TIME = Get-Date

# Step 1: Install Prerequisites
Write-Host "[1/8] Installing Prerequisites..." -ForegroundColor Green

# Install Node.js
$nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeInstalled) {
    Write-Host "  Downloading Node.js 20.x..." -ForegroundColor Yellow
    $nodeUrl = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"
    $nodeInstaller = "$env:TEMP\node-installer.msi"
    Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller -TimeoutSec 120
    Start-Process msiexec.exe -ArgumentList "/i", $nodeInstaller, "/quiet", "/norestart" -Wait
    Remove-Item $nodeInstaller -ErrorAction SilentlyContinue
    Write-Host "  Node.js installed!" -ForegroundColor Green
} else {
    Write-Host "  Node.js: $(node --version)" -ForegroundColor Green
}

# Install Python
$pythonInstalled = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonInstalled) {
    Write-Host "  Downloading Python 3.11..." -ForegroundColor Yellow
    $pythonUrl = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe"
    $pythonInstaller = "$env:TEMP\python-installer.exe"
    Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller -TimeoutSec 120
    Start-Process $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait
    Remove-Item $pythonInstaller -ErrorAction SilentlyContinue
    Write-Host "  Python installed!" -ForegroundColor Green
} else {
    Write-Host "  Python: $(python --version)" -ForegroundColor Green
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Step 2: Install Git
Write-Host "[2/8] Installing Git..." -ForegroundColor Green
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitInstalled) {
    Write-Host "  Downloading Git..." -ForegroundColor Yellow
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
    $gitInstaller = "$env:TEMP\git-installer.exe"
    Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -TimeoutSec 120
    Start-Process $gitInstaller -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
    Remove-Item $gitInstaller -ErrorAction SilentlyContinue
    Write-Host "  Git installed!" -ForegroundColor Green
} else {
    Write-Host "  Git: $(git --version)" -ForegroundColor Green
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Step 3: Clone OpenClaw from GitHub
Write-Host "[3/8] Cloning OpenClaw from GitHub..." -ForegroundColor Green
$OPENCLAW_DIR = "$env:USERPROFILE\openclaw-source"
if (Test-Path $OPENCLAW_DIR) {
    Remove-Item -Recurse -Force $OPENCLAW_DIR
}

git clone https://github.com/openclaw/openclaw.git $OPENCLAW_DIR
Write-Host "  OpenClaw cloned to: $OPENCLAW_DIR" -ForegroundColor Green

# Step 4: Install OpenClaw from source
Write-Host "[4/8] Installing OpenClaw from source..." -ForegroundColor Green
Set-Location $OPENCLAW_DIR

# Install dependencies
npm install

# Build OpenClaw
npm run build

# Link globally
npm link

Write-Host "  OpenClaw installed from GitHub!" -ForegroundColor Green

# Step 5: Configure Ollama API
Write-Host "[5/8] Configuring Ollama API..." -ForegroundColor Green

$CONFIG_DIR = "$env:USERPROFILE\.openclaw\config"
New-Item -ItemType Directory -Force -Path $CONFIG_DIR

$CONFIG_YAML = @"
# OpenClaw Configuration - Ollama API (Cloud)
# Installed from GitHub: https://github.com/openclaw/openclaw

llm:
  provider: ollama
  api:
    # Ollama API endpoint (cloud, not local)
    base_url: https://api.ollama.com/v1
    
    # Alternative: Your own Ollama instance
    # base_url: https://your-ollama-server.com/api
    
    # API key (if required by provider)
    # api_key: your-api-key-here
  
  # Model configuration
  model: kimi-k2.5
  
  # Available models:
  # - kimi-k2.5 (recommended)
  # - llama3.2
  # - mistral
  # - qwen2.5
  # - deepseek-coder
  
  # Generation settings
  temperature: 0.7
  max_tokens: 4096
  top_p: 0.9

# Gateway configuration
gateway:
  enabled: true
  port: 8080
  host: "127.0.0.1"

# Memory systems
memory:
  byterover:
    enabled: true
    auto_sync: true
  qmd:
    enabled: true
    auto_index: true

# Logging
logging:
  level: info
  file: "$env:USERPROFILE/.openclaw/logs/openclaw.log"
"@

Set-Content -Path "$CONFIG_DIR\config.yaml" -Value $CONFIG_YAML
Write-Host "  Ollama API configured!" -ForegroundColor Green

# Step 6: Create Finance Agent
Write-Host "[6/8] Creating Finance Agent..." -ForegroundColor Green

$WORKSPACE_DIR = "$env:USERPROFILE\.openclaw\workspace-finance"
New-Item -ItemType Directory -Force -Path $WORKSPACE_DIR
New-Item -ItemType Directory -Force -Path "$WORKSPACE_DIR\memory"
New-Item -ItemType Directory -Force -Path "$WORKSPACE_DIR\skills"
New-Item -ItemType Directory -Force -Path "$WORKSPACE_DIR\scripts"
New-Item -ItemType Directory -Force -Path "$WORKSPACE_DIR\.brv\context-tree"

# Create IDENTITY.md
$IDENTITY = @"
# IDENTITY.md - Finance Analyst Agent

## Core Identity
- **Name:** Finance Analyst
- **Creature:** AI assistant for financial document processing
- **Vibe:** Professional, detail-oriented, efficient, reliable
- **Emoji:** 💰

## Capabilities
- Receipt OCR and data extraction
- Spreadsheet automation (Excel, CSV)
- Financial data analysis
- Document processing
- Report generation

## LLM Configuration
- Provider: Ollama API (cloud)
- Model: kimi-k2.5
- Installed from: GitHub (openclaw/openclaw)

## Memory Systems
- ByteRover: Pattern memory
- QMD: Document search
"@
Set-Content -Path "$WORKSPACE_DIR\IDENTITY.md" -Value $IDENTITY

# Create SOUL.md
$SOUL = @"
# SOUL.md - Finance Analyst

## Core Principles
- Be genuinely helpful, not performatively helpful
- Focus on accuracy in financial data
- Maintain professional tone
- Learn from each task

## LLM Provider
I use Ollama API (cloud) with kimi-k2.5 model:
- Fast, reliable, no local GPU needed
- Access via Ollama's cloud API endpoints
- Installed from GitHub: https://github.com/openclaw/openclaw

## Memory System
I automatically use memory tools:
- **ByteRover:** `brv query` before tasks, `brv curate` after
- **QMD:** `python -m qmd search` for document retrieval

## Boundaries
- Financial data stays private
- Never share sensitive information externally
- Verify before acting on financial data
"@
Set-Content -Path "$WORKSPACE_DIR\SOUL.md" -Value $SOUL

# Create PROFESSIONAL.md
$PROFESSIONAL = @"
# PROFESSIONAL.md - Financial Analysis

## Domain
Financial analysis and document processing

## Core Skills
1. **Receipt OCR**
   - Extract text from receipt images
   - Parse amounts, dates, vendors
   - Validate extracted data

2. **Spreadsheet Automation**
   - Read/write Excel files (openpyxl)
   - Process CSV data (pandas)
   - Generate reports

3. **Data Analysis**
   - Clean and validate data
   - Calculate summaries
   - Identify patterns

4. **Document Processing**
   - PDF text extraction
   - Image OCR (Tesseract)
   - Structured data output

## Tools
- Python: pandas, openpyxl, pytesseract, Pillow
- Node.js: OpenClaw CLI
- OCR: Tesseract
- LLM: Ollama API (kimi-k2.5)
"@
Set-Content -Path "$WORKSPACE_DIR\PROFESSIONAL.md" -Value $PROFESSIONAL

# Create AGENTS.md
$AGENTS = @"
# AGENTS.md - Workspace Configuration

## Files Reference
- **SOUL.md** - Core identity and principles
- **IDENTITY.md** - Name, role, capabilities
- **PROFESSIONAL.md** - Skills and tools
- **TOOLS.md** - Environment configuration
- **MEMORY.md** - Long-term memory
- **memory/** - Daily notes

## Memory Systems

### ByteRover (Pattern Memory)
```bash
brv status                    # Check memory status
brv query "receipt processing" # Search patterns
brv curate "workflow name" --content "pattern"  # Save pattern
```

### QMD (Document Search)
```bash
python -m qmd status          # Check document index
python -m qmd search "query"   # Search documents
python -m qmd add collection ./path --pattern "**/*.md"  # Add docs
```

## Installation Source
- **Repository:** https://github.com/openclaw/openclaw
- **Method:** Git clone + npm install + npm link
- **Version:** Latest from main branch

## LLM Configuration
- **Provider:** Ollama API (cloud)
- **Model:** kimi-k2.5
- **Config:** ~/.openclaw/config/config.yaml
"@
Set-Content -Path "$WORKSPACE_DIR\AGENTS.md" -Value $AGENTS

Write-Host "  Agent identity created!" -ForegroundColor Green

# Step 7: Install Dependencies
Write-Host "[7/8] Installing Dependencies..." -ForegroundColor Green

# Python dependencies
$REQUIREMENTS = @"
pandas>=2.0.0
openpyxl>=3.1.0
pytesseract>=0.3.10
Pillow>=10.0.0
requests>=2.31.0
python-telegram-bot>=20.0
qmd>=0.1.0
numpy>=1.24.0
pyyaml>=6.0.1
"@
Set-Content -Path "$WORKSPACE_DIR\requirements.txt" -Value $REQUIREMENTS

python -m pip install -r "$WORKSPACE_DIR\requirements.txt" --quiet
Write-Host "  Python dependencies installed!" -ForegroundColor Green

# Install ByteRover
npm install -g byterover-cli --quiet

# Initialize ByteRover
Set-Location $WORKSPACE_DIR
$BRV_CONFIG = @"
{
  "version": "2.2.0",
  "provider": "byterover",
  "workspace": "workspace-finance"
}
"@
Set-Content -Path ".brv\config.json" -Value $BRV_CONFIG
Set-Content -Path ".brv\context-tree\.snapshot.json" -Value "{}"

Write-Host "  ByteRover installed!" -ForegroundColor Green

# Step 8: Create Startup Script
Write-Host "[8/8] Creating Startup Script..." -ForegroundColor Green

$STARTUP = @"
# OpenClaw Finance Agent - Startup Script
# Installed from GitHub: https://github.com/openclaw/openclaw

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Finance Agent (GitHub + Ollama API)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check configuration
`$configPath = "$env:USERPROFILE\.openclaw\config\config.yaml"
if (Test-Path `$configPath) {
    Write-Host "Config: `$configPath" -ForegroundColor Gray
} else {
    Write-Host "WARNING: Config not found!" -ForegroundColor Red
}

Write-Host "LLM: Ollama API (kimi-k2.5)" -ForegroundColor Green
Write-Host "Source: GitHub (openclaw/openclaw)" -ForegroundColor Green
Write-Host ""

# Available commands
Write-Host "Commands:" -ForegroundColor Yellow
Write-Host "  openclaw status          Check status"
Write-Host "  openclaw gateway start   Start gateway"
Write-Host "  brv status               Check memory"
Write-Host "  python -m qmd status     Check documents"
Write-Host ""

# Start OpenClaw
openclaw gateway start
"@

Set-Content -Path "$WORKSPACE_DIR\start-agent.ps1" -Value $STARTUP

# Create verification script
$VERIFY = @"
#!/usr/bin/env python3
\"\"\"Verify OpenClaw installation from GitHub\"\"\""

import sys
from pathlib import Path

def main():
    print("Verifying OpenClaw (GitHub) + Ollama API...")
    print("=" * 50)
    
    checks = {
        "OpenClaw source": Path.home() / "openclaw-source",
        "Config file": Path.home() / ".openclaw" / "config" / "config.yaml",
        "Finance workspace": Path.home() / ".openclaw" / "workspace-finance",
        "IDENTITY.md": Path.home() / ".openclaw" / "workspace-finance" / "IDENTITY.md",
        "SOUL.md": Path.home() / ".openclaw" / "workspace-finance" / "SOUL.md",
        "ByteRover config": Path.home() / ".openclaw" / "workspace-finance" / ".brv" / "config.json",
    }
    
    all_ok = True
    for name, path in checks.items():
        exists = path.exists()
        status = "OK" if exists else "FAIL"
        print(f"  [{status}] {name}")
        if not exists:
            all_ok = False
    
    print("=" * 50)
    
    if all_ok:
        print("All checks passed!")
        print("Run: .\\start-agent.ps1")
        return 0
    else:
        print("Some checks failed.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
"@

Set-Content -Path "$WORKSPACE_DIR\verify.py" -Value $VERIFY

# Calculate elapsed time
$END_TIME = Get-Date
$ELAPSED = $END_TIME - $START_TIME

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Time: $($ELAPSED.Minutes)m $($ELAPSED.Seconds)s" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installation Summary:" -ForegroundColor White
Write-Host "  Source: GitHub (openclaw/openclaw)" -ForegroundColor Cyan
Write-Host "  Location: $OPENCLAW_DIR" -ForegroundColor Cyan
Write-Host "  Agent: $WORKSPACE_DIR" -ForegroundColor Cyan
Write-Host "  Config: $CONFIG_DIR\config.yaml" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Configure Ollama API:" -ForegroundColor White
Write-Host "   notepad `$env:USERPROFILE\.openclaw\config\config.yaml" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Set API key (if required):" -ForegroundColor White
Write-Host "   [Environment]::SetEnvironmentVariable('OLLAMA_API_KEY', 'your-key', 'User')" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Restart PowerShell (to apply env vars)" -ForegroundColor White
Write-Host ""
Write-Host "4. Start the agent:" -ForegroundColor White
Write-Host "   cd $WORKSPACE_DIR" -ForegroundColor Cyan
Write-Host "   .\start-agent.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Verify installation:" -ForegroundColor White
Write-Host "   python verify.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ready to process receipts and financial documents!" -ForegroundColor Green
