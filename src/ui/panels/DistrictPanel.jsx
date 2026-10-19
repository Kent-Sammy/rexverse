import { useEffect, useState } from 'react';
import { useGame } from '../../store/useGame.js';
import { formatNaira } from '../../game/money.js';

const DESTINATIONS = [
  {
    id: 'ngx',
    name: 'NGX Stock Exchange',
    icon: '📈',
    text: 'Buy and sell simulated shares, track your portfolio and learn about risk.',
    status: 'Open preview',
    available: true,
  },
  {
    id: 'savings',
    name: 'RexSave & RexVault',
    icon: '🐷',
    text: 'Savings goals, emergency funds and fixed-term savings.',
    status: 'Coming soon',
  },
  {
    id: 'business',
    name: 'Business District',
    icon: '🏪',
    text: 'Start a virtual business and learn about revenue, costs and profit.',
    status: 'Coming soon',
  },
  {
    id: 'arena',
    name: 'Financial Challenge Arena',
    icon: '🏆',
    text: 'Quizzes, missions and campus competitions.',
    status: 'Coming soon',
  },
];

function NgxPlaceholder({ onBack }) {
  const investing = useGame((s) => s.wallet.investing);
  return (
    <div className="ngx">
      <button className="btn btn-ghost btn-small" onClick={onBack}>← Financial District</button>
      <div className="ngx-hero">
        <span className="eyebrow">NGX Stock Exchange · simulated</span>
        <h2>Investment gameplay is coming next</h2>
        <p>
          This is where you’ll put your investment pot to work. In the next milestone you’ll be able to:
        </p>
        <ul className="plain ngx-list">
          <li>📊 See simulated share prices for fictional Nigerian companies move in real time</li>
          <li>🛒 Buy and sell shares with your virtual naira (including trading fees)</li>
          <li>🧺 Build a diversified portfolio across sectors</li>
          <li>📉 Track gains and losses — and learn why prices go down as well as up</li>
        </ul>
        <div className="ngx-pot">
          <span>Your investment pot</span>
          <strong>{formatNaira(investing)}</strong>
          <small>{investing > 0 ? 'Ready and waiting for when trading opens.' : 'You didn’t set any money aside for investing this time.'}</small>
        </div>
        <p className="muted small">
          Simulated only. No real securities, prices or returns. Not financial advice.
        </p>
      </div>
    </div>
  );
}

export default function DistrictPanel() {
  const close = useGame((s) => s.closePanel);
  const visitDistrict = useGame((s) => s.visitDistrict);
  const [view, setView] = useState('hub');
  const [note, setNote] = useState(null);

  useEffect(() => {
    visitDistrict();
  }, [visitDistrict]);

  return (
    <div className="district" role="dialog" aria-modal="true" aria-label="Financial District">
      <div className="district-bg" aria-hidden>
        <div className="district-grid" />
        <div className="district-skyline">
          {[55, 80, 65, 95, 70, 85, 60, 75, 50, 88].map((h, i) => (
            <i key={i} style={{ height: `${h}%` }} />
          ))}
        </div>
      </div>
      <div className="district-inner">
        {view === 'hub' ? (
          <>
            <header className="district-head">
              <span className="eyebrow">Welcome to</span>
              <h1>The Financial District</h1>
              <p>The heart of REXVERSE. These are the places you’ll unlock as you grow.</p>
            </header>
            <div className="dest-grid">
              {DESTINATIONS.map((d) => (
                <button
                  key={d.id}
                  className={`dest ${d.available ? 'is-open' : 'is-soon'}`}
                  onClick={() => (d.available ? setView(d.id) : setNote(`${d.name} opens in a future update.`))}
                  aria-disabled={!d.available}
                >
                  <span className="dest-icon" aria-hidden>{d.icon}</span>
                  <strong>{d.name}</strong>
                  <span>{d.text}</span>
                  <span className={`dest-status ${d.available ? 'open' : ''}`}>{d.available ? '● ' : '🔒 '}{d.status}</span>
                </button>
              ))}
            </div>
            <p className="district-note" aria-live="polite">{note ?? ' '}</p>
            <div className="district-actions">
              <button className="btn btn-glass" onClick={close}>← Back to the neighbourhood</button>
            </div>
          </>
        ) : (
          <NgxPlaceholder onBack={() => setView('hub')} />
        )}
      </div>
    </div>
  );
}
