#!/usr/bin/env bash
# AgentS uninstaller — macOS & Linux
# Removes the launcher only. Your projects, keys, and local data stay untouched;
# delete the AgentS folder (and .agentscope/ inside it) to remove everything.
set -euo pipefail
rm -f "$HOME/bin/AgentS"
rm -f "$HOME/.local/share/applications/agents.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
echo "Launcher removed. Your data lives in .agentscope/ inside the AgentS folder."
