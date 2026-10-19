import { useRef, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import Avatar from '../world/Avatar.jsx';
import { useGame } from '../store/useGame.js';
import { PRESETS, SKIN_TONES, HAIR_STYLES, HAIR_COLORS, OUTFITS, ACCESSORIES } from '../data/avatars.js';
import Logo from './Logo.jsx';
import CanvasBoundary from './CanvasBoundary.jsx';

function Turntable({ look }) {
  const g = useRef();
  const motion = useRef({ speed: 0 });
  useFrame((_, dt) => {
    if (g.current) g.current.rotation.y += dt * 0.6;
  });
  return (
    <group ref={g} position={[0, -0.75, 0]}>
      <Avatar look={look} motion={motion} />
      <mesh rotation={[-Math.PI / 2, 0, 0]}>
        <circleGeometry args={[0.95, 48]} />
        <meshStandardMaterial color="#002766" />
      </mesh>
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.01, 0]}>
        <ringGeometry args={[0.9, 0.98, 48]} />
        <meshBasicMaterial color="#3fd0e8" />
      </mesh>
    </group>
  );
}

function Swatches({ label, options, value, onChange, render }) {
  return (
    <fieldset className="field">
      <legend>{label}</legend>
      <div className="swatches" role="radiogroup" aria-label={label}>
        {options.map((o) => {
          const id = typeof o === 'string' ? o : o.id;
          return (
            <button
              key={id}
              type="button"
              role="radio"
              aria-checked={value === id}
              className={`swatch ${value === id ? 'is-active' : ''}`}
              onClick={() => onChange(id)}
            >
              {render(o)}
            </button>
          );
        })}
      </div>
    </fieldset>
  );
}

export default function AvatarCreator() {
  const createPlayer = useGame((s) => s.createPlayer);
  const backToTitle = useGame((s) => s.backToTitle);
  const [characterId, setCharacterId] = useState(PRESETS[0].id);
  const [look, setLook] = useState(PRESETS[0].look);
  const [name, setName] = useState('');
  const [error, setError] = useState('');
  const [customise, setCustomise] = useState(false);
  const character = PRESETS.find((p) => p.id === characterId);
  const set = (k) => (v) => setLook((l) => ({ ...l, [k]: v }));

  const submit = (e) => {
    e.preventDefault();
    const clean = name.trim().replace(/\s+/g, ' ');
    if (clean.length < 2) {
      setError('Enter a display name with at least 2 characters.');
      return;
    }
    createPlayer({
      name: clean.slice(0, 16),
      characterId,
      character: character.label,
      identity: character.identity,
      dream: character.dream,
      look,
    });
  };

  return (
    <main className="creator">
      <header className="creator-head">
        <button className="btn btn-ghost btn-small" onClick={backToTitle}>← Back</button>
        <Logo size="sm" />
        <span className="step">Create your character</span>
      </header>
      <div className="creator-body">
        <div className="creator-preview">
          <CanvasBoundary>
            <Canvas camera={{ position: [0, 0.15, 4.6], fov: 40 }} dpr={[1, 1.75]} aria-label="Avatar preview">
              <ambientLight intensity={0.75} />
              <directionalLight position={[2, 4, 3]} intensity={1.4} />
              <directionalLight position={[-3, 2, -2]} intensity={1.2} color="#bcd0ff" />
              <directionalLight position={[3, 1, -3]} intensity={0.9} color="#3fd0e8" />
              <Turntable look={look} />
            </Canvas>
          </CanvasBoundary>
          <div className="identity-card">
            <strong>{name.trim() || character.label}</strong>
            <span>{character.identity}</span>
            <span className="muted">{character.dream}</span>
            <span className="identity-start">Starting point: living at your parents’ home · ₦0 of your own</span>
          </div>
        </div>
        <form className="creator-form" onSubmit={submit} noValidate>
          <fieldset className="field">
            <legend>Choose your character</legend>
            <div className="presets">
              {PRESETS.map((p) => (
                <button
                  key={p.id}
                  type="button"
                  className={`preset ${characterId === p.id ? 'is-active' : ''}`}
                  aria-pressed={characterId === p.id}
                  onClick={() => {
                    setCharacterId(p.id);
                    setLook(p.look);
                  }}
                >
                  <span className="preset-dot" style={{ background: p.look.skin }} aria-hidden />
                  <span className="preset-text">
                    <strong>{p.label}</strong>
                    <small>{p.identity}</small>
                  </span>
                </button>
              ))}
            </div>
          </fieldset>

          <label className="field">
            <span className="legend">Display name</span>
            <input
              value={name}
              maxLength={16}
              placeholder="e.g. Tobi_Saves"
              onChange={(e) => {
                setName(e.target.value);
                setError('');
              }}
              aria-invalid={!!error}
              aria-describedby={error ? 'name-error' : undefined}
              autoFocus
            />
          </label>
          {error && <p className="form-error" id="name-error" role="alert">{error}</p>}

          <button type="button" className="link" onClick={() => setCustomise((c) => !c)} aria-expanded={customise}>
            {customise ? '▾' : '▸'} Customise look (optional)
          </button>
          {customise && (
            <div className="customise">
              <Swatches label="Skin tone" options={SKIN_TONES} value={look.skin} onChange={set('skin')}
                render={(c) => <span className="dot" style={{ background: c }} aria-label={`Skin ${c}`} />} />
              <Swatches label="Hairstyle" options={HAIR_STYLES} value={look.hair} onChange={set('hair')} render={(o) => o.label} />
              <Swatches label="Hair colour" options={HAIR_COLORS} value={look.hairColor} onChange={set('hairColor')}
                render={(c) => <span className="dot" style={{ background: c }} aria-label={`Hair ${c}`} />} />
              <Swatches label="Outfit" options={OUTFITS} value={look.outfit} onChange={set('outfit')}
                render={(o) => <span className="dot" style={{ background: `linear-gradient(${o.top} 55%, ${o.bottom} 55%)` }} aria-label={`Outfit ${o.id}`} />} />
              <Swatches label="Accessory" options={ACCESSORIES} value={look.accessory} onChange={set('accessory')} render={(o) => o.label} />
            </div>
          )}

          <button className="btn btn-primary btn-lg" type="submit">
            Enter the world →
          </button>
        </form>
      </div>
    </main>
  );
}
