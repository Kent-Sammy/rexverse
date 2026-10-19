import { formatNaira } from './money.js';

export const ALLOWANCE = 10000;
export const CATEGORIES = [
  {
    id: 'spending',
    label: 'Spending',
    icon: '🛍️',
    hint: 'Food, transport, data, treats — money you use now.',
  },
  {
    id: 'saving',
    label: 'Saving',
    icon: '🐷',
    hint: 'A safety net for emergencies and future goals.',
  },
  {
    id: 'investing',
    label: 'Investing',
    icon: '📈',
    hint: 'Money that could grow over time — but can also fall.',
  },
];

// Whole naira only, no negatives, and the three parts must add up to exactly ₦10,000.
export function validateAllocation(a, total = ALLOWANCE) {
  const errors = [];
  for (const c of CATEGORIES) {
    const v = a[c.id];
    if (!Number.isInteger(v)) errors.push(`${c.label} must be a whole naira amount.`);
    else if (v < 0) errors.push(`${c.label} can't be negative.`);
    else if (v > total) errors.push(`${c.label} can't be more than ${formatNaira(total)}.`);
  }
  const sum = CATEGORIES.reduce((s, c) => s + (Number.isFinite(a[c.id]) ? a[c.id] : 0), 0);
  const remaining = total - sum;
  if (!errors.length && remaining > 0) errors.push(`You still have ${formatNaira(remaining)} to allocate.`);
  if (!errors.length && remaining < 0) errors.push(`You've allocated ${formatNaira(-remaining)} too much.`);
  return { ok: errors.length === 0, errors, sum, remaining };
}

// Turns a valid allocation into a profile, plain-language feedback and an XP reward.
// The biggest reward goes to balanced, responsible plans — not to the riskiest one.
export function assessAllocation(a, total = ALLOWANCE) {
  const spend = a.spending / total;
  const save = a.saving / total;
  const invest = a.investing / total;
  const pct = (x) => `${Math.round(x * 100)}%`;

  let profile;
  if (spend >= 0.7) {
    profile = {
      id: 'spender',
      title: 'Big Spender',
      xp: 100,
      summary: `You chose to enjoy most of your allowance now (${pct(spend)}). That's fine sometimes — but there's very little left to protect you from surprises or to grow for later.`,
    };
  } else if (invest >= 0.5 && save < 0.2) {
    profile = {
      id: 'bold',
      title: 'Bold Investor',
      xp: 110,
      summary: `You put ${pct(invest)} into investing with a small safety net. Investments can grow, but they can also fall — without savings, one emergency could force you to sell at a bad time.`,
    };
  } else if (save >= 0.6) {
    profile = {
      id: 'saver',
      title: 'Careful Saver',
      xp: 120,
      summary: `You saved ${pct(save)} — you're well protected. Over many years, though, prices rise (inflation), so money that only sits still slowly loses buying power. A small investment could help it grow.`,
    };
  } else if (save >= 0.2 && invest > 0 && spend <= 0.6) {
    profile = {
      id: 'balanced',
      title: 'Balanced Builder',
      xp: 150,
      summary: `Strong plan. You covered today (${pct(spend)}), protected tomorrow (${pct(save)}) and gave your money a chance to grow (${pct(invest)}). This balance is how long-term wealth usually starts.`,
    };
  } else {
    profile = {
      id: 'starter',
      title: 'Getting Started',
      xp: 110,
      summary: `A reasonable first plan. Many people aim to save at least 20% of what they receive and invest a little once they have a safety net.`,
    };
  }

  const notes = [];
  notes.push(
    a.spending === 0
      ? 'Nothing for spending: realistic budgets leave room for food, transport and data, or they’re hard to stick to.'
      : `${formatNaira(a.spending)} is your cash to spend. Once it's spent, it's gone.`,
  );
  notes.push(
    save >= 0.2
      ? `${formatNaira(a.saving)} in savings meets the common "save at least 20%" rule — a good start on an emergency fund.`
      : a.saving === 0
        ? 'No savings: an unexpected bill (phone repair, clinic visit) would have nothing to fall back on.'
        : `${formatNaira(a.saving)} in savings is a start. Try to reach 20% (${formatNaira(total * 0.2)}) next time.`,
  );
  notes.push(
    a.investing === 0
      ? 'Nothing invested: no risk, but also no chance for this money to grow.'
      : `${formatNaira(a.investing)} sits in your investment pot. You'll be able to use it at the NGX Stock Exchange in the Financial District. Its value may rise or fall.`,
  );

  return { ...profile, notes, shares: { spend, save, invest } };
}
