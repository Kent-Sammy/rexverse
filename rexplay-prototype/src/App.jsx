import { useCallback, useEffect, useState } from 'react';
import Phone from './Phone.jsx';
import { StoreProvider, useStore } from './store.jsx';
import Dashboard from './screens/Dashboard.jsx';
import PromoModal from './screens/PromoModal.jsx';
import RexPlayHome from './screens/RexPlayHome.jsx';
import Game from './screens/Game.jsx';
import GameResults from './screens/GameResults.jsx';
import Leaderboard from './screens/Leaderboard.jsx';
import Rewards from './screens/Rewards.jsx';
import Redeem from './screens/Redeem.jsx';
import RedeemForm from './screens/RedeemForm.jsx';
import RewardsHistory from './screens/RewardsHistory.jsx';

// Routes look like #/rexplay, #/game/fixed-deposit, #/redeem/cash.
const SCREENS = {
  dashboard: Dashboard,
  rexplay: RexPlayHome,
  game: Game,
  results: GameResults,
  leaderboard: Leaderboard,
  rewards: Rewards,
  redeem: Redeem,
  history: RewardsHistory,
};
const withParam = { redeem: RedeemForm };

// Background colour around the screen on phones, so notches/edges blend in.
const EDGE = { game: '#01296a', results: '#032c70', leaderboard: '#063179' };

const parse = (path) => {
  const [name, param] = path.replace(/^#?\/?/, '').split('/');
  return SCREENS[name] ? { name, param } : { name: 'dashboard' };
};
const fromHash = () => parse(window.location.hash);

function Shell() {
  const { coins } = useStore();
  const [route, setRoute] = useState(fromHash);
  const [promo, setPromo] = useState(() => (fromHash().name === 'dashboard' ? 'trophy' : null));

  // Keep the URL in sync so the phone's back gesture and browser back work.
  useEffect(() => {
    const onPop = () => setRoute(fromHash());
    window.addEventListener('popstate', onPop);
    return () => window.removeEventListener('popstate', onPop);
  }, []);

  const go = useCallback((path, { replace } = {}) => {
    const next = parse(path);
    if (next.name !== path.split('/')[0]) return; // unknown screen
    setPromo(null);
    const url = `#/${path}`;
    if (replace) window.history.replaceState(null, '', url);
    else window.history.pushState(null, '', url);
    setRoute(next);
  }, []);

  const back = useCallback(() => {
    if (window.history.length > 1 && route.name !== 'dashboard') window.history.back();
    else go('dashboard', { replace: true });
  }, [go, route]);

  const Screen = (route.param && withParam[route.name]) || SCREENS[route.name];
  const props = { go, back, coins, param: route.param };

  return (
    <Phone bg={EDGE[route.name] || '#f1f5ff'}>
      <div key={`${route.name}/${route.param || ''}`} className="size-full animate-[slide-in_.22s_ease-out]">
        {route.name === 'dashboard' ? (
          <Dashboard {...props} go={(r) => (r === 'rexplay' ? setPromo('controller') : go(r))} />
        ) : (
          <Screen {...props} />
        )}
      </div>
      {route.name === 'dashboard' && promo && (
        <PromoModal variant={promo} onClose={() => setPromo(null)} onPlay={() => go('rexplay')} />
      )}
    </Phone>
  );
}

export default function App() {
  return (
    <StoreProvider>
      <Shell />
    </StoreProvider>
  );
}
