// iOS status bar drawn in every Figma frame (time, signal, Wi-Fi, battery).
// File names are the Figma export names (see src/asset.js).
import { asset as a } from '../asset.js';

export default function StatusBar({ color = '#171616', files = {} }) {
  const f = { location: '7fea8.svg', wifi: '27385.svg', battery: 'b075c.svg', ...files };
  return (
    <div className="absolute flex h-[35px] items-center justify-between left-0 px-[20px] py-[6px] top-[6px] w-[402px] z-10 pointer-events-none">
      <div className="flex gap-[2px] items-center justify-center relative shrink-0">
        <p className="font-inter font-semibold text-[17px] tracking-[-0.68px] whitespace-nowrap leading-[normal]" style={{ color }}>
          9:41
        </p>
        <div className="relative shrink-0 size-[16px]">
          <img alt="" className="absolute block inset-0 max-w-none size-full" src={a(f.location)} />
        </div>
      </div>
      <div className="h-[14px] relative shrink-0 w-[76px]">
        <div className="-translate-y-1/2 absolute flex gap-[4px] items-center justify-end right-0 top-1/2">
          <div className="h-[14px] overflow-clip relative shrink-0 w-[20px]">
            {[
              ['12px', '7.95px', '0px'],
              ['9.6px', '2.65px', '1.2px'],
              ['7px', '-2.65px', '2.5px'],
              ['4.6px', '-7.95px', '3.7px'],
            ].map(([h, dx, dy]) => (
              <div
                key={dx}
                className="-translate-x-1/2 -translate-y-1/2 absolute rounded-[1px] w-[3.2px]"
                style={{ height: h, left: `calc(50% + ${dx})`, top: `calc(50% + ${dy})`, background: color }}
              />
            ))}
          </div>
          <div className="h-[12px] overflow-clip relative shrink-0 w-[20px]">
            <div className="-translate-x-1/2 -translate-y-1/2 absolute h-[11px] left-1/2 top-1/2 w-[15.675px]">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={a(f.wifi)} />
            </div>
          </div>
          <div className="h-[14px] relative shrink-0 w-[28px]">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={a(f.battery)} />
          </div>
        </div>
      </div>
    </div>
  );
}
