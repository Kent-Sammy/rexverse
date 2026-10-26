import { useState } from 'react';
import StatusBar from './StatusBar.jsx';
import { BackButton, Icon, TextLink } from './parts.jsx';
import { formatDate, formatPoints, useStore } from '../store.jsx';

// Figma: "rex play" › Rexplay — Rewards History (24454:41759)
export const FIGMA_ASSETS = 'https://www.figma.com/api/mcp/asset/c967710b-e384-446e-a3b7-dfec4338ebb2';

const TABS = ['All', 'Cash', 'Airtime', 'Data'];

const ICONS = {
  Cash: (
    <div className="bg-[rgba(255,152,0,0.08)] overflow-clip relative rounded-[9.882px] shrink-0 size-[42px]">
      <div className="-translate-x-1/2 -translate-y-1/2 absolute left-[calc(50%+0.5px)] size-[21px] top-1/2">
        <Icon src="a5ab2.svg" />
      </div>
    </div>
  ),
  Data: (
    <div className="bg-[rgba(51,94,247,0.08)] overflow-clip relative rounded-[9.059px] shrink-0 size-[44px]">
      <div className="-translate-x-1/2 -translate-y-1/2 absolute left-[calc(50%+0.65px)] size-[22px] top-[calc(50%+0.65px)]">
        <Icon src="708b3.svg" />
        <div className="absolute inset-[8.33%_8.37%_8.38%_8.33%]">
          <Icon src="92b69.svg" />
        </div>
        <div className="absolute inset-[29.57%_21.87%_55.37%_21.9%]">
          <Icon src="33ce7.svg" />
        </div>
        <div className="absolute inset-[44.79%_28.58%_42.5%_28.52%]">
          <Icon src="503d6.svg" />
        </div>
        <div className="absolute inset-[60.95%_37.74%_29.63%_37.69%]">
          <Icon src="432bd.svg" />
        </div>
      </div>
    </div>
  ),
  Airtime: (
    <div className="bg-[rgba(0,188,212,0.08)] overflow-clip relative rounded-[8.647px] shrink-0 size-[42px]">
      <div className="-translate-x-1/2 -translate-y-1/2 absolute left-[calc(50%+0.62px)] size-[21px] top-[calc(50%+0.62px)]">
        <div className="absolute inset-[8.33%_8.33%_55.72%_55.82%]">
          <Icon src="0743b.svg" />
        </div>
        <div className="absolute inset-[12.5%_12.5%_8.33%_8.33%]">
          <Icon src="c7196.svg" />
        </div>
      </div>
    </div>
  ),
};

const TITLES = { Cash: 'Cash Reward', Data: 'Data Bundle', Airtime: 'Airtime' };
const KIND = { cash: 'Cash', data: 'Data', airtime: 'Airtime' };

const BADGE = {
  success: { label: 'Successful', bg: 'bg-[#f1f9f1]', fg: 'text-[#008f18]' },
  pending: { label: 'Pending', bg: 'bg-[#fff6e5]', fg: 'text-[#b26b00]' },
  failed: { label: 'Failed', bg: 'bg-[#ffeef0]', fg: 'text-[#c62b3b]' },
};

function HistoryItem({ kind, title, detail, points, at, status = 'success' }) {
  const b = BADGE[status];
  return (
    <div className="bg-white h-[80.333px] overflow-clip relative rounded-[11px] shrink-0 w-full">
      <div className="-translate-x-1/2 -translate-y-1/2 absolute flex items-center justify-between left-[calc(50%+0.5px)] top-[calc(50%-0.17px)] w-[324px]">
        <div className="flex gap-[15px] items-start relative shrink-0">
          {ICONS[kind]}
          <div className="flex flex-col gap-[3px] items-start relative shrink-0 w-[143px]">
            <div className="flex flex-col gap-px items-start relative shrink-0 w-full">
              <p className="font-inter font-semibold leading-[normal] text-[#130f26] text-[11px] whitespace-nowrap">{title}</p>
              <p className="font-inter font-medium leading-[1.5] min-w-full text-[#6d7d9c] text-[10px] tracking-[-0.2px] w-min">{detail}</p>
            </div>
            <p className="font-inter font-medium leading-[1.5] text-[#6d7d9c] text-[10px] tracking-[-0.2px] w-full">{formatDate(at)}</p>
          </div>
        </div>
        <div className="flex flex-col gap-[7px] items-start justify-center relative shrink-0">
          <p
            className={`font-inter font-semibold leading-[1.5] min-w-full text-[12px] text-right tracking-[-0.24px] w-min whitespace-nowrap ${status === 'failed' ? 'text-[#a0a3bd] line-through' : 'text-[red]'}`}
          >
            -{formatPoints(points)} pts
          </p>
          <div className={`flex h-[20px] items-center justify-center px-[10px] relative rounded-[20px] shrink-0 self-end ${b.bg}`}>
            <p className={`font-inter font-medium leading-[1.5] text-[10px] tracking-[-0.2px] whitespace-nowrap ${b.fg}`}>{b.label}</p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function RewardsHistory({ back, go }) {
  const { redemptions } = useStore();
  const [tab, setTab] = useState('All');
  const items = redemptions
    .map((r) => ({ ...r, kind: KIND[r.kind], title: TITLES[KIND[r.kind]] }))
    .filter((i) => tab === 'All' || i.kind === tab);
  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <StatusBar />
      <div className="-translate-x-1/2 absolute flex flex-col gap-px items-start justify-center left-[calc(50%-1.5px)] top-[89px] w-[359px]">
        <p className="font-inter font-bold leading-[1.3] text-[#002766] text-[20px] whitespace-nowrap">Rewards History</p>
        <p className="font-inter font-medium leading-[normal] text-[#8f9bb3] text-[12px] w-[259px]">Your RexPoints redemptions</p>
      </div>
      <div className="-translate-x-[2px]">
        <BackButton onClick={back} />
      </div>

      <div className="-translate-x-1/2 absolute flex gap-[6px] items-center left-[calc(50%+0.5px)] top-[150px] w-[363px]">
        {TABS.map((t, i) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={`bg-white border border-solid ${tab === t ? 'border-[#639fff]' : 'border-0'} cursor-pointer flex items-center justify-center p-[10px] relative rounded-[6px] ${
              i === 0 ? 'shrink-0 w-[51px]' : 'flex-[1_0_0] min-w-px'
            }`}
          >
            <p className="font-inter font-semibold leading-[normal] text-[#002766] text-[10px] whitespace-nowrap">{t}</p>
          </button>
        ))}
      </div>

      <div className="absolute flex flex-col gap-[7px] items-start left-[20px] top-[195px] bottom-0 overflow-y-auto pb-[24px] w-[363px] [scrollbar-width:none]">
        {items.map((it) => (
          <HistoryItem key={it.reference} {...it} />
        ))}
        {items.length === 0 && (
          <div className="bg-white rounded-[11px] w-full p-[24px] flex flex-col items-center gap-[10px] text-center">
            <p className="font-inter font-semibold text-[13px] text-[#130f26]">No redemptions yet</p>
            <p className="font-inter font-medium text-[11px] text-[#6d7d9c]">Turn your RexPoints into airtime, data or cash.</p>
            <TextLink accent onClick={() => go('redeem')}>
              Redeem RexPoints
            </TextLink>
          </div>
        )}
      </div>
    </div>
  );
}
