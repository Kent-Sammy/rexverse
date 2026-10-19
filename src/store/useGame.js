import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { roundMoney, formatNaira } from '../game/money.js';
import { levelInfo } from '../game/progression.js';
import { ALLOWANCE, validateAllocation, assessAllocation } from '../game/allowance.js';
import { MISSIONS } from '../data/missions.js';

const MAX_TX = 50;

const freshGame = () => ({
  phase: 'intro', // intro | avatar | world
  player: null, // { name, characterId, look }
  wallet: { cash: 0, savings: 0, investing: 0 },
  transactions: [],
  xp: 0,
  completed: {}, // missionId -> ISO timestamp
  allocation: null, // { spending, saving, investing, profile, xp, at }
});

// Safe localStorage: private windows or blocked storage must not break the game.
const safeStorage = {
  getItem: (k) => {
    try {
      return localStorage.getItem(k);
    } catch {
      return null;
    }
  },
  setItem: (k, v) => {
    try {
      localStorage.setItem(k, v);
    } catch {
      /* ignore */
    }
  },
  removeItem: (k) => {
    try {
      localStorage.removeItem(k);
    } catch {
      /* ignore */
    }
  },
};

let toastSeq = 0;

export const useGame = create(
  persist(
    (set, get) => {
      const toast = (text, tone = 'info') => {
        const id = ++toastSeq;
        set((s) => ({ toasts: [...s.toasts, { id, text, tone }].slice(-3) }));
        setTimeout(() => set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) })), 4000);
      };

      const addTx = (s, entries) =>
        [...entries.map((e, i) => ({ id: `${Date.now()}-${i}`, ...e })).reverse(), ...s.transactions].slice(0, MAX_TX);

      // Marks a mission done and awards XP, announcing any level-up.
      const completeMission = (id, xp) => {
        const s = get();
        if (s.completed[id]) return false;
        const before = levelInfo(s.xp).level;
        set({ completed: { ...s.completed, [id]: new Date().toISOString() }, xp: s.xp + xp });
        const after = levelInfo(get().xp);
        if (after.level > before) toast(`⬆️ Level up! Level ${after.level} — ${after.title}`, 'success');
        return true;
      };

      return {
        ...freshGame(),
        // UI-only state (not saved)
        activePanel: null,
        nearby: null,
        toasts: [],

        goToAvatar: () => set({ phase: 'avatar' }),
        continueGame: () => set({ phase: 'world', activePanel: null }),
        backToTitle: () => set({ phase: 'intro', activePanel: null }),

        createPlayer: (player) => set({ ...freshGame(), phase: 'world', player, activePanel: 'welcome' }),

        resetGame: () => set({ ...freshGame(), activePanel: null, nearby: null, toasts: [] }),

        openPanel: (panel) => set({ activePanel: panel }),
        closePanel: () => set({ activePanel: null }),
        setNearby: (id) => get().nearby !== id && set({ nearby: id }),
        toast,

        // Mission 1: split the ₦10,000 allowance. Returns { ok, errors } or { ok, result }.
        completeAllowance: (alloc) => {
          const s = get();
          if (s.completed['first-allowance']) return { ok: false, errors: ['You have already planned this allowance.'] };
          const a = {
            spending: Number(alloc.spending),
            saving: Number(alloc.saving),
            investing: Number(alloc.investing),
          };
          const v = validateAllocation(a);
          if (!v.ok) return { ok: false, errors: v.errors };
          const result = assessAllocation(a);
          set((st) => ({
            wallet: {
              cash: roundMoney(st.wallet.cash + a.spending),
              savings: roundMoney(st.wallet.savings + a.saving),
              investing: roundMoney(st.wallet.investing + a.investing),
            },
            allocation: { ...a, profile: result.id, title: result.title, xp: result.xp, at: new Date().toISOString() },
            transactions: addTx(st, [
              { label: 'Allowance from your parents', amount: ALLOWANCE, account: 'cash' },
              { label: 'Moved to savings', amount: -a.saving, account: 'cash' },
              { label: 'Moved to investment pot', amount: -a.investing, account: 'cash' },
            ]),
          }));
          completeMission('first-allowance', result.xp);
          toast(`✅ Mission complete: Your First Allowance (+${result.xp} XP)`, 'success');
          return { ok: true, result };
        },

        // Mission 2: reach the Financial District.
        visitDistrict: () => {
          const m = MISSIONS.find((x) => x.id === 'visit-district');
          if (completeMission(m.id, m.reward)) toast(`🏙️ Mission complete: ${m.title} (+${m.reward} XP)`, 'success');
        },
      };
    },
    {
      name: 'rexverse-save-v2',
      version: 2,
      storage: createJSONStorage(() => safeStorage),
      partialize: (s) => ({
        player: s.player,
        wallet: s.wallet,
        transactions: s.transactions,
        xp: s.xp,
        completed: s.completed,
        allocation: s.allocation,
      }),
      // Always reopen on the title screen; it offers "Continue".
      merge: (persisted, current) => ({ ...current, ...(persisted || {}), phase: 'intro' }),
    },
  ),
);

export const totalBalance = (w) => roundMoney(w.cash + w.savings + w.investing);
export { formatNaira };
