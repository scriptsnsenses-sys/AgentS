#!/usr/bin/env bash
# AgentScope installer — macOS & Linux
# Run from the extracted AgentScope folder:
#   bash installer/install.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo ""
echo "  AgentScope installer"
echo "  ---------------------"
echo "  Folder: $ROOT"
echo ""

# 1. Node.js 24+
if ! command -v node >/dev/null 2>&1; then
  echo "[X] Node.js 24+ is required. Install it from https://nodejs.org and retry."
  exit 1
fi
NODE_MAJOR="$(node --version | sed 's/v\([0-9]*\).*/\1/')"
if [ "$NODE_MAJOR" -lt 24 ]; then
  echo "[X] Node.js 24+ is required (found $(node --version))."
  exit 1
fi
echo "[OK] Node.js $(node --version)"

# 2. pnpm
if ! command -v pnpm >/dev/null 2>&1; then
  echo "[..] Enabling pnpm via corepack"
  corepack enable 2>/dev/null || true
  corepack prepare pnpm@11.19.0 --activate 2>/dev/null || npm install -g pnpm@11.19.0
fi
echo "[OK] pnpm $(pnpm --version)"

# 3. Dependencies
echo "[..] Installing dependencies (a few minutes on first run)"
pnpm install --frozen-lockfile
echo "[OK] Dependencies installed"

if [ ! -f "$ROOT/dist/index.html" ]; then
  echo "[..] Building the interface"
  pnpm build
fi
echo "[OK] Interface ready"

# 4. Launcher in ~/bin (and a Start-menu entry on Linux)
mkdir -p "$HOME/bin"
cat > "$HOME/bin/agentscope" <<LAUNCH
#!/usr/bin/env bash
cd "$ROOT"
"$ROOT/node_modules/.bin/tsx" "$ROOT/server/main.ts" &
SERVER=\$!
for i in \$(seq 1 40); do
  curl -sf http://127.0.0.1:4317/api/session >/dev/null 2>&1 && break
  sleep 0.5
done
( command -v xdg-open >/dev/null && xdg-open http://127.0.0.1:4317 ) || open http://127.0.0.1:4317 2>/dev/null || true
wait \$SERVER
LAUNCH
chmod +x "$HOME/bin/agentscope"

if command -v xdg-desktop-menu >/dev/null 2>&1 && [ -d "$HOME/.local/share/applications" ]; then
  cat > "$HOME/.local/share/applications/agentscope.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=AgentScope
Exec=$HOME/bin/agentscope
Terminal=false
Categories=Development;
DESKTOP
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

echo ""
echo "  Installed. Start with:  ~/bin/agentscope"
echo "  It serves locally at http://127.0.0.1:4317"
echo "  Uninstall with:  bash installer/uninstall.sh"
echo ""
