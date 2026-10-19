export const SKIN_TONES = ['#f1c27d', '#c68642', '#a0662f', '#8d5524', '#5c3a1e'];
export const HAIR_STYLES = [
  { id: 'short', label: 'Short' },
  { id: 'afro', label: 'Afro' },
  { id: 'braids', label: 'Braids' },
  { id: 'bun', label: 'Bun' },
  { id: 'bald', label: 'Clean' },
];
export const HAIR_COLORS = ['#141414', '#3b2314', '#7a4a21', '#c9a25b', '#5b3fa6'];
export const OUTFITS = [
  { id: 'navy', top: '#002766', bottom: '#1f2937' },
  { id: 'blue', top: '#7399ef', bottom: '#1e293b' },
  { id: 'ankara', top: '#f59e0b', bottom: '#7c2d12', pattern: true },
  { id: 'violet', top: '#7c5cd6', bottom: '#1e1b4b' },
  { id: 'white', top: '#f3f4f6', bottom: '#002766' },
];
export const ACCESSORIES = [
  { id: 'none', label: 'None' },
  { id: 'glasses', label: 'Glasses' },
  { id: 'cap', label: 'Cap' },
];

// Preset characters, each with a simple starting identity.
export const PRESETS = [
  {
    id: 'tobi',
    label: 'Tobi',
    identity: '18 · Surulere, Lagos',
    dream: 'Wants to build a tech start-up.',
    look: { skin: '#8d5524', hair: 'afro', hairColor: '#141414', outfit: 'blue', accessory: 'none' },
  },
  {
    id: 'amaka',
    label: 'Amaka',
    identity: '19 · Enugu',
    dream: 'Dreams of running her own fashion brand.',
    look: { skin: '#5c3a1e', hair: 'braids', hairColor: '#141414', outfit: 'ankara', accessory: 'none' },
  },
  {
    id: 'musa',
    label: 'Musa',
    identity: '18 · Kaduna',
    dream: 'Wants to become a top investor.',
    look: { skin: '#a0662f', hair: 'short', hairColor: '#3b2314', outfit: 'white', accessory: 'cap' },
  },
  {
    id: 'zainab',
    label: 'Zainab',
    identity: '20 · Abuja',
    dream: 'Saving up to study medicine.',
    look: { skin: '#c68642', hair: 'bun', hairColor: '#3b2314', outfit: 'violet', accessory: 'glasses' },
  },
];

export const outfitById = (id) => OUTFITS.find((o) => o.id === id) ?? OUTFITS[0];
