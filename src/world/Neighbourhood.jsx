import { useMemo, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { Box, Sign } from './primitives.jsx';
import { C } from './theme.js';
import { FENCES, TREE_SPOTS } from '../data/locations.js';

const STREET_MIN_Z = -28.5;
const STREET_MAX_Z = 14;
const STREET_LEN = STREET_MAX_Z - STREET_MIN_Z;
const STREET_MID = (STREET_MAX_Z + STREET_MIN_Z) / 2;

function Ground() {
  const dashes = useMemo(() => {
    const out = [];
    for (let z = STREET_MAX_Z - 2; z > STREET_MIN_Z + 4; z -= 4) out.push(z);
    return out;
  }, []);
  return (
    <group>
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0, -8]} receiveShadow>
        <planeGeometry args={[90, 90]} />
        <meshStandardMaterial color={C.grass} />
      </mesh>
      {/* sidewalks + street running north */}
      <Box args={[9, 0.04, STREET_LEN]} position={[0, 0.02, STREET_MID]} color={C.sidewalk} cast={false} />
      <Box args={[6, 0.05, STREET_LEN]} position={[0, 0.04, STREET_MID]} color={C.road} cast={false} />
      {dashes.map((z) => (
        <Box key={z} args={[0.18, 0.02, 1.8]} position={[0, 0.075, z]} color={C.line} cast={false} />
      ))}
      {/* kerbs */}
      {[-3.05, 3.05].map((x) => (
        <Box key={x} args={[0.12, 0.12, STREET_LEN]} position={[x, 0.06, STREET_MID]} color="#b8b0a0" cast={false} />
      ))}
      {/* paved path from the street into the compound gate */}
      <Box args={[1.6, 0.05, 3.4]} position={[-3.8, 0.03, 0.5]} color="#c2b8a3" cast={false} />
      {/* compound yard (bare earth) */}
      <Box args={[13.4, 0.03, 18]} position={[-11.3, 0.015, 2]} color="#cfb48a" cast={false} />
    </group>
  );
}

function FamilyHome() {
  // Built facing +z, then rotated so the front faces the street (+x).
  return (
    <group position={[-11, 0, 2]} rotation={[0, Math.PI / 2, 0]}>
      <Box args={[10, 0.4, 8]} position={[0, 0.2, 0]} color="#bfb6a6" />
      <Box args={[10, 3.8, 8]} position={[0, 2.3, 0]} color={C.wallWarm} />
      {/* hipped roof */}
      <mesh position={[0, 5.4, 0]} rotation={[0, Math.PI / 4, 0]} scale={[1.25, 1, 1]} castShadow>
        <coneGeometry args={[6.6, 2.4, 4]} />
        <meshStandardMaterial color={C.roofTerracotta} flatShading />
      </mesh>
      {/* front door + steps */}
      <Box args={[1.4, 2.5, 0.12]} position={[-2.2, 1.65, 4.02]} color="#6b3a16" />
      <mesh position={[-1.75, 1.6, 4.1]}>
        <sphereGeometry args={[0.06, 8, 6]} />
        <meshStandardMaterial color="#e2b13c" metalness={0.8} roughness={0.3} />
      </mesh>
      {/* windows with burglary-proof bars */}
      {[1.4, 3.6, -4.2].map((x) => (
        <group key={x} position={[x, 2.5, 4.03]}>
          <Box args={[1.5, 1.2, 0.06]} color="#a9c4f5" emissive="#002766" emissiveIntensity={0.08} cast={false} />
          {[-0.5, -0.17, 0.17, 0.5].map((bx) => (
            <Box key={bx} args={[0.05, 1.2, 0.08]} position={[bx, 0, 0.04]} color="#3f3f46" cast={false} />
          ))}
        </group>
      ))}
      {/* porch with canopy */}
      <Box args={[10, 0.25, 2.2]} position={[0, 0.12, 5.1]} color="#a8a29e" cast={false} />
      <Box args={[10.4, 0.15, 2.6]} position={[0, 3.4, 5.2]} color="#7a4a21" />
      {[-4.8, 4.8].map((x) => (
        <Box key={x} args={[0.2, 3.3, 0.2]} position={[x, 1.7, 6.2]} color="#e7e5e4" />
      ))}
      <Sign position={[0, 4.15, 4.2]} variant="home">The Adeyemi Family Home</Sign>
    </group>
  );
}

