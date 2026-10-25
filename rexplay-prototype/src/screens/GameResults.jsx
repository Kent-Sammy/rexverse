import StatusBar from './StatusBar.jsx';
import { DARK_STATUS } from './Crowdpurr.jsx';
import { Fill, Icon } from './parts.jsx';
import { asset as a } from '../asset.js';
import { useStore } from '../store.jsx';
import { useCompact } from '../Phone.jsx';
import { gameById, PLAYERS } from '../games.jsx';

// Figma: "rex play" › Rexplay (24452:39633) — results after a game ends.
export const FIGMA_ASSETS = 'https://www.figma.com/api/mcp/asset/11214079-bf8c-4ed2-951c-8b4c9c5a5ae5';

export function Rays() {
  return (
    <div className="-translate-x-1/2 absolute h-[451px] left-[calc(50%+0.5px)] opacity-22 top-[-116px] w-[445px]">
      <Fill src="f56e7.png" cover />
    </div>
  );
}

export function TopGlow() {
  return (
    <div className="absolute left-[47px] size-[309px] top-[101px]">
      <div className="absolute inset-[-54.34%]">
        <img alt="" className="block max-w-none size-full" src={a('18522.svg')} />
      </div>
    </div>
  );
}

export function PrimaryButton({ children, onClick, light, className = 'w-full' }) {
  return (
    <button
      onClick={onClick}
      className={`${light ? 'bg-[#d1e3ff] text-[#001f52]' : 'bg-[#002766] text-white'} cursor-pointer flex items-center justify-center py-[18px] relative rounded-[12px] shrink-0 active:scale-[.98] transition-transform ${className}`}
    >
      <p className="font-inter font-semibold leading-[1.2] text-[14px] text-center whitespace-nowrap">{children}</p>
    </button>
  );
}

export default function GameResults({ go, back }) {
  const { plays, coins } = useStore();
  const last = plays[0] || { gameId: 'naira-savings', score: 0, total: 10, points: 0, rank: PLAYERS };
  const game = gameById(last.gameId);
  const poll = game.kind === 'poll';
  const compact = useCompact();
  return (
    <div className="bg-[#032c70] overflow-clip relative size-full">
      <Rays />
      <StatusBar {...DARK_STATUS} />
      <TopGlow />

      {/* White panel: results scroll if needed, the two buttons stay pinned at the bottom. */}
      <div
        className="absolute bg-white bottom-0 left-0 overflow-clip rounded-t-[23px] w-[402px] flex flex-col"
        style={{ top: compact ? 196 : 286 }}
      >
        <div className={`flex-1 min-h-0 overflow-y-auto overscroll-contain [scrollbar-width:none] px-[22.5px] flex flex-col gap-[10px] ${compact ? 'pt-[18px]' : 'pt-[29px]'}`}>
          {/* Score */}
          <div className={`bg-[#f4ecff] flex flex-col items-center px-[23px] rounded-[11px] w-full shrink-0 ${compact ? 'gap-[10px] py-[14px]' : 'gap-[16px] py-[20px]'}`}>
            <div className="flex flex-col gap-[7px] items-center leading-[normal] text-center">
              <p className="font-inter font-medium text-[#4f5a6e] text-[14px]">{poll ? 'Answered' : 'Your Score'}</p>
              <p className={`font-inter font-bold text-[#130f26] tracking-[-0.64px] ${compact ? 'text-[28px]' : 'text-[32px]'}`}>
                {last.score}/{last.total}
              </p>
            </div>
            <p className="font-inter font-medium leading-[normal] text-[#4f5a6e] text-[12px] text-center">
              {poll
                ? 'Thanks for sharing your saving habits with us!'
                : `You answered ${last.score} out of ${last.total} questions correctly.`}
            </p>
          </div>

          {/* Rank + points */}
          <div className="flex gap-[6px] items-center w-full shrink-0">
            <div className={`bg-[#eff2fe] flex-[1_0_0] min-w-px rounded-[11px] flex flex-col gap-[10px] items-center justify-center text-center leading-[normal] ${compact ? 'h-[104px]' : 'h-[130px]'}`}>
              <div className="flex flex-col gap-[3px] items-center">
                <p className="font-inter font-medium text-[#4f5a6e] text-[12px]">Your Rank</p>
                <p className="font-inter font-bold text-[#130f26] text-[20px] tracking-[-0.4px]">#{last.rank}</p>
              </div>
              <p className="font-inter font-medium text-[#4f5a6e] text-[12px]">Out of {PLAYERS} players</p>
            </div>
            <div className={`bg-[#fff7eb] flex-[1_0_0] min-w-px rounded-[11px] flex flex-col gap-[10px] items-center justify-center text-center leading-[normal] ${compact ? 'h-[104px]' : 'h-[130px]'}`}>
              <div className="flex flex-col gap-[3px] items-center">
                <p className="font-inter font-medium text-[#4f5a6e] text-[12px]">Points Earned</p>
                <div className="flex gap-[3px] items-start">
                  <div className="relative shrink-0 size-[26px]">
                    <div className="absolute inset-0 overflow-hidden pointer-events-none">
                      <img alt="" className="absolute left-[2.07%] max-w-none size-[99.04%] top-0" src={a('2a1e3.png')} />
                    </div>
                  </div>
                  <p className="font-inter font-bold text-[#130f26] text-[20px] tracking-[-0.4px] min-w-[33px]">{last.points}</p>
                </div>
              </div>
              <p className="font-inter font-medium text-[#4f5a6e] text-[12px]">Balance: {coins} pts</p>
            </div>
          </div>

          {/* Note */}
          <div className={`bg-[#eff2fe] rounded-[11px] w-full shrink-0 flex items-center gap-[14px] px-[15px] py-[12px] ${compact ? '' : 'mt-auto'}`}>
            <div className="relative size-[24px] shrink-0">
              <Icon src="7ba8d.svg" />
            </div>
            <p className="font-inter font-medium leading-[normal] text-[#4f5a6e] text-[12px] tracking-[-0.24px]">
              Your points have been added to your RexPlay balance. Redeem them for airtime, data or cash.
            </p>
          </div>
        </div>

        <div className={`shrink-0 flex flex-col gap-[7px] items-center px-[25.5px] pt-[14px] ${compact ? 'pb-[16px]' : 'pb-[24px]'}`}>
          <PrimaryButton onClick={() => go(`leaderboard/${game.id}`)}>View Leaderboard</PrimaryButton>
          <PrimaryButton light onClick={() => go('rexplay', { replace: true })}>
            Back to RexPlay
          </PrimaryButton>
        </div>
      </div>

      {/* Trophy header */}
      <div
        className={`-translate-x-1/2 absolute flex flex-col items-center left-1/2 w-[340px] ${compact ? 'gap-[8px] top-[50px]' : 'gap-[12px] top-[54px]'}`}
      >
        <div className={`relative shrink-0 animate-[pop-in_.5s_ease-out] ${compact ? 'size-[64px]' : 'size-[116px]'}`}>
          <Fill src="8c91a.png" />
        </div>
        <div className="flex flex-col gap-[9px] items-center justify-end w-full">
          <p className="font-inter font-bold leading-[normal] text-[19.6px] text-center text-white tracking-[-0.392px] w-[320px]">{game.title}</p>
          <p className="font-inter font-medium leading-[normal] min-w-full text-[#d7e4ff] text-[14px] text-center w-min">
            The experience has ended. Here’s how you did!
          </p>
        </div>
      </div>
    </div>
  );
}
