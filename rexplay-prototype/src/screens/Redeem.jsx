import StatusBar from './StatusBar.jsx';
import { BackButton, Icon, TitleBlock } from './parts.jsx';
import { PointsBanner } from './Rewards.jsx';
import { FEATURES, REWARDS, REXVAULT } from '../config.js';
import { formatPoints, useStore } from '../store.jsx';

// Figma: "rex play" › Redeem Rewards (24454:40947)
export const FIGMA_ASSETS = 'https://www.figma.com/api/mcp/asset/3b7394a5-728b-4e46-874e-9bf8696abe44';

function Chevron() {
  return (
    <div className="bg-[#f0f3ff] overflow-clip relative rounded-[24px] shrink-0 size-[24px]">
      <div className="-translate-x-1/2 -translate-y-1/2 absolute flex items-center justify-center left-1/2 size-[12px] top-1/2">
        <div className="-rotate-90 flex-none">
          <div className="relative size-[12px]">
            <Icon src="18e56.svg" />
          </div>
        </div>
      </div>
    </div>
  );
}

function Option({ icon, title, body, badge, textWidth = 143, row, onClick }) {
  return (
    <button
      onClick={onClick}
      className="bg-white h-[80px] shrink-0 overflow-clip relative rounded-[11px] w-full cursor-pointer text-left active:scale-[.99] transition-transform"
    >
      <div className={`absolute flex items-center ${row}`}>
        <div className="flex gap-[15px] items-center relative shrink-0">
          {icon}
          <div className="flex flex-col gap-[3px] items-start relative shrink-0" style={{ width: textWidth }}>
            <p className="font-inter font-semibold leading-[normal] text-[#130f26] text-[11px] whitespace-nowrap flex items-center gap-[6px]">
              {title}
              {badge && <span className="bg-[#ebfafc] text-[#0b7285] rounded-[8px] px-[6px] py-[1px] text-[8px] font-bold">{badge}</span>}
            </p>
            <p className="font-inter font-medium leading-[1.5] min-w-full text-[#6d7d9c] text-[10px] tracking-[-0.2px] w-min">{body}</p>
          </div>
        </div>
        <Chevron />
      </div>
    </button>
  );
}

export default function Redeem({ go, back, coins }) {
  const { vault, poolRemaining } = useStore();
  const cashLocked = REXVAULT.enabled && REXVAULT.cashRedemptionVaultOnly && !vault;
  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <StatusBar />
      <TitleBlock title="Redeem Rewards" subtitle={`Convert your ${REWARDS.pointsName} to airtime, data or cash`} subtitleWidth={259} coins={coins} />
      <BackButton onClick={back} />

      <div className="-translate-x-1/2 absolute flex flex-col items-start left-[calc(50%+0.5px)] top-[145px] w-[363px]">
        <PointsBanner coins={coins} height={116} />
      </div>

      <div className="-translate-x-1/2 absolute flex flex-col gap-[6px] items-start left-[calc(50%+0.5px)] top-[275px] bottom-0 overflow-y-auto pb-[24px] [scrollbar-width:none] w-[363px]">
        {FEATURES.redeemCash && (
        <Option
          row="justify-between left-[20px] top-[16px] w-[324px]"
          title="Cash Reward"
          badge={REXVAULT.enabled && REXVAULT.cashRedemptionVaultOnly ? (vault ? 'RexVault' : '🔒 RexVault') : null}
          body={cashLocked ? 'For RexVault customers — paid into your Rex account' : 'Paid instantly into your Rex account'}
          onClick={() => go('redeem/cash')}
          icon={
            <div className="bg-[rgba(255,152,0,0.08)] overflow-clip relative rounded-[9.882px] shrink-0 size-[42px]">
              <div className="-translate-x-1/2 -translate-y-1/2 absolute left-[calc(50%+0.5px)] size-[21px] top-1/2">
                <Icon src="a5ab2.svg" />
              </div>
            </div>
          }
        />
        )}
        {FEATURES.redeemAirtime && (
        <Option
          row="justify-between left-[18px] top-[18.67px] w-[323px]"
          title="Airtime"
          body="Get airtime for your number"
          onClick={() => go('redeem/airtime')}
          icon={
            <div className="bg-[rgba(0,188,212,0.08)] overflow-clip relative rounded-[8.647px] shrink-0 size-[42px]">
              <div className="-translate-x-1/2 -translate-y-1/2 absolute left-[calc(50%+0.62px)] size-[21px] top-[calc(50%+0.62px)]">
                <div className="absolute inset-[8.33%_8.33%_55.72%_55.83%]">
                  <Icon src="29177.svg" />
                </div>
                <div className="absolute inset-[12.5%_12.5%_8.33%_8.33%]">
                  <Icon src="c7196.svg" />
                </div>
              </div>
            </div>
          }
        />
        )}
        {FEATURES.redeemData && (
        <Option
          row="gap-[75px] left-[18px] top-[19.33px]"
          title="Data Bundle"
          body="Get a data bundle for your number"
          textWidth={167}
          onClick={() => go('redeem/data')}
          icon={
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
          }
        />
        )}
        <div className="w-full bg-white rounded-[11px] p-[14px] flex flex-col gap-[7px] mt-[4px] shrink-0">
          <div className="flex justify-between items-baseline">
            <p className="font-inter font-semibold text-[11px] text-[#130f26]">Today’s RexPlay rewards pool</p>
            <p className="font-inter font-semibold text-[11px] text-[#002766]">
              ₦{formatPoints(poolRemaining)} left of ₦{formatPoints(REWARDS.dailyBudgetNaira)}
            </p>
          </div>
          <div className="h-[6px] rounded-full bg-[#eff2fe] overflow-hidden">
            <div className="h-full rounded-full bg-[#22a447]" style={{ width: `${(poolRemaining / REWARDS.dailyBudgetNaira) * 100}%` }} />
          </div>
          <p className="font-inter font-medium text-[10px] text-[#6d7d9c]">Rewards are limited each day and refresh at midnight.</p>
        </div>
      </div>
    </div>
  );
}
