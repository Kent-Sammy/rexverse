import { useState } from 'react';
import Modal, { Notice } from '../Modal.jsx';
import { useGame } from '../../store/useGame.js';
import { formatNaira } from '../../game/money.js';
import { ALLOWANCE, CATEGORIES, validateAllocation, assessAllocation } from '../../game/allowance.js';

const PRESETS = [
  { label: '50 / 30 / 20', values: { spending: 5000, saving: 3000, investing: 2000 } },
  { label: 'Treat myself', values: { spending: 8000, saving: 2000, investing: 0 } },
  { label: 'Safety first', values: { spending: 3000, saving: 6000, investing: 1000 } },
];

const toInt = (text) => (/^\d+$/.test(text) ? Number(text) : NaN);

function Intro({ onNext }) {
  return (
    <div className="allowance-intro">
      <div className="envelope" aria-hidden>
        <span>₦10,000</span>
      </div>
      <p>
        Your parents hand you an envelope: <strong>{formatNaira(ALLOWANCE)}</strong> — your very first allowance.
        “Use it wisely,” they say.
      </p>
      <p>You’ll decide how much to keep for <strong>spending</strong>, how much to <strong>save</strong>, and how much to set aside for <strong>investing</strong>. There’s no single right answer — but every choice has consequences.</p>
      <p className="muted small">This is a simulation with virtual money.</p>
      <div className="modal-actions">
        <button className="btn btn-primary" onClick={onNext}>Receive {formatNaira(ALLOWANCE)}</button>
      </div>
    </div>
  );
}

function Allocate({ onDone }) {
  const completeAllowance = useGame((s) => s.completeAllowance);
  const [text, setText] = useState({ spending: '', saving: '', investing: '' });
  const [submitted, setSubmitted] = useState(false);
  const [serverErrors, setServerErrors] = useState([]);

  const values = Object.fromEntries(CATEGORIES.map((c) => [c.id, toInt(text[c.id])]));
  const check = validateAllocation(values);
  const allocated = check.sum;
  const remaining = ALLOWANCE - allocated;

  const update = (id, raw) => {
    setServerErrors([]);
    const cleaned = String(raw).replace(/[^\d]/g, '').replace(/^0+(?=\d)/, '').slice(0, 5);
    setText((t) => ({ ...t, [id]: cleaned }));
  };
  const fillRemaining = (id) => {
    const others = CATEGORIES.filter((c) => c.id !== id).reduce((s, c) => s + (toInt(text[c.id]) || 0), 0);
    update(id, String(Math.max(0, ALLOWANCE - others)));
  };

  const confirm = () => {
    setSubmitted(true);
    if (!check.ok) return;
    const r = completeAllowance(values);
    if (!r.ok) setServerErrors(r.errors);
    else onDone();
  };

  return (
    <div>
      <p>Split your {formatNaira(ALLOWANCE)}. The three amounts must add up to <strong>exactly {formatNaira(ALLOWANCE)}</strong>.</p>
      <div className="chips" aria-label="Quick plans">
        {PRESETS.map((p) => (
          <button
            key={p.label}
            className="chip"
            onClick={() => {
              setServerErrors([]);
              setText(Object.fromEntries(Object.entries(p.values).map(([k, v]) => [k, String(v)])));
            }}
          >
            {p.label}
          </button>
        ))}
        <button className="chip" onClick={() => setText({ spending: '', saving: '', investing: '' })}>Clear</button>
      </div>

      <div className="alloc-rows">
        {CATEGORIES.map((c) => {
          const v = toInt(text[c.id]);
          const pct = Number.isFinite(v) ? Math.round((v / ALLOWANCE) * 100) : 0;
          return (
            <div key={c.id} className={`alloc-row alloc-${c.id}`}>
              <div className="alloc-label">
                <span className="alloc-icon" aria-hidden>{c.icon}</span>
                <span>
                  <strong>{c.label}</strong>
                  <small>{c.hint}</small>
                </span>
              </div>
              <input
                type="range"
                min={0}
                max={ALLOWANCE}
                step={500}
                value={Number.isFinite(v) ? Math.min(v, ALLOWANCE) : 0}
                onChange={(e) => update(c.id, e.target.value)}
                aria-label={`${c.label} slider`}
              />
              <div className="alloc-input">
                <span aria-hidden>₦</span>
                <input
                  inputMode="numeric"
                  value={text[c.id]}
                  placeholder="0"
                  onChange={(e) => update(c.id, e.target.value)}
                  aria-label={`${c.label} amount in naira`}
                />
              </div>
              <span className="alloc-pct">{pct}%</span>
              <button className="link small" onClick={() => fillRemaining(c.id)} title="Put whatever is left here">
                Fill rest
              </button>
            </div>
          );
        })}
      </div>

      <div className="alloc-bar" aria-hidden>
        {CATEGORIES.map((c) => {
          const v = toInt(text[c.id]);
          return <span key={c.id} className={`seg-${c.id}`} style={{ width: `${Math.min(100, ((Number.isFinite(v) ? v : 0) / ALLOWANCE) * 100)}%` }} />;
        })}
      </div>

      <div className={`alloc-status ${remaining === 0 ? 'is-ok' : remaining < 0 ? 'is-over' : ''}`} aria-live="polite">
        <span>Allocated {formatNaira(allocated)} of {formatNaira(ALLOWANCE)}</span>
        <strong>
          {remaining === 0 ? '✓ Perfectly allocated' : remaining > 0 ? `${formatNaira(remaining)} left to allocate` : `${formatNaira(-remaining)} over — reduce something`}
        </strong>
      </div>

      {submitted && !check.ok && (
        <Notice tone="error">
          <ul>{check.errors.map((e) => <li key={e}>{e}</li>)}</ul>
        </Notice>
      )}
      {serverErrors.length > 0 && <Notice tone="error">{serverErrors.join(' ')}</Notice>}

      <div className="modal-actions">
        <button className="btn btn-primary" onClick={confirm} disabled={submitted && !check.ok}>
          Confirm my plan
        </button>
      </div>
    </div>
  );
}

