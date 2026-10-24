import { useEffect, useState } from 'react';

// Every Figma screen is 402 wide and at least 874 tall.
// Phone: the screen fills the full width like a native app. The design's drawn iOS status
//   bar is hidden (the phone shows its real one) and screens stretch to the phone's height;
//   on short screens the page scrolls rather than shrinking.
// Laptop/tablet: the screen sits centred in a phone-shaped frame.
export const W = 402;
export const H = 874;
const STATUS_BAR = 44; // height of the drawn status bar hidden on real phones

const measure = () => {
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  const isPhone = vw < 640;
  if (isPhone) {
    const scale = vw / W;
    return { isPhone, vw, scale, height: Math.max(H, Math.ceil(vh / scale) + STATUS_BAR) };
  }
  return { isPhone, vw, scale: Math.min((vw - 48) / W, (vh - 48) / H, 1), height: H };
};

function useLayout() {
  const [layout, setLayout] = useState(measure);
  useEffect(() => {
    // Mobile browsers resize while the address bar slides in and out; only re-measure when
    // the width changes (rotation, laptop window resize) so the screen doesn't jump.
    const on = () => setLayout((cur) => (window.innerWidth !== cur.vw || !cur.isPhone ? measure() : cur));
    window.addEventListener('resize', on);
    return () => window.removeEventListener('resize', on);
  }, []);
  return layout;
}

export default function Phone({ children, bg = '#f1f5ff' }) {
  const { isPhone, scale, height } = useLayout();

  // Match the browser chrome and page background to the current screen.
  useEffect(() => {
    if (!isPhone) return;
    document.body.style.background = bg;
    document.querySelector('meta[name="theme-color"]')?.setAttribute('content', bg);
  }, [bg, isPhone]);

  if (isPhone) {
    return (
      <div className="relative overflow-hidden" style={{ width: '100%', height: (height - STATUS_BAR) * scale, background: bg }}>
        <div
          className="relative"
          style={{
            width: W,
            height,
            transform: `translateY(${-STATUS_BAR * scale}px) scale(${scale})`,
            transformOrigin: 'top left',
          }}
        >
          {children}
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 flex items-center justify-center overflow-hidden">
      <div
        className="relative overflow-hidden"
        style={{ width: W * scale, height: H * scale, borderRadius: 30 * scale, boxShadow: '0 30px 80px rgba(0,0,0,.45)' }}
      >
        <div className="relative" style={{ width: W, height: H, transform: `scale(${scale})`, transformOrigin: 'top left' }}>
          {children}
        </div>
      </div>
    </div>
  );
}
