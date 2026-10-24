import { useEffect, useState } from 'react';

// Every Figma screen is 402×874. On a phone the screen is scaled to fill the
// display; on a larger screen it sits centred in a phone-shaped frame.
export const W = 402;
export const H = 874;

function useScale() {
  const get = () => {
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const isPhone = vw < 640;
    const pad = isPhone ? 0 : 48;
    return { isPhone, scale: Math.min((vw - pad) / W, (vh - pad) / H, isPhone ? Infinity : 1) };
  };
  const [s, setS] = useState(get);
  useEffect(() => {
    const on = () => setS(get());
    window.addEventListener('resize', on);
    return () => window.removeEventListener('resize', on);
  }, []);
  return s;
}

export default function Phone({ children, bg = '#f1f5ff' }) {
  const { isPhone, scale } = useScale();
  return (
    <div
      className="fixed inset-0 flex items-center justify-center overflow-hidden"
      style={{ background: isPhone ? bg : undefined }}
    >
      <div
        className="relative overflow-hidden"
        style={{
          width: W * scale,
          height: H * scale,
          borderRadius: isPhone ? 0 : 30 * scale,
          boxShadow: isPhone ? 'none' : '0 30px 80px rgba(0,0,0,.45)',
        }}
      >
        <div className="relative" style={{ width: W, height: H, transform: `scale(${scale})`, transformOrigin: 'top left' }}>
          {children}
        </div>
      </div>
    </div>
  );
}
