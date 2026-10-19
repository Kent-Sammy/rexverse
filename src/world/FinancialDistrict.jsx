import { useMemo, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { Box, Sign } from './primitives.jsx';
import { C } from './theme.js';
import { useGame } from '../store/useGame.js';

const GATE_Z = -25.8;

function Tower({ position, size, color = C.navy, accent = C.blue, stripes = 6 }) {
  const [w, h, d] = size;
  return (
    <group position={position}>
      <Box args={[w, h, d]} position={[0, h / 2, 0]} color={color} metalness={0.35} roughness={0.35} />
      {Array.from({ length: stripes }).map((_, i) => (
        <Box
          key={i}
          args={[w + 0.04, 0.12, d + 0.04]}
          position={[0, ((i + 1) * h) / (stripes + 1), 0]}
          color={accent}
          emissive={accent}
          emissiveIntensity={0.55}
          cast={false}
        />
      ))}
      <Box args={[w * 0.6, 0.5, d * 0.6]} position={[0, h + 0.25, 0]} color={accent} emissive={accent} emissiveIntensity={0.3} />
    </group>
  );
}

function Gateway({ unlocked }) {
  const ring = useRef();
  const portal = useRef();
  useFrame(({ clock }) => {
    const t = clock.elapsedTime;
    if (ring.current) ring.current.rotation.z = t * 0.4;
    if (portal.current) portal.current.material.opacity = (unlocked ? 0.28 : 0.12) + Math.sin(t * 2) * 0.06;
  });
  const glow = unlocked ? C.cyan : '#94a3b8';
  return (
    <group position={[0, 0, GATE_Z]}>
      {[-4, 4].map((x) => (
        <group key={x} position={[x, 0, 0]}>
          <Box args={[1.4, 0.5, 1.4]} position={[0, 0.25, 0]} color="#1e293b" />
          <Box args={[1.1, 7, 1.1]} position={[0, 3.75, 0]} color={C.navy} metalness={0.4} roughness={0.3} />
          <Box args={[0.16, 6.4, 1.14]} position={[x < 0 ? 0.56 : -0.56, 3.8, 0]} color={glow} emissive={glow} emissiveIntensity={0.9} cast={false} />
        </group>
      ))}
      <Box args={[10, 1, 1.3]} position={[0, 7.6, 0]} color={C.navy} metalness={0.4} roughness={0.3} />
      <Box args={[9.4, 0.14, 1.34]} position={[0, 7.15, 0]} color={C.blue} emissive={C.blue} emissiveIntensity={0.8} cast={false} />
      {/* rotating emblem */}
      <group position={[0, 9.4, 0]}>
        <mesh ref={ring}>
          <torusGeometry args={[1, 0.08, 8, 40]} />
          <meshStandardMaterial color={C.cyan} emissive={C.cyan} emissiveIntensity={0.8} />
        </mesh>
        <mesh>
          <octahedronGeometry args={[0.55]} />
          <meshStandardMaterial color={C.blue} emissive={C.blue} emissiveIntensity={0.5} metalness={0.5} roughness={0.2} />
        </mesh>
      </group>
      {/* shimmering portal plane */}
      <mesh ref={portal} position={[0, 3.6, 0]}>
        <planeGeometry args={[6.8, 7]} />
        <meshBasicMaterial color={unlocked ? C.cyan : '#cbd5e1'} transparent opacity={0.25} depthWrite={false} />
      </mesh>
      <Sign position={[0, 7.6, 0.7]} variant="district" scale={9}>
        FINANCIAL DISTRICT
      </Sign>
    </group>
  );
}

function Plaza() {
  const tiles = useMemo(() => {
    const out = [];
    for (let x = -14; x <= 14; x += 4) for (let z = -24; z >= -40; z -= 4) out.push([x, z]);
    return out;
  }, []);
  return (
    <group>
      <Box args={[44, 0.06, 24]} position={[0, 0.03, -36]} color="#dfe6f3" cast={false} />
      {tiles.map(([x, z]) => (
        <Box key={`${x}${z}`} args={[3.9, 0.02, 0.06]} position={[x, 0.07, z]} color={C.blue} emissive={C.blue} emissiveIntensity={0.2} cast={false} />
      ))}
      {/* glowing path continues the street through the gate */}
      <Box args={[3, 0.04, 20]} position={[0, 0.08, -34]} color="#c7d6f7" cast={false} />
      {[-1.6, 1.6].map((x) => (
        <Box key={x} args={[0.1, 0.04, 20]} position={[x, 0.1, -34]} color={C.cyan} emissive={C.cyan} emissiveIntensity={0.7} cast={false} />
      ))}
    </group>
  );
}

// Low glowing barrier marking the edge of the playable area for this milestone.
function DistrictEdge() {
  return (
    <group position={[0, 0, -28.6]}>
      {[-11.75, 11.75].map((x) => (
        <group key={x} position={[x, 0, 0]}>
          <Box args={[14.5, 0.9, 0.5]} position={[0, 0.45, 0]} color="#3f7a3a" />
          <Box args={[14.5, 0.08, 0.52]} position={[0, 0.95, 0]} color={C.blue} emissive={C.blue} emissiveIntensity={0.5} cast={false} />
        </group>
      ))}
    </group>
  );
}

function Skyline() {
  return (
    <group>
      <Tower position={[-10, 0, -40]} size={[5, 18, 5]} />
      <Tower position={[-3.5, 0, -46]} size={[4.5, 26, 4.5]} color="#0b2f73" accent={C.cyan} stripes={9} />
      <Tower position={[4, 0, -42]} size={[5.5, 21, 5]} color="#13306e" accent={C.purple} stripes={7} />
      <Tower position={[12, 0, -39]} size={[4.5, 14, 4.5]} />
      <Tower position={[-17, 0, -45]} size={[5, 12, 5]} color="#1c3a7a" accent={C.blue} stripes={4} />
      <Tower position={[17.5, 0, -46]} size={[6, 17, 5]} color="#0b2f73" accent={C.cyan} stripes={5} />
      {/* NGX-style exchange hall at the end of the glowing path */}
      <group position={[0, 0, -36]}>
        <Box args={[9, 0.6, 5]} position={[0, 0.3, 0]} color="#e2e8f0" />
        {[-3.4, -1.7, 0, 1.7, 3.4].map((x) => (
          <mesh key={x} position={[x, 2.6, 2]} castShadow>
            <cylinderGeometry args={[0.3, 0.34, 4, 12]} />
            <meshStandardMaterial color="#f8fafc" />
          </mesh>
        ))}
        <Box args={[9, 4.4, 3.4]} position={[0, 2.8, -0.6]} color="#cbd5e1" />
        <Box args={[9.6, 0.6, 5.4]} position={[0, 4.9, 0]} color={C.navy} />
        <Box args={[9.62, 0.12, 5.42]} position={[0, 4.62, 0]} color={C.cyan} emissive={C.cyan} emissiveIntensity={0.7} cast={false} />
        <Sign position={[0, 4.9, 2.75]} variant="district small" scale={8}>NGX STOCK EXCHANGE</Sign>
      </group>
    </group>
  );
}

export default function FinancialDistrict() {
  const unlocked = useGame((s) => !!s.completed['first-allowance']);
  return (
    <group>
      <Plaza />
      <DistrictEdge />
      <Gateway unlocked={unlocked} />
      <Skyline />
    </group>
  );
}
