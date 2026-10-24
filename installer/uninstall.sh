#!/usr/bin/env bash
# AgentScope uninstaller — macOS & Linux
# Removes the launcher only. Your projects, keys, and local data stay untouched;
# delete the AgentScope folder (and .agentscope/ inside it) to remove everything.
set -euo pipefail
rm -f "$HOME/bin/agentscope"
rm -f "$HOME/.local/share/applications/agentscope.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
echo "Launcher removed. Your data lives in .agentscope/ inside the AgentScope folder."
