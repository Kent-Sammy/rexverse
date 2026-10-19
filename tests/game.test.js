import { describe, it, expect } from 'vitest';
import { roundMoney, formatNaira, parseAmount } from '../src/game/money.js';
import { mulberry32 } from '../src/game/random.js';
import { createMarket, tickMarket, closeDay, stepPrice } from '../src/game/market.js';
import { buyShares, sellShares, quoteBuy, quoteSell, maxAffordable, portfolioValue, sectorsHeld, concentration } from '../src/game/portfolio.js';
import { levelInfo } from '../src/game/progression.js';

const stock = (symbol, price) => ({ symbol, price, prevClose: price, history: [price] });

describe('money', () => {
  it('rounds to kobo', () => {
    expect(roundMoney(0.1 + 0.2)).toBe(0.3);
    expect(roundMoney(1.005)).toBe(1.01);
  });
  it('formats naira', () => {
    expect(formatNaira(5000)).toBe('₦5,000');
    expect(formatNaira(12.5)).toBe('₦12.50');
    expect(formatNaira(-300)).toBe('−₦300');
    expect(formatNaira(300, { sign: true })).toBe('+₦300');
  });
  it('parses user amounts', () => {
    expect(parseAmount('₦1,500')).toBe(1500);
    expect(parseAmount('12.34')).toBe(12.34);
    expect(parseAmount('-5')).toBeNaN();
    expect(parseAmount('abc')).toBeNaN();
    expect(parseAmount('0')).toBeNaN();
  });
});

describe('market', () => {
  it('starts every stock at its base price with history', () => {
    const m = createMarket(mulberry32(1));
    expect(m.length).toBeGreaterThan(3);
    m.forEach((s) => expect(s.history.length).toBeGreaterThan(10));
    expect(m.find((s) => s.symbol === 'JLT').price).toBe(120);
  });
  it('never drops below the price floor', () => {
    expect(stepPrice(1, { drift: 0, vol: 0.5 }, 1, -10)).toBe(0.5);
  });
  it('ticks and closes days', () => {
    const rng = mulberry32(7);
    let m = createMarket(rng);
    m = tickMarket(m, rng);
    const { stocks } = closeDay(m, rng, 1);
    stocks.forEach((s, i) => expect(s.prevClose).toBe(m[i].price));
  });
});

describe('portfolio', () => {
  const s = stock('EKB', 45);
  it('charges a minimum fee', () => {
    expect(quoteBuy(45, 1)).toEqual({ value: 45, fee: 10, total: 55 });
    expect(quoteBuy(100, 100).fee).toBe(50);
    expect(quoteSell(5, 1).total).toBe(0); // fee capped at sale value
  });
  it('buys only what you can afford', () => {
    expect(buyShares({ wallet: 50, holdings: {} }, s, 1).ok).toBe(false);
    const r = buyShares({ wallet: 1000, holdings: {} }, s, 10);
    expect(r.ok).toBe(true);
    expect(r.wallet).toBe(1000 - 450 - 10);
    expect(r.holdings.EKB).toEqual({ shares: 10, cost: 460 });
  });
  it('rejects bad quantities', () => {
    expect(buyShares({ wallet: 1e6, holdings: {} }, s, 0).ok).toBe(false);
    expect(buyShares({ wallet: 1e6, holdings: {} }, s, 1.5).ok).toBe(false);
    expect(buyShares({ wallet: 1e6, holdings: {} }, s, -2).ok).toBe(false);
  });
  it('maxAffordable never overspends', () => {
    for (const cash of [0, 54, 55, 999, 5000, 12345.67]) {
      const q = maxAffordable(45, cash);
      if (q > 0) expect(quoteBuy(45, q).total).toBeLessThanOrEqual(cash);
      expect(quoteBuy(45, q + 1).total).toBeGreaterThan(cash);
    }
  });
  it('sells with correct realised profit and cost basis', () => {
    const bought = buyShares({ wallet: 1000, holdings: {} }, s, 10);
    const up = stock('EKB', 60);
    const sold = sellShares(bought, up, 4);
    expect(sold.ok).toBe(true);
    // proceeds 240 - 10 fee = 230; cost portion 460*4/10 = 184
    expect(sold.realized).toBe(46);
    expect(sold.holdings.EKB).toEqual({ shares: 6, cost: 276 });
    const all = sellShares(sold, up, 6);
    expect(all.holdings.EKB).toBeUndefined();
    expect(sellShares(all, up, 1).ok).toBe(false);
  });
  it('values portfolio, sectors and concentration', () => {
    const holdings = { EKB: { shares: 10, cost: 460 }, JLT: { shares: 1, cost: 130 } };
    const stocks = [stock('EKB', 50), stock('JLT', 100)];
    expect(portfolioValue(holdings, stocks)).toBe(600);
    expect(sectorsHeld(holdings).size).toBe(2);
    expect(concentration(holdings, stocks)).toBeCloseTo(500 / 600);
  });
});

describe('progression', () => {
  it('computes levels', () => {
    expect(levelInfo(0).level).toBe(1);
    expect(levelInfo(99).level).toBe(1);
    expect(levelInfo(100).level).toBe(2);
    expect(levelInfo(150).progress).toBeCloseTo(50 / 150);
    expect(levelInfo(99999).progress).toBe(1);
  });
});
