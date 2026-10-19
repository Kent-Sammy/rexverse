import { Sky } from '@react-three/drei';
import Neighbourhood from './Neighbourhood.jsx';
import FinancialDistrict from './FinancialDistrict.jsx';
import Hotspots from './Hotspots.jsx';
import Player from './Player.jsx';
import { BOUNDS } from '../data/locations.js';

// Soft hedges marking the edges of the neighbourhood.
function Hedges() {
  const { minX, maxX, maxZ } = BOUNDS;
  const len = maxZ - -28.5;
  const mid = (maxZ + -28.5) / 2;
  return (
    <group>
      {[minX - 0.4, maxX + 0.4].map((x) => (
        <mesh key={x} position={[x, 0.6, mid]} castShadow receiveShadow>
          <boxGeometry args={[0.8, 1.2, len]} />
          <meshStandardMaterial color="#4e8c45" />
        </mesh>
      ))}
      <mesh position={[0, 0.6, maxZ + 0.4]} castShadow receiveShadow>
        <boxGeometry args={[maxX - minX + 1.6, 1.2, 0.8]} />
        <meshStandardMaterial color="#4e8c45" />
      </mesh>
    </group>
  );
}

export default function World() {
  return (
    <>
      <color attach="background" args={['#cfe1fb']} />
      <Sky sunPosition={[40, 22, 30]} turbidity={5} rayleigh={1.1} mieCoefficient={0.004} />
      <fog attach="fog" args={['#d8e4f7', 45, 115]} />
      <hemisphereLight args={['#fff6e8', '#6b8f5e', 0.7]} />
      <ambientLight intensity={0.15} color="#7399ef" />
      <directionalLight
        position={[22, 30, 14]}
        intensity={1.7}
        color="#fff1dc"
        castShadow
        shadow-mapSize={[1024, 1024]}
        shadow-camera-left={-32}
        shadow-camera-right={32}
        shadow-camera-top={32}
        shadow-camera-bottom={-32}
        shadow-camera-near={1}
        shadow-camera-far={90}
        shadow-bias={-0.0006}
      />
      <Neighbourhood />
      <FinancialDistrict />
      <Hedges />
      <Hotspots />
      <Player />
    </>
  );
}
