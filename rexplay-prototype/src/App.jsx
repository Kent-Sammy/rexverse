import { useCallback, useEffect, useState } from 'react';
import Phone from './Phone.jsx';
import Dashboard from './screens/Dashboard.jsx';
import PromoModal from './screens/PromoModal.jsx';
import RexPlayHome from './screens/RexPlayHome.jsx';
import Crowdpurr from './screens/Crowdpurr.jsx';
import GameResults from './screens/GameResults.jsx';
import Leaderboard from './screens/Leaderboard.jsx';
import Rewards from './screens/Rewards.jsx';
import Redeem from './screens/Redeem.jsx';
import RedeemAirtime from './screens/RedeemAirtime.jsx';
import RewardsHistory from './screens/RewardsHistory.jsx';

const SCREENS = {
  dashboard: Dashboard,
  rexplay: RexPlayHome,
  crowdpurr: Crowdpurr,
  results: GameResults,
  leaderboard: Leaderboard,
  rewards: Rewards,
  redeem: Redeem,
  'redeem-airtime': RedeemAirtime,
  history: RewardsHistory,
};

// Background colour around the screen on phones, so notches/edges blend in.
const EDGE = { crowdpurr: '#01296a', results: '#032c70', leaderboard: '#063179' };

// Points shown before and after playing, as in the Figma screens.
const POINTS_AFTER_GAME = 83;

const fromHash = () => {
  const r = window.location.hash.replace(/^#\/?/, '');
  return SCREENS[r] ? r : 'dashboard';
};

export default function App() {
  const [route, setRoute] = useState(fromHash);
  const [promo, setPromo] = useState(() => (fromHash() === 'dashboard' ? 'trophy' : null));
  const [coins, setCoins] = useState(() => (fromHash() === 'dashboard' ? 0 : POINTS_AFTER_GAME));

  // Keep the URL in sync so the phone's back gesture and browser back work.
  useEffect(() => {
    const onPop = () => setRoute(fromHash());
    window.addEventListener('popstate', onPop);
    return () => window.removeEventListener('popstate', onPop);
  }, []);

  const go = useCallback((next, { replace } = {}) => {
    if (!SCREENS[next]) return; // screen not built yet (not loaded from Figma)
    if (next === 'results') setCoins(POINTS_AFTER_GAME);
    setPromo(null);
    const url = `#/${next}`;
    if (replace) window.history.replaceState(null, '', url);
    else window.history.pushState(null, '', url);
    setRoute(next);
  }, []);

  const back = useCallback(() => {
    if (window.history.length > 1 && route !== 'dashboard') window.history.back();
    else go('dashboard', { replace: true });
  }, [go, route]);

  const Screen = SCREENS[route];
  const props = { go, back, coins };
  if (route === 'crowdpurr') props.exitTo = () => go('rexplay', { replace: true });

  return (
    <Phone bg={EDGE[route] || '#f1f5ff'}>
      <div key={route} className="size-full animate-[slide-in_.22s_ease-out]">
        {route === 'dashboard' ? <Dashboard {...props} go={(r) => (r === 'rexplay' ? setPromo('controller') : go(r))} /> : <Screen {...props} />}
      </div>
      {route === 'dashboard' && promo && (
        <PromoModal variant={promo} onClose={() => setPromo(null)} onPlay={() => go('rexplay')} />
      )}
    </Phone>
  );
}
