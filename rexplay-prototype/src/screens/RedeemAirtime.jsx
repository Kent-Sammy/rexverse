import { useState } from 'react';
import StatusBar from './StatusBar.jsx';
import { BackButton, TitleBlock } from './parts.jsx';
import { PrimaryButton } from './GameResults.jsx';
import { Coin } from './Rewards.jsx';
import { asset as a } from '../asset.js';

// Figma: "rex play" › Rexplay — Redeem Airtime: empty (24454:41329), filled (24454:41509),
// success sheet (24454:41612).
export const FIGMA_ASSETS = [
  'https://www.figma.com/api/mcp/asset/45154cf3-7104-41e9-9bfc-ca07bf9390c5',
  'https://www.figma.com/api/mcp/asset/c6bdb3ab-a268-4c16-a38b-f7f9f4d3f9d6',
  'https://www.figma.com/api/mcp/asset/60368927-2c9b-4be1-8b09-992bab96bd70',
];

const AMOUNTS = [100, 200, 500, 1000, 2000, 5000];

function BalanceCard({ coins }) {
  return (
    <div className="-translate-x-1/2 absolute flex flex-col items-start left-[calc(50%+0.5px)] top-[145px] w-[363px]">
      <div className="bg-gradient-to-r from-[#002766] to-[#004ecc] h-[85px] overflow-clip relative rounded-[8px] shrink-0 w-full">
        <div className="-translate-y-1/2 absolute flex flex-col gap-[7px] items-start justify-center left-[16px] top-1/2 w-[179px]">
          <p className="font-inter font-medium h-[16px] leading-[1.5] overflow-hidden text-[#f1f5ff] text-[12px] tracking-[-0.24px] w-full whitespace-nowrap">
            Your Balance
          </p>
          <div className="flex h-[22px] items-center relative shrink-0 w-full">
            <p className="font-inter font-bold leading-[1.256] text-[#f1f5ff] text-[20px] tracking-[-0.8px] whitespace-nowrap">{coins} Points</p>
          </div>
        </div>
        <Coin size={76} className="!absolute -translate-y-1/2 left-[262px] top-[calc(50%+0.5px)]" />
      </div>
    </div>
  );
}

function AmountTile({ pts, selected, onClick }) {
  return (
    <button
      onClick={onClick}
      className={`flex-[1_0_0] h-full min-w-px overflow-clip relative rounded-[11px] cursor-pointer border border-solid transition-colors ${
        selected ? 'bg-[#e4ecff] border-[#5395ff]' : 'bg-white border-transparent'
      }`}
    >
      <div className="-translate-y-1/2 absolute flex flex-col gap-[13px] items-center left-[27px] top-[calc(50%+0.5px)] w-[61px]">
        <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[14px] whitespace-nowrap">{pts}pts</p>
        <p
          className={`font-inter font-medium text-[10px] text-center tracking-[-0.2px] whitespace-nowrap leading-[1.5] ${
            selected ? 'text-[#2c6ef2]' : 'text-[#6d7d9c]'
          }`}
        >
          <span className="font-bold">₦</span>
          {pts} Airtime
        </p>
      </div>
    </button>
  );
}

