# Design tokens

Source of truth in code: `lib/core/design_system/` (`rex_colors.dart`, `rex_typography.dart`,
`rex_dimens.dart`, `rex_icons.dart`).

Figma variables could **not** be read (MCP plan limit, see `FIGMA_INSPECTION.md`), so:
- **Geometry is exact.** It comes from Figma node metadata (x/y/width/height).
- **Colours were sampled** from the Figma render of section `25218:51967` at known node coordinates.
  Sampling is accurate for flat fills. Thin text and icons were read as the darkest or most saturated
  pixel in the node's box, which is reliable to roughly ±1 shade. **Replace these with the real
  variables when available.**

## Colours

> Several text colours were darkened for WCAG 2.0 AA contrast. See `ACCESSIBILITY.md` for the before and after values.

| Token | Value | Where measured |
|---|---|---|
| `navy` | `#002766` | header title, "OM" text, "Make another transfer" button, welcome sheet base |
| `primary` | `#323DFF` | user bubbles, mic/send icons, "Use PIN instead" |
| `bubbleAssistant` / `softBlue` | `#E2EBFF` | assistant bubble, composer, review card, suggestion tiles, View Receipt |
| `avatarFill` | `#C5D7FF` | "OM" avatar, header logo disc |
| `headerIcon` | `#6CA4FF` | expand / close icons |
| `sheetHandle` | `#C0D6FF` (chat), `#A9C4F6` (welcome) | handles |
| `scrim` | `#090D1E` @ 75% | solved from dimmed vs undimmed host pixels (3 channels agree on α≈0.75) |
| `welcomeBase` / `welcomeGlow` | `#002766` / `#1D58BD` | welcome sheet base and blurred ellipses 1589/1591/1592 |
| quick-action tile | white @ 16% | `#294A7F` over `#002766` |
| icon disc on dark | white @ 20–32% | `#506B96` |
| `textPrimary` | `#313131` | bubble text, review rows |
| `textStrong` | `#130F26` | confirmation amount, fingerprint title, history titles |
| `textSecondary` | `#838383` | "GTBank **** 8716", suggestion subtitles |
| `textMuted` | `#696666` | "Your AI agent" |
| `textPlaceholder` | `#969696` | "Ask Rex Atlas..." |
| `textSubtle` | `#797979` | fingerprint body |
| `textBody` | `#646464` | result body |
| detail title / label / value | `#444444` / `#A5A5A5` / `#505050` | Transaction Details |
| `textTxMeta` | `#96A1B8` | history dates |
| `success` | `#008000` | "Successful" |
| `successTeal` | `#3DD6C9` (approx) | success badge (Lottie layer, approximated) |
| accent orange / cyan / green / mint | `#FFA412` / `#00BCD3` / `#00BC4F` / `#86FFB9` | piggy bank, banknotes, send, quick-action icons on dark |
| history icon discs | `#E1FFE3`, `#E7F0FE`, `#E2FCFF`, `#FFF0D9` | transactions list |
| ring gradient | `#02BEFF` → `#9A35FF` | assistant avatar ring |
| card wash | `#DCECFF` → `#FCD7FF` | confirmation/result card blurred ellipses |
| `gtBankOrange` | `#D94F00` | GTBank logo (matches the exported SVG) |
| host tiles | `#EBF3EB`, `#EFF3FF`, `#FFF7EB`, `#EBFAFC` | home service grid |

## Typography

**Font: SF Pro on iOS/macOS (system font), Inter elsewhere** (Inter bundled, SIL OFL, `assets/fonts/`). Figma's server render had to substitute the file's font, which points to SF Pro; Inter is the closest distributable match for Android and web. Hug-width text
boxes in the metadata match Inter at the chosen sizes within 1–4%, and box heights match a 1.21 line
height (14 → 17, 28 → 34, 10 → 12, 20 → 24). Figma's server render was narrower than both, which
suggests the render used a fallback font. **Confirm the family against the Rex style guide**
(`3455:108491`). To switch it, change `RexTypography.fontFamily`.

