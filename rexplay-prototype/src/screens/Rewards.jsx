import StatusBar from './StatusBar.jsx';
import { BackButton, Fill, Icon, TitleBlock } from './parts.jsx';
import { asset as a } from '../asset.js';
import { gameById, HERO_ART } from '../games.jsx';
import { formatDate, formatPoints, useStore } from '../store.jsx';
import { DEMO, REWARDS, REXVAULT, toNaira } from '../config.js';
import { useState } from 'react';

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
            <p className="font-inter font-bold leading-[1.256] text-[#f1f5ff] text-[20px] tracking-[-0.8px] whitespace-nowrap">{formatPoints(coins)} {REWARDS.pointsName}</p>
          </div>
          <div className="flex flex-col font-inter font-normal h-[29px] justify-center overflow-hidden text-[#f1f5ff] text-[10px] tracking-[-0.2px] w-full">
            <p className="leading-[1.5]">Worth about ₦{formatPoints(toNaira(coins))} in airtime, data or cash.</p>
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

// RexVault: everyone can play; qualifying RexVault customers get extra benefits
// (values in src/config.js, pending Compliance approval).
export function VaultCard({ onOpen }) {
  const { vault, setVault } = useStore();
  if (!REXVAULT.enabled) return null;
  const perks = [
    `${REXVAULT.pointsMultiplier}× ${REWARDS.pointsName} on every correct answer`,
    `Earn up to ${formatPoints(REXVAULT.dailyEarnCap)} ${REWARDS.pointsName} a day (instead of ${formatPoints(REWARDS.dailyEarnCap)})`,
    REXVAULT.cashRedemptionVaultOnly && 'Redeem RexPoints as cash into your Rex account',
  ].filter(Boolean);
  return (
    <div className={`w-full rounded-[10px] p-[14px] flex gap-[12px] items-start ${vault ? 'bg-[#e6f9e8]' : 'bg-white'}`}>
      <div className="size-[38px] shrink-0 rounded-[10px] bg-[#ebfafc] relative">
        <div className="absolute inset-[7px]">
          <Icon src="89d81.svg" />
        </div>
      </div>
      <div className="flex-1 min-w-0 flex flex-col gap-[4px]">
        <p className="font-inter font-bold text-[13px] text-[#130f26]">{vault ? 'RexVault Boost is active' : 'Unlock RexVault Boost'}</p>
        {perks.map((p) => (
          <p key={p} className="font-inter font-medium text-[11px] leading-[1.4] text-[#4f5a6e]">
            {vault ? '✓ ' : '• '}
            {p}
          </p>
        ))}
        {!vault ? (
          <button onClick={onOpen} className="self-start mt-[6px] bg-[#002766] text-white rounded-[6px] px-[12px] py-[6px] font-inter font-semibold text-[10px] cursor-pointer">
            Save in RexVault to unlock
          </button>
        ) : (
          DEMO.tools && <button onClick={() => setVault(false)} className="self-start mt-[2px] font-inter font-medium text-[10px] text-[#6d7d9c] underline cursor-pointer">
            Demo: switch to a regular customer
          </button>
        )}
      </div>
    </div>
  );
}

export function VaultSheet({ onClose }) {
  const { setVault } = useStore();
  return (
    <>
      <div onClick={onClose} className="absolute bg-[rgba(10,13,31,0.75)] inset-0 z-20 animate-[fade_.2s_ease-out]" />
      <div className="absolute bg-white bottom-0 left-0 w-[402px] rounded-t-[30px] z-30 animate-[sheet-up_.3s_ease-out] px-[26px] pt-[28px] pb-[30px] flex flex-col gap-[14px]">
        <div className="size-[56px] rounded-[14px] bg-[#ebfafc] relative self-center">
          <div className="absolute inset-[12px]">
            <Icon src="89d81.svg" />
          </div>
        </div>
        <p className="font-inter font-bold text-[18px] text-[#130f26] text-center">Save more, earn more</p>
        <p className="font-inter font-medium text-[13px] leading-[1.5] text-[#6d7d9c] text-center">
          RexVault customers earn {REXVAULT.pointsMultiplier}× {REWARDS.pointsName}, a higher daily limit
          {REXVAULT.cashRedemptionVaultOnly ? ' and can redeem for cash' : ''}. Keep an active RexVault savings plan to qualify.
        </p>
        <div className="flex flex-col gap-[7px] mt-[6px]">
          <PrimaryButtonLite
            dark
            onClick={() => {
              setVault(true);
              onClose();
            }}
          >
            Start saving in RexVault
          </PrimaryButtonLite>
          <PrimaryButtonLite onClick={onClose}>Maybe later</PrimaryButtonLite>
        </div>
        <p className="font-inter font-medium text-[10px] text-[#a0a3bd] text-center">Prototype: tapping “Start saving” marks you as a RexVault customer.</p>
      </div>
    </>
  );
}

