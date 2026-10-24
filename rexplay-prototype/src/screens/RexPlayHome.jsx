import { useState } from 'react';
import StatusBar from './StatusBar.jsx';
import { BackButton, Fill, GameCard, Icon, SectionHeader, SeeAll, TitleBlock } from './parts.jsx';

// Figma: "rex play" › Rexplay (24450:38752)
export const FIGMA_ASSETS = 'https://www.figma.com/api/mcp/asset/d9fcfd67-56bb-4742-9d5e-168656cdf0a2';

const TABS = ['All', 'Live Now', 'Polls', 'Trivia', 'Products'];

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
          <p className="leading-[1.5]">Play trivia, polls and challenges. Climb the leaderboard and earn points.</p>
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
          className={`bg-white flex items-center justify-center p-[10px] relative rounded-[6px] cursor-pointer border border-solid ${
            value === t ? 'border-[#639fff]' : 'border-0'
          } ${i === 0 ? 'shrink-0 w-[51px]' : 'flex-[1_0_0] min-w-px'}`}
        >
          <p className="font-inter font-semibold leading-[normal] text-[#002766] text-[10px] whitespace-nowrap">{t}</p>
        </button>
      ))}
    </div>
  );
}

// Card artwork, positioned exactly as in Figma.
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
};

export default function RexPlayHome({ go, back, coins }) {
  const [tab, setTab] = useState('All');
  const showLive = tab === 'All' || tab === 'Live Now' || tab === 'Polls' || tab === 'Trivia';
  const showTrivia = tab !== 'Live Now' && tab !== 'Polls';

  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <StatusBar />
      <TitleBlock title="RexPlay" subtitle="Play at your own pace" coins={coins} onCoins={() => go('rewards')} />
      <BackButton onClick={back} />

      <div className="-translate-x-1/2 absolute flex flex-col gap-[14px] items-start left-[calc(50%+0.5px)] top-[145px] w-[363px]">
        <div className="flex flex-col gap-[9px] items-start relative shrink-0 w-full">
          <HeroBanner />
          <FilterTabs value={tab} onChange={setTab} />
        </div>

        {showLive && (
          <div className="flex flex-col gap-[9px] items-center relative shrink-0 w-full">
            <SectionHeader
              title="Live Now"
              width={66}
              right={
                <div className="flex gap-[5px] items-center relative shrink-0">
                  <div className="relative shrink-0 size-[6px] animate-pulse">
                    <Icon src="64f7e.svg" />
                  </div>
                  <p className="font-inter font-semibold leading-[normal] text-[#556276] text-[10px] whitespace-nowrap">2 live experiences</p>
                </div>
              }
            />
            <div className="flex gap-[5px] items-center relative shrink-0 w-full">
              {tab !== 'Polls' && (
                <GameCard
                  live
                  from="#9dff89"
                  art={ART.trophy}
                  title="Naira Savings Trivia"
                  body="Test your knowledge about savings and investing in Nigeria."
                  points={500}
                  onClick={() => go('crowdpurr')}
                />
              )}
              {tab !== 'Trivia' && (
                <GameCard
                  live
                  from="#d4baff"
                  art={ART.phone}
                  title="RexPay Product Poll"
                  body="Help us improve by sharing your opinion."
                  points={300}
                  nudge="1px"
                  onClick={() => go('crowdpurr')}
                />
              )}
            </div>
          </div>
        )}

        {showTrivia && (
          <div className="flex flex-col gap-[9px] items-start relative shrink-0 w-full">
            <SectionHeader title="Rex Play Trivia" width={104} right={<SeeAll onClick={() => go('trivia-list')} />} />
            <div className="flex gap-[5px] items-center relative shrink-0 w-full">
              <GameCard
                from="#ffcf62"
                to="#f8ebce"
                art={ART.budget}
                title="Budgeting Challenge"
                body="See how well you can build a monthly budget."
                points={500}
                onClick={() => go('crowdpurr')}
              />
              <GameCard
                from="#88ebff"
                art={ART.trophy}
                title="Rex Product Quiz"
                body="Learn about Rex Products and earn rewards."
                points={300}
                nudge="1px"
                onClick={() => go('crowdpurr')}
              />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
