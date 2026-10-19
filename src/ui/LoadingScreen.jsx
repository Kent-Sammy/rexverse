export default function LoadingScreen({ text = 'Building your neighbourhood…' }) {
  return (
    <div className="loading" role="status" aria-live="polite">
      <div className="loading-gem" aria-hidden />
      <p>{text}</p>
    </div>
  );
}
