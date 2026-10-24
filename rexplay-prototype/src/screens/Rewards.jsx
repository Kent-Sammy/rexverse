import StatusBar from './StatusBar.jsx';
import { BackButton, Fill, TitleBlock } from './parts.jsx';
import { asset as a } from '../asset.js';
import { gameById, HERO_ART } from '../games.jsx';
import { formatDate, useStore } from '../store.jsx';

// Figma: "rex play" › Your RexPlay Rewards (24454:40672)
export const FIGMA_ASSETS = 'https://www.figma.com/api/mcp/asset/ec005c03-591e-4575-a8c9-79e92c838628';

export function Coin({ size, className = '', style }) {
  return (
    <div className={`relative shrink-0 ${className}`} style={{ width: size, height: size, ...style }}>
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <img alt="" className="absolute left-[2.07%] max-w-none size-[99.04%] top-0" src={a('2a1e3.png')} />
      </div>
    </div>
  );
}

function SmallCoin({ blurred, left, top, size }) {
  return (
    <div className={`absolute ${blurred ? 'blur-[2.429px]' : ''}`} style={{ left, top, width: size, height: size }}>
      <Fill src="0afe0.png" />
    </div>
  );
}

// Blue "83 Points" banner. `height` 147 on Rewards (with button), 116 on Redeem.
export function PointsBanner({ coins, height = 147, children }) {
  const dy = height === 147 ? 0 : -23; // the small coins sit 23px higher on the shorter banner
  return (
    <div className="bg-gradient-to-r from-[#002766] to-[#004ecc] overflow-clip relative rounded-[8px] shrink-0 w-full" style={{ height }}>
      <Coin size={108} className="!absolute -translate-y-1/2 left-[212px]" style={{ top: `calc(50% + ${height === 147 ? 2.5 : 2}px)` }} />
      <SmallCoin blurred left={308.17} top={37 + dy} size={33.279} />
      <SmallCoin left={317.42} top={44.4 + dy} size={29.581} />
      <SmallCoin blurred left={188} top={78.6 + dy} size={33.279} />
      <SmallCoin left={197.25} top={86 + dy} size={29.581} />
      <div
        className="-translate-y-1/2 absolute flex flex-col gap-[10px] items-start left-[17px] w-[179px]"
        style={{ top: height === 147 ? 'calc(50% + 0.5px)' : '50%' }}
      >
        <div className="flex flex-col gap-[7px] items-start justify-center relative shrink-0 w-full">
          <div className="flex gap-[3px] h-[22px] items-center relative shrink-0 w-full">
            <Coin size={18} />
            <p className="font-inter font-bold leading-[1.256] text-[#f1f5ff] text-[20px] tracking-[-0.8px] whitespace-nowrap">{coins} Points</p>
          </div>
          <div className="flex flex-col font-inter font-normal h-[29px] justify-center overflow-hidden text-[#f1f5ff] text-[10px] tracking-[-0.2px] w-full">
            <p className="leading-[1.5]">Play, learn and earn. Redeem your points for exciting rewards.</p>
          </div>
        </div>
        {children}
      </div>
    </div>
  );
}

function Stat({ label, value, icon, labelWidth = 98, center = '0.5px' }) {
  return (
    <div className="bg-white flex-[1_0_0] h-full min-w-px overflow-clip relative rounded-[11px]">
      <div
        className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[10px] items-center top-[calc(50%+20.5px)]"
        style={{ left: `calc(50% + ${center})`, width: labelWidth }}
      >
        <p className="font-inter font-medium leading-[normal] text-[#4f5a6e] text-[10px] text-center w-full">{label}</p>
        <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[16px] text-center tracking-[-0.32px]">{value}</p>
      </div>
      {icon}
    </div>
  );
}

function RecentGame({ game, play }) {
  return (
    <div className="bg-white h-[101px] overflow-clip relative rounded-[10px] shrink-0 w-full">
      <div
        className="-translate-x-1/2 -translate-y-1/2 absolute h-[81px] left-[calc(50%-128.5px)] overflow-clip rounded-[6px] top-1/2 w-[86px]"
        style={{ backgroundImage: `linear-gradient(to bottom, ${game.from}, ${game.to || '#f3f5ff'})` }}
      >
        {game.art === 'trophy' ? (
          <div className="-translate-x-1/2 -translate-y-1/2 absolute h-[54px] left-[calc(50%+0.5px)] top-[calc(50%+0.5px)] w-[59px]">
            <Fill src="35672.png" cover />
          </div>
        ) : game.art === 'phone' ? (
          <div className="-translate-x-1/2 absolute h-[56px] left-[calc(50%-3.5px)] top-[19px] w-[61px]">
            <Fill src="659ef.png" cover />
          </div>
        ) : (
          <div className="-translate-x-1/2 -translate-y-1/2 absolute h-[60px] left-1/2 top-1/2 w-[66px]">
            <Fill src={HERO_ART[game.art]} />
          </div>
        )}
      </div>
      <div className="absolute flex flex-col gap-[10px] items-start left-[110px] top-[15px] w-[170px]">
        <div className="flex flex-col gap-[3px] items-start relative shrink-0 w-full">
          <p className="font-inter font-semibold leading-[normal] text-[#130f26] text-[11px] whitespace-nowrap">{game.title}</p>
          <p className="font-inter font-medium leading-[1.5] text-[#6d7d9c] text-[10px] tracking-[-0.2px] w-full">
            {game.kind === 'poll' ? `${play.score} answers shared` : `Scored ${play.score}/${play.total} · Rank #${play.rank}`}
          </p>
        </div>
        <p className="font-inter font-semibold leading-[1.5] text-[#6d7d9c] text-[10px] tracking-[-0.2px] w-full">{formatDate(play.at)}</p>
      </div>
      <div className="-translate-y-1/2 absolute bg-[#c7ffbd] h-[17px] flex items-center px-[7px] right-[19px] rounded-[22.5px] top-1/2">
        <p className="font-inter font-medium text-[#147f00] text-[7.313px] leading-[14.989px] whitespace-nowrap">+{play.points}pts</p>
      </div>
    </div>
  );
}

