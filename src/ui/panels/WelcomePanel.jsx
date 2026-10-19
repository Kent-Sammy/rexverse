import Modal from '../Modal.jsx';
import { useGame } from '../../store/useGame.js';

export default function WelcomePanel() {
  const player = useGame((s) => s.player);
  const close = useGame((s) => s.closePanel);
  return (
    <Modal title={`Welcome home, ${player.name}`} icon="🏠" subtitle={`${player.identity} · ${player.dream}`}>
      <p>
        You live with your parents and don’t have money of your own yet. Today your parents are giving you your
        <strong> first allowance</strong> — what you do with it is up to you.
      </p>
      <ol className="steps">
        <li><span>1</span> Walk to the glowing ring by the <strong>porch table</strong> in your family compound (left of the street).</li>
        <li><span>2</span> Press <kbd>E</kbd> to collect ₦10,000 and plan how to spend, save and invest it.</li>
        <li><span>3</span> Then walk north up the street to the <strong>Financial District</strong> gateway.</li>
      </ol>
      <div className="controls-grid">
        <div><kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd> or arrow keys — move</div>
        <div><kbd>Shift</kbd> — run</div>
        <div>Click &amp; drag — turn the camera · scroll — zoom</div>
        <div><kbd>E</kbd> — interact · <kbd>Esc</kbd> — close · <kbd>H</kbd> — help</div>
      </div>
      <div className="modal-actions">
        <button className="btn btn-primary" onClick={close}>Let’s go</button>
      </div>
    </Modal>
  );
}
