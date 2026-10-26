import { Fill } from './screens/parts.jsx';
import { FEATURES, REWARDS } from './config.js';

// RexPlay games: trivia across four categories, a daily 5-question challenge and (switched
// off for launch) a quick poll. Points per answer come from src/config.js.

export const CATEGORIES = [
  { id: 'sports', label: 'Sports', name: 'Football & Sports', topic: 'SPORTS' },
  { id: 'entertainment', label: 'Entertainment', name: 'Entertainment', topic: 'ENTERTAINMENT' },
  { id: 'general', label: 'General', name: 'General Knowledge', topic: 'GENERAL KNOWLEDGE' },
  { id: 'money', label: 'Money', name: 'Money & Finance', topic: 'MONEY' },
];
export const categoryById = (id) => CATEGORIES.find((c) => c.id === id);

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
  cup: (
    <div className="-translate-x-1/2 absolute h-[84px] left-1/2 top-[26px] w-[84px]">
      <Fill src="8c91a.png" />
    </div>
  ),
  party: (
    <div className="-translate-x-1/2 absolute size-[78px] left-1/2 top-[28px] -rotate-[20deg]">
      <Fill src="ccc03.svg" />
    </div>
  ),
  rocket: (
    <div className="-translate-x-1/2 absolute size-[84px] left-1/2 top-[26px]">
      <Fill src="afadc.svg" />
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
  cup: '8c91a.png',
  party: 'ccc03.svg',
  rocket: 'afadc.svg',
};

const q = (question, options, answer, explain) => ({ question, options, answer, explain });

const SPORTS_GAMES = [
  {
    id: 'football-fever',
    title: 'Football Fever',
    body: 'Super Eagles, AFCON, the World Cup and more.',
    topic: 'SPORTS',
    from: '#a6f4c5',
    art: 'cup',
    live: true,
    category: 'sports',
    kind: 'quiz',
    seconds: 20,
    questions: [
      q('What is the nickname of Nigeria’s men’s national football team?', ['Black Stars', 'Super Eagles', 'Indomitable Lions', 'Flying Eagles'], 1,
        'The Black Stars are Ghana and the Indomitable Lions are Cameroon. The Flying Eagles are Nigeria’s U-20 side.'),
      q('Which country has won the most FIFA World Cups?', ['Germany', 'Italy', 'Brazil', 'Argentina'], 2,
        'Brazil have lifted the trophy five times — 1958, 1962, 1970, 1994 and 2002.'),
      q('How many times have the Super Eagles won the Africa Cup of Nations?', ['Once', 'Twice', 'Three times', 'Five times'], 2,
        'Nigeria won AFCON in 1980, 1994 and 2013.'),
      q('In which year did Nigeria win Olympic gold in men’s football?', ['1980', '1996', '2004', '2008'], 1,
        'The “Dream Team” beat Argentina 3–2 in the final at the Atlanta 1996 Olympics.'),
      q('What is the nickname of Nigeria’s women’s national football team?', ['Super Falcons', 'Golden Eaglets', 'Lionesses', 'Banyana Banyana'], 0,
        'The Super Falcons are Africa’s most successful women’s team at the Women’s AFCON.'),
      q('How many players does each team have on the pitch in a football match?', ['9', '10', '11', '12'], 2,
        'Eleven per side, including the goalkeeper.'),
      q('Which country hosted the 2010 FIFA World Cup, the first in Africa?', ['Nigeria', 'Egypt', 'Morocco', 'South Africa'], 3,
        'South Africa 2010 gave the world the vuvuzela — and Spain won the trophy.'),
      q('Jay-Jay Okocha became a fan favourite at which English club?', ['Arsenal', 'Bolton Wanderers', 'Chelsea', 'Everton'], 1,
        'Okocha captained Bolton and was famous for his skills: “so good they named him twice”.'),
      q('Which Nigerian striker was named CAF African Footballer of the Year for 2023?', ['Victor Osimhen', 'Ademola Lookman', 'Kelechi Iheanacho', 'Ahmed Musa'], 0,
        'Osimhen won it after firing Napoli to the Serie A title.'),
      q('Chioma Ajunwa won Olympic gold for Nigeria in 1996 in which event?', ['100m sprint', 'Long jump', 'Boxing', 'Weightlifting'], 1,
        'She was Nigeria’s first individual Olympic gold medallist.'),
    ],
  },
];

