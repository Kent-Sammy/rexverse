import { useEffect, useRef } from 'react';
import { useGame } from '../store/useGame.js';

export default function Modal({ title, icon, subtitle, wide, children }) {
  const close = useGame((s) => s.closePanel);
  const ref = useRef();
  useEffect(() => {
    const prev = document.activeElement;
    ref.current?.focus();
    return () => prev?.focus?.();
  }, []);
  return (
    <div className="overlay" onMouseDown={(e) => e.target === e.currentTarget && close()}>
      <div
        ref={ref}
        className={`modal ${wide ? 'modal-wide' : ''}`}
        role="dialog"
        aria-modal="true"
        aria-label={title}
        tabIndex={-1}
      >
        <header className="modal-head">
          <div>
            <h2>
              {icon && <span aria-hidden>{icon} </span>}
              {title}
            </h2>
            {subtitle && <p className="muted">{subtitle}</p>}
          </div>
          <button className="icon-btn" onClick={close} aria-label="Close (Esc)">✕</button>
        </header>
        <div className="modal-body">{children}</div>
      </div>
    </div>
  );
}

export function Notice({ tone = 'info', children }) {
  return <div className={`notice notice-${tone}`} role={tone === 'error' ? 'alert' : undefined}>{children}</div>;
}
