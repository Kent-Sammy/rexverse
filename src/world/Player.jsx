import { useEffect, useRef } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import { Vector3 } from 'three';
import Avatar from './Avatar.jsx';
import { input } from './input.js';
import { useGame } from '../store/useGame.js';
import { COLLIDERS, LOCATIONS, BOUNDS } from '../data/locations.js';

const RADIUS = 0.45;
const WALK = 5.5;
const RUN = 9;
const SPAWN = new Vector3(0, 0, 7);
const CAM_OFFSET = new Vector3(0, 7.5, 11);
const EYE = 1.3;

const fwd = new Vector3();
const right = new Vector3();
const move = new Vector3();
const delta = new Vector3();

// Push a point out of any building box it overlaps.
function resolveCollisions(p) {
  for (const [cx, cz, hx, hz] of COLLIDERS) {
    const ex = hx + RADIUS;
    const ez = hz + RADIUS;
    const dx = p.x - cx;
    const dz = p.z - cz;
    if (Math.abs(dx) < ex && Math.abs(dz) < ez) {
      const px = ex - Math.abs(dx);
      const pz = ez - Math.abs(dz);
      if (px < pz) p.x += Math.sign(dx || 1) * px;
      else p.z += Math.sign(dz || 1) * pz;
    }
  }
  p.x = Math.max(BOUNDS.minX + RADIUS, Math.min(BOUNDS.maxX - RADIUS, p.x));
  p.z = Math.max(BOUNDS.minZ + RADIUS, Math.min(BOUNDS.maxZ - RADIUS, p.z));
}

const lerpAngle = (a, b, t) => {
  let d = ((b - a + Math.PI) % (Math.PI * 2)) - Math.PI;
  if (d < -Math.PI) d += Math.PI * 2;
  return a + d * t;
};

export default function Player() {
  const root = useRef();
  const facing = useRef();
  const motion = useRef({ speed: 0 });
  const look = useGame((s) => s.player.look);
  const camera = useThree((s) => s.camera);
  const controls = useThree((s) => s.controls);

  // ?debug in the URL exposes the player position (used by automated journey tests).
  useEffect(() => {
    if (!window.location.search.includes('debug')) return;
    window.__rexPlayer = () => root.current && { x: root.current.position.x, z: root.current.position.z };
    return () => delete window.__rexPlayer;
  }, []);

  useEffect(() => {
    if (!controls) return;
    controls.target.set(SPAWN.x, EYE, SPAWN.z);
    camera.position.copy(SPAWN).add(CAM_OFFSET);
    controls.update();
  }, [controls, camera]);

  useFrame((_, rawDt) => {
    const dt = Math.min(rawDt, 0.05);
    const g = root.current;
    if (!g) return;
    const st = useGame.getState();
    const paused = !!st.activePanel;

    camera.getWorldDirection(fwd);
    fwd.y = 0;
    fwd.normalize();
    right.set(-fwd.z, 0, fwd.x);

    const mz = paused ? 0 : (input.forward ? 1 : 0) - (input.back ? 1 : 0);
    const mx = paused ? 0 : (input.right ? 1 : 0) - (input.left ? 1 : 0);
    move.set(0, 0, 0).addScaledVector(fwd, mz).addScaledVector(right, mx);
    const moving = move.lengthSq() > 0;
    const speed = input.sprint ? RUN : WALK;

    if (moving) {
      move.normalize();
      const before = g.position.clone();
      g.position.addScaledVector(move, speed * dt);
      resolveCollisions(g.position);
      delta.subVectors(g.position, before);
      // Camera follows the player while keeping the user's chosen orbit angle.
      camera.position.add(delta);
      if (controls) controls.target.add(delta);
      const targetYaw = Math.atan2(move.x, move.z);
      facing.current.rotation.y = lerpAngle(facing.current.rotation.y, targetYaw, Math.min(1, dt * 12));
    }
    motion.current.speed += ((moving ? (input.sprint ? 1 : 0.65) : 0) - motion.current.speed) * Math.min(1, dt * 10);

    // Which hotspot is the player standing near?
    let best = null;
    let bestD = Infinity;
    for (const loc of LOCATIONS) {
      const d = Math.hypot(g.position.x - loc.position[0], g.position.z - loc.position[2]);
      if (d < loc.radius && d < bestD) {
        best = loc.id;
        bestD = d;
      }
    }
    st.setNearby(best);
  });

  return (
    <group ref={root} position={SPAWN.toArray()}>
      <group ref={facing} rotation={[0, Math.PI, 0]}>
        <Avatar look={look} motion={motion} />
      </group>
      {/* Soft blob shadow helps on low shadow-map resolutions */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.02, 0]}>
        <circleGeometry args={[0.45, 20]} />
        <meshBasicMaterial color="#000" transparent opacity={0.18} depthWrite={false} />
      </mesh>
    </group>
  );
}
