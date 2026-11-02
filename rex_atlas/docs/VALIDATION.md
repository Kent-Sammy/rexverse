# Validation report

## Environment

| Item | Result |
|---|---|
| Flutter / Dart | 3.47.9 stable / 3.13.7 (installed during this work; Linux cloud container) |
| Android emulator | **not available**: no Android SDK and no `/dev/kvm` in the container |
| iOS simulator | **not available**: requires macOS/Xcode |
| Rendering used for screenshots | Flutter **web** release build in headless Chromium (Playwright) at 402 × 874 (the Figma artboard), `?frame=1` to inject iPhone 16 Pro safe areas (top 62 / bottom 34) |

The web target uses the same Flutter widgets and layout as mobile. Platform-specific behaviour
(real software keyboard, haptics, iOS/Android system fonts, gesture feel) has **not** been verified on a
device.

## Automated checks

| Command | Result |
|---|---|
| `flutter pub get` | ✅ |
| `flutter analyze` (flutter_lints) | ✅ No issues found |
| `flutter test` | ✅ 29 tests passed |
| `flutter build web --release` | ✅ |

The tests load the real Inter font so text measurements match the app. They cover:
- intent parsing (amounts, banks, accounts, phones, confirm/cancel/change, unsupported features, outage);
- controller flows: the designed transfer, cancel, change amount, step-by-step slot filling, unknown
  account, AI outage, biometric dismissal and resume, over-limit failure, airtime, history;
- UI end-to-end: open from home → quick action → review → quick reply → fingerprint → result → receipt
  (demo banner) → back → close → reopen keeps the conversation;
- PIN fallback collects no PIN; full-screen toggle; drag-to-close; feedback for undesigned controls;
- keyboard: a collapsed sheet expands and the composer stays above a 336 pt keyboard;
- **no layout overflow** across the full flow at 320×568, 360×640 and 430×932.

## Visual comparison (Figma left, Flutter right)

Screenshots are in `docs/validation/`. Each compared screen went through capture → compare → fix → recapture.

| Screen | Status | Fixed during validation | Remaining differences |
|---|---|---|---|
| 1 Home (host) | close | header offset (15 pt too low), banner button width | illustrations are placeholders; host is a stand-in |
| 2 Welcome sheet | close | composer font 17→14, send button no longer dimmed at rest | avatar placeholder; glow shapes approximated; greeting follows time of day |
| 3 Chat + review card | close | Amount→Fee pitch 43→36 pt, name/row sizes, quick-reply chips no longer stretch, input keeps focus after send | bubble line breaks differ where Figma used fixed-width text boxes; "OA" vs "OM" |
| 4 Confirmation card | close | none | from-row shows the user (intentional) |
| 5 Fingerprint sheet | very close | none | added demo caption |
| 6–7 Result card | close | none | static badge instead of Lottie; demo footnote |
| 8 Suggestions | close | title/subtitle size; long title scales to fit | duplicate tile removed |
| 9 Transactions | close | row pitch 51→62 pt | new demo transfers appear at the top |

Not claimed: pixel-perfect fidelity. The colours are sampled, the font is unconfirmed, and several
assets are placeholders (see `ASSETS.md`).

## Not tested

- Real devices or emulators (Android, iOS), real software keyboards, screen readers (only semantics labels were added).
- Dark mode (not designed).
- Landscape and tablets.