| Role | Size / weight | Figma evidence |
|---|---|---|
| Bubble text | 14 / 400 | box h 17, "Shall I go ahead?" hug 111 (Inter 112.5) |
| Header title / subtitle | 17 / 600, 10 / 400 | box h 21 / 12 |
| Welcome greeting | 28 / 500 | box h 34, "Ololade!" hug 108 (Inter 109) |
| Composer | 14 / 400 | rendered width of "Ask Rex Atlas..." |
| Review rows / total | 14 / 400–600 | box h 17 |
| Confirmation amount | 22 / 700 | box h 27 |
| Fingerprint title / body | 20 / 600, 14 / 400 | box h 24 / 17 |
| Result title / body | **16** / 600, **13** / 400 (Figma 15, 11.5) | matched to the chat's 14 px text |
| Small buttons | **12** / 600 (Figma 9) | one line, scales down to fit |
| Detail rows | **11** / 400–500 (Figma 8) | raised for legibility in the narrower cards |
| Suggestion title / subtitle | 14 / 400 (scales down to fit), 12 / 400 | see note* |
| History title / meta / amount / status | 13/500, 11/400, 13/600, 11/500 (Figma 12/10) | minimum 11 px |

\* The Figma text box for "Get Started With Rexy December" (269 wide) overflows its 298-wide tile,
so the title scales down to fit rather than overflowing.

## Spacing and geometry (selected)

| Item | Value |
|---|---|
| Collapsed sheet height | 631 of 874 (72.2% of screen height) |
| Expanded sheet top | safe-area top (62 on iPhone 16 Pro, as in Figma) |
| Sheet radius | 20 |
| Handle | 48 × 4, top 13 (welcome) / 18 (chat) |
| Header | 33 tall at y 33; divider at y 82 |
| Page padding | 16 |
| Message gap | 20 |
| Avatars | 33; avatar→bubble 8; bubble→user avatar 6 |
| Bubble | radius 10, assistant min-height 50, tail ≈ 8 |
| Composer | 366 × 48 pill, 17 side inset, 26 bottom inset |
| Review card | padding 10, recipient row 56, rows 29 + 7, total box 40 |
| Confirmation card | 370 wide, inner dividers inset 20, fee box radius 8 |
| Result card | 17 side inset, buttons 29.2 high with 8 gap, details panel inset 28 |
| Suggestion tile | 56 high, 72 left indent, icon disc 36 |
| History row | 33 icon, 62 row pitch |

## Type scale for app screens

Transactions, the transaction filter, Transaction Details, Share Receipt, the Report sheet and RexFlex all use this scale (Inter):

| Role | Size / weight | Where |
|---|---|---|
| Page title | 17 / Bold | header bars (All Transactions, Transaction Details, Share Receipt, RexFlex) |
| Large amount | 22 / Bold | Transaction Details, RexFlex headers |
| Sheet title | 18 / Bold | Transaction filter, Report, success sheets |
| Section heading | 15 / SemiBold | day groups, filter sections, RexFlex sections |
| Summary amount | 16 / Bold | Received / Spent |
| Row title | 14 / SemiBold | transaction rows, menu rows |
| Row amount | 14 / Bold | transaction rows |
| Body, inputs, options | 14 / Regular–Medium | search, date fields, report reasons |
| Primary button | 15 / SemiBold | Apply Filter, Submit report, all RexFlex buttons |
| Supporting text | 13 / Regular | sheet subtitles, empty states |
| Tabs, chips, links | 13 / SemiBold (unselected chips Medium) | product tabs, filter chips, active-filter chips, "Clear all filters" |
| Meta, labels, status | 12 / Medium | "Transfer • 8:12 AM", Received/Spent, receipt labels, status |
| Caption | 11 / Medium | summary footer, slider ticks, demo notes |
| Empty state | title 14 Bold · message 11 Medium · button 12 SemiBold | transactions and RexFlex empty states |

Small grey text uses Medium (500) rather than Regular, so it meets WCAG AA contrast at small sizes. Home keeps the Figma home scale (10–14), because its cards are designed smaller.

Long text is cut off with an ellipsis:
- titles, labels, chips and buttons stay on one line;
- receipt values get up to two lines (name plus bank line);
- notices get up to three.
