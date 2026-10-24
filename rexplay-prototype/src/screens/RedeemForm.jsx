import { useEffect, useState } from 'react';
import StatusBar from './StatusBar.jsx';
import { BackButton, TitleBlock } from './parts.jsx';
import { PrimaryButton } from './GameResults.jsx';
import { Coin } from './Rewards.jsx';
import { asset as a } from '../asset.js';
import { formatPoints, useStore } from '../store.jsx';

// Redeem Airtime / Data / Cash. Airtime follows the Figma frames 24454:41329, 24454:41509
// and 24454:41612; Data and Cash reuse the same layout and success sheet.
export const FIGMA_ASSETS = [
  'https://www.figma.com/api/mcp/asset/45154cf3-7104-41e9-9bfc-ca07bf9390c5',
  'https://www.figma.com/api/mcp/asset/c6bdb3ab-a268-4c16-a38b-f7f9f4d3f9d6',
  'https://www.figma.com/api/mcp/asset/60368927-2c9b-4be1-8b09-992bab96bd70',
];

const POINTS = [100, 200, 500, 1000, 2000, 5000];
const DATA = {
  100: ['110MB', '1 day'],
  200: ['350MB', '2 days'],
  500: ['1GB', '7 days'],
  1000: ['2.5GB', '30 days'],
  2000: ['6GB', '30 days'],
  5000: ['20GB', '30 days'],
};
const naira = (n) => `₦${formatPoints(n)}`;

const KINDS = {
  airtime: { title: 'Redeem Airtime', sent: 'Airtime Sent!', tile: (p) => [<b key="n">₦</b>, `${p} Airtime`], custom: true },
  data: { title: 'Redeem Data', sent: 'Data Sent!', tile: (p) => `${DATA[p][0]} · ${DATA[p][1]}`, custom: false },
  cash: { title: 'Redeem Cash', sent: 'Cash Sent!', tile: (p) => [<b key="n">₦</b>, `${p} Cash`], custom: true },
};

const NETWORKS = {
  MTN: { color: '#ffcb05', prefixes: ['0803', '0806', '0703', '0706', '0813', '0816', '0810', '0814', '0903', '0906', '0913', '0916', '0704'] },
  Airtel: { color: '#e40000', prefixes: ['0802', '0808', '0708', '0812', '0701', '0902', '0901', '0904', '0907', '0912'] },
  Glo: { color: '#50b651', prefixes: ['0805', '0807', '0705', '0815', '0811', '0905', '0915'] },
  '9mobile': { color: '#006d52', prefixes: ['0809', '0817', '0818', '0909', '0908'] },
};
const detectNetwork = (phone) => Object.keys(NETWORKS).find((n) => NETWORKS[n].prefixes.includes(phone.slice(0, 4)));

const BANKS = ['Access Bank', 'First Bank', 'GTBank', 'Kuda', 'Moniepoint', 'OPay', 'UBA', 'Zenith Bank'];
const WALLET = { name: 'Ololade Mr. Money', number: '11028281921' };

function BalanceCard({ coins }) {
  return (
    <div className="-translate-x-1/2 absolute flex flex-col items-start left-[calc(50%+0.5px)] top-[145px] w-[363px]">
      <div className="bg-gradient-to-r from-[#002766] to-[#004ecc] h-[85px] overflow-clip relative rounded-[8px] shrink-0 w-full">
        <div className="-translate-y-1/2 absolute flex flex-col gap-[7px] items-start justify-center left-[16px] top-1/2 w-[179px]">
          <p className="font-inter font-medium h-[16px] leading-[1.5] overflow-hidden text-[#f1f5ff] text-[12px] tracking-[-0.24px] w-full whitespace-nowrap">
            Your Balance
          </p>
          <div className="flex h-[22px] items-center relative shrink-0 w-full">
            <p className="font-inter font-bold leading-[1.256] text-[#f1f5ff] text-[20px] tracking-[-0.8px] whitespace-nowrap">{formatPoints(coins)} Points</p>
          </div>
        </div>
        <Coin size={76} className="!absolute -translate-y-1/2 left-[262px] top-[calc(50%+0.5px)]" />
      </div>
    </div>
  );
}

