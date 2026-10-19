import { useGame } from '../store/useGame.js';
import Logo from './Logo.jsx';

const PILLARS = [
  { icon: '🎮', title: 'Play', text: 'Explore a 3D neighbourhood with your own avatar.' },
  { icon: '📚', title: 'Learn', text: 'Make real-life money choices and see what they mean.' },
  { icon: '📈', title: 'Invest', text: 'Head to the Financial District and the NGX Stock Exchange.' },
  { icon: '🌱', title: 'Grow', text: 'Earn XP, level up and build your virtual net worth.' },
];

export default function IntroScreen() {
  const goToAvatar = useGame((s) => s.goToAvatar);
  const continueGame = useGame((s) => s.continueGame);
  const resetGame = useGame((s) => s.resetGame);
  const player = useGame((s) => s.player);

  return (
    <main className="intro">
      <div className="intro-bg" aria-hidden>
        <div className="intro-grid" />
        <span className="orb orb-a" />
        <span className="orb orb-b" />
        <span className="orb orb-c" />
        <div className="intro-skyline">
          {[38, 62, 48, 80, 55, 70, 42, 90, 58, 46, 66, 36].map((h, i) => (
            <i key={i} style={{ height: `${h}%` }} />
          ))}
        </div>
      </div>
      <section className="intro-card">
        <span className="eyebrow">Powered by REX</span>
        <Logo />
        <p className="tagline">Play. Learn. Invest. Grow.</p>
        <p className="intro-lede">
          Start with a small allowance at your parents’ home. Make money decisions, see what they
          mean, and work your way towards financial independence — with virtual naira, no real money.
        </p>
        <div className="intro-actions">
          {player ? (
            <>
              <button className="btn btn-primary btn-lg" onClick={continueGame}>
                Continue as {player.name}
              </button>
              <button
                className="btn btn-ghost"
                onClick={() => {
                  if (window.confirm('Start a new game? Your saved progress will be replaced.')) {
                    resetGame();
                    goToAvatar();
                  }
                }}
              >
                New game
              </button>
            </>
          ) : (
            <button className="btn btn-primary btn-lg" onClick={goToAvatar}>
              Enter REXVERSE
            </button>
          )}
        </div>
        <div className="pillars">
          {PILLARS.map((p) => (
            <div key={p.title} className="pillar">
              <span className="pillar-icon" aria-hidden>{p.icon}</span>
              <strong>{p.title}</strong>
              <span>{p.text}</span>
            </div>
          ))}
        </div>
        <p className="disclaimer">
          Prototype · No account needed · All money is virtual and all outcomes are simulated. Best on
          a laptop with a keyboard.
        </p>
      </section>
    </main>
  );
}