// Porch table holding the allowance envelope (world position matches the collider).
function AllowanceTable() {
  const env = useRef();
  useFrame(({ clock }) => {
    if (env.current) env.current.position.y = 0.98 + Math.sin(clock.elapsedTime * 2.2) * 0.03;
  });
  return (
    <group position={[-5.6, 0, 0.5]}>
      <Box args={[0.9, 0.08, 1.5]} position={[0, 0.85, 0]} color={C.wood} />
      {[[-0.38, -0.65], [0.38, -0.65], [-0.38, 0.65], [0.38, 0.65]].map(([x, z], i) => (
        <Box key={i} args={[0.07, 0.85, 0.07]} position={[x, 0.42, z]} color={C.wood} />
      ))}
      <group ref={env} position={[0, 0.98, 0]}>
        <Box args={[0.42, 0.04, 0.6]} color="#f8fafc" />
        <Box args={[0.43, 0.045, 0.16]} position={[0, 0.005, 0.12]} color={C.blue} cast={false} />
      </group>
      {/* plastic chairs */}
      {[-1, 1].map((z) => (
        <group key={z} position={[-0.1, 0, z * 1.25]}>
          <Box args={[0.5, 0.06, 0.5]} position={[0, 0.48, 0]} color="#e11d48" />
          <Box args={[0.5, 0.55, 0.06]} position={[-0.22, 0.75, 0]} rotation={[0, Math.PI / 2, 0]} color="#e11d48" />
          {[[-0.2, -0.2], [0.2, -0.2], [-0.2, 0.2], [0.2, 0.2]].map(([x, zz], i) => (
            <Box key={i} args={[0.05, 0.48, 0.05]} position={[x, 0.24, zz]} color="#be123c" cast={false} />
          ))}
        </group>
      ))}
    </group>
  );
}

function Fences() {
  return FENCES.map(([x1, z1, x2, z2], i) => {
    const len = Math.hypot(x2 - x1, z2 - z1);
    const horizontal = z1 === z2;
    return (
      <group key={i} position={[(x1 + x2) / 2, 0, (z1 + z2) / 2]}>
        <Box args={horizontal ? [len, 1.5, 0.25] : [0.25, 1.5, len]} position={[0, 0.75, 0]} color="#e8dfcc" />
        <Box args={horizontal ? [len + 0.1, 0.12, 0.35] : [0.35, 0.12, len + 0.1]} position={[0, 1.55, 0]} color="#9a8f7a" />
      </group>
    );
  });
}

function Gate() {
  return (
    <group position={[-4.6, 0, 0.5]}>
      {[-2.1, 2.1].map((z) => (
        <Box key={z} args={[0.45, 2.1, 0.45]} position={[0, 1.05, z]} color="#cfc4ad" />
      ))}
      {/* open metal gate leaves */}
      <Box args={[1.8, 1.5, 0.06]} position={[-0.95, 0.85, -2]} rotation={[0, 0, 0]} color={C.navy} metalness={0.4} roughness={0.5} />
    </group>
  );
}

function YardDetails() {
  return (
    <group>
      {/* water tank on a stand */}
      <group position={[-16, 0, -4.2]}>
        {[[-0.7, -0.7], [0.7, -0.7], [-0.7, 0.7], [0.7, 0.7]].map(([x, z], i) => (
          <Box key={i} args={[0.12, 1.6, 0.12]} position={[x, 0.8, z]} color="#4b5563" />
        ))}
        <Box args={[1.7, 0.1, 1.7]} position={[0, 1.6, 0]} color="#4b5563" />
        <mesh position={[0, 2.35, 0]} castShadow>
          <cylinderGeometry args={[0.8, 0.8, 1.4, 18]} />
          <meshStandardMaterial color="#1d4ed8" />
        </mesh>
      </group>
      {/* clothesline */}
      <group position={[-12, 0, 9]}>
        {[-2.5, 2.5].map((x) => (
          <Box key={x} args={[0.08, 2, 0.08]} position={[x, 1, 0]} color="#52525b" />
        ))}
        <Box args={[5, 0.02, 0.02]} position={[0, 1.95, 0]} color="#d4d4d8" cast={false} />
        {[[-1.6, '#f59e0b'], [-0.5, '#7399ef'], [0.6, '#f8fafc'], [1.6, '#7c5cd6']].map(([x, c]) => (
          <Box key={x} args={[0.7, 0.8, 0.03]} position={[x, 1.5, 0]} color={c} />
        ))}
      </group>
      {/* generator */}
      <group position={[-7.6, 0, -5.6]}>
        <Box args={[1, 0.7, 0.7]} position={[0, 0.35, 0]} color="#dc2626" />
        <Box args={[1.05, 0.08, 0.75]} position={[0, 0.75, 0]} color="#111827" />
      </group>
      {/* potted plants on the porch */}
      {[-6.2, 3.6].map((z) => (
        <group key={z} position={[-6, 0, z]}>
          <mesh position={[0, 0.3, 0]} castShadow>
            <cylinderGeometry args={[0.28, 0.2, 0.6, 10]} />
            <meshStandardMaterial color="#b45309" />
          </mesh>
          <mesh position={[0, 0.85, 0]} castShadow>
            <icosahedronGeometry args={[0.4, 0]} />
            <meshStandardMaterial color="#3f8f3a" flatShading />
          </mesh>
        </group>
      ))}
    </group>
  );
}

