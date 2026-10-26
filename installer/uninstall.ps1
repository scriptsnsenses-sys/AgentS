# AgentS uninstaller — Windows
# Removes shortcuts only. Your projects, keys, and local data stay untouched;
# delete the AgentS folder (and .agentscope\ inside it) to remove everything.
$ErrorActionPreference = "SilentlyContinue"
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = Join-Path ([Environment]::GetFolderPath("StartMenu")) "Programs"
Remove-Item (Join-Path $desktop "AgentS.lnk")
Remove-Item (Join-Path $startMenu "AgentS.lnk")
Write-Host "Shortcuts removed. Your data lives in .agentscope\ inside the AgentS folder." -ForegroundColor Green
