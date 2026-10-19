// World layout. The street runs north (−z) from the family home towards the
// Financial District gateway. Add new interactive spots to LOCATIONS.
export const BOUNDS = { minX: -19, maxX: 19, minZ: -28.5, maxZ: 13 };

export const LOCATIONS = [
  {
    id: 'allowance',
    label: 'Your First Allowance',
    doneLabel: 'Allowance plan',
    action: 'Collect your ₦10,000 allowance',
    doneAction: 'Review your allowance plan',
    panel: 'allowance',
    position: [-4.4, 0, 0.5],
    radius: 2.2,
    icon: '💰',
  },
  {
    id: 'gateway',
    label: 'Financial District',
    action: 'Enter the Financial District',
    panel: 'district',
    position: [0, 0, -25.5],
    radius: 3.2,
    icon: '🏙️',
    requires: 'first-allowance',
    lockedText: 'Complete “Your First Allowance” first',
  },
  {
    id: 'board',
    label: 'Notice board',
    action: 'How to play',
    panel: 'help',
    position: [5.6, 0, 10.6],
    radius: 1.8,
    icon: '📌',
  },
];

// Solid boxes the player can't walk through: [centerX, centerZ, halfX, halfZ]
export const COLLIDERS = [
  [-11, 2, 4, 5], // family home
  [-5.6, 0.5, 0.45, 0.75], // porch table
  [10, 4, 3.5, 2.5], // Mama Ngozi's kiosk
  [5.4, -5, 1.1, 0.7], // parked keke
  [-16, -4.2, 1, 1], // water tank
  [-11, -16, 3, 3.5], // neighbour house west
  [11, -14, 3, 3.5], // neighbour house east
  [-5.55, -1.5, 0.9, 0.1], // open gate leaf
  [5.6, 9.6, 1.1, 0.25], // notice board
  [-4, -25.8, 0.8, 0.8], // gateway pillar
  [4, -25.8, 0.8, 0.8], // gateway pillar
];

// Compound fence around the home, with a gate opening onto the street.
export const FENCES = [
  // [x1, z1, x2, z2]
  [-18, -7, -4.6, -7],
  [-18, 11, -4.6, 11],
  [-18, -7, -18, 11],
  [-4.6, -7, -4.6, -1.6],
  [-4.6, 2.6, -4.6, 11],
];
for (const [x1, z1, x2, z2] of FENCES) {
  COLLIDERS.push([(x1 + x2) / 2, (z1 + z2) / 2, Math.abs(x2 - x1) / 2 + 0.1, Math.abs(z2 - z1) / 2 + 0.1]);
}

export const TREE_SPOTS = [
  [-16.5, 8.5], [-8.5, -10], [-16, -20], [8, -20], [16, -6], [16, 10], [-7, 12], [7, -9.5], [16, -22], [-16, -11],
];
for (const [x, z] of TREE_SPOTS) COLLIDERS.push([x, z, 0.45, 0.45]);
