import { STOCK_DEFS, MARKET_NEWS } from '../data/stocks.js';
import { randn, pick } from './random.js';

const HISTORY_LEN = 40;
const MIN_PRICE = 0.5;

const round2 = (n) => Math.round(n * 100) / 100;

// One geometric-Brownian-motion step. dt is a fraction of an in-game day.
export function stepPrice(price, { drift, vol }, dt, z, shock = 0) {
  const exponent = (drift - 0.5 * vol * vol) * dt + vol * Math.sqrt(dt) * z;
  return Math.max(MIN_PRICE, round2(price * Math.exp(exponent) * (1 + shock)));
}

export function createMarket(rng = Math.random) {
  return STOCK_DEFS.map((def) => {
    // Pre-roll a short history so charts are not empty on day 1.
    const history = [];
    let p = def.basePrice;
    for (let i = 0; i < 24; i++) {
      p = stepPrice(p, def, 0.25, randn(rng));
      history.push(p);
    }
    // Re-centre on the base price so every game starts from known prices.
    const scale = def.basePrice / p;
    const scaled = history.map((h) => round2(h * scale));
    return {
      symbol: def.symbol,
      price: def.basePrice,
      prevClose: scaled[scaled.length - 5] ?? def.basePrice,
      history: scaled,
    };
  });
}

// Small intraday move while the player is in the world.
export function tickMarket(stocks, rng = Math.random, dt = 0.04) {
  return stocks.map((s) => {
    const def = getDef(s.symbol);
    const price = stepPrice(s.price, def, dt, randn(rng));
    return { ...s, price, history: [...s.history, price].slice(-HISTORY_LEN) };
  });
}

// End-of-day close: a full day's move, plus possible sector news.
export function closeDay(stocks, rng = Math.random, newsChance = 0.6) {
  const news = rng() < newsChance ? pick(MARKET_NEWS, rng) : null;
  const next = stocks.map((s) => {
    const def = getDef(s.symbol);
    const shock = news && news.sector === def.sector ? news.shock : 0;
    const price = stepPrice(s.price, def, 1, randn(rng), shock);
    return {
      ...s,
      prevClose: s.price,
      price,
      history: [...s.history, price].slice(-HISTORY_LEN),
    };
  });
  return { stocks: next, news };
}

const defMap = Object.fromEntries(STOCK_DEFS.map((d) => [d.symbol, d]));
export const getDef = (symbol) => defMap[symbol];

export const changePct = (s) => (s.prevClose ? (s.price - s.prevClose) / s.prevClose : 0);
