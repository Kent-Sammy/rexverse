# Assets

## Included

| Asset | Source | Path |
|---|---|---|
| Inter Regular/Medium/SemiBold/Bold | rsms/inter v4.1 (SIL OFL 1.1) | `assets/fonts/` |
| `carbon:send-alt-filled`, `fa7-solid:piggy-bank`, `wpf:banknotes`, `bxs:phone-call`, `bi:fingerprint`, `boxicons:maximize-filled`, `coolicons:close`, `ant-design:audio-filled`, `bi:arrow-left`, `ant-design:check-circle-outlined`, `ri:lightbulb-ai-fill` | Iconify, using the **exact icon names from the Figma layer names** (same open-source sets the designer used) | `assets/icons/*.svg` |

## Exported from Figma by the design owner

Originals are kept unchanged in `design/figma-exports/`. The app uses copies under `assets/`.

| Figma layer | App file | Used in |
|---|---|---|
| "Gemini_Generated_Image…" avatar (with ring) | `assets/images/atlas_assistant_avatar.png` | welcome sheet, every assistant message |
| "Frame 2147234634" (mark on light-blue disc) | `assets/images/rex_atlas_badge.svg` | chat header, confirmation card |
| mark paths from that frame | `assets/images/rex_atlas_mark.svg` | home "RexAtlas" tile |
| "Component 5" (mark on navy disc) | `assets/images/rex_atlas_badge_dark.svg` | home "Ask RexAtlas" bar |
| "GTBank Plc" | `assets/images/banks/058.svg` | review and confirmation cards |
| "95088-success" | `assets/images/success_badge.png` (3×, extracted from the SVG's embedded image) | result card |
| "🎉" | `assets/images/party_popper.png` (3×, extracted) | home savings card |
| Iconly Send, audio frame, copy | `assets/icons/iconly_send.svg`, `mic_frame.svg`, `copy.svg` | composer, Transaction Details |
| Notification, Light, wifi-square, Wallet, briefcase, Ticket, lightbulb-ai, check-circle | `assets/icons/*.svg` | home screen |
| home-2, Frame 33798, Chart, wallet, Frame 33801 | `assets/icons/nav_home/save/invest/borrow/more.svg` | home bottom menu |
| Show | `assets/icons/eye.svg` | balance visibility icon |
| Arrow - Down 2 | `assets/icons/chevron.svg` | ">" chevrons (suggestions, See More, Transactions, Start Goal) |
| Coin Stack | `assets/images/coin_stack.png` | home banner illustration |

The SVG files `95088-success.svg` and `🎉.svg` wrap bitmap images in SVG patterns, which
`flutter_svg` cannot draw, so they were converted to transparent PNGs.

## Derived from the exports

| File | Made from | Why |
|---|---|---|
| `assets/images/atlas_assistant_avatar_chat.png` | `atlas head.png` | Figma's chat rows show the same robot on the brand-blue disc; the white background was flood-filled and replaced with #323DFF |
| `assets/images/success_badge.png` | `95088-success.svg` | the embedded image had a solid white background that showed as a square on the card wash; white was converted to transparency |

## Still missing (exports needed)

| Figma layer | Where | Currently shown |
|---|---|---|
| `vuesax/twotone/add` | composer "+" | Material `add` |
| `vuesax/outline/card`, `card-coin`, `Iconly/Curved/Calling`, `vuesax/outline/bank` | transactions list | Material icons |
| `Iconly/Bulk/Calling` | home "Airtime" tile | Material icon |
| `vuesax/outline/copy` (white, account number) | home screen | Material icon |
| Balance-card background shapes, Learn Finance thumbnail | home screen | plain fill / Material icon |
| Welcome "Emoji" 👋 | greeting | system emoji |

The other bank logos in the mock directory (Access, Zenith…) never appear in the designs.
They fall back to a coloured disc with initials.

## Icons matched by name

The quick-action and sheet icons (`carbon:send-alt-filled`, `fa7-solid:piggy-bank`, `wpf:banknotes`,
`bxs:phone-call`, `bi:fingerprint`, `boxicons:maximize-filled`, `coolicons:close`, `bi:arrow-left`)
come from Iconify, using the exact icon names in the Figma layer names.

## Image sharpness audit (RexFlex update)

Phones draw at about 3× density. A raster image needs at least 3× its on-screen width in pixels.

| Asset | Pixels | Shown at | Ratio | Status |
| --- | --- | --- | --- | --- |
| `atlas_assistant_avatar.png` / `_chat.png` | 428 | 92 / 33 pt | 4.6× / 13× | ✅ sharp |
| `coin_stack.png` | 444 | 148 pt | 3.0× | ✅ |
| `party_popper.png` | 234 | 78 pt | 3.0× | ✅ |
| `success_badge.png` | 189 | 62.8 pt (Atlas), 64 pt (RexFlex) | 3.0× | ✅ (RexFlex was 72 pt, now 64) |
| `rexflex/rexflex_hero.png` | 1206 (Figma export) | 402 pt | 3.0× | ✅ |
| `rexflex/rexflex_cash.png` | 246 (Figma export) | 80 pt | 3.1× | ✅ |
| `rexflex/rexflex_cash_tilt.png` | 258 (Figma export) | 86 / 70 pt | 3.0× / 3.7× | ✅ |
| `rexflex/rexflex_journey.png` | 419 (Figma export) | 118 pt | 3.6× | ✅ |
| `rexflex/rexflex_empty.png` | 167×206 (from the uploaded `16656-empty-state.png`, trimmed) | 108 pt tall | ~1.9× | ⚠️ slightly soft; a 3× export or the Lottie JSON would make it crisp |
| `icons/flex_money_*.svg`, `icons/flex_safe_lock.svg` | vector (Figma export) | 18–22 pt | ∞ | ✅ |
| Icons, logos, bank logos (SVG) | vector | any | ∞ | ✅ |

### RexFlex exports (done)

The design owner exported the RexFlex illustrations and icons. They were uploaded to another branch's root; copies were trimmed to their visible content and added here:

| File | Source |
| --- | --- |
| `rexflex_hero.png` | `Gemini_Generated_Image_k5s8a7k5s8a7k5s8 1.png` |
| `rexflex_cash.png` | `Frame 2147235173.png` |
| `rexflex_cash_tilt.png` | `Money.png` |
| `rexflex_journey.png` | `Gemini_Generated00.png` |
| `rexflex_empty.png` | `16656-empty-state.png` (second upload) |
| `icons/flex_money_repaid.svg` | `money.svg` |
| `icons/flex_money_total.svg` | `money-1.svg` |
| `icons/flex_safe_lock.svg` | `mingcute_safe-lock-fill.svg` |

## Home dashboard (Figma 25371:78681)

Downloaded from the frame with the Figma tools (3× where available):

| File | Use |
|---|---|
| `images/home/rexy_december_bg.jpg` | Rexy December banner background (1080 wide) |
| `images/home/capital_market.png` | Capital market banner art (1080 wide) |
| `images/home/rex_coin.png` | Rex coin in the header and RexPlay banner |
| `images/home/rexshop_bag.png` | RexShop slide |
| `icons/gamepad.svg` | RexPlay strip |

The second and third banners (capital market, RexPlay) are built in code, pending the banner frame 25373:79117.
