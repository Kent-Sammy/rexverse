import { Fill } from './screens/parts.jsx';

// RexPlay games: financial-literacy trivia plus one quick poll.
// Quiz: 50 points per correct answer. Poll: 20 points per answer (no wrong answers).

// Card artwork, positioned as in the Figma cards.
export const ART = {
  trophy: (
    <div className="-translate-x-1/2 -translate-y-1/2 absolute h-[76px] left-[calc(50%-3.5px)] top-[calc(50%+14.5px)] w-[83px]">
      <Fill src="35672.png" cover />
    </div>
  ),
  phone: (
    <div className="-translate-x-1/2 absolute h-[77.679px] left-1/2 top-[34.32px] w-[85px]">
      <Fill src="659ef.png" cover />
    </div>
  ),
  budget: (
    <div className="absolute h-[86px] left-[28px] top-[25px] w-[95px]">
      <Fill src="635e3.png" cover />
    </div>
  ),
  coins: (
    <div className="-translate-x-1/2 absolute h-[92px] left-1/2 top-[22px] w-[110px]">
      <Fill src="91f71.png" />
    </div>
  ),
  controller: (
    <div className="-translate-x-1/2 absolute h-[92px] left-1/2 top-[22px] w-[100px]">
      <Fill src="2bdd4.png" />
    </div>
  ),
};

// Bigger artwork for the game's start screen.
export const HERO_ART = {
  trophy: '35672.png',
  phone: '659ef.png',
  budget: '635e3.png',
  coins: '91f71.png',
  controller: '2bdd4.png',
};

const q = (question, options, answer, explain) => ({ question, options, answer, explain });

