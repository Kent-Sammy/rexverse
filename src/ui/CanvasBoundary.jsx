import { Component } from 'react';

export function hasWebGL() {
  try {
    const c = document.createElement('canvas');
    return !!(window.WebGLRenderingContext && (c.getContext('webgl2') || c.getContext('webgl')));
  } catch {
    return false;
  }
}

// Catches 3D/WebGL failures and shows a friendly message instead of a blank screen.
export default class CanvasBoundary extends Component {
  state = { error: null };

  static getDerivedStateFromError(error) {
    return { error };
  }

  componentDidCatch(error) {
    console.error('REXVERSE 3D error:', error);
  }

  render() {
    if (this.state.error || !hasWebGL()) {
      return (
        <div className="canvas-error" role="alert">
          <strong>We couldn’t start the 3D view.</strong>
          <span>
            Your browser or device may not support WebGL, or hardware acceleration is turned off. Try the
            latest Chrome, Edge or Firefox, enable hardware acceleration, then reload.
          </span>
          {this.props.onReset && (
            <button className="btn btn-small" onClick={this.props.onReset}>Back to title</button>
          )}
        </div>
      );
    }
    return this.props.children;
  }
}
