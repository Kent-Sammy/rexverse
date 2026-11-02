# Figma inspection report

File: **Rex Africa Version 2.0 Mobile App** (`bGSrbvtXmV2kBDiwzraoy1`)
Linked node: `25218:51967`, the section **"RexAtlas  New work flow"** (4362 × 1494).

## What was accessed

| Source | Status |
|---|---|
| Page list of the file | ✅ read (19 pages) |
| Full layer tree of section `25218:51967` (every node's id, name, x/y, size, hidden flag) | ✅ read, 1 MB of geometry |
| Screenshot of the whole section (4000 px wide, about 0.9× scale) | ✅ downloaded |
| `get_design_context` for frame `25217:41326` and sheet `25217:41695` | ⚠️ returned **sparse** (structure only, no styles), because the frames are too large for one call |
| Design variables (`get_variable_defs`) | ❌ **blocked**: Figma MCP **Starter-plan call limit reached** |
| Per-node design context (colours, fonts, effects, auto-layout) | ❌ blocked (same limit) |
| Asset export (`download_assets`: avatar image, logos, illustrations, Lottie) | ❌ blocked (same limit) |
| Prototype connections / interactions | ❌ not available: the MCP does not expose prototype links, and the limit stopped further inspection |
| Other pages (Style Guide and Components `3455:108491`, Hifi V2, Rex W1, …) | ❌ not inspected (limit). The Rex design system's own variables/components were **not** seen |

**Effect.** Layout geometry is exact: positions and sizes come straight from Figma metadata. Colours were
**sampled from the Figma render** (see `DESIGN_TOKENS.md`). The font was inferred from text-box
metrics. Bitmap and vector assets use documented placeholders (`ASSETS.md`).

**To close the gap**, do either of these:
1. Upgrade the Figma plan, or run the inspection from an account with a higher MCP limit.
2. Export the assets listed in `ASSETS.md` from Figma and drop them into `assets/images/`.
   No code changes are needed.

## Screen inventory (all frames 402 × 874, iPhone 16 Pro)

| # | Node | Content | Implemented as |
|---|---|---|---|
| 1 | `25217:40957` | Rex home (host). Entry points: "Ask RexAtlas….." pill and the "RexAtlas" service tile | `RexHomeScreen` (host stand-in) |
| 2 | `25217:41326` (sheet `25217:41695`) | Atlas **collapsed** sheet: avatar, greeting, 4 quick actions, recent transfer, composer | `AtlasWelcomeView` in `AtlasSheet` (collapsed) |
| 3 | `25217:42526` | Chat: Send Money → "Which account…" → user details → "Got it…" + **review card** → "Shall I go ahead?" → "Yes, continue please" | `AtlasChatView` + `PaymentReviewCard` |
| 4 | `25218:43762` | "Please confirm with your biometrics…" + **confirmation card** (amount, to, from, fee, total) | `PaymentConfirmationCard` |
| 5 | `25218:44964` (+ sheet `25218:46089`) | **Fingerprint sheet** over frame 4: "Confirm with your fingerprint", "Use PIN instead" | `BiometricPromptSheet` |
| 6 | `25218:46875` | **Transfer Successful!** card with View Receipt / Make another transfer + Transaction Details; "Is there anything else…" | `PaymentResultCard` + `TransactionDetailsPanel` |
| 7 | `25218:48244` | Same result scrolled, then "Here are a few things you might want to do next." | same |
| 8 | `25218:49453` | Follow-up **suggestion tiles** (Save ₦50,000, Pay A Bill ×2, Rexy December) | `SuggestionTile` |
| 9 | `25218:50727` | "Show my recent transactions" → **transactions list** (Card Payment, Transfer, Airtime, Business Transfer) | `TransactionsCard` |

## User-flow map

```
Rex home ──(Ask RexAtlas pill | RexAtlas tile)──▶ Atlas collapsed (welcome)
   ▲                                                   │ quick action / type / See All
   │ close (×) / drag down / tap scrim                 ▼
   └──────────────────────────────────────── Atlas expanded (chat) ◀──▶ full screen (⤢)
                                                        │
  Send Money ─▶ collect account/bank/amount ─▶ review card ─▶ "Shall I go ahead?"
                     ▲            (cancel / change amount) ◀──┘   │ yes
                     │                                            ▼
                     │                      confirmation card + fingerprint sheet
                     │                         │ close ─▶ paused ("Continue"/"Cancel")
                     │                         ▼ authorise (simulated)
                     │                  processing ─▶ result card ─▶ View Receipt ─▶ receipt screen
                     └──────────── "Make another transfer"            └─▶ suggestions
  Show my recent transactions ─▶ transactions list ─▶ row ─▶ receipt screen
  Buy Airtime ─▶ (same review/confirm/result pattern; flow assumed, see ASSUMPTIONS.md)
```

## Missing or ambiguous designs

These are resolved conservatively; each decision is listed in `ASSUMPTIONS.md`.
- No receipt screen ("View Receipt" target).
- No designs for the airtime, bills or save flows beyond the quick-action tiles.
- No error, loading, failed-payment or empty states.
- No design for "Use PIN instead", the composer "+" button or the microphone.
- No interaction spec for the expand (⤢) icon, or for drag/collapse behaviour.
- The frame-6 copy ("Is there anything else i can help you with? You can also ask me to:") and the
  frame-7/8 copy ("Here are a few things you might want to do next.") are alternatives. Frames 7/8 were used.
- Frame 8 lists "Pay A Bill" twice (looks like a placeholder duplicate). The duplicate was removed.
- Several texts reuse placeholder data: recipient avatar "OM", sender shown as "ODELEYE OLAYINKA ANTHONY".
