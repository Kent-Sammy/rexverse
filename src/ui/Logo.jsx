export default function Logo({ size = 'lg' }) {
  return (
    <div className={`logo logo-${size}`} aria-label="REXVERSE">
      <span className="logo-gem" aria-hidden />
      <span className="logo-rex">REX</span>
      <span className="logo-verse">VERSE</span>
    </div>
  );
}
