import Modal from '../Modal.jsx';
import { useGame } from '../../store/useGame.js';

export default function HelpPanel() {
  const close = useGame((s) => s.closePanel);
  const resetGame = useGame((s) => s.resetGame);
  return (
    <Modal title="How to play" icon="📌">
      <div className="controls-grid">
        <div><kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd> or arrow keys — move</div>
        <div><kbd>Shift</kbd> — run</div>
        <div>Click &amp; drag — turn the camera · scroll — zoom</div>
        <div><kbd>E</kbd> — interact with glowing rings</div>
        <div><kbd>Esc</kbd> — close a window</div>
        <div>On touch screens use the arrow pad (bottom left)</div>
      </div>
      <h3>Where to go</h3>
      <ul className="plain">
        <li>💰 <strong>Porch table</strong> (your family compound, left of the street) — “Your First Allowance”.</li>
        <li>🏙️ <strong>Financial District gateway</strong> (north end of the street) — unlocks after your first allowance.</li>
      </ul>
      <p className="muted small">
        Your progress is saved in this browser automatically. Everything here uses virtual money — nothing is real
        trading, saving or borrowing.
      </p>
      <div className="modal-actions">
        <button
          className="btn btn-ghost"
          onClick={() => {
            if (window.confirm('Restart from the beginning? This clears your saved progress.')) resetGame();
          }}
        >
          Restart game
        </button>
        <button className="btn btn-primary" onClick={close}>Back to the game</button>
      </div>
    </Modal>
  );
}
