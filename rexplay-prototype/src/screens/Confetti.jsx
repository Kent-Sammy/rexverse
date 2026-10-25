import { useEffect, useRef } from 'react';

// One-off confetti burst in Rex colours. Two cannons fire from the lower corners and a
// shower falls from the top; everything fades out after a few seconds.
const COLORS = ['#ffcb05', '#ffd84d', '#2c6ef2', '#8fb6ff', '#22a447', '#7cf29c', '#e44555', '#ffffff'];
const DURATION = 4200;

const rand = (a, b) => a + Math.random() * (b - a);

function makePieces(w, h) {
  const pieces = [];
  const add = (x, y, angle, speed) =>
    pieces.push({
      x,
      y,
      vx: Math.cos(angle) * speed,
      vy: Math.sin(angle) * speed,
      size: rand(5, 10),
      ratio: rand(0.4, 1),
      color: COLORS[Math.floor(Math.random() * COLORS.length)],
      rot: rand(0, Math.PI * 2),
      spin: rand(-0.25, 0.25),
      wobble: rand(0, Math.PI * 2),
      round: Math.random() < 0.25,
    });
  for (let i = 0; i < 70; i++) add(-10, h * 0.62, rand(-1.35, -0.75), rand(9, 16)); // left cannon
  for (let i = 0; i < 70; i++) add(w + 10, h * 0.62, rand(-2.4, -1.8), rand(9, 16)); // right cannon
  for (let i = 0; i < 60; i++) add(rand(0, w), rand(-h * 0.4, -10), rand(1.3, 1.85), rand(1, 3)); // shower
  return pieces;
}

export default function Confetti({ width = 402, height = 874 }) {
  const ref = useRef(null);

  useEffect(() => {
    if (window.matchMedia?.('(prefers-reduced-motion: reduce)').matches) return undefined;
    const canvas = ref.current;
    const ctx = canvas.getContext('2d');
    const dpr = 2;
    canvas.width = width * dpr;
    canvas.height = height * dpr;
    ctx.scale(dpr, dpr);

    const pieces = makePieces(width, height);
    const start = performance.now();
    let frame;

    const tick = (now) => {
      const t = now - start;
      ctx.clearRect(0, 0, width, height);
      const fade = t > DURATION - 900 ? Math.max(0, (DURATION - t) / 900) : 1;
      for (const p of pieces) {
        p.vy += 0.28; // gravity
        p.vx *= 0.985; // air drag
        p.vy *= 0.985;
        p.wobble += 0.12;
        p.x += p.vx + Math.sin(p.wobble) * 0.6;
        p.y += p.vy;
        p.rot += p.spin;
        if (p.y > height + 20) continue;
        ctx.save();
        ctx.globalAlpha = fade;
        ctx.translate(p.x, p.y);
        ctx.rotate(p.rot);
        ctx.fillStyle = p.color;
        if (p.round) {
          ctx.beginPath();
          ctx.arc(0, 0, p.size * 0.4, 0, Math.PI * 2);
          ctx.fill();
        } else {
          // scaleY flutter makes the paper look like it's turning in the air
          ctx.scale(1, Math.cos(p.wobble));
          ctx.fillRect(-p.size / 2, (-p.size * p.ratio) / 2, p.size, p.size * p.ratio);
        }
        ctx.restore();
      }
      if (t < DURATION) frame = requestAnimationFrame(tick);
      else ctx.clearRect(0, 0, width, height);
    };
    frame = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(frame);
  }, [width, height]);

  return <canvas ref={ref} className="absolute inset-0 z-40 pointer-events-none" style={{ width, height }} aria-hidden="true" />;
}
