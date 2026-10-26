import { useState } from 'react';
import { useCompact, useScreenHeight } from '../Phone.jsx';
import StatusBar from './StatusBar.jsx';
import { BackButton, TitleBlock } from './parts.jsx';
import { PrimaryButton } from './GameResults.jsx';
import { Coin, VaultCard, VaultSheet } from './Rewards.jsx';
import { asset as a } from '../asset.js';
import { formatPoints, useStore } from '../store.jsx';
import { REWARDS, REXVAULT, toPoints } from '../config.js';

// Redeem Airtime / Data / Cash. Airtime follows the Figma frames 24454:41329, 24454:41509
// and 24454:41612; Data and Cash reuse the same layout.
// Flow: pick a reward → Confirm sheet → Processing → Successful / Pending / Failed.
export const FIGMA_ASSETS = [
  'https://www.figma.com/api/mcp/asset/45154cf3-7104-41e9-9bfc-ca07bf9390c5',
  'https://www.figma.com/api/mcp/asset/c6bdb3ab-a268-4c16-a38b-f7f9f4d3f9d6',
  'https://www.figma.com/api/mcp/asset/60368927-2c9b-4be1-8b09-992bab96bd70',
];

const P = REWARDS.pointsName;
const naira = (n) => `₦${formatPoints(n)}`;

// Sample data bundles per naira value (final bundles depend on the telco partner).
const DATA = {
  50: ['50MB', '1 day'],
  100: ['110MB', '1 day'],
  200: ['230MB', '2 days'],
  500: ['750MB', '7 days'],
  1000: ['1.5GB', '30 days'],
  1500: ['3GB', '30 days'],
  2000: ['4.5GB', '30 days'],
  5000: ['15GB', '30 days'],
};

const KINDS = {
  airtime: { title: 'Redeem Airtime', sent: 'Airtime Sent!', values: REWARDS.airtimeNaira, tile: (n) => `${naira(n)} Airtime` },
  data: { title: 'Redeem Data', sent: 'Data Sent!', values: REWARDS.dataNaira, tile: (n) => `${DATA[n]?.[0] ?? naira(n)} · ${DATA[n]?.[1] ?? 'data'}` },
  cash: { title: 'Redeem Cash', sent: 'Cash Sent!', values: REWARDS.cashNaira, tile: (n) => `${naira(n)} Cash` },
};

const NETWORKS = {
  MTN: { color: '#ffcb05', prefixes: ['0803', '0806', '0703', '0706', '0813', '0816', '0810', '0814', '0903', '0906', '0913', '0916', '0704'] },
  Airtel: { color: '#e40000', prefixes: ['0802', '0808', '0708', '0812', '0701', '0902', '0901', '0904', '0907', '0912'] },
  Glo: { color: '#50b651', prefixes: ['0805', '0807', '0705', '0815', '0811', '0905', '0915'] },
  '9mobile': { color: '#006d52', prefixes: ['0809', '0817', '0818', '0909', '0908'] },
};
const detectNetwork = (phone) => Object.keys(NETWORKS).find((n) => NETWORKS[n].prefixes.includes(phone.slice(0, 4)));

// Points can only be cashed out to the user's own Rex account.
const REX_ACCOUNT = { name: 'Ololade Mr. Money', number: '11028281921' };

