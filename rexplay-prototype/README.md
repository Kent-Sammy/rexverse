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

## Launch scope

Trivia across four categories, a simple leaderboard and RexPoints. Polls and "live" games are
still in the code but switched off in `src/config.js`.

- **Categories:** Football & Sports, Entertainment (Afrobeats & Nollywood), General Knowledge, Money & Finance.
- **Daily Challenge:** 5 questions (one per category plus a bonus), 15s each, a new set every day, playable once a day.
- **10-question challenges:** 20s per question.
- **Leaderboard:** one per game, ranked by correct answers, then by total answer time. The results screen
  and the leaderboard use the same ranking.
- **RexPoints:** earned per correct answer, limited per customer per day.
- **Redemption:** airtime, data and cash (cash to the customer’s Rex account only). Every redemption has a
  confirmation step, a processing state and a status: Successful, Pending or Failed (failed redemptions
  don’t take RexPoints). Rewards History shows each status.
- **RexVault:** everyone can play; RexVault customers earn more and can redeem cash.

## Settings (`src/config.js`)

All rewards numbers are **placeholders** until points issuance, redemption values, eligibility and the
RexVault benefits are agreed (RexVault benefits also need Compliance approval).

| Setting | Placeholder |
|---|---|
| RexPoints per correct answer | 10 (Daily Challenge: 20) |
| Daily earning cap per customer | 300 RexPoints (RexVault: 450) |
| Conversion | 10 RexPoints = ₦1 |
| Daily rewards budget | ₦25,000 across all customers |
| Airtime / data / cash options | ₦50–₦2,000 / ₦100–₦2,000 / ₦100–₦5,000 |
| RexVault boost | 1.5× RexPoints, higher daily cap, cash redemption |

`DEMO.tools` shows prototype-only helpers (add 1,000 RexPoints, switch RexVault on/off). Turn it off for customers.

To demonstrate every redemption status: a phone number ending in **1111** gives *Pending* (settles after
15 seconds) and one ending in **0000** gives *Failed*.

## Editing the games

Questions, answers and the tip shown after each answer live in `src/games.jsx`.

## Code

- `src/screens/` — one file per screen; screens from Figma note the Figma node they came from.
- `src/config.js` — rewards economics, RexVault benefits, launch switches.
- `src/store.jsx` — RexPoints balance, daily cap, games played, redemptions and RexVault status.
- `src/Phone.jsx` — scales the 402×874 design to the device.
- `scripts/download-assets.mjs` — fetches every Figma image the screens reference into `public/assets/`.
