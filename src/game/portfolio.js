import { roundMoney, formatNaira } from './money.js';
import { getDef } from './market.js';

// Simulated brokerage fee: 0.5% of trade value, minimum ₦10.
export const FEE_RATE = 0.005;
export const MIN_FEE = 10;

export const tradeFee = (value) => (value <= 0 ? 0 : Math.max(MIN_FEE, roundMoney(value * FEE_RATE)));

export function quoteBuy(price, qty) {
  const value = roundMoney(price * qty);
  const fee = tradeFee(value);
  return { value, fee, total: roundMoney(value + fee) };
}

export function quoteSell(price, qty) {
  const value = roundMoney(price * qty);
  // The fee never exceeds the sale value, so a sale can't cost you money.
  const fee = Math.min(tradeFee(value), value);
  return { value, fee, total: roundMoney(value - fee) };
}

// Largest whole number of shares affordable with the given cash.
export function maxAffordable(price, cash) {
  if (price <= 0 || cash <= 0) return 0;
  let qty = Math.floor(cash / price);
  while (qty > 0 && quoteBuy(price, qty).total > cash) qty--;
  return qty;
}

const validQty = (qty) => Number.isInteger(qty) && qty > 0;

export function buyShares({ wallet, holdings }, stock, qty) {
  if (!stock) return { ok: false, error: 'That stock does not exist.' };
  if (!validQty(qty)) return { ok: false, error: 'Enter a whole number of shares (1 or more).' };
  const q = quoteBuy(stock.price, qty);
  if (q.total > wallet) {
    return {
      ok: false,
      error: `Not enough cash. This trade costs ${formatNaira(q.total)} but you have ${formatNaira(wallet)}.`,
    };
  }
  const h = holdings[stock.symbol] ?? { shares: 0, cost: 0 };
  return {
    ok: true,
    quote: q,
    wallet: roundMoney(wallet - q.total),
    holdings: {
      ...holdings,
      [stock.symbol]: { shares: h.shares + qty, cost: roundMoney(h.cost + q.total) },
    },
  };
}

export function sellShares({ wallet, holdings }, stock, qty) {
  if (!stock) return { ok: false, error: 'That stock does not exist.' };
  if (!validQty(qty)) return { ok: false, error: 'Enter a whole number of shares (1 or more).' };
  const h = holdings[stock.symbol];
  if (!h || h.shares < qty) {
    return { ok: false, error: `You only own ${h?.shares ?? 0} share(s) of ${stock.symbol}.` };
  }
  const q = quoteSell(stock.price, qty);
  const costPortion = qty === h.shares ? h.cost : roundMoney((h.cost * qty) / h.shares);
  const realized = roundMoney(q.total - costPortion);
  const next = { ...holdings };
  if (qty === h.shares) delete next[stock.symbol];
  else next[stock.symbol] = { shares: h.shares - qty, cost: roundMoney(h.cost - costPortion) };
  return { ok: true, quote: q, realized, wallet: roundMoney(wallet + q.total), holdings: next };
}

export function positions(holdings, stocks) {
  const bySymbol = Object.fromEntries(stocks.map((s) => [s.symbol, s]));
  return Object.entries(holdings)
    .map(([symbol, h]) => {
      const s = bySymbol[symbol];
      const value = roundMoney((s?.price ?? 0) * h.shares);
      const pl = roundMoney(value - h.cost);
      return {
        symbol,
        sector: getDef(symbol)?.sector,
        shares: h.shares,
        cost: h.cost,
        avgCost: roundMoney(h.cost / h.shares),
        value,
        pl,
        plPct: h.cost ? pl / h.cost : 0,
      };
    })
    .sort((a, b) => b.value - a.value);
}

export const portfolioValue = (holdings, stocks) =>
  roundMoney(positions(holdings, stocks).reduce((sum, p) => sum + p.value, 0));

export const sectorsHeld = (holdings) =>
  new Set(Object.keys(holdings).map((sym) => getDef(sym)?.sector).filter(Boolean));

// Share of the portfolio held in the single largest position (0..1).
export function concentration(holdings, stocks) {
  const pos = positions(holdings, stocks);
  const total = pos.reduce((s, p) => s + p.value, 0);
  if (!total) return 0;
  return pos[0].value / total;
}