export const GAMES = [
  {
    id: 'naira-savings',
    title: 'Naira Savings Trivia',
    body: 'Test your knowledge about savings and investing in Nigeria.',
    topic: 'SAVINGS',
    from: '#9dff89',
    art: 'trophy',
    live: true,
    tags: ['trivia'],
    kind: 'quiz',
    seconds: 20,
    questions: [
      q('What is an emergency fund mainly for?', ['Buying the latest phone', 'Unexpected costs like medical bills or job loss', 'Holidays and owambe', 'Trying out crypto'], 1,
        'Aim to keep 3–6 months of living expenses in an emergency fund you can reach quickly.'),
      q('“Pay yourself first” means…', ['Spend on yourself before bills', 'Save part of your income as soon as you’re paid', 'Ask for a salary advance', 'Pay off friends first'], 1,
        'Move savings out on payday, before spending starts — an auto-save makes this effortless.'),
      q('You save ₦5,000 every week for a year (52 weeks). How much do you have?', ['₦60,000', '₦240,000', '₦260,000', '₦520,000'], 2,
        '₦5,000 × 52 weeks = ₦260,000 — small, steady amounts add up.'),
      q('Which usually pays the highest interest?', ['Current account', 'Cash kept at home', 'Regular savings account', 'Fixed deposit'], 3,
        'Fixed deposits pay more because you agree to leave the money untouched for a set period.'),
      q('Inflation means…', ['Prices rise, so each naira buys less', 'Your salary rises automatically', 'Banks pay more interest', 'The naira gets stronger'], 0,
        'If prices rise 20% in a year, ₦10,000 buys what ₦8,333 bought before.'),
      q('Inflation is 20% and your savings earn 5% a year. What happens to your buying power?', ['It grows', 'It stays the same', 'It shrinks', 'It doubles'], 2,
        'Your money must grow faster than inflation to keep its value.'),
      q('Ajo / Esusu is…', ['A type of bank loan', 'Group savings where members take turns collecting the pot', 'A government bond', 'A mobile game'], 1,
        'It builds discipline, but has no interest and depends on trusting every member.'),
      q('Which body insures deposits if a Nigerian bank fails?', ['SEC', 'FIRS', 'NDIC', 'NAFDAC'], 2,
        'The Nigeria Deposit Insurance Corporation protects deposits up to a set limit per depositor.'),
      q('Which is the best savings goal?', ['Save more this year', '₦300,000 for rent by December', 'Save whatever is left', 'Save when I feel like it'], 1,
        'A clear amount and deadline tells you exactly how much to save each month.'),
      q('Compound interest is interest earned on…', ['Only the money you deposit', 'Your deposit plus interest already earned', 'Loans only', 'Money in your current account'], 1,
        'Interest on interest makes savings grow faster the longer you leave them.'),
    ],
  },
  {
    id: 'fixed-deposit',
    title: 'Fixed Deposit Challenge',
    body: 'How well do you know fixed deposits? Find out and earn.',
    topic: 'FIXED DEPOSIT',
    from: '#ffe08a',
    to: '#fff7e3',
    art: 'coins',
    live: true,
    tags: ['products'],
    kind: 'quiz',
    seconds: 20,
    questions: [
      q('A fixed deposit is…', ['Money you can withdraw any time', 'Money locked for a set period at an agreed interest rate', 'A loan from the bank', 'A type of current account'], 1,
        'You agree the amount, rate and period up front — in return you get a better rate.'),
      q('The “tenor” of a fixed deposit is…', ['The interest rate', 'How long the money stays fixed', 'The bank’s fee', 'The minimum deposit'], 1,
        'Common tenors are 30, 60, 90, 180 and 365 days.'),
      q('What usually happens if you withdraw before maturity?', ['You get a bonus', 'Nothing changes', 'You may lose some or all of the interest', 'The bank doubles your money'], 2,
        'This is called premature liquidation — only fix money you won’t need before the date.'),
      q('₦100,000 fixed at 12% a year for 1 year earns how much interest (before tax)?', ['₦1,200', '₦10,000', '₦12,000', '₦120,000'], 2,
        '₦100,000 × 12% = ₦12,000.'),
      q('What tax is deducted from fixed deposit interest in Nigeria?', ['7.5% VAT', '10% withholding tax', '5% stamp duty', 'No tax at all'], 1,
        'Banks deduct 10% withholding tax from the interest, not from your principal.'),
      q('“Rollover” means…', ['Closing the deposit early', 'Reinvesting the deposit for another tenor at maturity', 'Moving it to another bank', 'Converting it to dollars'], 1,
        'You can roll over the principal only, or principal plus interest to compound it.'),
      q('₦200,000 at 12% a year, fixed for 3 months, earns roughly…', ['₦2,400', '₦6,000', '₦12,000', '₦24,000'], 1,
        '12% a year is about 3% for 3 months: ₦200,000 × 3% = ₦6,000.'),
      q('“12% p.a.” means 12%…', ['Per month', 'Per week', 'Per year', 'For the whole tenor'], 2,
        'p.a. = per annum (per year). Shorter tenors earn a proportion of it.'),
      q('Which money suits a fixed deposit best?', ['Your daily transport money', 'Rent you’ll pay in 6 months', 'Money for tomorrow’s groceries', 'Your emergency fund'], 1,
        'Fix money with a known future date; keep emergency money where you can reach it instantly.'),
      q('Fixed deposits are best known for…', ['High risk, high reward', 'Low risk and predictable returns', 'Daily price swings', 'Guaranteed doubling'], 1,
        'You know your return in advance, which makes them great for planned goals.'),
    ],
  },
  {
    id: 'budgeting',
    title: 'Budgeting Challenge',
    body: 'See how well you can build a monthly budget.',
    topic: 'BUDGETING',
    from: '#ffcf62',
    to: '#f8ebce',
    art: 'budget',
    tags: ['trivia'],
    kind: 'quiz',
    seconds: 20,
    questions: [
      q('The 50/30/20 rule splits income into…', ['Savings / wants / needs', 'Needs / wants / savings', 'Rent / food / transport', 'Tax / pension / savings'], 1,
        '50% needs, 30% wants, 20% savings and debt repayment.'),
      q('Which of these is a need?', ['Netflix', 'Rent', 'New sneakers', 'Eating out'], 1,
        'Needs keep you housed, fed, healthy and able to work.'),
      q('You earn ₦150,000 a month. With 50/30/20, how much should you save?', ['₦15,000', '₦30,000', '₦45,000', '₦75,000'], 1,
        '20% of ₦150,000 = ₦30,000.'),
      q('What is the first step in making a budget?', ['Open a new account', 'Know your total monthly income', 'Cut all spending', 'Buy a budgeting app'], 1,
        'You can’t plan spending until you know exactly what comes in.'),
      q('Tracking your expenses helps you…', ['Earn more interest', 'See where your money goes and cut waste', 'Avoid paying tax', 'Get a loan faster'], 1,
        'Most people underestimate small daily spends like snacks and data.'),
      q('Regular support for family (“black tax”) should be…', ['Ignored in your budget', 'Paid from savings', 'Planned in as a fixed budget line', 'Borrowed for'], 2,
        'Planning it avoids surprises and protects your savings.'),
      q('A good way to avoid impulse buying is to…', ['Shop when hungry', 'Wait 24–48 hours before non-essential buys', 'Use only credit', 'Keep cards in your phone case'], 1,
        'Most impulse urges pass after a day or two.'),
      q('How often should you review your budget?', ['Once a year', 'Never — set and forget', 'Monthly, or when income changes', 'Only when you’re broke'], 2,
        'Life changes; your budget should too.'),
      q('If your expenses are more than your income, you have…', ['A surplus', 'A deficit', 'A dividend', 'A balanced budget'], 1,
        'Close the gap by cutting wants first, then finding ways to earn more.'),
      q('Your income changes every month. Budget using…', ['Your best month', 'Your average month', 'Your lowest expected month', 'Last year’s income'], 2,
        'Budgeting on your lowest month keeps you safe; extra goes to savings.'),
    ],
  },
  {
    id: 'money-smart',
    title: 'Money Smart Quiz',
    body: 'General money know-how: investing, credit and staying safe.',
    topic: 'MONEY BASICS',
    from: '#88ebff',
    art: 'trophy',
    tags: ['trivia', 'products'],
    kind: 'quiz',
    seconds: 20,
    questions: [
      q('Diversification means…', ['Putting all your money in one stock', 'Spreading money across different investments', 'Keeping cash under the mattress', 'Only saving in dollars'], 1,
        '“Don’t put all your eggs in one basket” — it reduces the damage if one investment falls.'),
      q('Nigerian Treasury Bills are issued by…', ['Commercial banks', 'The Federal Government through the CBN', 'The Nigerian Stock Exchange', 'Fintech apps'], 1,
        'They’re short-term government borrowing and among the lowest-risk naira investments.'),
      q('Using the Rule of 72, money earning 12% a year doubles in about…', ['3 years', '6 years', '12 years', '72 years'], 1,
        '72 ÷ 12 = 6 years.'),
      q('A credit score shows…', ['How much you earn', 'How reliably you repay borrowed money', 'Your account balance', 'Your BVN'], 1,
        'Paying loans on time builds a good score and cheaper borrowing later.'),
      q('“Guaranteed 50% monthly returns, no risk!” is most likely…', ['A great deal', 'A government scheme', 'A Ponzi scheme or scam', 'A fixed deposit'], 2,
        'High returns always come with risk. “Guaranteed” plus “high” is a red flag.'),
      q('Someone calls “from your bank” asking for your OTP. You should…', ['Read it out quickly', 'Send it by SMS instead', 'Hang up and never share it', 'Share only half'], 2,
        'Your bank will never ask for your PIN, OTP or password.'),
      q('Which of these is an asset?', ['Car loan', 'Credit card debt', 'Shares in a company', 'Unpaid electricity bill'], 2,
        'Assets put money in your pocket or hold value; liabilities take money out.'),
      q('Interest on a loan is…', ['A gift from the bank', 'The cost of borrowing', 'A type of savings', 'Tax-free income'], 1,
        'Compare interest and fees before you borrow.'),
      q('A mutual fund is…', ['A loan from friends', 'A pool of investors’ money managed by professionals', 'A government grant', 'A savings group'], 1,
        'It lets small investors diversify without picking individual stocks.'),
      q('Net worth equals…', ['Income minus tax', 'Assets minus liabilities', 'Salary times 12', 'Savings plus loans'], 1,
        'Track it yearly — growing net worth means you’re building wealth.'),
    ],
  },
  {
    id: 'savings-poll',
    title: 'Saving Habits Poll',
    body: 'Tell us how you save and see how others do it.',
    topic: 'POLL',
    from: '#d4baff',
    art: 'phone',
    tags: ['poll'],
    kind: 'poll',
    seconds: 30,
    questions: [
      { question: 'How often do you save?', options: ['Every payday', 'Weekly', 'When I have extra', 'Rarely'], results: [38, 21, 31, 10] },
      { question: 'Where do you keep most of your savings?', options: ['Bank savings account', 'Fixed deposit', 'Ajo / Esusu group', 'Cash at home'], results: [46, 18, 24, 12] },
      { question: 'What are you saving for right now?', options: ['Rent', 'Emergency fund', 'Starting a business', 'Gadgets or travel'], results: [33, 27, 26, 14] },
      { question: 'Which would help you save more?', options: ['Auto-save from salary', 'Goals with reminders', 'Higher interest', 'Saving with friends'], results: [35, 22, 30, 13] },
      { question: 'How confident are you about investing?', options: ['Very confident', 'Somewhat', 'Not really', 'Not at all'], results: [12, 41, 32, 15] },
    ],
  },
];

