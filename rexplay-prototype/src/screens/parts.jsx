import { asset as a } from '../asset.js';
import { REWARDS } from '../config.js';

// Pieces that repeat across the RexPlay screens in Figma.

export const Fill = ({ src, cover, className }) => (
  <img
    alt=""
    className={className || `absolute inset-0 max-w-none ${cover ? 'object-cover' : 'object-contain'} pointer-events-none size-full`}
    src={a(src)}
  />
);

export const Icon = ({ src }) => <img alt="" className="absolute block inset-0 max-w-none size-full" src={a(src)} />;

// "←" in the top-left of every RexPlay screen.
export function BackButton({ onClick, file = '3a6d0.svg' }) {
  return (
    <div className="-translate-x-1/2 absolute h-[42px] left-[calc(50%+0.5px)] top-[48px] w-[357px] z-10">
      <button
        onClick={onClick}
        aria-label="Back"
        className="-translate-y-1/2 absolute flex flex-col items-start justify-center left-[-8px] top-1/2 cursor-pointer p-[8px]"
      >
        <div className="relative shrink-0 size-[24px]">
          <Icon src={file} />
        </div>
      </button>
    </div>
  );
}

// White pill with the gold coin and the user's points.
export function CoinPill({ coins = 0, onClick, className = '' }) {
  return (
    <button
      onClick={onClick}
      className={`absolute bg-white block cursor-pointer h-[31px] overflow-clip right-0 rounded-[40px] shadow-[0px_4px_35.5px_0px_#c6d6ff] top-[11px] min-w-[59px] pr-[12px] ${className}`}
    >
      <p className="-translate-y-1/2 absolute font-inter font-medium left-[36px] text-[#335285] text-[13px] text-left top-[calc(50%+1px)] whitespace-nowrap leading-[26.648px]">
        {coins}
      </p>
      <span className="invisible font-inter font-medium text-[13px] pl-[36px]">{coins}</span>
      <div className="-translate-y-1/2 absolute left-[5px] size-[26px] top-[calc(50%+0.5px)]">
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <img alt="" className="absolute left-[2.07%] max-w-none size-[99.04%] top-0" src={a('2a1e3.png')} />
        </div>
      </div>
    </button>
  );
}

// Screen title block: "RexPlay / Play at your own pace" with the coin pill on the right.
export function TitleBlock({ title, subtitle, subtitleWidth = 216, coins, onCoins }) {
  return (
    <div className="-translate-x-1/2 absolute flex flex-col gap-px items-start justify-center left-[calc(50%+0.5px)] top-[89px] w-[359px]">
      <p className="font-inter font-bold leading-[1.3] text-[#002766] text-[20px] whitespace-nowrap">{title}</p>
      <p className="font-inter font-medium leading-[normal] text-[#8f9bb3] text-[12px]" style={{ width: subtitleWidth }}>
        {subtitle}
      </p>
      {coins !== undefined && <CoinPill coins={coins} onClick={onCoins} />}
    </div>
  );
}

function Chevron({ file = '18e56.svg' }) {
  return (
    <div className="-translate-x-1/2 -translate-y-1/2 absolute flex items-center justify-center left-1/2 size-[12px] top-1/2">
      <div className="-rotate-90 flex-none">
        <div className="relative size-[12px]">
          <Icon src={file} />
        </div>
      </div>
    </div>
  );
}

export function LiveBadge() {
  return (
    <div className="absolute bg-[#e44555] flex gap-[2px] h-[14px] items-center justify-center left-[10px] p-[6.364px] rounded-[12.091px] top-[8px]">
      <div className="relative shrink-0 size-[4px]">
        <Icon src="42593.svg" />
      </div>
      <p className="font-inter font-semibold leading-[normal] text-[6.364px] text-white whitespace-nowrap">Live Now</p>
    </div>
  );
}

