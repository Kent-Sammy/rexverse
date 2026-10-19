import { useEffect, useState } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';
import World from './world/World.jsx';
import { bindKeyboard, clearInput } from './world/input.js';
import { useGame } from './store/useGame.js';
import { tryInteract } from './store/interact.js';
import HUD from './ui/HUD.jsx';
import Panels from './ui/Panels.jsx';
import LoadingScreen from './ui/LoadingScreen.jsx';
import CanvasBoundary from './ui/CanvasBoundary.jsx';

const isTyping = (t) => t && (t.tagName === 'INPUT' || t.tagName === 'SELECT' || t.tagName === 'TEXTAREA');

export default function Game() {
  const [ready, setReady] = useState(false);
  const activePanel = useGame((s) => s.activePanel);
  const backToTitle = useGame((s) => s.backToTitle);

  // Keyboard: movement, E to interact, Esc to close panels, H for help.
  useEffect(() => {
    const unbind = bindKeyboard();
    const onKey = (e) => {
      if (isTyping(e.target)) return;
      const st = useGame.getState();
      if (e.code === 'Escape' && st.activePanel) {
        st.closePanel();
        return;
      }
      if (st.activePanel) return;
      if (e.code === 'KeyE') tryInteract();
      if (e.code === 'KeyH') st.openPanel('help');
    };
    window.addEventListener('keydown', onKey);
    return () => {
      unbind();
      window.removeEventListener('keydown', onKey);
    };
  }, []);

  // Stop the avatar from walking off on its own when a panel opens.
  useEffect(() => {
    if (activePanel) clearInput();
  }, [activePanel]);

  return (
    <div className="game">
      <CanvasBoundary onReset={backToTitle}>
        <Canvas
          shadows
          dpr={[1, 1.5]}
          camera={{ fov: 50, near: 0.1, far: 220, position: [0, 8, 18] }}
          gl={{ antialias: true, powerPreference: 'high-performance' }}
          onCreated={() => requestAnimationFrame(() => setReady(true))}
        >
          <World />
          <OrbitControls
            makeDefault
            enablePan={false}
            enableDamping
            dampingFactor={0.12}
            minDistance={6}
            maxDistance={22}
            minPolarAngle={0.4}
            maxPolarAngle={1.32}
          />
        </Canvas>
      </CanvasBoundary>
      {!ready && <LoadingScreen />}
      {ready && <HUD />}
      <Panels />
    </div>
  );
}
