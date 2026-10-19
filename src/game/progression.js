export const LEVELS = [
  { level: 1, xp: 0, title: 'Home Starter' },
  { level: 2, xp: 100, title: 'Money Aware' },
  { level: 3, xp: 250, title: 'Smart Planner' },
  { level: 4, xp: 500, title: 'Junior Investor' },
  { level: 5, xp: 900, title: 'Wealth Builder' },
];

export function levelInfo(xp) {
  let idx = 0;
  for (let i = 0; i < LEVELS.length; i++) if (xp >= LEVELS[i].xp) idx = i;
  const cur = LEVELS[idx];
  const next = LEVELS[idx + 1] ?? null;
  const progress = next ? (xp - cur.xp) / (next.xp - cur.xp) : 1;
  return { ...cur, next, progress: Math.max(0, Math.min(1, progress)) };
}
