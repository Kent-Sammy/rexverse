# RexPlay clickable prototype

A tappable web version of the **"rex play"** section of the *Rex Africa Version 2.0 Mobile App* Figma file.
On a phone it fills the screen like the real app; on a laptop it shows in a phone-sized frame.

## Run it

```bash
npm install
npm run assets   # download the images from Figma (needs www.figma.com network access)
npm run dev      # http://localhost:5173
```

## Share it

Deploy this folder to Vercel as its own project (set **Root Directory** to `rexplay-prototype`).
Run `npm run assets` and commit `public/assets/` first, so the images ship with it.

## The flow

1. **Dashboard** opens with the RexPlay promo pop-up. "RexPlay... Let’s Play" (or the green RexPlay banner) opens RexPlay.
2. **RexPlay** lists the games; the filter tabs work and a lone card stays at normal width on the left.
3. **Games** (`src/games.jsx`) — real, playable financial-literacy games:
   - Naira Savings Trivia, Fixed Deposit Challenge, Budgeting Challenge, Money Smart Quiz — 10 timed questions,
     50 points per correct answer, a short money tip after every answer.
   - Saving Habits Poll — 5 questions, 20 points per answer, shows how other players answered.
   ✕ shows the "End game?" sheet.
4. **Results** → **Leaderboard** — your real score, rank and points.
5. Coin counter → **Your RexPlay Rewards** (real stats and recent games) → **Redeem Rewards** →
   **Airtime**, **Data** or **Cash** (paid into your Rex account only) → success receipt → **Rewards History**.
   Points are deducted; rewards you can’t afford yet are greyed out.

Points, games played and redemptions are kept for the browser session (a refresh keeps them; a new tab starts fresh).
The phone back gesture and browser back button work on every screen.

## Editing the games

Questions, answers and the tip shown after each answer live in `src/games.jsx`. Add a game by adding an entry to `GAMES`.

## Code

- `src/screens/` — one file per screen; screens from Figma note the Figma node they came from.
- `src/store.jsx` — points balance, games played and redemptions.
- `src/Phone.jsx` — scales the 402×874 design to the device.
- `scripts/download-assets.mjs` — fetches every Figma image the screens reference into `public/assets/`.
