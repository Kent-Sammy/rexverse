// Money helpers. All money in REXVERSE is virtual naira (₦), stored as numbers rounded to kobo (2 dp).

export const roundMoney = (n) => Math.round((Number(n) + Number.EPSILON) * 100) / 100;

export function formatNaira(n, { sign = false } = {}) {
  const value = roundMoney(n);
  const abs = Math.abs(value);
  const decimals = Number.isInteger(abs) ? 0 : 2;
  const body = abs.toLocaleString('en-NG', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
  if (value < 0) return `−₦${body}`;
  if (sign && value > 0) return `+₦${body}`;
  return `₦${body}`;
}

export const formatPct = (p, { sign = true } = {}) => {
  const v = Math.round(p * 1000) / 10;
  const s = `${Math.abs(v).toFixed(1)}%`;
  if (v < 0) return `−${s}`;
  return sign && v > 0 ? `+${s}` : s;
};

// Parse a user-typed amount. Returns NaN for anything that isn't a positive number.
export function parseAmount(text) {
  const cleaned = String(text ?? '').replace(/[₦,\s]/g, '');
  if (!/^\d+(\.\d{0,2})?$/.test(cleaned)) return NaN;
  const n = Number(cleaned);
  return n > 0 ? roundMoney(n) : NaN;
}
