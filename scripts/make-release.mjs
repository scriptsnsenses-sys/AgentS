#!/usr/bin/env node
// Packages a distributable AgentS zip (source + prebuilt dist + installer)
// into release/AgentS-setup.zip for GitHub Releases.
import { cpSync, existsSync, mkdirSync, rmSync, statSync, readdirSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const require = createRequire(import.meta.url);
const { version } = require(path.join(root, 'package.json'));
const staging = path.join(root, 'release', 'staging');
const outFile = path.join(root, 'release', 'AgentS-setup.zip');

if (!existsSync(path.join(root, 'dist', 'index.html'))) {
  console.error('dist/ is missing or stale. Run the frontend build first (pnpm build).');
  process.exit(1);
}

const EXCLUDE = new Set(['.git', '.agentscope', 'node_modules', 'release', 'test-results', 'playwright-report', '.env', 'server.log']);

function shouldInclude(name) {
  return !EXCLUDE.has(name) && !name.endsWith('.log') && !name.startsWith('.env');
}

rmSync(path.join(root, 'release'), { recursive: true, force: true });
mkdirSync(staging, { recursive: true });

for (const entry of readdirSync(root)) {
  if (!shouldInclude(entry)) continue;
  cpSync(path.join(root, entry), path.join(staging, entry), { recursive: true, filter: source => shouldInclude(path.basename(source)) });
}

console.log(`Staged AgentS v${version} → ${staging}`);

if (process.platform === 'win32') {
  execFileSync('powershell.exe', ['-NoProfile', '-Command', `Compress-Archive -Path "${staging}\\*" -DestinationPath "${outFile}" -Force`], { stdio: 'inherit' });
} else {
  execFileSync('zip', ['-r', '-q', outFile, '.'], { cwd: staging, stdio: 'inherit' });
}

const megabytes = (statSync(outFile).size / 1_000_000).toFixed(1);
console.log(`Created ${outFile} (${megabytes} MB)`);
console.log('Upload it to the GitHub release as the asset "AgentS-setup.zip".');
