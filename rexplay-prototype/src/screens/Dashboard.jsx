import { asset as a } from '../asset.js';
import StatusBar from './StatusBar.jsx';

// Figma: "rex play" › Dashboard (24449:38168)
export const FIGMA_ASSETS = 'https://www.figma.com/api/mcp/asset/2563ee72-3e43-4713-840a-cb75c702934c';

const Img = ({ src, className = 'absolute block inset-0 max-w-none size-full' }) => (
  <img alt="" className={className} src={a(src)} />
);

function Tile({ bg, label, children, nudge = '0.25px' }) {
  return (
    <div className={`flex-[1_0_0] h-[73px] min-w-px overflow-clip relative rounded-[8px]`} style={{ background: bg }}>
      <div
        className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[11px] items-center top-1/2 w-[50px]"
        style={{ left: `calc(50% + ${nudge})` }}
      >
        {children}
        <p className="font-inter font-medium min-w-full text-[#2e3d60] text-[10px] text-center leading-[normal]">{label}</p>
      </div>
    </div>
  );
}

function Arrow({ file = '4735d.svg', inset = 'inset-[-21.43%_-10.71%]' }) {
  return (
    <div className="flex items-center justify-center relative shrink-0 size-[12px]">
      <div className="-rotate-90 flex-none">
        <div className="relative size-[12px]">
          <div className="absolute inset-[35.42%_20.83%]">
            <div className={`absolute ${inset}`}>
              <Img src={file} className="block max-w-none size-full" />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function SeeMore() {
  return (
    <div className="flex gap-[2px] items-center justify-center relative shrink-0">
      <p className="font-inter font-semibold text-[#002766] text-[10px] whitespace-nowrap leading-[normal]">See More</p>
      <Arrow />
    </div>
  );
}

// Decorative hexagon pattern used on the blue cards.
function Hexes({ files, className, style }) {
  return (
    <div className={className} style={style}>
      <div className="absolute h-[174.646px] left-[35px] top-[25px] w-[299px]">
        <div className="absolute h-[138.648px] left-[172.9px] top-0 w-[126.103px]"><Img src={files[0]} /></div>
        <div className="absolute h-[138.646px] left-0 top-[36px] w-[126.103px]"><Img src={files[1]} /></div>
        <div className="absolute h-[57.809px] left-[156.76px] top-[54.06px] w-[52.579px]"><Img src={files[2]} /></div>
      </div>
    </div>
  );
}

function Glow({ className }) {
  return (
    <div className={`absolute size-[142px] ${className}`}>
      <div className="absolute inset-[-48.87%]">
        <Img src="6af0f.svg" className="block max-w-none size-full" />
      </div>
    </div>
  );
}

function TabItem({ label, active, children }) {
  return (
    <div className="overflow-clip relative shrink-0 size-[53px]">
      {children}
      <p
        className={`-translate-x-1/2 -translate-y-1/2 absolute font-inter font-semibold left-[26.5px] text-[12px] text-center top-[42px] whitespace-nowrap leading-[1.3] ${
          active ? 'text-[#002766]' : 'text-[#a0a3bd]'
        }`}
      >
        {label}
      </p>
    </div>
  );
}

export function BottomTabs() {
  return (
    <div className="-translate-x-1/2 absolute bg-white bottom-0 h-[74px] left-[calc(50%+0.5px)] overflow-clip shadow-[0px_-6px_24px_0px_rgba(125,124,152,0.08)] w-[405px]">
      <div className="-translate-x-1/2 absolute flex gap-[20px] items-start left-1/2 top-[11px]">
        <TabItem label="Home" active>
          <div className="absolute left-[14.5px] size-[24px] top-[3px]"><Img src="27ace.svg" /></div>
        </TabItem>
        <TabItem label="Save">
          <div className="-translate-x-1/2 absolute left-[calc(50%+0.5px)] size-[24px] top-[3px]"><Img src="b3731.svg" /></div>
        </TabItem>
        <TabItem label="Invest">
          <div className="-translate-x-1/2 absolute left-[calc(50%+0.5px)] size-[24px] top-[3px]">
            <div className="absolute inset-[8.33%]"><Img src="f0ce0.svg" /></div>
          </div>
        </TabItem>
        <TabItem label="Borrow">
          <div className="absolute left-[14px] size-[24px] top-[3px]"><Img src="b32dd.svg" /></div>
        </TabItem>
        <TabItem label="More">
          <div className="absolute left-[14px] size-[24px] top-[3px]"><Img src="62f56.svg" /></div>
        </TabItem>
      </div>
    </div>
  );
}

export default function Dashboard({ go, coins = 0 }) {
  return (
    <div className="overflow-clip relative size-full bg-[#f1f5ff]">
      <StatusBar />

      {/* Main column */}
      <div className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[10px] items-start left-1/2 top-[calc(50%+32px)] w-[362px]">
        {/* Search, coins, notifications, avatar */}
        <div className="flex gap-[4px] items-start relative shrink-0 w-full">
          <button className="bg-white block cursor-pointer h-[40px] overflow-clip relative rounded-[40px] shrink-0 w-[212px]">
            <div className="absolute bg-[#002766] left-[10px] overflow-clip rounded-[28.73px] size-[21.707px] top-[9px]">
              <div className="-translate-y-1/2 absolute h-[9px] left-[5.37px] top-1/2 w-[11.368px]"><Img src="85975.svg" /></div>
            </div>
            <p className="-translate-y-1/2 absolute left-[40px] top-[calc(50%-0.34px)] font-inter font-medium text-[#335285] text-[13px] text-left whitespace-nowrap leading-[26.648px]">
              Ask RexAtlas.....
            </p>
          </button>
          <button
            onClick={() => go('rewards')}
            className="bg-white block cursor-pointer h-[40px] overflow-clip relative rounded-[40px] shrink-0 w-[57px]"
          >
            <p className="-translate-y-1/2 absolute font-inter font-medium left-[36px] text-[#335285] text-[13px] text-left top-[calc(50%+0.5px)] whitespace-nowrap leading-[26.648px]">
              {coins}
            </p>
            <div className="-translate-y-1/2 absolute left-[5px] size-[26px] top-1/2">
              <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <Img src="2a1e3.png" className="absolute left-[2.07%] max-w-none size-[99.04%] top-0" />
              </div>
            </div>
          </button>
          <div className="bg-white flex items-center justify-center overflow-clip px-[5px] py-[8px] relative rounded-[40px] shrink-0 w-[40px]">
            <div className="overflow-clip relative shrink-0 size-[24px]">
              <div className="absolute inset-[8.33%_14.58%_10.02%_14.59%]"><Img src="52e16.svg" /></div>
            </div>
          </div>
          <div className="bg-white flex items-center justify-center overflow-clip px-[5px] py-[8px] relative rounded-[40px] shrink-0 w-[40px]">
            <div className="bg-[#cfdcff] overflow-clip relative rounded-[28px] shrink-0 size-[24px]">
              <p className="absolute font-inter font-semibold left-[calc(50%-7px)] text-[#0f346f] text-[8.567px] top-[calc(50%-5px)] whitespace-nowrap leading-[normal]">
                OM
              </p>
            </div>
          </div>
        </div>

        {/* Balance card */}
        <div className="bg-[#002766] flex flex-col gap-[10px] h-[156px] items-start overflow-clip relative rounded-[8px] shrink-0 w-full">
          <Glow className="left-[-18px] top-[-47px]" />
          <Glow className="left-[244px] top-[48px]" />
          <Hexes files={['84215.svg', 'e520e.svg', '70391.svg']} className="h-[216.117px] relative shrink-0 w-full" />
          <div className="-translate-x-1/2 -translate-y-1/2 absolute flex flex-col gap-[16px] items-center justify-center left-1/2 top-1/2 w-[332px]">
            <div className="flex flex-col gap-[14px] items-center justify-center relative shrink-0 w-full">
              <div className="flex gap-[5px] items-center justify-center relative shrink-0">
                <div className="flex font-inter font-medium gap-px items-center text-[#f1f5ff] text-[10px] whitespace-nowrap leading-[normal]">
                  <p>11028281921</p>
                  <p>{' |'}</p>
                  <p>Ololade Mr. Money</p>
                </div>
                <div className="relative shrink-0 size-[12px]"><Img src="08862.svg" /></div>
              </div>
              <div className="flex flex-col gap-[5px] items-center justify-center relative shrink-0">
                <div className="flex gap-[10px] items-center relative shrink-0">
                  <p className="font-inter font-bold text-[#f1f5ff] text-[20px] tracking-[-0.4px] whitespace-nowrap leading-[normal]">
                    ₦500,563,670.00
                  </p>
                  <div className="relative shrink-0 size-[17px]">
                    <div className="absolute inset-[19.79%_11.44%_19.36%_11.46%]">
                      <div className="absolute inset-[-5.14%_-4.05%]">
                        <Img src="176be.svg" className="block max-w-none size-full" />
                      </div>
                    </div>
                  </div>
                </div>
                <div className="flex gap-[5px] items-start opacity-59 text-[#f1f5ff] text-[10px] whitespace-nowrap leading-[normal]">
                  <p className="font-inter font-medium">Book Balance :</p>
                  <p className="font-inter font-semibold">₦500,563,670.00</p>
                </div>
              </div>
            </div>
            <div className="flex gap-[8px] items-center relative shrink-0 w-[280px]">
              {['Transfer', 'Add Money', 'History'].map((t) => (
                <div key={t} className="bg-white flex flex-[1_0_0] items-center justify-center min-w-px p-[10px] relative rounded-[6px]">
                  <p className="font-inter font-semibold text-[#002766] text-[10px] whitespace-nowrap leading-[normal]">{t}</p>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Quick actions */}
        <div className="bg-white flex flex-col gap-[10px] items-start overflow-clip p-[10px] relative rounded-[8px] shrink-0 w-full">
          <div className="flex gap-[8px] items-center relative shrink-0 w-full">
            <Tile bg="rgba(221,235,220,0.58)" label="Airtime">
              <div className="relative shrink-0 size-[24px]">
                <div className="absolute inset-[8.33%_8.33%_55.72%_55.83%]"><Img src="adbee.svg" /></div>
                <div className="absolute inset-[12.5%_12.5%_8.33%_8.33%]"><Img src="3c6af.svg" /></div>
              </div>
            </Tile>
            <Tile bg="#eff3ff" label="Data" nudge="-0.25px">
              <div className="relative shrink-0 size-[24px]">
                <Img src="972db.svg" />
                <div className="absolute inset-[8.33%_8.37%_8.38%_8.33%]"><Img src="6bf12.svg" /></div>
                <div className="absolute inset-[29.57%_21.87%_55.37%_21.9%]"><Img src="65324.svg" /></div>
                <div className="absolute inset-[44.79%_28.58%_42.5%_28.52%]"><Img src="c39c0.svg" /></div>
                <div className="absolute inset-[60.95%_37.74%_29.63%_37.69%]"><Img src="f9434.svg" /></div>
              </div>
            </Tile>
            <Tile bg="#fff7eb" label="Electricity">
              <div className="overflow-clip relative shrink-0 size-[28px]">
                <div className="absolute bottom-[3.12%] left-1/4 right-1/4 top-[3.11%]"><Img src="7abed.svg" /></div>
              </div>
            </Tile>
            <Tile bg="#ebfafc" label="Budgets" nudge="-0.25px">
              <div className="relative shrink-0 size-[24px]"><Img src="d716c.svg" /></div>
            </Tile>
          </div>
          <div className="flex gap-[8px] items-center relative shrink-0 w-full">
            <Tile bg="#fff7eb" label="RexSave">
              <div className="relative shrink-0 size-[24px]">
                <div className="absolute inset-[12.5%_8.33%]"><Img src="8cc95.svg" /></div>
              </div>
            </Tile>
            <Tile bg="#ebfafc" label="RexVault" nudge="-0.25px">
              <div className="relative shrink-0 size-[24px]"><Img src="89d81.svg" /></div>
            </Tile>
            <Tile bg="rgba(221,235,220,0.58)" label="RexFlex">
              <div className="relative shrink-0 size-[24px]">
                <div className="absolute inset-[16.67%_8.33%]"><Img src="78d78.svg" /></div>
              </div>
            </Tile>
            <Tile bg="#eff3ff" label="RexAtlas" nudge="-0.25px">
              <div className="h-[19px] relative shrink-0 w-[24px]"><Img src="8c647.svg" /></div>
            </Tile>
          </div>
        </div>

        {/* Promo carousel (second card peeks in, as in the design) */}
        <div className="flex gap-[7px] items-center justify-end overflow-clip relative shrink-0 w-full">
          <div className="bg-[#4782c6] flex flex-col gap-[10px] items-start overflow-clip p-[15px] relative rounded-[8px] shrink-0 w-[347px]">
            <Glow className="left-[223px] top-[-81px]" />
            <div className="flex flex-col gap-[10px] items-start relative shrink-0 w-[183px]">
              <div className="flex flex-col gap-[2px] items-start relative shrink-0 w-full whitespace-nowrap">
                <p className="font-inter font-semibold text-[#f1f5ff] text-[12px] leading-[normal]">Capital Market Investments</p>
                <p className="font-inter font-normal leading-[1.5] min-w-full overflow-hidden text-[#e5eeff] text-[8px] text-ellipsis tracking-[-0.16px] w-min">
                  Subscribe to live IPOs and exercise rights issues - straight from your wallet.
                </p>
              </div>
              <div className="bg-white flex h-[26px] items-center justify-center p-[5px] relative rounded-[6px] shrink-0 w-[90px]">
                <p className="font-inter font-semibold text-[#002766] text-[10px] whitespace-nowrap leading-[normal]">Explore Offers</p>
              </div>
            </div>
            <Hexes
              files={['7b46d.svg', '087d7.svg', '6b096.svg']}
              className="-translate-y-1/2 absolute h-[216.117px] left-[15px] top-[calc(50%-0.44px)] w-[317px]"
            />
            <div className="absolute h-[116px] left-[199px] top-0 w-[148px]">
              <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <Img src="91f71.png" className="absolute h-[152.56%] left-[-14.05%] max-w-none top-[-28.67%] w-[119.93%]" />
              </div>
            </div>
          </div>
          <div className="bg-[#4e87c8] flex flex-col gap-[10px] items-start overflow-clip p-[15px] relative rounded-[8px] shrink-0 w-[347px]">
            <div className="flex flex-col gap-[10px] items-start relative shrink-0 w-[157px]">
              <div className="flex flex-col gap-[2px] items-start relative shrink-0 whitespace-nowrap">
                <p className="font-inter font-semibold text-[#f1f5ff] text-[12px] leading-[normal]">Create a Business Account</p>
                <p className="font-inter font-normal leading-[1.5] text-[#e5eeff] text-[8px] tracking-[-0.16px]">
                  Get a business account in minutes on Rex
                </p>
              </div>
              <div className="bg-white flex h-[26px] items-center justify-center p-[5px] relative rounded-[6px] shrink-0 w-[78px]">
                <p className="font-inter font-semibold text-[#002766] text-[10px] whitespace-nowrap leading-[normal]">Get Started</p>
              </div>
            </div>
            <Hexes
              files={['b77da.svg', '087d7.svg', '6b096.svg']}
              className="-translate-y-1/2 absolute h-[216.117px] left-[15px] top-[calc(50%-0.44px)] w-[317px]"
            />
            <div className="absolute left-[223px] overflow-clip size-[100px] top-[11px]">
              <div className="absolute inset-[5.56%_5.44%_5.4%_5%]"><Img src="afadc.svg" /></div>
            </div>
          </div>
        </div>

        {/* Suggested savings plan */}
        <div className="bg-white flex flex-col gap-[10px] items-start overflow-clip p-[10px] relative rounded-[8px] shrink-0 w-full">
          <div className="flex items-center justify-between relative shrink-0 w-full">
            <p className="font-inter font-semibold text-[#130f26] text-[12px] tracking-[-0.06px] w-[142px] leading-[normal]">
              Suggested Savings Plan
            </p>
            <SeeMore />
          </div>
          <div className="border border-[#f4f4f4] border-solid flex gap-[10px] items-center overflow-clip p-[10px] relative rounded-[11px] shrink-0 w-full">
            <div className="flex flex-col gap-[7px] items-start relative shrink-0 w-[195px]">
              <div className="flex flex-col gap-[3px] items-start relative shrink-0 w-full">
                <p className="font-inter font-semibold text-[#130f26] text-[11px] whitespace-nowrap leading-[normal]">Detty December</p>
                <p className="font-inter font-medium leading-[1.5] min-w-full text-[#6d7d9c] text-[10px] tracking-[-0.2px] w-min">
                  Save small-small now, ball in December.
                </p>
              </div>
              <div className="flex items-center relative shrink-0">
                <p className="font-inter font-bold text-[#323dff] text-[10px] tracking-[-0.2px] whitespace-nowrap leading-[1.5]">Start Goal</p>
                <Arrow file="d61b8.svg" inset="inset-[-14.29%_-7.14%]" />
              </div>
            </div>
            <div className="absolute flex items-center justify-center left-[251px] size-[77.406px] top-[14px]">
              <div className="-rotate-30 flex-none">
                <div className="relative size-[56.665px]"><Img src="ccc03.svg" /></div>
              </div>
            </div>
          </div>
        </div>

        {/* Learn finance */}
        <div className="bg-white flex flex-col gap-[10px] items-start overflow-clip p-[10px] relative rounded-[8px] shrink-0 w-full">
          <div className="flex items-center justify-between relative shrink-0 w-full">
            <p className="font-inter font-semibold text-[#130f26] text-[12px] tracking-[-0.06px] w-[142px] leading-[normal]">Learn Finance</p>
            <SeeMore />
          </div>
          <div className="border border-[#f4f4f4] border-solid flex gap-[10px] items-center overflow-clip p-[10px] relative rounded-[11px] shrink-0 w-full">
            <div className="bg-[#e1f7ed] h-[69px] overflow-clip relative rounded-[7px] shrink-0 w-[75px]">
              <div className="absolute inset-[30.43%_13.33%_-7.6%_13.33%]"><Img src="72d1a.svg" /></div>
            </div>
            <div className="flex flex-col gap-[7px] items-start relative shrink-0">
              <div className="bg-[#daf2ed] flex h-[11px] items-center justify-center p-[5px] relative rounded-[29px] shrink-0">
                <p className="font-inter font-semibold text-[#1b9279] text-[6px] tracking-[-0.12px] whitespace-nowrap leading-[1.5]">MINDSET</p>
              </div>
              <div className="flex flex-col gap-[3px] items-start relative shrink-0 w-full">
                <p className="font-inter font-semibold text-[#130f26] text-[11px] whitespace-nowrap leading-[normal]">
                  How to beat lifestyle inflation in your 20s
                </p>
                <p className="font-inter font-medium leading-[1.5] min-w-full text-[#6d7d9c] text-[8px] tracking-[-0.16px] w-min">
                  Save small-small now, ball in December.
                </p>
              </div>
              <p className="font-inter font-medium leading-[1.5] min-w-full text-[#6d7d9c] text-[8px] tracking-[-0.16px] w-min">6 mins Read</p>
            </div>
          </div>
        </div>
      </div>

      <BottomTabs />

      {/* RexPlay banner — entry point to the game */}
      <button
        onClick={() => go('rexplay')}
        className="absolute bg-[#b8ffd1] h-[28px] left-0 overflow-clip top-[47px] w-[402px] cursor-pointer"
      >
        <div className="-translate-y-1/2 absolute flex h-[110px] items-center justify-center left-[-2px] top-1/2 w-[109px]">
          <div className="-scale-y-100 flex-none rotate-180">
            <div className="blur-[8.1px] h-[110px] opacity-56 relative w-[109px]">
              <Img src="4465b.png" className="absolute inset-0 max-w-none object-contain pointer-events-none size-full" />
            </div>
          </div>
        </div>
        <div className="-translate-y-1/2 absolute blur-[8.1px] opacity-56 right-0 size-[118px] top-1/2">
          <Img src="4465b.png" className="absolute inset-0 max-w-none object-contain pointer-events-none size-full" />
        </div>
        <div className="-translate-x-1/2 absolute flex gap-[14px] items-center left-[calc(50%+0.5px)] top-[2px]">
          <div className="relative shrink-0 size-[24px]"><Img src="31268.svg" /></div>
          <div className="flex font-inter font-semibold gap-[7px] italic items-center text-[#00903c] text-[12px] text-center tracking-[-0.06px] leading-[normal]">
            <div className="flex items-center relative shrink-0">
              <p className="relative shrink-0 w-[59px] whitespace-nowrap">RexPlay...</p>
              <p className="relative shrink-0 w-[96px] whitespace-nowrap">Play. Learn. Earn</p>
            </div>
            <p className="relative shrink-0 underline w-[68px] whitespace-nowrap">Play Now!!!</p>
          </div>
          <div className="relative shrink-0 size-[24px]"><Img src="31268.svg" /></div>
        </div>
      </button>
    </div>
  );
}