function Kiosk() {
  // Mama Ngozi's provisions kiosk across the street, facing it (−x).
  return (
    <group position={[10.5, 0, 4]} rotation={[0, -Math.PI / 2, 0]}>
      <Box args={[5, 3, 6]} position={[0, 1.5, 0]} color="#fde68a" />
      <Box args={[5.4, 0.25, 6.4]} position={[0, 3.12, 0]} color="#92400e" />
      {Array.from({ length: 5 }).map((_, i) => (
        <Box key={i} args={[1, 0.08, 1.4]} position={[-2 + i, 2.6, 3.55]} rotation={[0.35, 0, 0]} color={i % 2 ? '#ffffff' : C.blue} />
      ))}
      <Box args={[3.2, 1.6, 0.1]} position={[0, 1.4, 3.02]} color="#1f2937" />
      <Box args={[3.4, 0.9, 0.7]} position={[0, 0.45, 3.4]} color="#a16207" />
      {[-0.9, 0, 0.9].map((x, i) => (
        <mesh key={x} position={[x, 1.05, 3.4]} castShadow>
          <sphereGeometry args={[0.22, 10, 8]} />
          <meshStandardMaterial color={['#f97316', '#65a30d', '#facc15'][i]} />
        </mesh>
      ))}
      <Sign position={[0, 3.55, 3.3]} variant="kiosk">Mama Ngozi&apos;s Provisions</Sign>
    </group>
  );
}

function Keke() {
  // Parked tricycle taxi.
  return (
    <group position={[5.4, 0, -5]} rotation={[0, Math.PI / 2, 0]}>
      <Box args={[1.2, 0.9, 1.9]} position={[0, 0.85, 0]} color="#facc15" />
      <Box args={[1.25, 0.12, 2]} position={[0, 1.85, -0.1]} color="#111827" />
      {[[-0.55, 0.7], [0.55, 0.7]].map(([x, z], i) => (
        <Box key={i} args={[0.06, 0.9, 0.06]} position={[x, 1.35, z]} color="#111827" />
      ))}
      {[[-0.6, -0.6], [0.6, -0.6], [0, 0.9]].map(([x, z], i) => (
        <mesh key={i} position={[x, 0.3, z]} rotation={[0, 0, Math.PI / 2]} castShadow>
          <cylinderGeometry args={[0.3, 0.3, 0.18, 14]} />
          <meshStandardMaterial color="#18181b" />
        </mesh>
      ))}
    </group>
  );
}

function NeighbourHouse({ position, wall, roof, rotation = 0 }) {
  return (
    <group position={position} rotation={[0, rotation, 0]}>
      <Box args={[7, 3.4, 6]} position={[0, 1.7, 0]} color={wall} />
      <mesh position={[0, 4.3, 0]} rotation={[0, Math.PI / 4, 0]} scale={[1.15, 1, 1]} castShadow>
        <coneGeometry args={[4.9, 1.9, 4]} />
        <meshStandardMaterial color={roof} flatShading />
      </mesh>
      <Box args={[1.2, 2.2, 0.1]} position={[0, 1.1, 3.02]} color="#4b2e16" />
      {[-2.2, 2.2].map((x) => (
        <Box key={x} args={[1.2, 1, 0.06]} position={[x, 2, 3.02]} color="#a9c4f5" cast={false} />
      ))}
    </group>
  );
}

