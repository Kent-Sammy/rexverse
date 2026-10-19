import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { Html } from '@react-three/drei';
import { LOCATIONS } from '../data/locations.js';
import { useGame } from '../store/useGame.js';
import { isLocked } from '../store/interact.js';

const MISSION_FOR = { allowance: 'first-allowance', gateway: 'visit-district' };

function Hotspot({ loc }) {
  const ring = useRef();
  const icon = useRef();
  const nearby = useGame((s) => s.nearby === loc.id);
  const completed = useGame((s) => s.completed);
  const locked = isLocked(loc, completed);
  const done = MISSION_FOR[loc.id] && completed[MISSION_FOR[loc.id]];
  const color = locked ? '#94a3b8' : done ? '#7399ef' : '#3fd0e8';
  const label = done && loc.doneLabel ? loc.doneLabel : loc.label;

  useFrame(({ clock }) => {
    const t = clock.elapsedTime;
    if (ring.current) {
      const s = 1 + Math.sin(t * 3 + loc.position[2]) * 0.06 + (nearby ? 0.1 : 0);
      ring.current.scale.set(s, s, s);
    }
    if (icon.current) icon.current.position.y = 2.7 + Math.sin(t * 2 + loc.position[0]) * 0.12;
  });

  return (
    <group position={loc.position}>
      <mesh ref={ring} rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.12, 0]}>
        <ringGeometry args={[loc.radius * 0.5, loc.radius * 0.62, 48]} />
        <meshBasicMaterial color={color} transparent opacity={nearby ? 0.95 : 0.65} depthWrite={false} />
      </mesh>
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.11, 0]}>
        <circleGeometry args={[loc.radius * 0.5, 48]} />
        <meshBasicMaterial color={color} transparent opacity={0.14} depthWrite={false} />
      </mesh>
      <group ref={icon} position={[0, 2.7, 0]}>
        <Html center distanceFactor={14} zIndexRange={[20, 0]} style={{ pointerEvents: 'none' }}>
          <div className={`world-label ${nearby ? 'is-near' : ''} ${locked ? 'is-locked' : ''} ${done ? 'is-done' : ''}`}>
            <span className="world-label-icon" aria-hidden>{locked ? '🔒' : done ? '✓' : loc.icon}</span>
            <span>{label}</span>
          </div>
        </Html>
      </group>
    </group>
  );
}

export default function Hotspots() {
  return LOCATIONS.map((loc) => <Hotspot key={loc.id} loc={loc} />);
}
