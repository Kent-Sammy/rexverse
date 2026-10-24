import StatusBar from './StatusBar.jsx';
import { DARK_STATUS } from './Crowdpurr.jsx';
import { Fill, Icon } from './parts.jsx';
import { asset as a } from '../asset.js';

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
  return (
    <div className="bg-[#032c70] overflow-clip relative size-full">
      <Rays />
      <StatusBar {...DARK_STATUS} />
      <TopGlow />

      <div className="absolute bg-white h-[588px] left-0 overflow-clip rounded-[23px] top-[286px] w-[402px]">
        {/* Score */}
        <div className="-translate-x-1/2 absolute bg-[#f4ecff] flex flex-col gap-[16px] items-center left-[calc(50%+0.5px)] overflow-clip px-[23px] py-[20px] rounded-[11px] top-[29px] w-[357px]">
          <div className="flex flex-col gap-[7px] items-start leading-[normal] text-center w-[98px]">
            <p className="font-inter font-medium text-[#4f5a6e] text-[14px] w-full">Your Score</p>
            <p className="font-inter font-bold text-[#130f26] text-[32px] tracking-[-0.64px] w-full">8/10</p>
          </div>
          <p className="font-inter font-medium leading-[normal] min-w-full text-[#4f5a6e] text-[12px] text-center w-min">
            You answered 8 out of 10 questions correctly.
          </p>
        </div>

        {/* Rank + points */}
        <div className="-translate-x-1/2 absolute flex gap-[6px] items-center left-[calc(50%+0.5px)] top-[170px] w-[357px]">
          <div className="bg-[#eff2fe] flex-[1_0_0] h-[130px] min-w-px overflow-clip relative rounded-[11px]">
            <div className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[10px] items-center leading-[normal] left-[calc(50%-0.25px)] text-center top-1/2 w-[133px]">
              <div className="flex flex-col gap-[3px] items-start w-full">
                <p className="font-inter font-medium text-[#4f5a6e] text-[12px] w-full">Your Rank</p>
                <p className="font-inter font-bold text-[#130f26] text-[20px] tracking-[-0.4px] w-full">#7</p>
              </div>
              <p className="font-inter font-medium text-[#4f5a6e] text-[12px] w-full">Out of 248 players</p>
            </div>
          </div>
          <div className="bg-[#fff7eb] flex-[1_0_0] h-[130px] min-w-px overflow-clip relative rounded-[11px]">
            <div className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[10px] items-center left-[calc(50%+0.25px)] top-[calc(50%-0.5px)] w-[98px]">
              <div className="flex flex-col gap-[3px] items-center justify-center w-full">
                <p className="font-inter font-medium leading-[normal] min-w-full text-[#4f5a6e] text-[12px] text-center w-min">Points Earned</p>
                <div className="flex gap-[3px] items-start">
                  <div className="relative shrink-0 size-[26px]">
                    <div className="absolute inset-0 overflow-hidden pointer-events-none">
                      <img alt="" className="absolute left-[2.07%] max-w-none size-[99.04%] top-0" src={a('2a1e3.png')} />
                    </div>
                  </div>
                  <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[20px] text-center tracking-[-0.4px] w-[33px]">83</p>
                </div>
              </div>
              <p className="font-inter font-medium leading-[normal] text-[#4f5a6e] text-[12px] text-center w-full">+50 points</p>
            </div>
          </div>
        </div>

        {/* Note */}
        <div className="absolute bg-[#eff2fe] h-[61px] left-[23px] overflow-clip rounded-[11px] top-[363px] w-[357px]">
          <p className="absolute font-inter font-medium leading-[normal] left-[53px] text-[#4f5a6e] text-[12px] top-[calc(50%-14.5px)] tracking-[-0.24px] w-[285px]">
            Points will be credited to your account once results have been verified.
          </p>
          <div className="absolute left-[15px] size-[24px] top-[19px]">
            <Icon src="7ba8d.svg" />
          </div>
        </div>

        <div className="absolute flex flex-col gap-[7px] items-center left-[23px] top-[450px] w-[351px]">
          <PrimaryButton onClick={() => go('leaderboard')}>View Leaderboard</PrimaryButton>
          <PrimaryButton light onClick={back}>
            Back to RexPlay
          </PrimaryButton>
        </div>
      </div>

      {/* Trophy header */}
      <div className="-translate-x-1/2 absolute flex flex-col gap-[12px] items-center left-1/2 top-[54px] w-[236px]">
        <div className="relative shrink-0 size-[116px] animate-[pop-in_.5s_ease-out]">
          <Fill src="8c91a.png" />
        </div>
        <div className="flex flex-col gap-[9px] items-center justify-end w-full">
          <p className="font-inter font-bold leading-[normal] text-[19.6px] text-center text-white tracking-[-0.392px] w-[196px]">Naira Savings Trivia</p>
          <p className="font-inter font-medium leading-[normal] min-w-full text-[#d7e4ff] text-[14px] text-center w-min">
            The experience has ended. Here’s how you did!
          </p>
        </div>
      </div>
    </div>
  );
}
