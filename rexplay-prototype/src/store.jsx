import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { REWARDS, REXVAULT } from './config.js';
import { todayKey } from './games.jsx';

// Demo state shared by every screen: RexPoints balance, games played, redemptions and the
// customer's RexVault status. Kept for the browser session so a refresh doesn't wipe the demo.
const KEY = 'rexplay-demo-v2';
const EMPTY = { coins: 0, plays: [], redemptions: [], vault: false };
const PENDING_SETTLES_MS = 15000; // demo: pending redemptions complete after 15 seconds

const load = () => {
  try {
    const saved = JSON.parse(sessionStorage.getItem(KEY));
    return saved && typeof saved.coins === 'number' ? { ...EMPTY, ...saved } : EMPTY;
  } catch {
    return EMPTY;
  }
};

const isToday = (ts) => todayKey(new Date(ts)) === todayKey();

// Share of today's ₦25,000 pool already paid to other customers (simulated, rises through the day).
const othersPaidToday = () => {
  const now = new Date();
  const dayFraction = (now.getHours() * 60 + now.getMinutes()) / 1440;
  return Math.round(REWARDS.dailyBudgetNaira * 0.55 * dayFraction);
};

const Ctx = createContext(null);

export function StoreProvider({ children }) {
  const [state, setState] = useState(load);
  const ref = useRef(state);
  ref.current = state;

  useEffect(() => {
    try {
      sessionStorage.setItem(KEY, JSON.stringify(state));
    } catch {
      // storage unavailable (private mode) — the demo still works in memory
    }
  }, [state]);

  // Settle pending redemptions.
  useEffect(() => {
    const pending = state.redemptions.filter((r) => r.status === 'pending');
    if (!pending.length) return undefined;
    const wait = Math.max(0, Math.min(...pending.map((r) => r.at + PENDING_SETTLES_MS - Date.now())));
    const t = setTimeout(() => {
      setState((s) => ({
        ...s,
        redemptions: s.redemptions.map((r) => (r.status === 'pending' && Date.now() >= r.at + PENDING_SETTLES_MS - 50 ? { ...r, status: 'success' } : r)),
      }));
    }, wait);
    return () => clearTimeout(t);
  }, [state.redemptions]);

  const earnedToday = state.plays.filter((p) => isToday(p.at)).reduce((n, p) => n + p.points, 0);
  const dailyCap = state.vault && REXVAULT.enabled ? REXVAULT.dailyEarnCap : REWARDS.dailyEarnCap;
  const multiplier = state.vault && REXVAULT.enabled ? REXVAULT.pointsMultiplier : 1;
  const paidToday = state.redemptions.filter((r) => isToday(r.at) && r.status !== 'failed').reduce((n, r) => n + r.naira, 0);
  const poolRemaining = Math.max(0, REWARDS.dailyBudgetNaira - othersPaidToday() - paidToday);

  // result: { gameId, score, total, time, rank, rawPoints } → returns the saved play with
  // the RexPoints actually credited after the RexVault boost and the daily cap.
  const addPlay = useCallback(
    (result) => {
      const boosted = Math.round(result.rawPoints * multiplier);
      const credited = Math.max(0, Math.min(boosted, dailyCap - earnedToday));
      const play = { ...result, boosted, points: credited, capped: credited < boosted, at: Date.now() };
      setState((s) => ({ ...s, coins: s.coins + credited, plays: [play, ...s.plays] }));
      return play;
    },
    [multiplier, dailyCap, earnedToday],
  );

  // entry: { kind, points, naira, detail, recipient, reference, status: 'success' | 'pending' | 'failed' }
  // Failed redemptions don't take any RexPoints.
  const redeem = useCallback((entry) => {
    setState((s) => ({
      ...s,
      coins: entry.status === 'failed' ? s.coins : s.coins - entry.points,
      redemptions: [{ ...entry, at: Date.now() }, ...s.redemptions],
    }));
  }, []);

  const setVault = useCallback((vault) => setState((s) => ({ ...s, vault })), []);
  // Demo only: top up the balance so redemption can be shown without days of play.
  const addDemoPoints = useCallback((n) => setState((s) => ({ ...s, coins: s.coins + n })), []);

  const value = useMemo(
    () => ({ ...state, earnedToday, dailyCap, multiplier, poolRemaining, addPlay, redeem, setVault, addDemoPoints }),
    [state, earnedToday, dailyCap, multiplier, poolRemaining, addPlay, redeem, setVault, addDemoPoints],
  );
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export const useStore = () => useContext(Ctx);

// Best run in a game, for the leaderboard: most correct answers, then fastest.
export const bestRun = (plays, gameId) =>
  plays
    .filter((p) => p.gameId === gameId)
    .reduce((best, p) => (!best || p.score > best.score || (p.score === best.score && p.time < best.time) ? p : best), null);

export const formatDate = (ts) => {
  const d = new Date(ts);
  const date = d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  const time = d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  return `${date} . ${time}`;
};

export const formatPoints = (n) => n.toLocaleString('en-US');