function BalanceCard({ coins, height = 85 }) {
  return (
    <div className="-translate-x-1/2 absolute flex flex-col items-start left-[calc(50%+0.5px)] top-[145px] w-[363px]">
      <div className="bg-gradient-to-r from-[#002766] to-[#004ecc] overflow-clip relative rounded-[8px] shrink-0 w-full" style={{ height }}>
        <div className="-translate-y-1/2 absolute flex flex-col gap-[7px] items-start justify-center left-[16px] top-1/2 w-[179px]">
          <p className="font-inter font-medium h-[16px] leading-[1.5] overflow-hidden text-[#f1f5ff] text-[12px] tracking-[-0.24px] w-full whitespace-nowrap">
            Your Balance
          </p>
          <div className="flex h-[22px] items-center relative shrink-0 w-full">
            <p className="font-inter font-bold leading-[1.256] text-[#f1f5ff] text-[20px] tracking-[-0.8px] whitespace-nowrap">{formatPoints(coins)} {P}</p>
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
        <p className="font-inter font-bold leading-[normal] text-[#130f26] text-[14px] whitespace-nowrap">{formatPoints(pts)} pts</p>
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

function RexAccountCard({ top }) {
  const tight = useScreenHeight() < 700;
  return (
    <div className="absolute left-[20px] w-[360px] flex flex-col gap-[8px]" style={{ top }}>
      <div className="bg-[#e4ecff] border border-solid border-[#5395ff] rounded-[11px] flex items-center gap-[12px] px-[14px] py-[12px]">
        <div className="bg-[#002766] rounded-full size-[34px] shrink-0 flex items-center justify-center">
          <div className="relative h-[11px] w-[14px]">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={a('85975.svg')} />
          </div>
        </div>
        <div className="flex-1 min-w-0">
          <p className="font-inter font-semibold text-[13px] text-[#130f26]">{REX_ACCOUNT.name}</p>
          <p className="font-inter font-medium text-[11px] text-[#2c6ef2]">Rex Account · {REX_ACCOUNT.number}</p>
        </div>
        <div className="size-[20px] shrink-0 rounded-full bg-[#2c6ef2] text-white text-[11px] font-bold flex items-center justify-center">✓</div>
      </div>
      {!tight && <p className="font-inter font-medium text-[11px] text-[#6d7d9c] pl-[4px]">Cash rewards are paid instantly into your Rex account.</p>}
    </div>
  );
}


function Sheet({ children, onBackdrop }) {
  return (
    <>
      <div onClick={onBackdrop} className="absolute bg-[rgba(10,13,31,0.75)] inset-0 z-20 animate-[fade_.2s_ease-out]" />
      <div className="absolute bg-white bottom-0 left-0 w-[402px] max-h-[calc(100%-40px)] rounded-t-[30px] z-30 animate-[sheet-up_.3s_ease-out] flex flex-col">
        {children}
      </div>
    </>
  );
}

function Rows({ rows, compact }) {
  return (
    <div className={`bg-[#f1f5ff] rounded-[10px] w-full ${compact ? 'p-[16px]' : 'p-[20px]'}`}>
      <div className={`flex flex-col font-inter font-medium text-[12px] w-full ${compact ? 'gap-[10px]' : 'gap-[14px]'}`}>
        {rows.map(([k, v]) => (
          <div key={k} className="flex items-center justify-between w-full whitespace-nowrap gap-[12px]">
            <p className="leading-[1.2] text-[#6e768b]">{k}</p>
            <p className="leading-[1.6] text-[#1f1f1f] overflow-hidden text-ellipsis">{v}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

function ConfirmSheet({ rows, processing, onConfirm, onCancel }) {
  const compact = useCompact();
  return (
    <Sheet onBackdrop={processing ? undefined : onCancel}>
      <div className={`flex-1 min-h-0 overflow-y-auto px-[33.5px] flex flex-col items-center gap-[16px] ${compact ? 'pt-[22px]' : 'pt-[32px]'}`}>
        <p className="font-inter font-bold text-[18px] text-[#130f26]">Confirm redemption</p>
        <p className="font-inter font-medium text-[13px] leading-[1.5] text-[#8491ab] text-center">Please check the details. Redemptions can’t be reversed once sent.</p>
        <Rows rows={rows} compact={compact} />
      </div>
      <div className={`shrink-0 flex flex-col gap-[7px] px-[33.5px] pt-[16px] ${compact ? 'pb-[16px]' : 'pb-[28px]'}`}>
        <PrimaryButton onClick={processing ? undefined : onConfirm}>
          {processing ? (
            <span className="inline-flex items-center gap-[8px]">
              <span className="size-[14px] rounded-full border-2 border-white/40 border-t-white animate-spin" />
              Processing…
            </span>
          ) : (
            'Confirm Redemption'
          )}
        </PrimaryButton>
        {!processing && (
          <PrimaryButton light onClick={onCancel}>
            Cancel
          </PrimaryButton>
        )}
      </div>
    </Sheet>
  );
}

const STATUS = {
  success: { color: 'text-[#008f18]', label: 'Successful' },
  pending: { color: 'text-[#b26b00]', label: 'Pending' },
  failed: { color: 'text-[#c62b3b]', label: 'Failed' },
};

function StatusSheet({ status, title, message, rows, onHome, onHistory, onRetry }) {
  const compact = useCompact();
  return (
    <Sheet>
      <div className={`flex-1 min-h-0 overflow-y-auto [scrollbar-width:none] flex flex-col items-center px-[33.5px] ${compact ? 'pt-[22px] gap-[16px]' : 'pt-[37px] gap-[22px]'}`}>
        <div className="flex flex-col gap-[13px] items-center w-[297px]">
          <div className={`relative shrink-0 animate-[pop-in_.5s_ease-out] ${compact ? 'h-[84px] w-[90px]' : 'h-[110px] w-[118px]'}`}>
            {status === 'success' && (
              <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <img alt="" className="absolute h-[126.48%] left-[-6.27%] max-w-none top-[-10.28%] w-[118.08%]" src={a('40be3.png')} />
              </div>
            )}
            {status === 'pending' && <img alt="" className="absolute inset-[8%] object-contain" src={a('50a4c.png')} />}
            {status === 'failed' && (
              <div className="absolute inset-[12%] rounded-full bg-[#ffeef0] flex items-center justify-center">
                <div className="size-[56%] rounded-full bg-[#e44555] text-white font-bold text-[30px] flex items-center justify-center">✕</div>
              </div>
            )}
          </div>
          <div className="flex flex-col gap-[9px] items-center w-full">
            <p className="font-inter font-bold text-[#130f26] text-[18px] text-center">{title}</p>
            <p className="font-inter font-medium leading-[20px] text-[#8491ab] text-[14px] text-center">{message}</p>
          </div>
        </div>
        <Rows rows={[['Status', <span key="s" className={`font-semibold ${STATUS[status].color}`}>{STATUS[status].label}</span>], ...rows]} compact={compact} />
      </div>
      <div className={`shrink-0 flex flex-col gap-[7px] px-[33.5px] pt-[14px] ${compact ? 'pb-[16px]' : 'pb-[28px]'}`}>
        {status === 'failed' && onRetry ? (
          <PrimaryButton onClick={onRetry}>Try Again</PrimaryButton>
        ) : (
          <PrimaryButton onClick={onHome}>Back to My RexPlay</PrimaryButton>
        )}
        <PrimaryButton light onClick={onHistory}>
          View My Rewards History
        </PrimaryButton>
      </div>
    </Sheet>
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

// Prototype outcome rules so every status can be demonstrated:
// a phone number ending in 0000 fails, one ending in 1111 is pending; the daily pool can run out.
function outcome({ kind, phone, nairaValue, poolRemaining }) {
  if (nairaValue > poolRemaining) return { status: 'failed', reason: 'Today’s RexPlay rewards pool has been used up. Please try again tomorrow.' };
  if (kind !== 'cash' && phone.endsWith('0000')) return { status: 'failed', reason: 'The network provider couldn’t complete this top-up.' };
  if (kind !== 'cash' && phone.endsWith('1111')) return { status: 'pending' };
  return { status: 'success' };
}

export default function RedeemForm({ go, back, coins, param }) {
  const kind = KINDS[param] ? param : 'airtime';
  const cfg = KINDS[kind];
  const { redeem, vault, poolRemaining } = useStore();
  const locked = kind === 'cash' && REXVAULT.enabled && REXVAULT.cashRedemptionVaultOnly && !vault;

  const [value, setValue] = useState(null); // naira
  const [phone, setPhone] = useState('');
  const [network, setNetwork] = useState('MTN');
  const [error, setError] = useState('');
  const [step, setStep] = useState('form'); // form | confirm | processing | done
  const [result, setResult] = useState(null);
  const [vaultSheet, setVaultSheet] = useState(false);

  const pts = value ? toPoints(value) : 0;
  const short = pts ? pts - coins : 0;

  const what = () =>
    kind === 'airtime' ? `${naira(value)} airtime` : kind === 'data' ? `${DATA[value]?.[0] ?? naira(value)} data (${DATA[value]?.[1] ?? ''})` : `${naira(value)} cash`;
  const to = () => (kind === 'cash' ? `Rex Account · ${REX_ACCOUNT.number}` : `${phone} · ${network}`);

  const review = () => {
    if (!value) return setError('Choose a reward to redeem.');
    if (short > 0) return go('rexplay');
    if (kind !== 'cash' && phone.length !== 11) return setError('Enter a valid 11-digit phone number.');
    setError('');
    setStep('confirm');
    return undefined;
  };

  const confirm = () => {
    setStep('processing');
    setTimeout(() => {
      const { status, reason } = outcome({ kind, phone, nairaValue: value, poolRemaining });
      const ref = reference();
      const detail = kind === 'cash' ? `${naira(value)} to Rex account` : kind === 'data' ? `${DATA[value]?.[0]} data · ${DATA[value]?.[1]}` : `${naira(value)} airtime`;
      redeem({ kind, points: pts, naira: value, detail, recipient: to(), reference: ref, status, reason });
      const messages = {
        success: `You’ve redeemed ${formatPoints(pts)} ${P} for ${what()}.`,
        pending: `We’re processing your ${what()}. Your ${P} are on hold and you’ll be notified when it’s done.`,
        failed: `${reason} Your ${formatPoints(pts)} ${P} have not been deducted.`,
      };
      const titles = { success: cfg.sent, pending: 'Redemption pending', failed: 'Redemption failed' };
      setResult({
        status,
        title: titles[status],
        message: messages[status],
        rows: [
          ['Reward', what()],
          ['Sent To', to()],
          [`${P} Used`, status === 'failed' ? '0' : `-${formatPoints(pts)}`],
          ['Reference', ref],
          ['Date', timestamp()],
        ],
      });
      setStep('done');
    }, 1400);
  };

  const compact = useCompact();
  const L = compact
    ? { card: 72, label: 238, rows: [258, 334], tile: 70, label2: 430, field: 448, content: 560 }
    : { card: 85, label: 252.5, rows: [275, 366], tile: 84, label2: 482, field: 505, content: 600 };
  const buttonBottom = compact ? 18 : 47;
  const footer = buttonBottom + 80; // pinned area: message line above the button
  const buttonLabel = !value ? 'Redeem Now' : short > 0 ? 'Play Games to Earn More' : `Redeem Now (${formatPoints(pts)} ${P})`;

  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <div className="absolute inset-x-0 top-0 overflow-y-auto overscroll-contain [scrollbar-width:none]" style={{ bottom: locked ? 0 : footer }}>
        <div className="relative w-full" style={{ height: L.content }}>
          <StatusBar />
          <TitleBlock title={cfg.title} subtitle={`${REWARDS.pointsPerNaira} ${P} = ₦1`} subtitleWidth={259} />
          <BackButton onClick={back} />
          <BalanceCard coins={coins} height={L.card} />

          {locked ? (
            <div className="absolute left-[20px] w-[363px] flex flex-col gap-[12px]" style={{ top: L.label - 10 }}>
              <p className="font-inter font-bold text-[14px] text-[#130f26]">Cash rewards are for RexVault customers</p>
              <VaultCard onOpen={() => setVaultSheet(true)} />
              <p className="font-inter font-medium text-[11px] text-[#6d7d9c]">You can still redeem {P} for airtime and data.</p>
            </div>
          ) : (
            <>
              <Label top={L.label}>{kind === 'data' ? 'Select Bundle' : 'Select Amount'}</Label>
              {[cfg.values.slice(0, 3), cfg.values.slice(3, 6)].map((row, i) => (
                <div key={i} className="-translate-x-1/2 absolute flex gap-[6px] items-center left-[calc(50%+0.5px)] w-[363px]" style={{ top: L.rows[i], height: L.tile }}>
                  {row.map((n) => (
                    <AmountTile
                      key={n}
                      pts={toPoints(n)}
                      sub={cfg.tile(n)}
                      selected={value === n}
                      disabled={toPoints(n) > coins}
                      onClick={() => {
                        setValue(n);
                        setError('');
                      }}
                    />
                  ))}
                </div>
              ))}

              {kind === 'cash' ? (
                <>
                  <Label top={L.label2}>Send To</Label>
                  <RexAccountCard top={L.field} />
                </>
              ) : (
                <>
                  <Label top={L.label2}>Phone Number</Label>
                  <PhoneField top={L.field} phone={phone} setPhone={setPhone} network={network} setNetwork={setNetwork} />
                </>
              )}
            </>
          )}
        </div>
      </div>

      {!locked && (
        <>
          {(error || short > 0) && (
            <p className="absolute left-[24px] right-[24px] text-center font-inter font-medium text-[12px] text-[#c62b3b] animate-[fade_.2s_ease-out]" style={{ bottom: buttonBottom + 62 }}>
              {short > 0 ? `You need ${formatPoints(short)} more ${P} for this reward.` : error}
            </p>
          )}
          <div className="-translate-x-1/2 absolute left-[calc(50%+0.5px)] w-[351px]" style={{ bottom: buttonBottom }}>
            <PrimaryButton onClick={review}>{buttonLabel}</PrimaryButton>
          </div>
        </>
      )}

      {(step === 'confirm' || step === 'processing') && (
        <ConfirmSheet
          processing={step === 'processing'}
          rows={[
            ['Reward', what()],
            ['Sent To', to()],
            [`${P} to use`, formatPoints(pts)],
            ['Balance after', `${formatPoints(coins - pts)} ${P}`],
          ]}
          onConfirm={confirm}
          onCancel={() => setStep('form')}
        />
      )}
      {step === 'done' && result && (
        <StatusSheet
          {...result}
          onHome={() => go('rexplay', { replace: true })}
          onHistory={() => go('history', { replace: true })}
          onRetry={() => {
            setResult(null);
            setStep('form');
          }}
        />
      )}
      {vaultSheet && <VaultSheet onClose={() => setVaultSheet(false)} />}
    </div>
  );
}
