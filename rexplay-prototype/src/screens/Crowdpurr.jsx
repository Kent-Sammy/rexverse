import { Fill, Icon } from './parts.jsx';
import { asset as a } from '../asset.js';

// Pieces from the Figma "Crowdpurr page" (24452:39477) and "End game" (24453:39833) frames,
// used by the game screen (Game.jsx).
export const FIGMA_ASSETS = [
  'https://www.figma.com/api/mcp/asset/37c95de4-493c-489c-b9d4-e417f7389304',
  'https://www.figma.com/api/mcp/asset/db3c9ab1-a1d2-4a02-9b81-64169c00fbd2',
];

export const DARK_STATUS = { color: '#fbfbfb', files: { location: '21e33.svg', wifi: '757fe.svg', battery: 'f6966.svg' } };

function Glow({ className }) {
  return (
    <div className={`absolute size-[309px] ${className}`}>
      <div className="absolute inset-[-54.34%]">
        <img alt="" className="block max-w-none size-full" src={a('18522.svg')} />
      </div>
    </div>
  );
}

export function DarkBackdrop() {
  return (
    <>
      <Glow className="left-[-135px] top-[115px]" />
      <Glow className="left-[calc(75%+6.5px)] top-[319px]" />
      <div className="absolute left-[-193px] size-[335px] top-[643px]">
        <Icon src="eddbf.svg" />
      </div>
    </>
  );
}

export function CloseButton({ onClick }) {
  return (
    <button
      onClick={onClick}
      aria-label="Close"
      className="absolute bg-[rgba(255,255,255,0.35)] block cursor-pointer overflow-clip right-[36px] rounded-[40px] size-[32px] top-[66px] z-10"
    >
      <div className="-translate-x-1/2 -translate-y-1/2 absolute left-1/2 size-[18px] top-1/2">
        <Icon src="0598a.svg" />
      </div>
    </button>
  );
}

// Bottom sheet: "End game?" with Cancel / Yes, Exit.
export function EndGameSheet({ onCancel, onExit }) {
  return (
    <>
      <div
        onClick={onCancel}
        className="absolute bg-[rgba(10,13,31,0.75)] inset-0 z-20 animate-[fade_.2s_ease-out]"
      />
      <div className="-translate-x-1/2 absolute bg-white bottom-0 h-[349px] left-1/2 overflow-clip rounded-tl-[30px] rounded-tr-[30px] w-[402px] z-30 animate-[sheet_.25s_ease-out]">
        <div className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[27px] items-center left-[calc(50%+0.5px)] top-[calc(50%+52px)] w-[351px]">
          <div className="flex flex-col gap-[11px] items-center relative shrink-0">
            <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[18px] whitespace-nowrap">End game?</p>
            <p className="font-inter font-medium leading-[20px] text-[#8491ab] text-[14px] text-center w-[297px]">
              You’ll exit this game and return to the RexPlay List.
            </p>
          </div>
          <div className="flex gap-[7px] items-start justify-center relative shrink-0 w-full">
            <button
              onClick={onCancel}
              className="bg-[#d1e3ff] cursor-pointer flex flex-[1_0_0] items-center justify-center min-w-px py-[18px] relative rounded-[12px] active:scale-[.98] transition-transform"
            >
              <p className="font-inter font-semibold leading-[1.2] text-[#001f52] text-[14px] text-center whitespace-nowrap">Cancel</p>
            </button>
            <button
              onClick={onExit}
              className="bg-[#002766] cursor-pointer flex flex-[1_0_0] items-center justify-center min-w-px py-[18px] relative rounded-[12px] active:scale-[.98] transition-transform"
            >
              <p className="font-inter font-semibold leading-[1.2] text-[14px] text-center text-white whitespace-nowrap">Yes, Exit</p>
            </button>
          </div>
        </div>
        <div className="-translate-x-1/2 absolute left-1/2 size-[90px] top-[34px]">
          <Fill src="50a4c.png" cover />
        </div>
      </div>
    </>
  );
}
