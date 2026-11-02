# Assets

## Included

| Asset | Source | Path |
|---|---|---|
| Inter Regular/Medium/SemiBold/Bold | rsms/inter v4.1 (SIL OFL 1.1) | `assets/fonts/` |
| `carbon:send-alt-filled`, `fa7-solid:piggy-bank`, `wpf:banknotes`, `bxs:phone-call`, `bi:fingerprint`, `boxicons:maximize-filled`, `coolicons:close`, `ant-design:audio-filled`, `bi:arrow-left`, `ant-design:check-circle-outlined`, `ri:lightbulb-ai-fill` | Iconify, using the **exact icon names from the Figma layer names** (same open-source sets the designer used) | `assets/icons/*.svg` |

## Missing Figma assets (placeholders in use)

Drop the exported file at the given path and it replaces the placeholder automatically
(`ReplaceableAsset` checks the asset manifest at runtime). After adding files, run `flutter pub get`.

| Figma layer | Node (example) | Slot path | Current placeholder |
|---|---|---|---|
| Assistant avatar "Gemini_Generated_Image_cpel96cpel96cpel 1" | `25217:42513` | `assets/images/atlas_assistant_avatar.png` | blue disc with a robot glyph inside the (correct) gradient ring |
| Rex Atlas mark (header, tile, confirmation card) | `25217:43423` | `assets/images/rex_atlas_mark.svg` | hand-drawn approximation (`_AtlasMarkPainter`), **temporary** |
| "GTBank Plc" logo | `25218:43726` | `assets/images/banks/058.png` | orange disc with "GTB" |
| Other bank / network logos | none | `assets/images/banks/<bankCode>.png`, `net-<Network>.png` | coloured disc with initials |
| Success Lottie "95088-success" | `25218:48000` | none (needs the `lottie` package) | static teal check badge |
| Home banner coins, 🎉 illustration, Learn Finance thumbnail, balance-card shapes | `25217:42730`, `25217:42746`, … | none (host stand-in only) | Material icon / emoji |
| Welcome "Emoji" 👋 | `25217:42497` | none | system emoji glyph |

## Icon substitutions (Iconly / vuesax sets are not publicly available)

| Figma icon | Used instead |
|---|---|
| `vuesax/twotone/add` (composer +) | `Icons.add` |
| `Iconly/Bold/Send` (composer send) | `carbon:send-alt-filled` (also a paper plane) |
| `Iconly/Light/Arrow - Down 2` (chevrons) | `Icons.chevron_right_rounded` |
| `vuesax/outline/card`, `card-coin`, `Iconly/Curved/Calling`, `vuesax/outline/bank` | `Icons.credit_card_rounded`, `currency_exchange_rounded`, `phone_in_talk_outlined`, `account_balance_outlined` |
| `Copy` | `Icons.copy_rounded` |
| Host icons (`vuesax/bold/home-2`, `Iconly/Bold/Wallet`, …) | Material equivalents |
