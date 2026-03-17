#!/usr/bin/env pwsh
# OpenClaw + Ollama (Local LLM) Deployment Script
# This installs OpenClaw from GitHub AND sets up Ollama locally with kimi-k2.5
# Run as Administrator

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw + Ollama (Local LLM Setup)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Please run as Administrator!" -ForegroundColor Red
    exit 1
}

$START_TIME = Get-Date

# Step 1: Install Prerequisites (Node.js, Python, Git)
Write-Host "[1/10] Installing Prerequisites..." -ForegroundColor Green

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
    Start-Process $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=1", "/PrependPath=1" -Wait
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

# Step 2: Install Ollama
Write-Host "[2/10] Installing Ollama..." -ForegroundColor Green
$ollamaInstalled = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollamaInstalled) {
    Write-Host "  Downloading Ollama..." -ForegroundColor Yellow
    $ollamaUrl = "https://ollama.com/download/OllamaSetup.exe"
    $ollamaInstaller = "$env:TEMP\ollama-installer.exe"
    Invoke-WebRequest -Uri $ollamaUrl -OutFile $ollamaInstaller -TimeoutSec 180
    Write-Host "  Installing Ollama (this may take a minute)..." -ForegroundColor Yellow
    Start-Process $ollamaInstaller -ArgumentList "/SILENT" -Wait
    Remove-Item $ollamaInstaller -ErrorAction SilentlyContinue
    
    # Add Ollama to PATH
    $env:Path += ";C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama"
    [Environment]::SetEnvironmentVariable("Path", $env:Path, "User")
    
    Write-Host "  Ollama installed!" -ForegroundColor Green
} else {
    Write-Host "  Ollama already installed: $(ollama --version)" -ForegroundColor Green
}

# Step 3: Pull kimi-k2.5 model
Write-Host "[3/10] Downloading kimi-k2.5 model..." -ForegroundColor Green
Write-Host "  This will download ~5GB. Please wait..." -ForegroundColor Yellow
ollama pull kimi-k2.5
Write-Host "  kimi-k2.5 model ready!" -ForegroundColor Green

# Step 4: Start Ollama service
Write-Host "[4/10] Starting Ollama service..." -ForegroundColor Green
Start-Process ollama -ArgumentList "serve" -WindowStyle Hidden
Start-Sleep -Seconds 5
Write-Host "  Ollama service running!" -ForegroundColor Green

# Step 5: Clone OpenClaw from GitHub
Write-Host "[5/10] Cloning OpenClaw from GitHub..." -ForegroundColor Green
$OPENCLAW_DIR = "D:\openclaw-source"
if (Test-Path $OPENCLAW_DIR) {
    Remove-Item -Recurse -Force $OPENCLAW_DIR
}
git clone https://github.com/openclaw/openclaw.git $OPENCLAW_DIR
Write-Host "  OpenClaw cloned!" -ForegroundColor Green

# Step 6: Install OpenClaw from source
Write-Host "[6/10] Building OpenClaw..." -ForegroundColor Green
Set-Location $OPENCLAW_DIR
npm install
npm run build
npm link
Write-Host "  OpenClaw built and installed!" -ForegroundColor Green

# Step 7: Configure OpenClaw to use local Ollama
Write-Host "[7/10] Configuring OpenClaw for Ollama..." -ForegroundColor Green
$CONFIG_DIR = "D:\openclaw\config"
New-Item -ItemType Directory -Force -Path $CONFIG_DIR

$CONFIG_YAML = @"
# OpenClaw Configuration - Local Ollama
# Ollama is running locally on port 11434

llm:
  provider: ollama
  api:
    # Local Ollama endpoint
    base_url: http://localhost:11434/api
  
  # Model - must match what you pulled with 'ollama pull'
  model: kimi-k2.5
  
  # Alternative models you can use:
  # model: llama3.2
  # model: mistral
  # model: qwen2.5
  # model: deepseek-coder
  
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
Write-Host "  OpenClaw configured for local Ollama!" -ForegroundColor Green

