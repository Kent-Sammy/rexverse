import { lazy, Suspense } from 'react';
import { useGame } from './store/useGame.js';
import IntroScreen from './ui/IntroScreen.jsx';
import AvatarCreator from './ui/AvatarCreator.jsx';
import LoadingScreen from './ui/LoadingScreen.jsx';

// The 3D game is loaded on demand so the title screen appears instantly.
const Game = lazy(() => import('./Game.jsx'));

export default function App() {
  const phase = useGame((s) => s.phase);
  if (phase === 'intro') return <IntroScreen />;
  if (phase === 'avatar') return <AvatarCreator />;
  return (
    <Suspense fallback={<LoadingScreen />}>
      <Game />
    </Suspense>
  );
}
