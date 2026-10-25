import { createContext, useContext, useEffect, useState } from 'react';

// Every Figma screen is 402 wide and at least 874 tall.
// Phone: the screen fills the full width like a native app. The design's drawn iOS status
//   bar is hidden (the phone shows its real one) and each screen is laid out for the phone's
//   exact height, with its main button pinned to the bottom.
// Laptop/tablet: the screen sits centred in a phone-shaped frame.
export const W = 402;
export const H = 874;
const STATUS_BAR = 44; // height of the drawn status bar hidden on real phones
const MIN_H = 640;

// Logical height of the current screen (874 on laptops; the phone's own height on phones).
// Screens use it to pin their main button and squeeze or scroll the content above it.
const ScreenHeight = createContext(H);
export const useScreenHeight = () => useContext(ScreenHeight);
export const useCompact = () => useContext(ScreenHeight) < 800;

const measure = () => {
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  const isPhone = vw < 640;
  if (isPhone) {
    const scale = vw / W;
    return { isPhone, vw, scale, height: Math.max(MIN_H, Math.floor(vh / scale) + STATUS_BAR) };
  }
  return { isPhone, vw, scale: Math.min((vw - 48) / W, (vh - 48) / H, 1), height: H };
};

function useLayout() {
  const [layout, setLayout] = useState(measure);
  useEffect(() => {
    const on = () => setLayout(measure());
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
          <ScreenHeight.Provider value={height}>{children}</ScreenHeight.Provider>
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