function PrimaryButtonLite({ dark, children, onClick }) {
  return (
    <button
      onClick={onClick}
      className={`${dark ? 'bg-[#002766] text-white' : 'bg-[#d1e3ff] text-[#001f52]'} w-full rounded-[12px] py-[16px] font-inter font-semibold text-[14px] cursor-pointer active:scale-[.98] transition-transform`}
    >
      {children}
    </button>
  );
}

export default function Rewards({ go, back, coins }) {
  const { plays, earnedToday, dailyCap, addDemoPoints } = useStore();
  const [vaultSheet, setVaultSheet] = useState(false);
  const earned = plays.reduce((n, p) => n + p.points, 0);
  const bestRank = plays.filter((p) => p.rank).reduce((m, p) => Math.min(m, p.rank), Infinity);
  const P = REWARDS.pointsName;

  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <StatusBar />
      <TitleBlock title="Your RexPlay Rewards" subtitle="Play. Learn. Earn RexPoints." coins={coins} />
      <BackButton onClick={back} />

      <div className="absolute inset-x-0 top-[145px] bottom-0 overflow-y-auto overscroll-contain [scrollbar-width:none]">
        <div className="mx-auto translate-x-[0.5px] w-[363px] flex flex-col gap-[14px] pb-[28px]">
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

          {/* Today's earning limit */}
          <div className="bg-white rounded-[10px] p-[14px] flex flex-col gap-[8px]">
            <div className="flex justify-between items-baseline">
              <p className="font-inter font-bold text-[13px] text-[#130f26]">Earned today</p>
              <p className="font-inter font-semibold text-[12px] text-[#002766]">
                {formatPoints(earnedToday)} / {formatPoints(dailyCap)} {P}
              </p>
            </div>
            <div className="h-[8px] rounded-full bg-[#eff2fe] overflow-hidden">
              <div className="h-full rounded-full bg-[#2c6ef2] transition-[width] duration-500" style={{ width: `${Math.min(100, (earnedToday / dailyCap) * 100)}%` }} />
            </div>
            <p className="font-inter font-medium text-[10px] text-[#6d7d9c]">
              {earnedToday >= dailyCap ? 'Daily limit reached — you can still play for the leaderboard.' : 'Daily limit resets at midnight.'}
            </p>
          </div>

          <VaultCard onOpen={() => setVaultSheet(true)} />

          {DEMO.tools && (
            <button
              onClick={() => addDemoPoints(DEMO.bonusPoints)}
              className="self-start font-inter font-medium text-[10px] text-[#6d7d9c] underline cursor-pointer -mt-[6px]"
            >
              Demo: add {formatPoints(DEMO.bonusPoints)} {P} (prototype only)
            </button>
          )}

          <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[14px] mt-[4px]">Your Stats</p>
          <div className="flex gap-[6px] h-[112px] items-center w-full shrink-0">
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
            <Stat label={`Total ${P}`} value={formatPoints(earned)} icon={<Coin size={29} className="!absolute left-[43px] top-[16px]" />} />
          </div>

          <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[14px] mt-[4px]">Recent Games</p>
          <div className="flex flex-col gap-[5px] w-full">
            {plays.length === 0 ? (
              <div className="bg-white rounded-[10px] w-full p-[20px] flex flex-col items-center gap-[10px] text-center">
                <p className="font-inter font-semibold text-[12px] text-[#130f26]">No games yet</p>
                <p className="font-inter font-medium text-[11px] text-[#6d7d9c]">Play a RexPlay game to start earning {P}.</p>
                <button onClick={() => go('rexplay')} className="bg-[#002766] text-white rounded-[8px] px-[16px] py-[9px] font-inter font-semibold text-[11px] cursor-pointer">
                  Play Now
                </button>
              </div>
            ) : (
              plays.map((p) => <RecentGame key={p.at} game={gameById(p.gameId)} play={p} />)
            )}
          </div>
        </div>
      </div>
      {vaultSheet && <VaultSheet onClose={() => setVaultSheet(false)} />}
    </div>
  );
}
