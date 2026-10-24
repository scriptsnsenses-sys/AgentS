# AgentScope uninstaller — Windows
# Removes shortcuts only. Your projects, keys, and local data stay untouched;
# delete the AgentScope folder (and .agentscope\ inside it) to remove everything.
$ErrorActionPreference = "SilentlyContinue"
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = Join-Path ([Environment]::GetFolderPath("StartMenu")) "Programs"
Remove-Item (Join-Path $desktop "AgentScope.lnk")
Remove-Item (Join-Path $startMenu "AgentScope.lnk")
Write-Host "Shortcuts removed. Your data lives in .agentscope\ inside the AgentScope folder." -ForegroundColor Green
