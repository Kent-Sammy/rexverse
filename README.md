# REXVERSE — First Playable Prototype

**Play. Learn. Invest. Grow.** A browser-based 3D financial life simulation for young Nigerians, powered by REX.

This milestone is one playable slice: create a character, walk around your family's neighbourhood, complete **Your First Allowance** (split ₦10,000 between spending, saving and investing), then walk up the street to the **Financial District** gateway.

> All money is virtual. Nothing in this prototype involves real money, real securities or real financial products.

## Run it locally

Requires Node.js 18+.

```bash
npm install
npm run dev        # http://localhost:5173
```

Other commands:

```bash
npm test           # unit tests for money, allocation rules, levels and the game store
npm run build      # production build into dist/
npm run preview    # serve the production build at http://localhost:4173
```

## Deploy to Vercel

**From the dashboard:** push this repo to GitHub → vercel.com → *Add New… → Project* → import the repo. Vercel detects Vite automatically (`vercel.json` pins build `npm run build`, output `dist`). Click **Deploy**.

**From the CLI:**

```bash
npm i -g vercel
vercel           # first time: link/create the project, deploys a preview
vercel --prod    # deploy to production
```

No environment variables, backend or paid services are needed.

## How to play

| Action | Control |
|---|---|
| Move | `W A S D` or arrow keys (on-screen pad on touch screens) |
| Run | `Shift` |
| Turn camera / zoom | click-and-drag / scroll |
| Interact | `E` (or click the prompt) when standing in a glowing ring |
| Close window | `Esc` |
| Help | `H` |

The journey: **Enter REXVERSE → choose a character and name → porch table in your family compound (left of the street) → plan your ₦10,000 → mission complete → walk north to the Financial District gateway → open NGX Stock Exchange preview.**

Progress (character, wallet, XP, missions, allocation) is saved in `localStorage`. Reloading shows **Continue**, and **Help → Restart game** clears the save.

## Architecture

```
src/
  main.jsx, App.jsx        app entry; routes between intro → avatar → game (3D is lazy-loaded)
  Game.jsx                 R3F <Canvas>, orbit camera, keyboard handling, HUD + panels
  game/                    pure, unit-tested logic (no React)
    allowance.js           ₦10,000 split validation + feedback/XP rules
    progression.js         XP → level
    money.js               naira formatting/rounding
    market.js, portfolio.js, random.js   simulated stock engine for the next milestone (tested, not wired in yet)
  store/
    useGame.js             Zustand store (persisted): player, wallet, XP, missions, allocation
    interact.js            "press E" logic + location locking
  data/                    content you edit to extend the game
    avatars.js             characters, identities, customisation options
    missions.js            mission list (first incomplete = daily mission)
    locations.js           interactive hotspots, colliders, world bounds
    stocks.js              fictional companies for the upcoming NGX gameplay
  world/                   3D scene (procedural low-poly geometry, no external assets)
    World.jsx              lights, sky, composition
    Neighbourhood.jsx      family home, compound, street, kiosk, keke, trees, lamps
    FinancialDistrict.jsx  gateway, plaza, skyline, NGX hall
    Player.jsx             movement, camera follow, collisions, hotspot detection
    Avatar.jsx             primitive humanoid with walk cycle + customisation
    Hotspots.jsx           glowing interaction rings and labels
  ui/                      DOM overlay (HUD, modals, screens) styled in styles.css
    panels/                Welcome, Allowance mission, Financial District + NGX preview, Help
tests/                     Vitest unit tests
```

### Extending

- **New mission:** add it to `data/missions.js`, add a store action that calls `completeMission(id, xp)` internally, and build a panel in `ui/panels/`.
- **New interactive place:** add a location to `data/locations.js` (`panel`, `position`, `radius`, optional `requires`), add colliders, add its geometry under `world/`, and register its panel in `ui/Panels.jsx`.
- **Brand colours:** CSS tokens at the top of `styles.css` and `world/theme.js`.

## Known limitations (this milestone)

- Collisions use simple axis-aligned boxes and circles, so they're tight but not pixel-perfect.
- Characters and buildings are procedural low-poly geometry. Swapping in licensed GLB models later is straightforward with drei's `useGLTF`.
- The Financial District hub is a 2D transition screen. Only the NGX Stock Exchange opens (as an explanatory preview). The others say "coming soon".
- Progress is saved per browser (no accounts, by design).