const ENTERTAINMENT_GAMES = [
  {
    id: 'afrobeats-nollywood',
    title: 'Afrobeats & Nollywood',
    body: 'Music, movies and the stars making Naija proud.',
    topic: 'ENTERTAINMENT',
    from: '#ffc2e2',
    art: 'party',
    category: 'entertainment',
    kind: 'quiz',
    seconds: 20,
    questions: [
      q('Which Nigerian star calls himself the “African Giant”?', ['Wizkid', 'Davido', 'Burna Boy', 'Olamide'], 2,
        '“African Giant” is also the name of Burna Boy’s 2019 album.'),
      q('Wizkid featured on which Drake song that topped charts worldwide?', ['Hotline Bling', 'One Dance', 'God’s Plan', 'Passionfruit'], 1,
        '“One Dance” (2016) was one of the most-streamed songs of its time.'),
      q('Rema’s hit “Calm Down” got a global remix featuring which singer?', ['Selena Gomez', 'Rihanna', 'Beyoncé', 'Dua Lipa'], 0,
        'The remix took “Calm Down” into the US top 5 in 2023.'),
      q('“Nollywood” is the nickname of which country’s film industry?', ['Ghana', 'Nigeria', 'Kenya', 'South Africa'], 1,
        'Nollywood is one of the largest film industries in the world by number of films made.'),
      q('Which 1992 film is widely credited with launching modern Nollywood?', ['Living in Bondage', 'The Wedding Party', 'October 1', 'King of Boys'], 0,
        'It was a straight-to-video hit that started the home-video boom.'),
      q('Who is known as the pioneer of Afrobeat?', ['King Sunny Adé', 'Fela Kuti', 'Ebenezer Obey', 'Onyeka Onwenu'], 1,
        'Fela blended highlife, jazz and funk with political lyrics in the 1970s.'),
      q('Burna Boy won his first Grammy for which album?', ['African Giant', 'Love, Damini', 'Twice as Tall', 'Outside'], 2,
        '“Twice as Tall” won Best Global Music Album at the 2021 Grammys.'),
      q('Tems featured on which Wizkid song that became a global hit?', ['Ojuelegba', 'Essence', 'Joro', 'Come Closer'], 1,
        'The Justin Bieber remix took “Essence” into the US Billboard Hot 100 top 10 in 2021.'),
      q('Who directed the 2016 box-office hit “The Wedding Party”?', ['Kemi Adetiba', 'Kunle Afolayan', 'Funke Akindele', 'Genevieve Nnaji'], 0,
        'Kemi Adetiba later directed the crime drama “King of Boys”.'),
      q('Asake’s debut album was called…', ['Work of Art', 'Mr. Money with the Vibe', 'Lungu Boy', 'Rave & Roses'], 1,
        'Released in 2022, it topped charts across Africa.'),
    ],
  },
];

const GENERAL_GAMES = [
  {
    id: 'naija-general',
    title: 'Naija General Knowledge',
    body: 'History, geography and science — how much do you know?',
    topic: 'GENERAL KNOWLEDGE',
    from: '#d4baff',
    art: 'rocket',
    category: 'general',
    kind: 'quiz',
    seconds: 20,
    questions: [
      q('What is the capital of Nigeria?', ['Lagos', 'Abuja', 'Ibadan', 'Kano'], 1,
        'Abuja replaced Lagos as the capital in December 1991.'),
      q('In which year did Nigeria gain independence?', ['1957', '1960', '1963', '1970'], 1,
        'Nigeria became independent on 1 October 1960 and a republic in 1963.'),
      q('How many states does Nigeria have?', ['30', '36', '37', '40'], 1,
        'Thirty-six states plus the Federal Capital Territory, Abuja.'),
      q('Who designed the Nigerian flag?', ['Taiwo Akinkunmi', 'Herbert Macaulay', 'Nnamdi Azikiwe', 'Obafemi Awolowo'], 0,
        'Taiwo Akinkunmi designed it as a student in 1959. Green stands for land, white for peace.'),
      q('What is the longest river in Africa?', ['Niger', 'Congo', 'Nile', 'Zambezi'], 2,
        'The Nile runs about 6,650 km. The Niger is the third longest.'),
      q('100 kobo make one…', ['Cedi', 'Naira', 'Rand', 'Shilling'], 1,
        'The naira replaced the Nigerian pound in 1973.'),
      q('Which is the largest planet in our solar system?', ['Earth', 'Saturn', 'Mars', 'Jupiter'], 3,
        'Jupiter is so big that all the other planets could fit inside it.'),
      q('Which gas do plants take in from the air to make food?', ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Helium'], 1,
        'Plants use carbon dioxide, water and sunlight in photosynthesis, and release oxygen.'),
      q('Which ocean lies to the south of Nigeria?', ['Indian Ocean', 'Pacific Ocean', 'Atlantic Ocean', 'Arctic Ocean'], 2,
        'Nigeria’s coast is on the Gulf of Guinea, part of the Atlantic.'),
      q('How many continents are there?', ['5', '6', '7', '8'], 2,
        'Africa, Antarctica, Asia, Australia (Oceania), Europe, North America and South America.'),
    ],
  },
];

