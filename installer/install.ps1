# AgentScope installer — Windows
# Run from the extracted AgentScope folder:
#   powershell -ExecutionPolicy Bypass -File .\installer\install.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Write-Host ""
Write-Host "  AgentScope installer" -ForegroundColor Green
Write-Host "  ---------------------" -ForegroundColor DarkGray
Write-Host "  Folder: $root"
Write-Host ""

# 1. Node.js 24+
try { $nodeVersion = (node --version) } catch { $nodeVersion = $null }
if (-not $nodeVersion -or [int]($nodeVersion -replace 'v(\d+)\..*','$1') -lt 24) {
  Write-Host "[X] Node.js 24 or newer is required. Install it from https://nodejs.org and run this installer again." -ForegroundColor Red
  exit 1
}
Write-Host "[OK] Node.js $nodeVersion" -ForegroundColor DarkGray

# 2. pnpm (corepack ships with Node)
Set-Location $root
try { $null = pnpm --version 2>$null } catch {}
if (-not $?) {
  Write-Host "[..] Enabling pnpm via corepack" -ForegroundColor DarkGray
  corepack enable 2>$null
  corepack prepare pnpm@11.19.0 --activate 2>$null
}
try { $pnpmVersion = pnpm --version } catch { $pnpmVersion = $null }
if (-not $pnpmVersion) {
  Write-Host "[..] Installing pnpm with npm" -ForegroundColor DarkGray
  npm install -g pnpm@11.19.0
  $pnpmVersion = pnpm --version
}
Write-Host "[OK] pnpm $pnpmVersion" -ForegroundColor DarkGray

# 3. Dependencies
Write-Host "[..] Installing dependencies (a few minutes on first run)" -ForegroundColor DarkGray
pnpm install --frozen-lockfile
if ($LASTEXITCODE -ne 0) { Write-Host "[X] Dependency installation failed. Check your internet connection." -ForegroundColor Red; exit 1 }
Write-Host "[OK] Dependencies installed" -ForegroundColor DarkGray

if (-not (Test-Path "$root\dist\index.html")) {
  Write-Host "[..] Building the interface" -ForegroundColor DarkGray
  pnpm build
  if ($LASTEXITCODE -ne 0) { Write-Host "[X] Build failed." -ForegroundColor Red; exit 1 }
}
Write-Host "[OK] Interface ready" -ForegroundColor DarkGray

# 4. Shortcuts (Desktop + Start Menu) pointing at the launcher
$launcher = Join-Path $PSScriptRoot "launch-agentscope.bat"
$wsh = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = Join-Path ([Environment]::GetFolderPath("StartMenu")) "Programs"
$icon = Join-Path $root "public" "favicon.svg"
foreach ($location in @((Join-Path $desktop "AgentScope.lnk"), (Join-Path $startMenu "AgentScope.lnk"))) {
  $shortcut = $wsh.CreateShortcut($location)
  $shortcut.TargetPath = $launcher
  $shortcut.WorkingDirectory = $PSScriptRoot
  $shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,220"
  $shortcut.Description = "AgentScope - your model, a better agent around it"
  $shortcut.Save()
}
Write-Host "[OK] Shortcuts created (Desktop + Start Menu)" -ForegroundColor DarkGray

Write-Host ""
Write-Host "  Installed. Start AgentScope from the desktop shortcut," -ForegroundColor Green
Write-Host "  or run:  installer\launch-agentscope.bat" -ForegroundColor Green
Write-Host "  It serves locally at http://127.0.0.1:4317" -ForegroundColor DarkGray
Write-Host "  Uninstall anytime with:  installer\uninstall.ps1" -ForegroundColor DarkGray
Write-Host ""
