@echo off
rem AgentS launcher - starts the local service and opens the workspace.
setlocal
set "ROOT=%~dp0.."
cd /d "%ROOT%"

if not exist "%ROOT%\node_modules\.bin\tsx.cmd" (
  echo AgentS dependencies are missing.
  echo Run installer\install.ps1 first.
  pause
  exit /b 1
)

start "AgentS" /min cmd /c ""%ROOT%\node_modules\.bin\tsx.cmd" "%ROOT%\server\main.ts""

powershell -NoProfile -Command "for($i=0;$i -lt 40;$i++){try{Invoke-WebRequest -UseBasicParsing http://127.0.0.1:4317/api/session -TimeoutSec 1|Out-Null;exit 0}catch{Start-Sleep -Milliseconds 500}}"
start "" http://127.0.0.1:4317
endlocal