const MONEY_GAMES = [
  {
    id: 'naira-savings',
    title: 'Naira Savings Trivia',
    body: 'Test your knowledge about savings and investing in Nigeria.',
    topic: 'SAVINGS',
    from: '#9dff89',
    art: 'trophy',
    live: true,
    category: 'money',
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
    category: 'money',
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
    category: 'money',
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
    category: 'money',
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
    category: 'money',
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

// Launch order: Sports and Entertainment first; polls only when switched on.
export const GAMES = [...SPORTS_GAMES, ...ENTERTAINMENT_GAMES, ...GENERAL_GAMES, ...MONEY_GAMES].filter(
  (g) => FEATURES.polls || g.kind !== 'poll',
);

// Daily Challenge: 5 questions, one from each category plus one bonus, picked fresh each day.
export const DAILY_QUESTIONS = 5;
export const todayKey = (d = new Date()) => `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`;

function seeded(seedText) {
  let h = 2166136261;
  for (const c of seedText) h = Math.imul(h ^ c.charCodeAt(0), 16777619);
  return () => {
    h = Math.imul(h ^ (h >>> 15), 2246822507);
    h = Math.imul(h ^ (h >>> 13), 3266489909);
    h ^= h >>> 16;
    return (h >>> 0) / 4294967296;
  };
}

export function dailyChallenge(key = todayKey()) {
  const rand = seeded(`daily-${key}`);
  const pool = (cat) =>
    GAMES.filter((g) => g.kind === 'quiz' && g.category === cat).flatMap((g) => g.questions.map((qq) => ({ ...qq, topic: categoryById(cat).topic })));
  const pick = (list) => list.splice(Math.floor(rand() * list.length), 1)[0];
  const pools = Object.fromEntries(CATEGORIES.map((c) => [c.id, pool(c.id)]));
  const questions = CATEGORIES.map((c) => pick(pools[c.id]));
  const bonus = CATEGORIES[Math.floor(rand() * CATEGORIES.length)].id;
  questions.push(pick(pools[bonus]));
  return {
    id: `daily-${key}`,
    daily: true,
    title: 'Daily Challenge',
    body: 'Five quick questions from every category. A new set every day.',
    topic: 'DAILY',
    from: '#ffe08a',
    art: 'controller',
    kind: 'quiz',
    seconds: 15,
    questions,
  };
}

export const gameById = (id) => (id?.startsWith('daily-') ? dailyChallenge(id.slice(6)) : GAMES.find((g) => g.id === id));
export const pointsPerAnswer = (g) => (g.kind === 'poll' ? 20 : g.daily ? REWARDS.dailyChallengePointsPerCorrect : REWARDS.pointsPerCorrect);
export const maxPoints = (g) => g.questions.length * pointsPerAnswer(g);

// ── Leaderboard ──────────────────────────────────────────────────────────────
// Every game has its own leaderboard of 248 players, ranked by correct answers and then by
// total answer time (faster wins a tie). Other players are simulated but fixed per game,
// so the board doesn't change between visits.
export const PLAYERS = 248;
const NAMED = [
  ['Amaka K.', '8d91b.png', true],
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
export const ME = { name: 'Ololade M.', file: 'c7b7f.png', photo: false };

const byRank = (a, b) => b.score - a.score || a.time - b.time;

function rivalsFor(game) {
  const rand = seeded(`board-${game.id}`);
  const n = game.questions.length;
  const others = [];
  for (let i = 0; i < PLAYERS - 1; i++) {
    // Most players get around 60% right; a few ace it.
    let score = 0;
    const skill = 0.35 + rand() * 0.6;
    for (let k = 0; k < n; k++) if (rand() < skill) score++;
    const time = Math.round(n * (3 + rand() * (game.seconds - 5)) * 10) / 10;
    others.push({ score, time });
  }
  others.sort(byRank);
  return others.map((o, i) => ({ ...o, ...(NAMED[i] ? { name: NAMED[i][0], file: NAMED[i][1], photo: !!NAMED[i][2] } : { name: `Player ${1000 + i}` }) }));
}

// mine: { score, time } for your best run in this game, or null if you haven't played it.
export function leaderboard(game, mine) {
  const all = rivalsFor(game);
  if (mine) all.push({ ...mine, ...ME, you: true });
  all.sort(byRank);
  const rows = all.map((r, i) => ({ ...r, rank: i + 1 }));
  const you = rows.find((r) => r.you);
  return { rows, rank: you?.rank ?? null, total: rows.length };
}
