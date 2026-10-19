import { useGame } from './useGame.js';
import { LOCATIONS } from '../data/locations.js';

export const isLocked = (loc, completed) => !!loc.requires && !completed[loc.requires];

export function tryInteract() {
  const st = useGame.getState();
  const loc = LOCATIONS.find((l) => l.id === st.nearby);
  if (!loc || st.activePanel) return;
  if (isLocked(loc, st.completed)) {
    st.toast(`🔒 ${loc.lockedText}. Head back home to the porch table.`, 'warn');
    return;
  }
  st.openPanel(loc.panel);
}