function AmountTile({ pts, sub, selected, disabled, onClick }) {
  return (
    <button
      onClick={onClick}
      className={`flex-[1_0_0] h-full min-w-px overflow-clip relative rounded-[11px] cursor-pointer border border-solid transition-colors ${
        selected ? 'bg-[#e4ecff] border-[#5395ff]' : 'bg-white border-transparent'
      } ${disabled && !selected ? 'opacity-50' : ''}`}
    >
      <div className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[13px] items-center left-1/2 top-[calc(50%+0.5px)] w-[110px]">
        <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[14px] whitespace-nowrap">{pts}pts</p>
        <p className={`font-inter font-medium text-[10px] text-center tracking-[-0.2px] whitespace-nowrap leading-[1.5] ${selected ? 'text-[#2c6ef2]' : 'text-[#6d7d9c]'}`}>
          {sub}
        </p>
      </div>
    </button>
  );
}

function Label({ top, children }) {
  return (
    <p className="-translate-y-1/2 absolute font-inter font-bold leading-[normal] left-[20px] text-[#130f26] text-[14px] whitespace-nowrap" style={{ top }}>
      {children}
    </p>
  );
}

function NetworkBadge({ network }) {
  if (network === 'MTN' || !network) {
    return (
      <div className="h-[20px] relative rounded-[18.667px] shrink-0 w-[19px]">
        <div className="absolute inset-0 overflow-hidden pointer-events-none rounded-[18.667px]">
          <img alt="" className="absolute h-full left-[-38.89%] max-w-none top-0 w-[177.78%]" src={a('82161.png')} />
        </div>
      </div>
    );
  }
  return (
    <div className="size-[20px] rounded-full shrink-0 flex items-center justify-center font-inter font-bold text-[9px] text-white" style={{ background: NETWORKS[network].color }}>
      {network[0]}
    </div>
  );
}

