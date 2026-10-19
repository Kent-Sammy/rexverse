import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { outfitById } from '../data/avatars.js';

// Low-poly humanoid built from primitives (~1.8 units tall).
// `motion.current.speed` (0..1) drives the walk cycle.
export default function Avatar({ look, motion }) {
  const outfit = outfitById(look.outfit);
  const legL = useRef();
  const legR = useRef();
  const armL = useRef();
  const armR = useRef();
  const body = useRef();
  const phase = useRef(0);

  useFrame((_, dt) => {
    const speed = motion?.current?.speed ?? 0;
    phase.current += dt * (6 + speed * 6) * (speed > 0.05 ? 1 : 0);
    const swing = Math.sin(phase.current) * 0.7 * Math.min(1, speed * 1.5);
    if (legL.current) {
      legL.current.rotation.x = swing;
      legR.current.rotation.x = -swing;
      armL.current.rotation.x = -swing * 0.8;
      armR.current.rotation.x = swing * 0.8;
      // Gentle idle breathing / walk bob
      const t = performance.now() / 1000;
      body.current.position.y = speed > 0.05 ? Math.abs(Math.sin(phase.current)) * 0.06 : Math.sin(t * 2) * 0.01;
    }
  });

  const skin = look.skin;
  const shoe = '#111827';
  const hasCap = look.accessory === 'cap';

  return (
    <group ref={body}>
      {/* Legs (pivot at hips) */}
      {[
        [legL, -0.14],
        [legR, 0.14],
      ].map(([ref, x], i) => (
        <group key={i} ref={ref} position={[x, 0.85, 0]}>
          <mesh position={[0, -0.4, 0]} castShadow>
            <boxGeometry args={[0.2, 0.8, 0.22]} />
            <meshStandardMaterial color={outfit.bottom} />
          </mesh>
          <mesh position={[0, -0.8, 0.05]} castShadow>
            <boxGeometry args={[0.22, 0.12, 0.32]} />
            <meshStandardMaterial color={shoe} roughness={0.5} />
          </mesh>
        </group>
      ))}

      {/* Torso */}
      <mesh position={[0, 1.15, 0]} castShadow>
        <boxGeometry args={[0.56, 0.62, 0.3]} />
        <meshStandardMaterial color={outfit.top} />
      </mesh>
      {outfit.pattern && (
        <>
          {[-0.15, 0, 0.15].map((x) => (
            <mesh key={x} position={[x, 1.15, 0.155]}>
              <circleGeometry args={[0.06, 6]} />
              <meshStandardMaterial color="#7c2d12" />
            </mesh>
          ))}
        </>
      )}

      {/* Arms (pivot at shoulders) */}
      {[
        [armL, -0.36],
        [armR, 0.36],
      ].map(([ref, x], i) => (
        <group key={i} ref={ref} position={[x, 1.42, 0]}>
          <mesh position={[0, -0.27, 0]} castShadow>
            <boxGeometry args={[0.15, 0.55, 0.17]} />
            <meshStandardMaterial color={outfit.top} />
          </mesh>
          <mesh position={[0, -0.6, 0]} castShadow>
            <sphereGeometry args={[0.08, 10, 8]} />
            <meshStandardMaterial color={skin} />
          </mesh>
        </group>
      ))}

      {/* Head */}
      <mesh position={[0, 1.62, 0]}>
        <cylinderGeometry args={[0.07, 0.08, 0.12, 10]} />
        <meshStandardMaterial color={skin} />
      </mesh>
      <mesh position={[0, 1.83, 0]} castShadow>
        <sphereGeometry args={[0.22, 20, 16]} />
        <meshStandardMaterial color={skin} />
      </mesh>
      {/* Eyes */}
      {[-0.075, 0.075].map((x) => (
        <mesh key={x} position={[x, 1.86, 0.2]}>
          <sphereGeometry args={[0.025, 8, 6]} />
          <meshStandardMaterial color="#111" />
        </mesh>
      ))}

      <Hair style={hasCap && look.hair !== 'bald' ? 'short' : look.hair} color={look.hairColor} />

      {look.accessory === 'glasses' && <Glasses color="#111827" lens="#bfdbfe" />}
      {hasCap && (
        <group position={[0, 1.9, 0]}>
          <mesh>
            <sphereGeometry args={[0.225, 18, 10, 0, Math.PI * 2, 0, Math.PI / 2]} />
            <meshStandardMaterial color="#7399ef" />
          </mesh>
          <mesh position={[0, 0.02, 0.22]} rotation={[0.1, 0, 0]}>
            <boxGeometry args={[0.3, 0.03, 0.2]} />
            <meshStandardMaterial color="#002766" />
          </mesh>
        </group>
      )}
    </group>
  );
}

function Glasses({ color, lens }) {
  return (
    <group position={[0, 1.86, 0.215]}>
      {[-0.08, 0.08].map((x) => (
        <mesh key={x} position={[x, 0, 0]}>
          <boxGeometry args={[0.11, 0.07, 0.02]} />
          <meshStandardMaterial color={lens} transparent opacity={0.85} />
        </mesh>
      ))}
      <mesh>
        <boxGeometry args={[0.3, 0.02, 0.02]} />
        <meshStandardMaterial color={color} />
      </mesh>
    </group>
  );
}

function Hair({ style, color }) {
  const mat = <meshStandardMaterial color={color} roughness={0.9} />;
  switch (style) {
    case 'afro':
      return (
        <mesh position={[0, 1.95, -0.03]} castShadow>
          <sphereGeometry args={[0.3, 16, 12]} />
          {mat}
        </mesh>
      );
    case 'braids':
      return (
        <group>
          <mesh position={[0, 1.88, -0.01]}>
            <sphereGeometry args={[0.235, 16, 12, 0, Math.PI * 2, 0, Math.PI / 1.9]} />
            {mat}
          </mesh>
          {[-0.16, -0.08, 0, 0.08, 0.16].map((x, i) => (
            <mesh key={i} position={[x, 1.6, -0.17]} castShadow>
              <cylinderGeometry args={[0.03, 0.025, 0.55, 6]} />
              {mat}
            </mesh>
          ))}
        </group>
      );
    case 'bun':
      return (
        <group>
          <mesh position={[0, 1.88, -0.01]}>
            <sphereGeometry args={[0.235, 16, 12, 0, Math.PI * 2, 0, Math.PI / 1.9]} />
            {mat}
          </mesh>
          <mesh position={[0, 2.1, -0.08]} castShadow>
            <sphereGeometry args={[0.12, 12, 10]} />
            {mat}
          </mesh>
        </group>
      );
    case 'short':
      return (
        <mesh position={[0, 1.87, -0.005]}>
          <sphereGeometry args={[0.228, 16, 12, 0, Math.PI * 2, 0, Math.PI / 2.2]} />
          {mat}
        </mesh>
      );
    default:
      return null;
  }
}