function Complete({ allocation, fresh }) {
  const close = useGame((s) => s.closePanel);
  const result = assessAllocation(allocation);
  return (
    <div className="complete">
      {fresh && (
        <div className="complete-banner">
          <span className="eyebrow">Mission complete</span>
          <h3>Your First Allowance</h3>
          <div className="xp-burst">+{allocation.xp} XP</div>
        </div>
      )}
      <div className="profile">
        <span className="eyebrow">Your money style</span>
        <strong>{result.title}</strong>
        <p>{result.summary}</p>
      </div>
      <div className="split-cards">
        {CATEGORIES.map((c) => (
          <div key={c.id} className={`split-card seg-${c.id}-soft`}>
            <span aria-hidden>{c.icon}</span>
            <small>{c.label}</small>
            <strong>{formatNaira(allocation[c.id])}</strong>
            <small>{Math.round((allocation[c.id] / ALLOWANCE) * 100)}%</small>
          </div>
        ))}
      </div>
      <h4>What this means</h4>
      <ul className="plain notes">
        {result.notes.map((n) => <li key={n}>{n}</li>)}
      </ul>
      {fresh && (
        <p className="muted small">
          Your wallet has been updated. Your investment pot will be usable at the NGX Stock Exchange in a future update.
          The <strong>Financial District gateway</strong> at the north end of the street is now open.
        </p>
      )}
      <div className="modal-actions">
        <button className="btn btn-primary" onClick={close}>Continue exploring</button>
      </div>
    </div>
  );
}

export default function AllowancePanel() {
  const allocation = useGame((s) => s.allocation);
  const [step, setStep] = useState(allocation ? 'review' : 'intro');

  const title = step === 'review' ? 'Your allowance plan' : 'Your First Allowance';
  return (
    <Modal title={title} icon="💰" subtitle={step === 'allocate' ? 'Decide how to spend, save and invest.' : undefined}>
      {step === 'intro' && <Intro onNext={() => setStep('allocate')} />}
      {step === 'allocate' && <Allocate onDone={() => setStep('done')} />}
      {(step === 'done' || step === 'review') && allocation && <Complete allocation={allocation} fresh={step === 'done'} />}
    </Modal>
  );
}
