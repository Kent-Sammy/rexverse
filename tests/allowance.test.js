import { describe, it, expect, beforeEach } from 'vitest';
import { validateAllocation, assessAllocation, ALLOWANCE } from '../src/game/allowance.js';

describe('validateAllocation', () => {
  it('accepts an exact ₦10,000 split', () => {
    expect(validateAllocation({ spending: 5000, saving: 3000, investing: 2000 }).ok).toBe(true);
    expect(validateAllocation({ spending: 10000, saving: 0, investing: 0 }).ok).toBe(true);
  });
  it('rejects under- and over-allocation', () => {
    const under = validateAllocation({ spending: 5000, saving: 3000, investing: 1000 });
    expect(under.ok).toBe(false);
    expect(under.remaining).toBe(1000);
    const over = validateAllocation({ spending: 6000, saving: 3000, investing: 2000 });
    expect(over.ok).toBe(false);
    expect(over.remaining).toBe(-1000);
  });
  it('rejects negatives, decimals and blanks', () => {
    expect(validateAllocation({ spending: 12000, saving: -2000, investing: 0 }).ok).toBe(false);
    expect(validateAllocation({ spending: 5000.5, saving: 4999.5, investing: 0 }).ok).toBe(false);
    expect(validateAllocation({ spending: NaN, saving: 10000, investing: 0 }).ok).toBe(false);
  });
});

describe('assessAllocation', () => {
  it('rewards a balanced plan most', () => {
    const balanced = assessAllocation({ spending: 5000, saving: 3000, investing: 2000 });
    const spender = assessAllocation({ spending: 9000, saving: 1000, investing: 0 });
    const bold = assessAllocation({ spending: 2000, saving: 1000, investing: 7000 });
    expect(balanced.id).toBe('balanced');
    expect(spender.id).toBe('spender');
    expect(bold.id).toBe('bold');
    expect(balanced.xp).toBeGreaterThan(spender.xp);
    expect(balanced.xp).toBeGreaterThan(bold.xp);
  });
  it('explains every category', () => {
    const r = assessAllocation({ spending: ALLOWANCE, saving: 0, investing: 0 });
    expect(r.notes).toHaveLength(3);
    expect(r.summary.length).toBeGreaterThan(20);
  });
});

describe('store: completeAllowance', () => {
  let useGame;
  beforeEach(async () => {
    const mem = {};
    globalThis.localStorage = {
      getItem: (k) => mem[k] ?? null,
      setItem: (k, v) => (mem[k] = String(v)),
      removeItem: (k) => delete mem[k],
    };
    ({ useGame } = await import('../src/store/useGame.js'));
    useGame.getState().resetGame();
    useGame.getState().createPlayer({ name: 'Tobi', characterId: 'tobi', look: {} });
  });

  it('rejects an invalid split without changing state', () => {
    const r = useGame.getState().completeAllowance({ spending: 5000, saving: 0, investing: 0 });
    expect(r.ok).toBe(false);
    const s = useGame.getState();
    expect(s.wallet).toEqual({ cash: 0, savings: 0, investing: 0 });
    expect(s.xp).toBe(0);
    expect(s.completed['first-allowance']).toBeUndefined();
  });

  it('updates wallet, allocation, XP and mission state', () => {
    const r = useGame.getState().completeAllowance({ spending: 5000, saving: 3000, investing: 2000 });
    expect(r.ok).toBe(true);
    const s = useGame.getState();
    expect(s.wallet).toEqual({ cash: 5000, savings: 3000, investing: 2000 });
    expect(s.allocation).toMatchObject({ spending: 5000, saving: 3000, investing: 2000, profile: 'balanced' });
    expect(s.xp).toBe(150);
    expect(s.completed['first-allowance']).toBeTruthy();
    // Can only be completed once
    expect(useGame.getState().completeAllowance({ spending: 10000, saving: 0, investing: 0 }).ok).toBe(false);
    expect(useGame.getState().wallet.cash).toBe(5000);
  });

  it('awards the district mission once', () => {
    useGame.getState().visitDistrict();
    useGame.getState().visitDistrict();
    expect(useGame.getState().xp).toBe(50);
  });

  it('persists progress to storage', () => {
    useGame.getState().completeAllowance({ spending: 4000, saving: 4000, investing: 2000 });
    const saved = JSON.parse(localStorage.getItem('rexverse-save-v2'));
    expect(saved.state.wallet.savings).toBe(4000);
    expect(saved.state.player.name).toBe('Tobi');
  });
});
