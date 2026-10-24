import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
const dir = resolve('scripts/shots');
mkdirSync(dir, { recursive: true });
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1600, height: 900 }, deviceScaleFactor: 1.5 });
const base = 'http://127.0.0.1:4317';
const shot = async (name) => {
  const p = resolve(dir, name);
  await page.screenshot({ path: p });
  console.log('saved', p);
};
await page.goto(base, { waitUntil: 'networkidle' });
await page.waitForSelector('.sidebar', { timeout: 30000 });
await page.waitForTimeout(1200);
await shot('workspace.png');
for (const [label, out] of [['Skills', 'skills.png'], ['Workflows', 'workflows.png'], ['Models', 'models.png']]) {
  await page.click(`.main-nav button:has-text("${label}")`);
  await page.waitForTimeout(900);
  await shot(out);
}
await page.click('.bottom-nav button[aria-label="Usage"]');
await page.waitForTimeout(900);
await shot('usage.png');
await page.click('.main-nav button:has-text("Workspace")');
await page.waitForTimeout(600);
await page.click('.search-nav');
await page.waitForTimeout(400);
await shot('palette.png');
await browser.close();
