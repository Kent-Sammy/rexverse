import { Html } from '@react-three/drei';

export function Box({ args, position, rotation, color, cast = true, receive = true, ...mat }) {
  return (
    <mesh position={position} rotation={rotation} castShadow={cast} receiveShadow={receive}>
      <boxGeometry args={args} />
      <meshStandardMaterial color={color} {...mat} />
    </mesh>
  );
}

// A DOM label pinned in 3D space (crisp text without loading font files).
export function Sign({ position, rotation, children, variant = '', scale = 8 }) {
  return (
    <Html
      position={position}
      rotation={rotation}
      transform
      center
      distanceFactor={scale}
      zIndexRange={[20, 0]}
      style={{ pointerEvents: 'none' }}
    >
      <div className={`world-sign ${variant}`}>{children}</div>
    </Html>
  );
}
