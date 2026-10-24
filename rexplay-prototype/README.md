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
2. **RexPlay** — filter tabs work; any game card opens the live game.
3. **Crowdpurr** (live game) — the game itself runs on Crowdpurr, so the prototype ends it after 6 seconds, or on a tap.
   ✕ shows the "End game?" sheet.
4. **Results** → **Leaderboard** (All Players / Top 10).
5. Coin counter → **Your RexPlay Rewards** → **Redeem Rewards** → **Redeem Airtime**
   (pick an amount or type one, enter a phone number, Redeem Now) → **Airtime Sent!** → **Rewards History**.

The phone back gesture and browser back button work on every screen.

## Not built yet

Five frames in the section were not loaded because the Figma Starter plan's monthly MCP limit was reached:
`24454:42186`, `24454:42268`, `24454:42437`, `24454:41867`, `24454:42060` (likely the Cash and Data redeem
screens), plus the second Dashboard (`24454:42709`). Tapping Cash Reward or Data Bundle does nothing for now.

## Code

- `src/screens/` — one file per Figma screen; each notes the Figma node it came from.
- `src/Phone.jsx` — scales the 402×874 design to the device.
- `scripts/download-assets.mjs` — fetches every image the screens reference into `public/assets/`.
