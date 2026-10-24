import { useState } from 'react';
import StatusBar from './StatusBar.jsx';
import { BackButton, CoinPill, Icon } from './parts.jsx';
import { asset as a } from '../asset.js';
import { gameById, leaderboard, GAMES } from '../games.jsx';
import { useStore } from '../store.jsx';

// Figma: "rex play" › Rexplay (24453:39999) — Leaderboard.
export const FIGMA_ASSETS = 'https://www.figma.com/api/mcp/asset/78ba60de-822e-4764-9c38-43e6cf418a02';

export const LIGHT_ON_BLUE_STATUS = { color: '#f1f5ff', files: { location: '0c7fa.svg', wifi: '4c360.svg', battery: 'f9b68.svg' } };


// Medal art for the top three, positioned as in Figma.
const MEDALS = {
  1: { bg: '#fff4e3', file: '28f2f.svg', box: 'left-[-5px] top-[-15px]', inset: 'inset-[0_13.98%]' },
  2: { bg: '#eff2fe', file: '6c829.svg', box: '-translate-x-1/2 bottom-[5px] left-1/2', inset: 'inset-[0_14%]' },
  3: { bg: '#f4ecff', file: '6467e.svg', box: '-translate-x-1/2 bottom-[6px] left-1/2', inset: 'inset-[0_13.98%]' },
};

function Points({ value }) {
  return (
    <div className="flex gap-[5px] items-center justify-center p-[10px] relative shrink-0">
      <div className="relative shrink-0 size-[18px]">
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <img alt="" className="absolute left-[2.07%] max-w-none size-[99.04%] top-0" src={a('2a1e3.png')} />
        </div>
      </div>
      <p className="font-inter font-semibold leading-[normal] text-[#130f26] text-[14px] whitespace-nowrap">{value}</p>
    </div>
  );
}

function Avatar({ file, photo }) {
  return (
    <div className={`relative shrink-0 size-[26px] ${photo ? 'rounded-[20px]' : ''}`}>
      {photo ? (
        <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[20px] size-full" src={a(file)} />
      ) : (
        <Icon src={file} />
      )}
    </div>
  );
}

function Row({ rank, name, points, file, photo, last, you }) {
  const medal = MEDALS[rank];
  const rankWidth = rank >= 11 ? 'w-[30px]' : 'w-[46px]';
  return (
    <div
      className={`flex gap-[12px] items-center relative shrink-0 w-full ${
        medal || you ? 'rounded-[10px]' : last ? '' : 'border-[#f6f6f6] border-b border-solid'
      }`}
      style={{ background: medal ? medal.bg : you ? '#f1f5ff' : undefined }}
    >
      {medal ? (
        <div className="flex flex-col items-center justify-center p-[10px] relative shrink-0">
          <div className="bg-white overflow-clip relative rounded-[20px] shrink-0 size-[26px]">
            <div className={`absolute overflow-clip size-[36px] ${medal.box}`}>
              <div className={`absolute ${medal.inset}`}>
                <Icon src={medal.file} />
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className={`flex flex-col ${rank === 10 ? 'items-start' : 'items-center'} justify-center p-[10px] relative shrink-0 ${rankWidth}`}>
          <p className={`font-inter font-semibold leading-[normal] text-[#130f26] text-[14px] ${rank >= 10 ? 'w-[17px]' : 'w-full'}`}>{rank}</p>
        </div>
      )}
      <div className="flex flex-[1_0_0] gap-[10px] items-center min-w-px p-[10px] relative">
        <Avatar file={file} photo={photo} />
        <p className="font-inter font-semibold leading-[normal] text-[#130f26] text-[14px] whitespace-nowrap">{name}</p>
      </div>
      <Points value={points} />
    </div>
  );
}

export default function Leaderboard({ go, back, coins, param }) {
  const { plays } = useStore();
  const game = gameById(param) || GAMES[0];
  // Your best result in this game (0 if you haven't played it yet).
  const best = plays.filter((p) => p.gameId === game.id).reduce((m, p) => Math.max(m, p.points), 0);
  const board = leaderboard(game, best).rows;
  const [tab, setTab] = useState('All Players');
  const rows = board.filter((r) => tab === 'All Players' || r.rank <= 10);
  const top = rows.filter((r) => r.rank <= 3);
  const rest = rows.filter((r) => r.rank > 3);

  return (
    <div className="overflow-clip relative size-full bg-[#063179]">
      <div className="absolute left-[calc(25%+24.5px)] size-[309px] top-[-46px]">
        <div className="absolute inset-[-54.34%]">
          <img alt="" className="block max-w-none size-full" src={a('18522.svg')} />
        </div>
      </div>
      <StatusBar {...LIGHT_ON_BLUE_STATUS} />

      <div className="-translate-x-1/2 absolute flex flex-col gap-px items-start justify-center left-[calc(50%+0.5px)] top-[89px] w-[359px]">
        <p className="font-inter font-bold leading-[1.3] text-[#f1f5ff] text-[20px] whitespace-nowrap">Leaderboard</p>
        <p className="font-inter font-medium leading-[normal] text-[#8f9bb3] text-[12px] w-[260px]">{game.title}</p>
        <CoinPill coins={coins} onClick={() => go('rewards')} className="shadow-none min-w-[66px]" />
      </div>
      <BackButton onClick={back} file="e15be.svg" />

      <div className="-translate-x-1/2 absolute bg-white bottom-0 left-1/2 overflow-clip rounded-t-[23px] top-[164px] w-[402px]">
        <div className="-translate-x-1/2 absolute flex gap-[6px] items-center left-[calc(50%+0.5px)] top-[15px] w-[363px]">
          {['All Players', 'Top 10'].map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`${tab === t ? 'bg-[#002766] text-white' : 'bg-[#f1f5ff] text-[#002766]'} cursor-pointer flex flex-[1_0_0] items-center justify-center min-w-px p-[10px] relative rounded-[9px] transition-colors`}
            >
              <p className="font-inter font-semibold leading-[normal] text-[12px] whitespace-nowrap">{t}</p>
            </button>
          ))}
        </div>

        <div className="-translate-x-1/2 absolute flex flex-col gap-[7px] bottom-0 items-start left-[calc(50%+0.5px)] overflow-y-auto overscroll-contain top-[63px] w-[363px] pb-[24px] [scrollbar-width:none]">
          <div className="bg-[#f1f5ff] flex gap-[12px] items-center relative rounded-[10px] shrink-0 w-full">
            <div className="flex flex-col items-center justify-center p-[10px] relative shrink-0">
              <p className="font-inter font-semibold leading-[normal] text-[#002766] text-[12px] w-full">#</p>
            </div>
            <div className="flex items-center pl-[28px] pr-[10px] py-[10px] relative shrink-0 w-[250px]">
              <p className="font-inter font-semibold leading-[normal] text-[#002766] text-[12px] whitespace-nowrap">Player</p>
            </div>
            <div className="flex items-center justify-center p-[10px] relative shrink-0 w-[55px]">
              <p className="font-inter font-semibold leading-[normal] text-[#002766] text-[12px] whitespace-nowrap">Points</p>
            </div>
          </div>
          <div className="flex flex-col gap-[7px] items-start relative shrink-0 w-full">
            {top.map((r) => (
              <Row key={r.name} {...r} />
            ))}
          </div>
          <div className="flex flex-col gap-[15px] items-start relative shrink-0 w-full">
            {rest.map((r, i) => (
              <Row key={r.name} {...r} last={i === rest.length - 1 || rest[i + 1].you || r.you} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
