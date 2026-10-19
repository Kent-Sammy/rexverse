// Shared keyboard/touch state read every frame by the player.
export const input = { forward: false, back: false, left: false, right: false, sprint: false };

const KEYMAP = {
  KeyW: 'forward', ArrowUp: 'forward',
  KeyS: 'back', ArrowDown: 'back',
  KeyA: 'left', ArrowLeft: 'left',
  KeyD: 'right', ArrowRight: 'right',
  ShiftLeft: 'sprint', ShiftRight: 'sprint',
};

const isTyping = (e) => {
  const t = e.target;
  return t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.tagName === 'SELECT' || t.isContentEditable);
};

export function bindKeyboard() {
  const down = (e) => {
    if (isTyping(e)) return;
    const k = KEYMAP[e.code];
    if (k) {
      input[k] = true;
      if (e.code.startsWith('Arrow')) e.preventDefault();
    }
  };
  const up = (e) => {
    const k = KEYMAP[e.code];
    if (k) input[k] = false;
  };
  const clear = () => Object.keys(input).forEach((k) => (input[k] = false));
  window.addEventListener('keydown', down);
  window.addEventListener('keyup', up);
  window.addEventListener('blur', clear);
  return () => {
    window.removeEventListener('keydown', down);
    window.removeEventListener('keyup', up);
    window.removeEventListener('blur', clear);
    clear();
  };
}

export const clearInput = () => Object.keys(input).forEach((k) => (input[k] = false));
