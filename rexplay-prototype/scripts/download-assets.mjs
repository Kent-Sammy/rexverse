// Downloads every image the screens use from Figma into public/assets/.
//
//   npm run assets
//
// Each screen file records the Figma export link(s) it came from (FIGMA_ASSETS).
// Figma names exported files by content, so one file name means the same image
// on every screen; the script tries each link until the file downloads.
// Figma export links expire 7 days after they were generated (October 2026).
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

const root = new URL('..', import.meta.url).pathname;
const srcDir = join(root, 'src');
const outDir = join(root, 'public', 'assets');
mkdirSync(outDir, { recursive: true });

const walk = (d) => readdirSync(d).flatMap((f) => (statSync(join(d, f)).isDirectory() ? walk(join(d, f)) : [join(d, f)]));
const sources = walk(srcDir).filter((f) => f.endsWith('.jsx') || f.endsWith('.js'));

const prefixes = new Set();
const files = new Set();
for (const f of sources) {
  const text = readFileSync(f, 'utf8');
  for (const m of text.matchAll(/https:\/\/www\.figma\.com\/api\/mcp\/asset\/[0-9a-f-]{36}/g)) prefixes.add(m[0]);
  for (const m of text.matchAll(/['"]([0-9a-f]{5}\.(?:svg|png|jpe?g|gif|webp))['"]/g)) files.add(m[1]);
}

console.log(`${files.size} images, ${prefixes.size} Figma export links`);

try {
  execFileSync('curl', ['-sS', '-o', '/dev/null', '--max-time', '15', 'https://www.figma.com/'], { stdio: 'pipe' });
} catch (e) {
  console.error(`Cannot reach www.figma.com (${String(e.stderr || e.message).trim()}).`);
  console.error('Allow www.figma.com in your network settings, then run `npm run assets` again.');
  process.exit(1);
}
let ok = 0;
const failed = [];
for (const file of [...files].sort()) {
  const dest = join(outDir, file);
  if (existsSync(dest) && statSync(dest).size > 0) {
    ok++;
    continue;
  }
  let saved = false;
  for (const prefix of prefixes) {
    try {
      execFileSync('curl', ['-sfL', '--max-time', '60', '-o', dest, `${prefix}/${file}`], { stdio: 'ignore' });
      if (statSync(dest).size > 0) {
        saved = true;
        break;
      }
    } catch {
      // try the next link
    }
  }
  if (saved) ok++;
  else failed.push(file);
}
console.log(`downloaded ${ok}/${files.size}`);
if (failed.length) {
  console.log(`missing: ${failed.join(', ')}`);
  process.exitCode = 1;
}
