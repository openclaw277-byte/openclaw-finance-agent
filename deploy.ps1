#!/usr/bin/env pwsh
# OpenClaw + Ollama Cloud Deployment Script
# This installs OpenClaw from GitHub and configures Ollama Cloud API
# Requires Ollama Pro account with API key
# Run as Administrator

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw + Ollama Cloud" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()].IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))) {
    Write-Host "ERROR: Please run as Administrator!" -ForegroundColor Red
    exit 1
}

$START_TIME = Get-Date

# Step 1: Install Prerequisites
Write-Host "[1/5] Installing Prerequisites..." -ForegroundColor Green

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

# Install Git
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

# Step 2: Clone OpenClaw from GitHub
Write-Host "[2/5] Cloning OpenClaw from GitHub..." -ForegroundColor Green
$OPENCLAW_DIR = "D:\openclaw-source"
if (Test-Path $OPENCLAW_DIR) {
    Remove-Item -Recurse -Force $OPENCLAW_DIR
}
git clone https://github.com/openclaw/openclaw.git $OPENCLAW_DIR
Write-Host "  OpenClaw cloned!" -ForegroundColor Green

# Step 3: Install OpenClaw from source
Write-Host "[3/5] Building OpenClaw..." -ForegroundColor Green
Set-Location $OPENCLAW_DIR
npm install
npm run build
npm link
Write-Host "  OpenClaw built and installed!" -ForegroundColor Green

# Step 4: Configure Ollama Cloud API
Write-Host "[4/5] Configuring Ollama Cloud API..." -ForegroundColor Green
$CONFIG_DIR = "D:\openclaw\config"
New-Item -ItemType Directory -Force -Path $CONFIG_DIR

$CONFIG_YAML = @"
# OpenClaw Configuration - Ollama Cloud
# Using Ollama Cloud API with kimi-k2.5
# Requires OLLAMA_API_KEY environment variable

llm:
  provider: ollama
  api:
    # Ollama Cloud API endpoint
    base_url: https://api.ollama.com/v1
    
    # API key from your Ollama Pro account
    # Set via environment variable: OLLAMA_API_KEY
    api_key: `${OLLAMA_API_KEY}
  
  # Model configuration - Cloud models (no download!)
  model: kimi-k2.5
  
  # Available cloud models:
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
  file: "D:/openclaw/logs/openclaw.log"
"@

Set-Content -Path "$CONFIG_DIR\config.yaml" -Value $CONFIG_YAML
Write-Host "  Ollama Cloud configured!" -ForegroundColor Green

# Step 5: Create Finance Agent
Write-Host "[5/5] Creating Finance Agent..." -ForegroundColor Green
$WORKSPACE_DIR = "D:\openclaw\workspace-finance"
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
- **Role:** Financial document processing and analysis
- **Vibe:** Professional, detail-oriented, efficient
- **Emoji:** 💰

## LLM Configuration
- Provider: Ollama Cloud
- Model: kimi-k2.5
- Endpoint: https://api.ollama.com/v1
- **Cloud model - no local download!**

## Capabilities
- Receipt OCR and data extraction
- Spreadsheet automation
- Financial analysis
- Document processing
"@
Set-Content -Path "$WORKSPACE_DIR\IDENTITY.md" -Value $IDENTITY

# Create SOUL.md
$SOUL = @"
# SOUL.md - Finance Analyst

## Core Principles
- Be helpful and efficient
- Focus on accuracy
- Maintain professional tone

## LLM Provider
I use Ollama Cloud with kimi-k2.5 model.
- **Cloud-based inference** - no local download
- Fast and reliable
- Requires OLLAMA_API_KEY

## Memory Systems
- ByteRover: brv query/curate
- QMD: python -m qmd search
"@
Set-Content -Path "$WORKSPACE_DIR\SOUL.md" -Value $SOUL

# Create PROFESSIONAL.md
$PROFESSIONAL = @"
# PROFESSIONAL.md - Financial Analysis

## Domain
Financial document processing and analysis

## Skills
- Receipt OCR (Tesseract)
- Spreadsheet automation (pandas, openpyxl)
- Data validation
- Report generation

## Tools
- Python: pandas, openpyxl, pytesseract, Pillow
- Ollama Cloud: API access (kimi-k2.5)
- Node.js: OpenClaw CLI
"@
Set-Content -Path "$WORKSPACE_DIR\PROFESSIONAL.md" -Value $PROFESSIONAL

Write-Host "  Agent identity created!" -ForegroundColor Green

# Install Python Dependencies
Write-Host "Installing Python dependencies..." -ForegroundColor Green
$REQUIREMENTS = @"
pandas>=2.0.0
openpyxl>=3.1.0
pytesseract>=0.3.10
Pillow>=10.0.0
requests>=2.31.0
qmd>=0.1.0
numpy>=1.24.0
pyyaml>=6.0.1
"@
Set-Content -Path "$WORKSPACE_DIR\requirements.txt" -Value $REQUIREMENTS
python -m pip install -r "$WORKSPACE_DIR\requirements.txt" --quiet

# Install ByteRover
npm install -g byterover-cli --quiet
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
Write-Host "  Dependencies installed!" -ForegroundColor Green

# Create startup script
$STARTUP = @"
# OpenClaw Finance Agent + Ollama Cloud Startup
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Finance Agent + Ollama Cloud" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if OLLAMA_API_KEY is set
if (-not `$env:OLLAMA_API_KEY) {
    Write-Host "ERROR: OLLAMA_API_KEY not set!" -ForegroundColor Red
    Write-Host "Set it with:" -ForegroundColor Yellow
    Write-Host "  [Environment]::SetEnvironmentVariable('OLLAMA_API_KEY', 'your-key', 'User')" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Get your API key from: https://ollama.com/settings/api-keys" -ForegroundColor Yellow
    exit 1
}

