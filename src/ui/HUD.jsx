import { useGame } from '../store/useGame.js';
import { formatNaira } from '../game/money.js';
import { levelInfo } from '../game/progression.js';
import { MISSIONS } from '../data/missions.js';
import { LOCATIONS } from '../data/locations.js';
import { tryInteract, isLocked } from '../store/interact.js';
import { input } from '../world/input.js';

function PlayerCard() {
  const player = useGame((s) => s.player);
  const xp = useGame((s) => s.xp);
  const level = levelInfo(xp);
  return (
    <section className="hud-card hud-player" aria-label="Player">
      <div className="hud-avatar" aria-hidden>
        <span className="hud-avatar-face" style={{ background: player.look.skin }} />
        <span className="hud-avatar-level">{level.level}</span>
      </div>
      <div className="hud-player-info">
        <div className="hud-name">{player.name}</div>
        <div className="hud-level">Level {level.level} · {level.title}</div>
        <div
          className="xpbar"
          role="progressbar"
          aria-valuemin={0}
          aria-valuemax={100}
          aria-valuenow={Math.round(level.progress * 100)}
          aria-label="Progress to next level"
        >
          <span style={{ width: `${level.progress * 100}%` }} />
        </div>
        <div className="hud-sub">
          {xp} XP{level.next ? ` · ${level.next.xp - xp} to Level ${level.next.level}` : ' · max level'}
        </div>
      </div>
    </section>
  );
}

function WalletCard() {
  const w = useGame((s) => s.wallet);
  const total = w.cash + w.savings + w.investing;
  return (
    <section className="hud-card hud-wallet" aria-label="Virtual wallet">
      <div className="hud-wallet-label">Cash</div>
      <div className="hud-wallet-cash">{formatNaira(w.cash)}</div>
      <div className="hud-wallet-split">
        <span title="Savings">🐷 {formatNaira(w.savings)}</span>
        <span title="Investment pot">📈 {formatNaira(w.investing)}</span>
      </div>
      <div className="hud-wallet-foot">Total {formatNaira(total)} · virtual ₦</div>
    </section>
  );
}

function DailyMission() {
  const completed = useGame((s) => s.completed);
  const current = MISSIONS.find((m) => !completed[m.id]);
  const done = MISSIONS.filter((m) => completed[m.id]).length;
  return (
    <section className="hud-card hud-mission" aria-label="Daily mission">
      <div className="hud-mission-head">
        <span className="eyebrow">Daily mission</span>
        <span className="muted">{done}/{MISSIONS.length}</span>
      </div>
      {current ? (
        <>
          <strong>{current.title}</strong>
          <p>{current.objective}</p>
          <span className="hud-mission-where">📍 {current.where} · {current.xp}</span>
        </>
      ) : (
        <>
          <strong>All missions complete 🎉</strong>
          <p>More life stages, jobs and investing are coming in the next milestone.</p>
        </>
      )}
    </section>
  );
}

function Prompt() {
  const nearby = useGame((s) => s.nearby);
  const activePanel = useGame((s) => s.activePanel);
  const completed = useGame((s) => s.completed);
  const loc = LOCATIONS.find((l) => l.id === nearby);
  if (!loc || activePanel) return null;
  const locked = isLocked(loc, completed);
  const done = loc.id === 'allowance' && completed['first-allowance'];
  return (
    <button className={`prompt ${locked ? 'is-locked' : ''}`} onClick={tryInteract}>
      <kbd>E</kbd>
      <span>
        <strong>{done ? loc.doneLabel : loc.label}</strong>
        <span>{locked ? `🔒 ${loc.lockedText}` : done ? loc.doneAction : loc.action}</span>
      </span>
    </button>
  );
}

function Toasts() {
  const toasts = useGame((s) => s.toasts);
  return (
    <div className="toasts" role="status" aria-live="polite">
      {toasts.map((t) => (
        <div key={t.id} className={`toast toast-${t.tone}`}>{t.text}</div>
      ))}
    </div>
  );
}

// On-screen pad for touch screens (hidden on devices with a mouse).
function TouchPad() {
  const hold = (k) => ({
    onPointerDown: (e) => {
      e.preventDefault();
      input[k] = true;
    },
    onPointerUp: () => (input[k] = false),
    onPointerLeave: () => (input[k] = false),
    onPointerCancel: () => (input[k] = false),
  });
  return (
    <div className="touchpad">
      <button aria-label="Move forward" className="tp-up" {...hold('forward')}>▲</button>
      <button aria-label="Move left" className="tp-left" {...hold('left')}>◀</button>
      <button aria-label="Move right" className="tp-right" {...hold('right')}>▶</button>
      <button aria-label="Move back" className="tp-down" {...hold('back')}>▼</button>
    </div>
  );
}

export default function HUD() {
  const openPanel = useGame((s) => s.openPanel);
  const backToTitle = useGame((s) => s.backToTitle);
  return (
    <div className="hud">
      <div className="hud-top-left">
        <PlayerCard />
        <DailyMission />
      </div>
      <div className="hud-top-right">
        <WalletCard />
        <nav className="hud-nav" aria-label="Game menu">
          <button className="btn btn-small btn-glass" onClick={() => openPanel('help')}>❔ Help</button>
          <button className="btn btn-small btn-glass" onClick={backToTitle}>⏏ Title</button>
        </nav>
      </div>
      <div className="controls-hint" aria-label="Controls">
        <span><kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd> / arrows move</span>
        <span><kbd>Shift</kbd> run</span>
        <span>drag to turn camera</span>
        <span><kbd>E</kbd> interact</span>
      </div>
      <Prompt />
      <Toasts />
      <TouchPad />
    </div>
  );
}