# Step 8: Create Finance Agent
Write-Host "[8/10] Creating Finance Agent..." -ForegroundColor Green
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
- Provider: Ollama (local)
- Model: kimi-k2.5
- Endpoint: http://localhost:11434

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
I use Ollama running locally with kimi-k2.5 model.
- No API keys needed
- Runs on your machine
- Private and secure

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
- Ollama: Local LLM (kimi-k2.5)
- Node.js: OpenClaw CLI
"@
Set-Content -Path "$WORKSPACE_DIR\PROFESSIONAL.md" -Value $PROFESSIONAL

Write-Host "  Agent identity created!" -ForegroundColor Green

# Step 9: Install Python Dependencies
Write-Host "[9/10] Installing Python dependencies..." -ForegroundColor Green
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

# Step 10: Create Startup Script
Write-Host "[10/10] Creating startup scripts..." -ForegroundColor Green

$STARTUP = @"
# OpenClaw Finance Agent + Ollama Startup
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Finance Agent + Ollama (Local)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Ollama is running
`$ollamaRunning = Get-Process ollama -ErrorAction SilentlyContinue
if (-not `$ollamaRunning) {
    Write-Host "Starting Ollama..." -ForegroundColor Yellow
    Start-Process ollama -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 3
}

Write-Host "Ollama: Running (kimi-k2.5)" -ForegroundColor Green
Write-Host "OpenClaw: Ready" -ForegroundColor Green
Write-Host ""
Write-Host "Commands:" -ForegroundColor Yellow
Write-Host "  openclaw status          Check status"
Write-Host "  openclaw gateway start   Start gateway"
Write-Host "  ollama list              Show installed models"
Write-Host "  ollama pull <model>      Download new model"
Write-Host ""

openclaw gateway start
"@

Set-Content -Path "$WORKSPACE_DIR\start-agent.ps1" -Value $STARTUP

# Create verification script
$VERIFY = @"
#!/usr/bin/env python3
\"\"\"Verify OpenClaw + Ollama installation\"\"\""

import sys
import subprocess
from pathlib import Path

def check():
    print("Verifying OpenClaw + Ollama setup...")
    print("=" * 50)
    
    checks = {}
    
    # Check Ollama
    try:
        result = subprocess.run(["ollama", "--version"], capture_output=True, text=True)
        checks["Ollama installed"] = result.returncode == 0
    except:
        checks["Ollama installed"] = False
    
    # Check kimi-k2.5 model
    try:
        result = subprocess.run(["ollama", "list"], capture_output=True, text=True)
        checks["kimi-k2.5 model"] = "kimi-k2.5" in result.stdout
    except:
        checks["kimi-k2.5 model"] = False
    
    # Check files
    checks["OpenClaw source"] = Path("D:/openclaw-source").exists()
    checks["Config file"] = Path("D:/openclaw/config/config.yaml").exists()
    checks["Finance workspace"] = Path("D:/openclaw/workspace-finance").exists()
    
    all_ok = True
    for name, result in checks.items():
        status = "OK" if result else "FAIL"
        print(f"  [{status}] {name}")
        if not result:
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
Write-Host "  Ollama: Installed with kimi-k2.5 model" -ForegroundColor Cyan
Write-Host "  OpenClaw: D:\openclaw-source\" -ForegroundColor Cyan
Write-Host "  Agent: D:\openclaw\workspace-finance\" -ForegroundColor Cyan
Write-Host "  Config: D:\openclaw\config\config.yaml" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Ollama is already running! (started automatically)" -ForegroundColor White
Write-Host ""
Write-Host "2. Start the agent:" -ForegroundColor White
Write-Host "   cd D:\openclaw\workspace-finance" -ForegroundColor Cyan
Write-Host "   .\start-agent.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Verify installation:" -ForegroundColor White
Write-Host "   python verify.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Manage Ollama models:" -ForegroundColor White
Write-Host "   ollama list              # Show models" -ForegroundColor Cyan
Write-Host "   ollama pull llama3.2     # Download another model" -ForegroundColor Cyan
Write-Host ""
Write-Host "No API keys needed - everything runs locally!" -ForegroundColor Green