function SuccessSheet({ amount, phone, onHome, onHistory }) {
  const rows = [
    ['Phone Number', phone || '080312233455'],
    ['Point Used', `-${amount} pts`],
    ['Reference', 'RXP-2026406349-1234'],
    ['Transaction Date', 'Oct 17th, 2026 13:38:31'],
  ];
  return (
    <>
      <div className="-translate-x-1/2 -translate-y-1/2 absolute bg-[rgba(10,13,31,0.75)] h-[919px] left-[calc(50%+0.5px)] top-[calc(50%+0.5px)] w-[453px] z-20 animate-[fade_.2s_ease-out]" />
      <div className="absolute bg-white bottom-0 h-[594px] left-0 overflow-clip rounded-tl-[30px] rounded-tr-[30px] w-[402px] z-30 animate-[sheet-up_.3s_ease-out]">
        <div className="-translate-x-1/2 absolute flex flex-col gap-[26px] items-center left-[calc(50%+0.5px)] top-[37px] w-[335px]">
          <div className="flex flex-col gap-[13px] items-center relative shrink-0 w-[297px]">
            <div className="h-[125px] relative shrink-0 w-[134px] animate-[pop-in_.5s_ease-out]">
              <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <img alt="" className="absolute h-[126.48%] left-[-6.27%] max-w-none top-[-10.28%] w-[118.08%]" src={a('40be3.png')} />
              </div>
            </div>
            <div className="flex flex-col gap-[11px] items-center relative shrink-0 w-full">
              <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[18px] whitespace-nowrap">Airtime Sent!</p>
              <p className="font-inter font-medium leading-[20px] text-[#8491ab] text-[14px] text-center w-[297px]">
                You’ve successfully redeemed {amount}pts for <span className="font-bold">₦</span>
                {amount} airtime
              </p>
            </div>
          </div>
          <div className="bg-[#f1f5ff] flex flex-col items-start p-[20px] relative rounded-[10px] shrink-0 w-full">
            <div className="flex flex-col font-inter font-medium gap-[14px] items-start text-[12px] w-full">
              {rows.map(([k, v]) => (
                <div key={k} className="flex items-center justify-between relative shrink-0 w-full whitespace-nowrap">
                  <p className="leading-[1.2] text-[#6e768b]">{k}</p>
                  <p className="leading-[1.6] text-[#1f1f1f]">{v}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
        <div className="-translate-x-1/2 absolute flex flex-col gap-[7px] items-center left-[calc(50%+0.5px)] top-[444px] w-[335px]">
          <PrimaryButton onClick={onHome}>Back to My RexPlay</PrimaryButton>
          <PrimaryButton light onClick={onHistory}>
            View My Rewards History
          </PrimaryButton>
        </div>
      </div>
    </>
  );
}

export default function RedeemAirtime({ go, back, coins }) {
  const [amount, setAmount] = useState(null);
  const [custom, setCustom] = useState('');
  const [phone, setPhone] = useState('');
  const [done, setDone] = useState(false);

  const pts = custom ? Number(custom) : amount;
  const ready = pts > 0 && phone.replace(/\D/g, '').length >= 10;

  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <StatusBar />
      <TitleBlock title="Redeem Airtime" subtitle="Convert your points to airtime, data, or cash" subtitleWidth={259} />
      <BackButton onClick={back} />
      <BalanceCard coins={coins} />

      <p className="-translate-y-1/2 absolute font-inter font-bold leading-[normal] left-[20px] text-[#130f26] text-[14px] top-[252.5px] whitespace-nowrap">Select Amount</p>
      {[AMOUNTS.slice(0, 3), AMOUNTS.slice(3)].map((row, i) => (
        <div
          key={i}
          className="-translate-x-1/2 absolute flex gap-[6px] h-[84px] items-center left-[calc(50%+0.5px)] w-[363px]"
          style={{ top: i === 0 ? 275 : 366 }}
        >
          {row.map((p) => (
            <AmountTile
              key={p}
              pts={p}
              selected={!custom && amount === p}
              onClick={() => {
                setAmount(p);
                setCustom('');
              }}
            />
          ))}
        </div>
      ))}

      {/* Custom amount */}
      <label className="absolute bg-white h-[48px] left-[20px] overflow-clip rounded-[11px] top-[470px] w-[360px] cursor-text">
        <input
          inputMode="numeric"
          value={custom}
          onChange={(e) => setCustom(e.target.value.replace(/\D/g, '').slice(0, 6))}
          placeholder="Custom Amount"
          className="absolute left-[25px] top-0 h-full w-[260px] bg-transparent outline-none font-inter font-semibold text-[14px] tracking-[-0.28px] text-[#130f26] placeholder:text-[#6d7d9c]"
        />
        <div className="-translate-y-1/2 absolute border-[#d7d7d7] border-l border-solid flex font-inter font-bold gap-[3px] items-center justify-end left-[297px] text-[#6d7d9c] text-[14px] text-center top-[calc(50%+0.5px)] tracking-[-0.28px] w-[48px] whitespace-nowrap leading-[1.5]">
          <span>{custom || 0}</span>
          <span>Pts</span>
        </div>
      </label>

      <p className="-translate-y-1/2 absolute font-inter font-bold leading-[normal] left-[20px] text-[#130f26] text-[14px] top-[546.5px] whitespace-nowrap">Phone Number</p>
      <label className="absolute bg-white h-[48px] left-[20px] overflow-clip rounded-[11px] top-[569px] w-[360px] cursor-text">
        <input
          type="tel"
          inputMode="tel"
          value={phone}
          onChange={(e) => setPhone(e.target.value.replace(/[^\d+]/g, '').slice(0, 14))}
          placeholder="Enter Phone Number"
          className="absolute left-[67px] top-0 h-full w-[280px] bg-transparent outline-none font-inter font-semibold text-[14px] tracking-[-0.28px] text-[#130f26] placeholder:text-[#6d7d9c]"
        />
        <div className="-translate-y-1/2 absolute border-[#d7d7d7] border-r border-solid flex items-center left-[13px] top-1/2 w-[44px] pointer-events-none">
          <div className="flex gap-[4px] items-center relative shrink-0">
            <div className="h-[20px] relative rounded-[18.667px] shrink-0 w-[19px]">
              <div className="absolute inset-0 overflow-hidden pointer-events-none rounded-[18.667px]">
                <img alt="" className="absolute h-full left-[-38.89%] max-w-none top-0 w-[177.78%]" src={a('82161.png')} />
              </div>
            </div>
            <div className="relative shrink-0 size-[16px]">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={a('5d5f2.svg')} />
            </div>
          </div>
        </div>
      </label>

      <div className="-translate-x-1/2 absolute left-[calc(50%+0.5px)] top-[771px] w-[351px]">
        <PrimaryButton onClick={() => (ready ? setDone(true) : null)}>
          {pts ? `Redeem Now (${pts}pts)` : 'Redeem Now'}
        </PrimaryButton>
      </div>

      {done && <SuccessSheet amount={pts} phone={phone} onHome={() => go('rexplay', { reset: true })} onHistory={() => go('history')} />}
    </div>
  );
}