function Trees() {
  return TREE_SPOTS.map(([x, z], i) => (
    <group key={i} position={[x, 0, z]} scale={0.9 + (i % 3) * 0.15}>
      <mesh position={[0, 1.1, 0]} castShadow>
        <cylinderGeometry args={[0.2, 0.3, 2.2, 7]} />
        <meshStandardMaterial color="#6b4220" />
      </mesh>
      {i % 3 === 1 ? (
        // palm: fronds as flattened cones
        <group position={[0, 2.3, 0]}>
          {[0, 1, 2, 3, 4, 5].map((k) => (
            <mesh key={k} rotation={[0.9, (k / 6) * Math.PI * 2, 0]} position={[Math.sin((k / 6) * Math.PI * 2) * 0.6, 0, Math.cos((k / 6) * Math.PI * 2) * 0.6]} castShadow>
              <coneGeometry args={[0.35, 1.8, 4]} />
              <meshStandardMaterial color="#3d8b3d" flatShading />
            </mesh>
          ))}
        </group>
      ) : (
        <mesh position={[0, 2.9, 0]} castShadow>
          <icosahedronGeometry args={[1.4, 0]} />
          <meshStandardMaterial color={i % 2 ? '#4d9c45' : '#3e8a3f'} flatShading />
        </mesh>
      )}
    </group>
  ));
}

function StreetLamps() {
  const spots = [[-4.2, 8], [4.2, -1], [-4.2, -10], [4.2, -17], [-4.2, -22]];
  return spots.map(([x, z], i) => (
    <group key={i} position={[x, 0, z]}>
      <Box args={[0.14, 3.6, 0.14]} position={[0, 1.8, 0]} color="#334155" />
      <Box args={[0.9, 0.1, 0.14]} position={[x < 0 ? 0.4 : -0.4, 3.6, 0]} color="#334155" />
      <mesh position={[x < 0 ? 0.8 : -0.8, 3.5, 0]}>
        <sphereGeometry args={[0.18, 10, 8]} />
        <meshStandardMaterial color="#fff7d6" emissive="#fde68a" emissiveIntensity={0.9} />
      </mesh>
    </group>
  ));
}

function NoticeBoard() {
  return (
    <group position={[5.6, 0, 9.6]}>
      {[-0.9, 0.9].map((x) => (
        <Box key={x} args={[0.12, 1.9, 0.12]} position={[x, 0.95, 0]} color="#5b3a1a" />
      ))}
      <Box args={[2.1, 1.3, 0.12]} position={[0, 1.75, 0]} color="#8b5a2b" />
      <Box args={[1.9, 1.1, 0.04]} position={[0, 1.75, 0.08]} color="#f5ecd7" cast={false} />
      <Sign position={[0, 1.75, 0.12]} variant="board" scale={5}>
        HOW TO PLAY
      </Sign>
    </group>
  );
}

// Bunting across the street makes the neighbourhood feel lived-in.
function Bunting() {
  const flags = useMemo(() => Array.from({ length: 12 }, (_, i) => i), []);
  return (
    <group position={[0, 0, -3]}>
      {flags.map((i) => {
        const x = -4.4 + i * 0.8;
        const sag = 4.2 - Math.sin((i / 11) * Math.PI) * 0.5;
        return (
          <mesh key={i} position={[x, sag, 0]} rotation={[0, 0, Math.PI]}>
            <coneGeometry args={[0.2, 0.4, 3]} />
            <meshStandardMaterial color={[C.blue, '#f8fafc', '#16a34a', '#f59e0b'][i % 4]} />
          </mesh>
        );
      })}
      {[-4.6, 4.6].map((x) => (
        <Box key={x} args={[0.1, 4.4, 0.1]} position={[x, 2.2, 0]} color="#64748b" />
      ))}
    </group>
  );
}

export default function Neighbourhood() {
  return (
    <group>
      <Ground />
      <FamilyHome />
      <AllowanceTable />
      <Fences />
      <Gate />
      <YardDetails />
      <Kiosk />
      <Keke />
      <NeighbourHouse position={[-11, 0, -16]} wall="#e9d5ff" roof="#7c2d12" rotation={Math.PI / 2} />
      <NeighbourHouse position={[11, 0, -14]} wall="#cfe0ff" roof="#9a3412" rotation={-Math.PI / 2} />
      <Trees />
      <StreetLamps />
      <NoticeBoard />
      <Bunting />
    </group>
  );
}
