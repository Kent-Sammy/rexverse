import { useState } from 'react';
import StatusBar from './StatusBar.jsx';
import { BackButton, Fill, GameCard, Icon, SectionHeader, TitleBlock } from './parts.jsx';
import { ART, CATEGORIES, GAMES, dailyChallenge, maxPoints } from '../games.jsx';
import { FEATURES, REWARDS } from '../config.js';
import { useStore } from '../store.jsx';

// Figma: "rex play" › Rexplay (24450:38752)
export const FIGMA_ASSETS = 'https://www.figma.com/api/mcp/asset/d9fcfd67-56bb-4742-9d5e-168656cdf0a2';

const TABS = ['All', ...CATEGORIES.map((c) => c.label)];

function Coin({ blurred, left, top, size }) {
  return (
    <div className={`absolute ${blurred ? 'blur-[2.429px]' : ''}`} style={{ left, top, width: size, height: size }}>
      <Fill src="0afe0.png" />
    </div>
  );
}

export function HeroBanner() {
  return (
    <div className="bg-gradient-to-r from-[#002766] to-[#004ecc] h-[93px] overflow-clip relative rounded-[8px] shrink-0 w-full">
      <div className="absolute h-[222.278px] left-[203px] top-[19px] w-[219.578px]">
        <Icon src="abeef.svg" />
      </div>
      <div className="-translate-y-1/2 absolute flex flex-col gap-[3px] items-start justify-center left-[19px] text-[#f1f5ff] top-[calc(50%+1px)] w-[179px]">
        <p className="font-inter font-bold text-[14.477px] leading-[1.256] tracking-[-0.5791px] w-full">Your next win starts here</p>
        <div className="flex flex-col font-inter font-normal h-[29px] justify-center overflow-hidden text-[10px] tracking-[-0.2px] w-full">
          <p className="leading-[1.5]">Sports, music, money and more. Climb the leaderboard and earn RexPoints.</p>
        </div>
      </div>
      <div className="absolute left-[220.54px] size-[116.291px] top-[7px]">
        <Fill src="2bdd4.png" />
      </div>
      <Coin blurred left={310.55} top={22.13} size={28.674} />
      <Coin left={318.51} top={28.51} size={25.488} />
      <Coin blurred left={207} top={57.98} size={28.674} />
      <Coin left={214.97} top={64.35} size={25.488} />
    </div>
  );
}

export function FilterTabs({ value, onChange }) {
  return (
    <div className="flex gap-[6px] items-center relative shrink-0 w-full">
      {TABS.map((t, i) => (
        <button
          key={t}
          onClick={() => onChange(t)}
          className={`bg-white flex items-center justify-center py-[10px] px-[4px] relative rounded-[6px] cursor-pointer border border-solid ${
            value === t ? 'border-[#639fff]' : 'border-0'
          } ${i === 0 ? 'shrink-0 w-[44px]' : t === 'Entertainment' ? 'flex-[1.45_0_0] min-w-px' : 'flex-[1_0_0] min-w-px'}`}
        >
          <p className="font-inter font-semibold leading-[normal] text-[#002766] text-[10px] whitespace-nowrap">{t}</p>
        </button>
      ))}
    </div>
  );
}

// Cards sit two per row at their Figma width; a lone card stays on the left.
function CardRows({ games, go }) {
  const rows = [];
  for (let i = 0; i < games.length; i += 2) rows.push(games.slice(i, i + 2));
  return rows.map((row) => (
    <div key={row[0].id} className="flex gap-[5px] items-center justify-start relative shrink-0 w-full">
      {row.map((g, i) => (
        <GameCard
          key={g.id}
          live={FEATURES.liveGames && g.live}
          from={g.from}
          to={g.to}
          art={ART[g.art]}
          title={g.title}
          body={g.body}
          points={maxPoints(g)}
          nudge={i === 1 ? '1px' : '0.5px'}
          onClick={() => go(`game/${g.id}`)}
        />
      ))}
    </div>
  ));
}

// Today's 5-question Daily Challenge.
function DailyCard({ go }) {
  const { plays } = useStore();
  const daily = dailyChallenge();
  const done = plays.find((p) => p.gameId === daily.id);
  return (
    <button
      onClick={() => go(`game/${daily.id}`)}
      className="relative w-full h-[96px] shrink-0 overflow-hidden rounded-[10px] bg-gradient-to-r from-[#ffcb05] to-[#ffe08a] text-left cursor-pointer active:scale-[.99] transition-transform"
    >
      <div className="absolute right-[-6px] top-[2px] size-[96px]">
        <Fill src="2bdd4.png" />
      </div>
      <div className="absolute left-[16px] top-1/2 -translate-y-1/2 w-[250px] flex flex-col gap-[4px]">
        <div className="flex items-center gap-[6px]">
          <p className="font-inter font-bold text-[15px] text-[#002766]">Daily Challenge</p>
          <span className="bg-[#002766] text-white rounded-[10px] px-[7px] py-[1px] font-inter font-semibold text-[9px]">NEW EVERY DAY</span>
        </div>
        <p className="font-inter font-medium text-[11px] leading-[1.4] text-[#3d3a1a]">
          {done
            ? `Done for today: ${done.score}/${done.total}, +${done.points} ${REWARDS.pointsName}. Come back tomorrow!`
            : `${daily.questions.length} quick questions · ${daily.seconds}s each · up to ${maxPoints(daily)} ${REWARDS.pointsName}`}
        </p>
        {!done && (
          <span className="mt-[2px] self-start bg-[#002766] text-white rounded-[6px] px-[12px] py-[5px] font-inter font-semibold text-[10px]">Play now</span>
        )}
      </div>
    </button>
  );
}

export default function RexPlayHome({ go, back, coins }) {
  const [tab, setTab] = useState('All');
  const cats = CATEGORIES.filter((c) => tab === 'All' || c.label === tab);

  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <StatusBar />
      <TitleBlock title="RexPlay" subtitle="Play. Learn. Earn RexPoints." coins={coins} onCoins={() => go('rewards')} />
      <BackButton onClick={back} />

      <div className="absolute left-0 right-0 top-[145px] bottom-0 overflow-y-auto overscroll-contain [scrollbar-width:none]">
        <div className="mx-auto translate-x-[0.5px] flex flex-col gap-[14px] items-start pb-[32px] w-[363px]">
          <div className="flex flex-col gap-[9px] items-start relative shrink-0 w-full">
            <HeroBanner />
            <FilterTabs value={tab} onChange={setTab} />
          </div>

          {FEATURES.dailyChallenge && tab === 'All' && <DailyCard go={go} />}

          {cats.map((c) => {
            const games = GAMES.filter((g) => g.category === c.id);
            if (!games.length) return null;
            return (
              <div key={c.id} className="flex flex-col gap-[9px] items-start relative shrink-0 w-full">
                <SectionHeader title={c.name} width={220} />
                <CardRows games={games} go={go} />
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