function PhoneField({ top, phone, setPhone, network, setNetwork }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="absolute left-[20px] w-[360px]" style={{ top }}>
      <label className="block relative bg-white h-[48px] overflow-clip rounded-[11px] cursor-text">
        <input
          type="tel"
          inputMode="tel"
          value={phone}
          onChange={(e) => {
            const v = e.target.value.replace(/\D/g, '').slice(0, 11);
            setPhone(v);
            const n = detectNetwork(v);
            if (n) setNetwork(n);
          }}
          placeholder="Enter Phone Number"
          className="absolute left-[67px] top-0 h-full w-[280px] bg-transparent outline-none font-inter font-semibold text-[14px] tracking-[-0.28px] text-[#130f26] placeholder:text-[#6d7d9c]"
        />
        <button
          type="button"
          onClick={() => setOpen(!open)}
          className="-translate-y-1/2 absolute border-[#d7d7d7] border-r border-solid flex items-center left-[13px] top-1/2 w-[44px] cursor-pointer"
          aria-label="Choose network"
        >
          <div className="flex gap-[4px] items-center relative shrink-0">
            <NetworkBadge network={network} />
            <div className="relative shrink-0 size-[16px]">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={a('5d5f2.svg')} />
            </div>
          </div>
        </button>
      </label>
      {open && (
        <div className="absolute z-10 left-0 top-[52px] w-[180px] bg-white rounded-[11px] shadow-[0_8px_30px_rgba(0,39,102,0.18)] p-[6px] animate-[fade_.15s_ease-out]">
          {Object.keys(NETWORKS).map((n) => (
            <button
              key={n}
              onClick={() => {
                setNetwork(n);
                setOpen(false);
              }}
              className={`w-full flex items-center gap-[10px] px-[10px] py-[9px] rounded-[8px] cursor-pointer ${n === network ? 'bg-[#f1f5ff]' : ''}`}
            >
              <NetworkBadge network={n} />
              <span className="font-inter font-semibold text-[13px] text-[#130f26]">{n}</span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

function CashDestination({ top, dest, setDest, bank, setBank, account, setAccount }) {
  const [banksOpen, setBanksOpen] = useState(false);
  const [resolved, setResolved] = useState(false);
  useEffect(() => {
    setResolved(false);
    if (account.length !== 10 || !bank) return undefined;
    const t = setTimeout(() => setResolved(true), 600);
    return () => clearTimeout(t);
  }, [account, bank]);

  const Choice = ({ id, title, sub }) => (
    <button
      onClick={() => setDest(id)}
      className={`flex-1 rounded-[11px] border border-solid px-[14px] py-[10px] text-left cursor-pointer ${dest === id ? 'bg-[#e4ecff] border-[#5395ff]' : 'bg-white border-transparent'}`}
    >
      <p className="font-inter font-semibold text-[13px] text-[#130f26]">{title}</p>
      <p className={`font-inter font-medium text-[10px] ${dest === id ? 'text-[#2c6ef2]' : 'text-[#6d7d9c]'}`}>{sub}</p>
    </button>
  );

  return (
    <div className="absolute left-[20px] w-[360px] flex flex-col gap-[6px]" style={{ top }}>
      <div className="flex gap-[6px]">
        <Choice id="wallet" title="Rex Wallet" sub={`${WALLET.number} · Instant`} />
        <Choice id="bank" title="Bank Account" sub="Any Nigerian bank" />
      </div>
      {dest === 'bank' && (
        <>
          <div className="relative">
            <button
              onClick={() => setBanksOpen(!banksOpen)}
              className="w-full bg-white h-[42px] rounded-[11px] px-[16px] flex items-center justify-between cursor-pointer"
            >
              <span className={`font-inter font-semibold text-[14px] ${bank ? 'text-[#130f26]' : 'text-[#6d7d9c]'}`}>{bank || 'Select Bank'}</span>
              <span className="relative size-[16px]">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={a('5d5f2.svg')} />
              </span>
            </button>
            {banksOpen && (
              <div className="absolute z-10 left-0 right-0 bottom-[46px] max-h-[220px] overflow-y-auto bg-white rounded-[11px] shadow-[0_8px_30px_rgba(0,39,102,0.18)] p-[6px] animate-[fade_.15s_ease-out]">
                {BANKS.map((b) => (
                  <button
                    key={b}
                    onClick={() => {
                      setBank(b);
                      setBanksOpen(false);
                    }}
                    className={`w-full text-left px-[12px] py-[10px] rounded-[8px] font-inter font-semibold text-[13px] text-[#130f26] cursor-pointer ${b === bank ? 'bg-[#f1f5ff]' : ''}`}
                  >
                    {b}
                  </button>
                ))}
              </div>
            )}
          </div>
          <input
            inputMode="numeric"
            value={account}
            onChange={(e) => setAccount(e.target.value.replace(/\D/g, '').slice(0, 10))}
            placeholder="10-digit Account Number"
            className="w-full bg-white h-[42px] rounded-[11px] px-[16px] outline-none font-inter font-semibold text-[14px] tracking-[-0.28px] text-[#130f26] placeholder:text-[#6d7d9c]"
          />
          {resolved && (
            <p className="font-inter font-semibold text-[12px] text-[#147f00] pl-[4px] animate-[fade_.2s_ease-out]">✓ OLOLADE MR. MONEY</p>
          )}
        </>
      )}
    </div>
  );
}

function SuccessSheet({ title, message, rows, onHome, onHistory }) {
  return (
    <>
      <div className="-translate-x-1/2 -translate-y-1/2 absolute bg-[rgba(10,13,31,0.75)] h-[919px] left-[calc(50%+0.5px)] top-[calc(50%+0.5px)] w-[453px] z-20 animate-[fade_.2s_ease-out]" />
      <div
        className="absolute bg-white bottom-0 left-0 overflow-clip rounded-tl-[30px] rounded-tr-[30px] w-[402px] z-30 animate-[sheet-up_.3s_ease-out]"
        style={{ height: 594 + Math.max(0, rows.length - 4) * 32 }}
      >
        <div className="-translate-x-1/2 absolute flex flex-col gap-[26px] items-center left-[calc(50%+0.5px)] top-[37px] w-[335px]">
          <div className="flex flex-col gap-[13px] items-center relative shrink-0 w-[297px]">
            <div className="h-[125px] relative shrink-0 w-[134px] animate-[pop-in_.5s_ease-out]">
              <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <img alt="" className="absolute h-[126.48%] left-[-6.27%] max-w-none top-[-10.28%] w-[118.08%]" src={a('40be3.png')} />
              </div>
            </div>
            <div className="flex flex-col gap-[11px] items-center relative shrink-0 w-full">
              <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[18px] whitespace-nowrap">{title}</p>
              <p className="font-inter font-medium leading-[20px] text-[#8491ab] text-[14px] text-center w-[297px]">{message}</p>
            </div>
          </div>
          <div className="bg-[#f1f5ff] flex flex-col items-start p-[20px] relative rounded-[10px] shrink-0 w-full">
            <div className="flex flex-col font-inter font-medium gap-[14px] items-start text-[12px] w-full">
              {rows.map(([k, v]) => (
                <div key={k} className="flex items-center justify-between relative shrink-0 w-full whitespace-nowrap gap-[12px]">
                  <p className="leading-[1.2] text-[#6e768b]">{k}</p>
                  <p className="leading-[1.6] text-[#1f1f1f] overflow-hidden text-ellipsis">{v}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
        <div className="-translate-x-1/2 absolute flex flex-col gap-[7px] items-center left-[calc(50%+0.5px)] bottom-[28px] w-[335px]">
          <PrimaryButton onClick={onHome}>Back to My RexPlay</PrimaryButton>
          <PrimaryButton light onClick={onHistory}>
            View My Rewards History
          </PrimaryButton>
        </div>
      </div>
    </>
  );
}

const reference = () => `RXP-${String(Date.now()).slice(-10)}-${Math.floor(1000 + Math.random() * 9000)}`;
const timestamp = () => {
  const d = new Date();
  const day = d.getDate();
  const suffix = [11, 12, 13].includes(day % 100) ? 'th' : ['th', 'st', 'nd', 'rd'][day % 10] || 'th';
  const month = d.toLocaleDateString('en-US', { month: 'short' });
  const time = d.toLocaleTimeString('en-GB', { hour12: false });
  return `${month} ${day}${suffix}, ${d.getFullYear()} ${time}`;
};

export default function RedeemForm({ go, back, coins, param }) {
  const kind = KINDS[param] ? param : 'airtime';
  const cfg = KINDS[kind];
  const { redeem } = useStore();

  const [amount, setAmount] = useState(null);
  const [custom, setCustom] = useState('');
  const [phone, setPhone] = useState('');
  const [network, setNetwork] = useState('MTN');
  const [dest, setDest] = useState('wallet');
  const [bank, setBank] = useState('');
  const [account, setAccount] = useState('');
  const [error, setError] = useState('');
  const [receipt, setReceipt] = useState(null);

  const pts = custom ? Number(custom) : amount;
  const short = pts ? pts - coins : 0;

  const submit = () => {
    if (!pts) return setError('Choose an amount to redeem.');
    if (short > 0) return go('rexplay');
    if (kind !== 'cash' && phone.length !== 11) return setError('Enter a valid 11-digit phone number.');
    if (kind === 'cash' && dest === 'bank' && (!bank || account.length !== 10)) return setError('Select your bank and enter a 10-digit account number.');
    setError('');

    const ref = reference();
    let detail;
    let message;
    let rows;
    if (kind === 'airtime') {
      detail = `${naira(pts)} airtime`;
      message = <>You’ve successfully redeemed {formatPoints(pts)}pts for <b>₦</b>{formatPoints(pts)} airtime</>;
      rows = [['Phone Number', `${phone} · ${network}`], ['Points Used', `-${formatPoints(pts)} pts`]];
    } else if (kind === 'data') {
      const [size, validity] = DATA[pts];
      detail = `${size} data · ${validity}`;
      message = `You’ve successfully redeemed ${formatPoints(pts)}pts for ${size} data, valid for ${validity}`;
      rows = [['Phone Number', `${phone} · ${network}`], ['Bundle', `${size} · ${validity}`], ['Points Used', `-${formatPoints(pts)} pts`]];
    } else {
      const to = dest === 'wallet' ? 'Rex wallet' : 'bank account';
      detail = `${naira(pts)} to ${to}`;
      message = <>You’ve successfully redeemed {formatPoints(pts)}pts for <b>₦</b>{formatPoints(pts)} cash to your {to}</>;
      rows = [
        ['Sent To', dest === 'wallet' ? `Rex Wallet · ${WALLET.number}` : `${bank} · ${account}`],
        ['Account Name', WALLET.name],
        ['Points Used', `-${formatPoints(pts)} pts`],
      ];
    }
    rows.push(['Reference', ref], ['Transaction Date', timestamp()]);
    redeem({ kind, points: pts, reference: ref, detail });
    setReceipt({ message, rows });
    return undefined;
  };

  const below = 470; // first row under the amount grid
  const buttonLabel = !pts ? 'Redeem Now' : short > 0 ? 'Play Games to Earn More Points' : `Redeem Now (${formatPoints(pts)}pts)`;

  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <StatusBar />
      <TitleBlock title={cfg.title} subtitle="Convert your points to airtime, data, or cash" subtitleWidth={259} />
      <BackButton onClick={back} />
      <BalanceCard coins={coins} />

      <Label top={252.5}>{kind === 'data' ? 'Select Bundle' : 'Select Amount'}</Label>
      {[POINTS.slice(0, 3), POINTS.slice(3)].map((row, i) => (
        <div key={i} className="-translate-x-1/2 absolute flex gap-[6px] h-[84px] items-center left-[calc(50%+0.5px)] w-[363px]" style={{ top: i === 0 ? 275 : 366 }}>
          {row.map((p) => (
            <AmountTile
              key={p}
              pts={p}
              sub={cfg.tile(p)}
              selected={!custom && amount === p}
              disabled={p > coins}
              onClick={() => {
                setAmount(p);
                setCustom('');
                setError('');
              }}
            />
          ))}
        </div>
      ))}

      {cfg.custom && (
        <label className="absolute bg-white h-[48px] left-[20px] overflow-clip rounded-[11px] w-[360px] cursor-text" style={{ top: below }}>
          <input
            inputMode="numeric"
            value={custom}
            onChange={(e) => {
              setCustom(e.target.value.replace(/\D/g, '').slice(0, 6));
              setError('');
            }}
            placeholder="Custom Amount"
            className="absolute left-[25px] top-0 h-full w-[260px] bg-transparent outline-none font-inter font-semibold text-[14px] tracking-[-0.28px] text-[#130f26] placeholder:text-[#6d7d9c]"
          />
          <div className="-translate-y-1/2 absolute border-[#d7d7d7] border-l border-solid flex font-inter font-bold gap-[3px] items-center justify-end right-[15px] pl-[10px] text-[#6d7d9c] text-[14px] text-center top-[calc(50%+0.5px)] tracking-[-0.28px] whitespace-nowrap leading-[1.5]">
            <span>{custom || 0}</span>
            <span>Pts</span>
          </div>
        </label>
      )}

      {kind === 'cash' ? (
        <>
          <Label top={538}>Send To</Label>
          <CashDestination top={556} dest={dest} setDest={setDest} bank={bank} setBank={setBank} account={account} setAccount={setAccount} />
        </>
      ) : (
        <>
          <Label top={cfg.custom ? 546.5 : below + 12}>Phone Number</Label>
          <PhoneField top={cfg.custom ? 569 : below + 35} phone={phone} setPhone={setPhone} network={network} setNetwork={setNetwork} />
        </>
      )}

      {(error || short > 0) && (
        <p className="absolute left-[24px] right-[24px] top-[744px] text-center font-inter font-medium text-[12px] text-[#c62b3b] animate-[fade_.2s_ease-out]">
          {short > 0 ? `You need ${formatPoints(short)} more points for this reward.` : error}
        </p>
      )}

      <div className="-translate-x-1/2 absolute left-[calc(50%+0.5px)] top-[771px] w-[351px]">
        <PrimaryButton onClick={submit}>{buttonLabel}</PrimaryButton>
      </div>

      {receipt && (
        <SuccessSheet
          title={cfg.sent}
          message={receipt.message}
          rows={receipt.rows}
          onHome={() => go('rexplay', { replace: true })}
          onHistory={() => go('history', { replace: true })}
        />
      )}
    </div>
  );
}