export const gameById = (id) => GAMES.find((g) => g.id === id);
export const maxPoints = (g) => g.questions.length * (g.kind === 'poll' ? 20 : 50);

// Leaderboard: other players' scores for a game. "You" are slotted in by score.
export const RIVALS = [
  ['Amaka k.', '8d91b.png', true],
  ['James Smith', '86cb5.png', true],
  ['Emily Johnson', '884ed.png', true],
  ['Michael Brown', '00f0f.png', true],
  ['Jessica Davis', 'c84e9.png'],
  ['David Wilson', '2b017.png'],
  ['Christopher Garcia', '04de9.png'],
  ['Ashley Martinez', 'bd58d.png'],
  ['Daniel Hernandez', '0438a.png'],
  ['Nancy Lopez', 'a1456.svg'],
  ['Matthew Perez', 'a1456.svg'],
  ['Sophia Thompson', 'a1456.svg'],
];
const RIVAL_SHARE = [1, 0.95, 0.92, 0.9, 0.88, 0.85, 0.8, 0.78, 0.75, 0.73, 0.7, 0.68];
export const PLAYERS = 248;

export function leaderboard(game, myPoints) {
  const max = maxPoints(game);
  const rivals = RIVALS.map(([name, file, photo], i) => ({ name, file, photo, points: Math.round((max * RIVAL_SHARE[i]) / 5) * 5 }));
  const me = { name: 'Ololade M. (You)', file: 'c7b7f.png', photo: false, points: myPoints, you: true };
  const ahead = rivals.filter((r) => r.points > myPoints).length;
  const rows = [...rivals.slice(0, ahead), me, ...rivals.slice(ahead)].map((r, i) => ({ ...r, rank: i + 1 }));
  // Below the named top players, spread the rank across the rest of the room.
  if (ahead === rivals.length) {
    const lowest = rivals[rivals.length - 1].points;
    me.rank = Math.min(PLAYERS, ahead + 1 + Math.round(((lowest - myPoints) / Math.max(lowest, 1)) * (PLAYERS - ahead - 1)));
    rows[rows.length - 1].rank = me.rank;
  }
  return { rows, rank: rows.find((r) => r.you).rank };
}
