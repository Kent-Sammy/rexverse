# Rex Atlas: Flutter prototype

Rex Atlas is the conversational AI assistant for the **Rex Africa** app. This is a standalone,
runnable Flutter implementation of the approved Figma designs (section *"RexAtlas  New work flow"*,
node `25218:51967`). Atlas opens as a bottom sheet over a stand-in Rex home screen.

> **Demo only.** Every service is a local mock. No real money moves, no real AI is called, no
> biometrics are read and no PINs are collected. Results and receipts are labelled as demo data.

## Quick start

Requires Flutter **3.47+** (Dart 3.13+). Check with `flutter --version`.

```bash
cd rex_atlas
flutter pub get
flutter run                      # pick an Android emulator / iOS simulator / device
```

Run in a browser (handy for demos; a desktop browser window shows a phone frame):

```bash
flutter run -d chrome
```

Web build with the iPhone 16 Pro safe areas forced, for 402 × 874 screenshots:

```bash
flutter build web --release --no-web-resources-cdn
cd build/web && python3 -m http.server 8765    # open http://localhost:8765/?frame=1
```

## Tests and checks

```bash
flutter analyze
flutter test
```

34 tests: unit tests (formatting, intent parsing, conversation/payment state machine) and widget
tests (end-to-end flow, PIN fallback, full screen, drag-to-close, keyboard, no-overflow at 3 sizes).
See `docs/VALIDATION.md`.

## What's implemented

| Area | Status |
|---|---|
| Entry from home ("Ask RexAtlas….." pill, RexAtlas tile) | ✅ |
| Collapsed welcome sheet: greeting, quick actions, recent transfer, composer (frame 2) | ✅ |
| Expanded chat, full screen, drag to snap/close, scrim tap / close / back | ✅ |
| Messages, typing indicator, auto-scroll, keyboard handling | ✅ |
| Send-money flow: collect details → review card → confirm → fingerprint → processing → result → suggestions (frames 3–8) | ✅ |
| Correct amount, cancel, pause/resume authorisation | ✅ (typed or quick replies) |
| Receipt view (demo-labelled) | ✅ (not designed; see assumptions) |
| Recent transactions (frame 9) → receipt | ✅ |
| Airtime purchase | ✅ (flow assumed, built from designed components) |
| Save, Pay Bills, Rexy December | ⏳ Atlas explains these aren't available yet (no designs) |
| Error states (AI outage + retry, unknown account, failed payment) | ✅ (not designed) |
| Premium polish: iMessage-style chat, frosted chrome, animated welcome glow, spring sheet, haptics | ✅ (requested; see `docs/ASSUMPTIONS.md`) |
| Real backends, real biometrics/PIN, analytics, localisation | ❌ for the Rex team |

## Project structure

```
lib/
  main.dart
  app/                     app shell, demo device frame (prototype-only)
  core/
    design_system/         colour, type, spacing tokens + SVG icon enum
    formatting/            ₦ and date formatting
    widgets/               Pressable, InitialsAvatar, ReplaceableAsset
  features/
    atlas/
      atlas.dart           public API: showRexAtlas(), AtlasController, AtlasDependencies
      domain/models/       messages, drafts, results, transactions, receipts, intents
      domain/services/     service interfaces (AI, accounts, beneficiaries, payments, auth, history, receipts)
      data/mock/           mock implementations + demo fixtures
      application/         AtlasController (ChangeNotifier state machine), events, DI container
      presentation/
        bottom_sheet/      AtlasSheetRoute (scrim + slide) and AtlasSheet (snap/drag/fullscreen)
        screens/           welcome view, chat view, receipt screen
        widgets/           bubbles, header, composer, review/confirm/result cards, details panel,
                           suggestions, transactions, biometric sheet, typing indicator, brand
    host/                  stand-in Rex home screen (prototype-only)
assets/  fonts (Inter), icons (Iconify SVGs named in Figma), images (drop-in slots)
docs/    inspection, tokens, assets, assumptions, mocks/demo script, integration, validation
test/    unit + widget tests
```

**State management:** one `ChangeNotifier` (`AtlasController`) plus a broadcast stream of one-off UI
events (show biometric prompt, open receipt). No third-party state package.
**Navigation:** Atlas is a `PopupRoute` over the host `Navigator`. The biometric prompt is a modal
bottom sheet and the receipt is a pushed page.
**Dependencies:** `flutter_svg` only (plus `flutter_lints` for dev).

## Documentation

- [`docs/FIGMA_INSPECTION.md`](docs/FIGMA_INSPECTION.md): what was (and wasn't) accessible, screen inventory, flow map
- [`docs/DESIGN_TOKENS.md`](docs/DESIGN_TOKENS.md): colours, typography, spacing and how each was measured
- [`docs/ASSETS.md`](docs/ASSETS.md): included assets, missing Figma assets and their drop-in slots
- [`docs/ASSUMPTIONS.md`](docs/ASSUMPTIONS.md): every undesigned behaviour and visual deviation
- [`docs/MOCK_SERVICES.md`](docs/MOCK_SERVICES.md): mock behaviour and a step-by-step demo script
- [`docs/INTEGRATION.md`](docs/INTEGRATION.md): moving Atlas into the Rex app; backend work still needed
- [`docs/VALIDATION.md`](docs/VALIDATION.md): checks run, screenshot comparisons, known gaps
- [`docs/ACCESSIBILITY.md`](docs/ACCESSIBILITY.md): WCAG 2.0 AA contrast table and accessibility measures

## Known limitations

- The Figma MCP plan limit blocked design variables and per-node styles, so colours are sampled from
  renders and the font is inferred (Inter). Most artwork was exported manually from Figma; see
  `docs/ASSETS.md` for the few still missing.
- Not run on a physical device or emulator: the build container has no Android SDK/KVM or macOS.
  Verified with Flutter web + headless Chromium and widget tests.
- The AI is a rule-based mock with a small vocabulary (see the demo script).