export default function Rewards({ go, back, coins }) {
  const { plays } = useStore();
  const earned = plays.reduce((n, p) => n + p.points, 0);
  const bestRank = plays.filter((p) => gameById(p.gameId).kind === 'quiz').reduce((m, p) => Math.min(m, p.rank), Infinity);

  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <StatusBar />
      <TitleBlock title="Your RexPlay Rewards" subtitle="Play at your own pace" coins={coins} />
      <BackButton onClick={back} />

      <div className="-translate-x-1/2 absolute flex flex-col gap-[14px] items-start left-[calc(50%+0.5px)] top-[145px] w-[363px]">
        <PointsBanner coins={coins}>
          <button
            onClick={() => go('redeem')}
            className="bg-white flex h-[32px] items-center justify-center p-[10px] relative rounded-[6px] shrink-0 w-[141px] cursor-pointer active:scale-95 transition-transform"
          >
            <p className="font-inter font-semibold leading-[normal] text-[#002766] text-[10px] whitespace-nowrap">Redeem Rewards</p>
          </button>
        </PointsBanner>
        <div className="flex gap-[6px] items-center relative shrink-0 w-full">
          {['Overview', 'History'].map((t) => (
            <button
              key={t}
              onClick={() => (t === 'History' ? go('history') : null)}
              className={`bg-white border border-solid ${t === 'Overview' ? 'border-[#9ec3ff]' : 'border-0'} cursor-pointer flex flex-[1_0_0] items-center justify-center min-w-px p-[10px] relative rounded-[9px]`}
            >
              <p className="font-inter font-semibold leading-[normal] text-[#002766] text-[12px] whitespace-nowrap">{t}</p>
            </button>
          ))}
        </div>
      </div>

      <p className="-translate-y-1/2 absolute font-inter font-bold leading-[normal] left-[20px] text-[#130f26] text-[14px] top-[363.5px] whitespace-nowrap">Your Stats</p>
      <div className="-translate-x-1/2 absolute flex gap-[6px] h-[112px] items-center left-[calc(50%+0.5px)] top-[387px] w-[363px]">
        <Stat
          label="Games Played"
          value={plays.length}
          labelWidth={89}
          center="0px"
          icon={
            <div className="-translate-x-1/2 absolute left-1/2 size-[29px] top-[16px]">
              <Fill src="2bdd4.png" />
            </div>
          }
        />
        <Stat
          label="Best Rank"
          value={Number.isFinite(bestRank) ? `#${bestRank}` : '–'}
          icon={
            <div className="absolute left-[43px] size-[29px] top-[16px]">
              <Fill src="8c91a.png" />
            </div>
          }
        />
        <Stat label="Total Points Earned" value={earned} icon={<Coin size={29} className="!absolute left-[43px] top-[16px]" />} />
      </div>

      <div className="absolute flex items-center justify-between left-[20px] py-[10px] w-[363px] top-[504px]">
        <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[14px] whitespace-nowrap">Recent Games</p>
      </div>
      <div className="absolute flex flex-col gap-[5px] items-start left-[20px] w-[363px] top-[546px] bottom-0 overflow-y-auto pb-[24px] [scrollbar-width:none]">
        {plays.length === 0 ? (
          <div className="bg-white rounded-[10px] w-full p-[20px] flex flex-col items-center gap-[10px] text-center">
            <p className="font-inter font-semibold text-[12px] text-[#130f26]">No games yet</p>
            <p className="font-inter font-medium text-[11px] text-[#6d7d9c]">Play a RexPlay game to start earning points.</p>
            <button onClick={() => go('rexplay')} className="bg-[#002766] text-white rounded-[8px] px-[16px] py-[9px] font-inter font-semibold text-[11px] cursor-pointer">
              Play Now
            </button>
          </div>
        ) : (
          plays.map((p) => <RecentGame key={p.at} game={gameById(p.gameId)} play={p} />)
        )}
      </div>
    </div>
  );
}
