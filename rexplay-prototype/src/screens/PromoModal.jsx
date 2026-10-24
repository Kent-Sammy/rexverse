import { asset as a } from '../asset.js';

// Figma: "rex play" › Modal Pop Up — trophy (24454:43484) and controller (24454:43078).
// Shown on top of the Dashboard.
export const FIGMA_ASSETS = [
  'https://www.figma.com/api/mcp/asset/f9f67c75-cc83-43a3-9b38-3c831008ce77',
  'https://www.figma.com/api/mcp/asset/0f99936b-456b-40d3-9eb8-7bf55c63e881',
];

const Fill = ({ src, className = 'absolute inset-0 max-w-none object-contain pointer-events-none size-full' }) => (
  <img alt="" className={className} src={a(src)} />
);

function Glow({ src, className }) {
  return (
    <div className={`absolute size-[142px] ${className}`}>
      <div className="absolute inset-[-48.87%]">
        <img alt="" className="block max-w-none size-full" src={a(src)} />
      </div>
    </div>
  );
}

function Coin({ blurred, left, top, size }) {
  return (
    <div className={`absolute ${blurred ? 'blur-[2.429px]' : ''}`} style={{ left, top, width: size, height: size }}>
      <Fill src="0afe0.png" />
    </div>
  );
}

export default function PromoModal({ variant = 'trophy', onClose, onPlay }) {
  return (
    <>
      <div
        onClick={onClose}
        className="absolute bg-[rgba(10,13,31,0.75)] inset-0 z-20 animate-[fade_.2s_ease-out]"
      />
      <div className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[16px] items-end justify-center left-[calc(50%+0.5px)] top-[calc(50%+0.5px)] w-[305px] z-30 animate-[pop_.25s_ease-out]">
        <button
          onClick={onClose}
          aria-label="Close"
          className="bg-white block cursor-pointer overflow-clip relative rounded-[40px] shrink-0 size-[32px]"
        >
          <div className="-translate-x-1/2 -translate-y-1/2 absolute left-1/2 size-[18px] top-1/2">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={a('ff39c.svg')} />
          </div>
        </button>
        <div className="border-2 border-solid border-white h-[365px] overflow-clip relative rounded-[23px] shrink-0 w-full bg-[#0866ff]">
          <Glow src="21320.svg" className="left-[242px] top-[46px]" />
          <Glow src="072dd.svg" className="left-[-73px] top-[278px]" />
          <Glow src="072dd.svg" className="left-[222px] top-[-78px]" />

          {variant === 'controller' && (
            <div className="absolute left-[85.19px] size-[139px] top-[14px]">
              <Fill src="2bdd4.png" />
            </div>
          )}
          <Coin blurred left={236} top={84} size={46.718} />
          <Coin left={248.98} top={94.39} size={41.527} />
          <Coin blurred left={21} top={29} size={46.801} />
          <Coin left={34} top={39.4} size={41.601} />

          <div className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[3px] items-center justify-center left-[calc(50%+3.5px)] text-[#f1f5ff] text-center top-[calc(50%+30.5px)] w-[246px]">
            <p className="font-inter font-bold text-[24px] leading-[1.05] tracking-[-0.96px] w-[205px]">Your next win starts here</p>
            <div className="flex flex-col font-inter font-normal h-[50px] justify-center min-w-full overflow-hidden text-[14px] tracking-[-0.28px] w-min">
              <p className="leading-[1.5]">Play trivia, polls and challenges. Climb the leaderboard and earn points.</p>
            </div>
          </div>
          <button
            onClick={onPlay}
            className="-translate-x-1/2 absolute bg-white border border-[#296ddc] border-solid flex h-[40px] items-center justify-center left-[calc(50%+4.5px)] p-[10px] rounded-[33px] top-[291px] w-[186px] cursor-pointer active:scale-95 transition-transform"
          >
            <p className="font-inter font-semibold text-[#002766] text-[12.211px] whitespace-nowrap leading-[normal]">RexPlay... Let’s Play</p>
          </button>

          {variant === 'trophy' && (
            <div className="-translate-x-1/2 -translate-y-1/2 absolute h-[146px] left-1/2 top-[calc(50%-98.5px)] w-[159px]">
              <Fill src="35672.png" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" />
            </div>
          )}
        </div>
      </div>
    </>
  );
}