Write-Host "LLM: Ollama Cloud (kimi-k2.5)" -ForegroundColor Green
Write-Host "Endpoint: https://api.ollama.com/v1" -ForegroundColor Green
Write-Host ""
Write-Host "Commands:" -ForegroundColor Yellow
Write-Host "  openclaw status          Check status"
Write-Host "  openclaw gateway start   Start gateway"
Write-Host ""

openclaw gateway start
"@

Set-Content -Path "$WORKSPACE_DIR\start-agent.ps1" -Value $STARTUP

# Create API key setup script
$APIKEY_SCRIPT = @"
# Set Ollama Cloud API Key
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ollama Cloud API Key Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Get your API key from: https://ollama.com/settings/api-keys" -ForegroundColor Yellow
Write-Host ""

`$apiKey = Read-Host "Enter your Ollama Cloud API key (starts with sk-)"

if (`$apiKey) {
    [Environment]::SetEnvironmentVariable('OLLAMA_API_KEY', `$apiKey, 'User')
    Write-Host "API key set successfully!" -ForegroundColor Green
    Write-Host "Restart PowerShell to apply changes." -ForegroundColor Yellow
} else {
    Write-Host "No API key entered." -ForegroundColor Red
}
"@

Set-Content -Path "$WORKSPACE_DIR\set-api-key.ps1" -Value $APIKEY_SCRIPT

# Create verification script
$VERIFY = @"
#!/usr/bin/env python3
\"\"\"Verify OpenClaw + Ollama Cloud installation\"\"\""

import sys
from pathlib import Path

def check():
    print("Verifying OpenClaw + Ollama Cloud setup...")
    print("=" * 50)
    
    checks = {
        "OpenClaw source": Path("D:/openclaw-source").exists(),
        "Config file": Path("D:/openclaw/config/config.yaml").exists(),
        "Finance workspace": Path("D:/openclaw/workspace-finance").exists(),
        "IDENTITY.md": Path("D:/openclaw/workspace-finance/IDENTITY.md").exists(),
        "SOUL.md": Path("D:/openclaw/workspace-finance/SOUL.md").exists(),
        "ByteRover config": Path("D:/openclaw/workspace-finance/.brv/config.json").exists(),
    }
    
    all_ok = True
    for name, result in checks.items():
        status = "OK" if result else "FAIL"
        print(f"  [{status}] {name}")
        if not result:
            all_ok = False
    
    print("=" * 50)
    
    if all_ok:
        print("All checks passed!")
        print("")
        print("IMPORTANT: Set your OLLAMA_API_KEY before running:")
        print("  .\\set-api-key.ps1")
        print("  # OR manually:")
        print("  [Environment]::SetEnvironmentVariable('OLLAMA_API_KEY', 'your-key', 'User')")
        print("")
        print("Then run: .\\start-agent.ps1")
        return 0
    else:
        print("Some checks failed.")
        return 1

if __name__ == "__main__":
    sys.exit(check())
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
Write-Host "  OpenClaw: D:\openclaw-source\" -ForegroundColor Cyan
Write-Host "  Agent: D:\openclaw\workspace-finance\" -ForegroundColor Cyan
Write-Host "  Config: D:\openclaw\config\config.yaml" -ForegroundColor Cyan
Write-Host "  LLM: Ollama Cloud (kimi-k2.5)" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Set your Ollama Cloud API key:" -ForegroundColor White
Write-Host "   cd D:\openclaw\workspace-finance" -ForegroundColor Cyan
Write-Host "   .\set-api-key.ps1" -ForegroundColor Cyan
Write-Host "   # Enter your API key when prompted" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Restart PowerShell (to apply API key)" -ForegroundColor White
Write-Host ""
Write-Host "3. Start the agent:" -ForegroundColor White
Write-Host "   cd D:\openclaw\workspace-finance" -ForegroundColor Cyan
Write-Host "   .\start-agent.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Verify installation:" -ForegroundColor White
Write-Host "   python verify.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "**NO 5GB DOWNLOAD** - Uses Ollama Cloud!" -ForegroundColor Green
Write-Host "Model: kimi-k2.5 via Ollama Cloud API" -ForegroundColor Green
