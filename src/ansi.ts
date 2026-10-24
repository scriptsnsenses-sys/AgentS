export interface AnsiSpan { text: string; color?: string; background?: string; bold?: boolean; italic?: boolean; underline?: boolean; dim?: boolean }

const BASE = ['#1b1d21','#e06c75','#98c379','#e5c07b','#61afef','#c678dd','#56b6c2','#abb2bf'];
const BRIGHT = ['#5c6370','#ff7b86','#b5e890','#ffd479','#7cc4ff','#e2b8ff','#7ce8de','#ffffff'];

function color256(code: number): string {
  if (code < 16) return (code < 8 ? BASE : BRIGHT)[code] ?? '#abb2bf';
  if (code < 232) {
    const cube = code - 16, step = [0, 95, 135, 175, 215, 255];
    return `rgb(${step[Math.floor(cube / 36) % 6]},${step[Math.floor(cube / 6) % 6]},${step[cube % 6]})`;
  }
  const level = 8 + (code - 232) * 10;
  return `rgb(${level},${level},${level})`;
}

function isLightBackground(): boolean {
  return document.documentElement.dataset.theme === 'light';
}

/** Parse text containing ANSI SGR escape sequences into styled spans for terminal rendering. */
export function parseAnsi(input: string): AnsiSpan[] {
  // Drop OSC titles and non-SGR CSI sequences, then collapse \r redraws (progress bars) to the final frame per line.
  const prepared = input
    .replace(/\x1b\][^\x07]*(?:\x07|\x1b\\)/g, '')
    .replace(/\x1b\[[0-9;]*[A-Za-z]/g, sequence => (sequence.endsWith('m') ? sequence : ''))
    .split('\n')
    .map(line => line.split('\r').at(-1) ?? '')
    .join('\n');
  const spans: AnsiSpan[] = [];
  let bold = false, italic = false, underline = false, dim = false, color: string | undefined, background: string | undefined;
  const light = isLightBackground();
  let index = 0;
  const pattern = /\x1b\[([0-9;]*)m/g;
  let match: RegExpExecArray | null;
  const push = (text: string) => {
    if (!text) return;
    const span: AnsiSpan = { text };
    const fg = color ?? (dim && !bold ? (light ? '#6b766f' : '#7d8a80') : undefined);
    if (fg) span.color = fg;
    if (background) span.background = light ? 'rgba(28,46,25,.12)' : background;
    if (bold) span.bold = bold;
    if (italic) span.italic = italic;
    if (underline) span.underline = underline;
    if (dim) span.dim = dim;
    spans.push(span);
  };
  while ((match = pattern.exec(prepared))) {
    push(prepared.slice(index, match.index));
    index = match.index + match[0].length;
    const parts = (match[1] || '0').split(';').map(value => Number(value || 0));
    for (let position = 0; position < parts.length; position++) {
      const code = parts[position] ?? 0;
      if (code === 0) { bold = italic = underline = dim = false; color = background = undefined; }
      else if (code === 1) bold = true;
      else if (code === 2) dim = true;
      else if (code === 3) italic = true;
      else if (code === 4) underline = true;
      else if (code === 22) { bold = dim = false; }
      else if (code === 23) italic = false;
      else if (code === 24) underline = false;
      else if (code >= 30 && code <= 37) color = BASE[code - 30];
      else if (code === 39) color = undefined;
      else if (code >= 40 && code <= 47) background = BASE[code - 40];
      else if (code === 49) background = undefined;
      else if (code >= 90 && code <= 97) color = BRIGHT[code - 90];
      else if (code >= 100 && code <= 107) background = BRIGHT[code - 100];
      else if ((code === 38 || code === 48) && parts[position + 1] === 5) {
        const value = color256(parts[position + 2] ?? 0);
        if (code === 38) color = value; else background = value;
        position += 2;
      } else if ((code === 38 || code === 48) && parts[position + 1] === 2) {
        const value = `rgb(${parts[position + 2] ?? 0},${parts[position + 3] ?? 0},${parts[position + 4] ?? 0})`;
        if (code === 38) color = value; else background = value;
        position += 4;
      }
    }
  }
  push(prepared.slice(index));
  return spans;
}

/** Strip ANSI sequences and the shell's directory marker for plain-text contexts. */
export function cleanTerminalText(text: string): string {
  return text
    .replace(/\x1b\][^\x07]*(?:\x07|\x1b\\)/g, '')
    .replace(/\x1b\[[0-9;]*[A-Za-z]/g, '')
    .replace(/__AS_CWD__[^\r\n]*/g, '')
    .split('\n')
    .map(line => line.split('\r').at(-1) ?? '')
    .join('\n');
}