// Game card used in the "Live Now" and "Rex Play Trivia" rows.
export function GameCard({ from, to = '#f3f5ff', art, live, title, body, points, onClick, nudge = '0.5px' }) {
  return (
    <button
      onClick={onClick}
      className="bg-white w-[179px] shrink-0 h-[232px] overflow-clip relative rounded-[10px] cursor-pointer text-left active:scale-[.98] transition-transform"
    >
      <div
        className="-translate-x-1/2 absolute h-[117px] left-[calc(50%+0.5px)] overflow-clip rounded-[6px] top-[9px] w-[156px]"
        style={{ backgroundImage: `linear-gradient(to bottom, ${from}, ${to})` }}
      >
        {art}
        {live && <LiveBadge />}
      </div>
      <div
        className="-translate-x-1/2 absolute flex flex-col gap-[14px] items-start top-[137px] w-[156px]"
        style={{ left: `calc(50% + ${nudge})` }}
      >
        <div className="flex flex-col gap-[3px] h-[47px] items-start relative shrink-0 w-full">
          <p className="font-inter font-semibold leading-[normal] text-[#130f26] text-[11px] whitespace-nowrap">{title}</p>
          <p className="font-inter font-medium leading-[1.5] min-w-full text-[#6d7d9c] text-[10px] tracking-[-0.2px] w-min">{body}</p>
        </div>
        <div className="flex items-center justify-between relative shrink-0 w-full">
          <div className="flex gap-[8px] items-center justify-center relative shrink-0">
            <div className="relative shrink-0 size-[16px]">
              <Icon src="546c8.svg" />
            </div>
            <p className="font-inter font-semibold leading-[normal] text-[#002d93] text-[11px] whitespace-nowrap">Up to {points} {REWARDS.pointsName}</p>
          </div>
          <div className="bg-[#dae2ff] overflow-clip relative rounded-[24px] shrink-0 size-[24px]">
            <Chevron />
          </div>
        </div>
      </div>
    </button>
  );
}

export function SectionHeader({ title, width, right }) {
  return (
    <div className="flex items-center justify-between relative shrink-0 w-full">
      <p className="font-inter font-semibold leading-[normal] text-[#130f26] text-[14px] tracking-[-0.07px]" style={{ width }}>
        {title}
      </p>
      {right}
    </div>
  );
}

// Inline text link with a chevron, as in the Figma "See More ›" (navy) and
// "Start Goal ›" (accent blue) links on the Dashboard.
export function TextLink({ children, onClick, accent, className = '' }) {
  const Tag = onClick ? 'button' : 'span'; // a span when it sits inside a tappable card
  return (
    <Tag onClick={onClick} className={`inline-flex items-center gap-[2px] cursor-pointer shrink-0 ${className}`}>
      <span
        className={`font-inter text-[10px] leading-[1.5] tracking-[-0.2px] whitespace-nowrap ${accent ? 'font-bold text-[#323dff]' : 'font-semibold text-[#002766]'}`}
      >
        {children}
      </span>
      <span className="flex items-center justify-center relative shrink-0 size-[12px]">
        <span className="-rotate-90 flex-none">
          <span className="block relative size-[12px]">
            <span className="absolute inset-[35.42%_20.83%]">
              <span className={`absolute ${accent ? 'inset-[-14.29%_-7.14%]' : 'inset-[-21.43%_-10.71%]'}`}>
                <img alt="" className="block max-w-none size-full" src={a(accent ? 'd61b8.svg' : '4735d.svg')} />
              </span>
            </span>
          </span>
        </span>
      </span>
    </Tag>
  );
}

// Small white button used on blue cards in Figma ("Explore Offers", "Redeem Rewards").
export function SmallButton({ children, onClick, dark }) {
  return (
    <button
      onClick={onClick}
      className={`${dark ? 'bg-[#002766] text-white' : 'bg-white text-[#002766]'} flex h-[26px] items-center justify-center px-[12px] rounded-[6px] shrink-0 cursor-pointer active:scale-95 transition-transform`}
    >
      <span className="font-inter font-semibold leading-[normal] text-[10px] whitespace-nowrap">{children}</span>
    </button>
  );
}
