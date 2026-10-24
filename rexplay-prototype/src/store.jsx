import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react';

// Demo state shared by every screen: points balance, games played and redemptions.
// Kept for the browser session so a refresh doesn't wipe the demo.
const KEY = 'rexplay-demo-v1';
const EMPTY = { coins: 0, plays: [], redemptions: [] };

const load = () => {
  try {
    const saved = JSON.parse(sessionStorage.getItem(KEY));
    return saved && typeof saved.coins === 'number' ? { ...EMPTY, ...saved } : EMPTY;
  } catch {
    return EMPTY;
  }
};

const Ctx = createContext(null);

export function StoreProvider({ children }) {
  const [state, setState] = useState(load);

  useEffect(() => {
    try {
      sessionStorage.setItem(KEY, JSON.stringify(state));
    } catch {
      // storage unavailable (private mode) — the demo still works in memory
    }
  }, [state]);

  // result: { gameId, score, total, points, rank }
  const addPlay = useCallback((result) => {
    setState((s) => ({ ...s, coins: s.coins + result.points, plays: [{ ...result, at: Date.now() }, ...s.plays] }));
  }, []);

  // entry: { kind: 'cash' | 'airtime' | 'data', points, detail, reference }
  const redeem = useCallback((entry) => {
    setState((s) => ({
      ...s,
      coins: s.coins - entry.points,
      redemptions: [{ ...entry, at: Date.now() }, ...s.redemptions],
    }));
  }, []);

  const value = useMemo(() => ({ ...state, addPlay, redeem }), [state, addPlay, redeem]);
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export const useStore = () => useContext(Ctx);

export const formatDate = (ts) => {
  const d = new Date(ts);
  const date = d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  const time = d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  return `${date} . ${time}`;
};

export const formatPoints = (n) => n.toLocaleString('en-US');
