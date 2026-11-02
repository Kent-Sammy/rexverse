# Accessibility (WCAG 2.0 AA)

Target: WCAG 2.0 level AA. Colour changes from the Figma values are listed below. Each is the closest
shade of the same hue that passes.

## 1.4.3 Contrast (minimum)

Normal text needs 4.5:1. Icons and UI parts are held to 3:1, the WCAG 2.1 non-text rule, as good practice.

| Text / element | Background | Ratio | Required |
|---|---|---|---|
| Body text #313131 | on bubble #E2EBFF | 10.88:1 | 4.5:1 |
| Secondary text #696969 (was #838383) | on white | 5.49:1 | 4.5:1 |
| Secondary text #696969 | on #E2EBFF | 4.59:1 | 4.5:1 |
| Placeholder #696969 (was #969696) | on #E2EBFF | 4.59:1 | 4.5:1 |
| Muted #696666 | on white | 5.69:1 | 4.5:1 |
| Subtle / detail labels #757575 (was #797979 / #A5A5A5) | on white | 4.61:1 | 4.5:1 |
| Transaction dates #667697 (was #96A1B8) | on white | 4.56:1 | 4.5:1 |
| Success #008000 | on white | 5.14:1 | 4.5:1 |
| Pending #A66600 (was #FFA412) | on white | 4.64:1 | 4.5:1 |
| Error #D92D20 | on white | 4.83:1 | 4.5:1 |
| White | on primary #323DFF | 6.47:1 | 4.5:1 |
| Primary #323DFF (links, chips) | on white | 6.47:1 | 4.5:1 |
| Navy #002766 | on #E2EBFF | 11.85:1 | 4.5:1 |
| White | on navy #002766 | 14.17:1 | 4.5:1 |
| Header icons #4D91FF (was #6CA4FF) | on white (UI icon, 3:1) | 3.08:1 | 3.0:1 |
| Welcome text white | on quick-action tile | 8.84:1 | 4.5:1 |
| Welcome hint white | on input pill | 4.66:1 | 4.5:1 |
| Home menu labels #5F76A1 (was #B9C3D6) | on white | 4.57:1 | 4.5:1 |
| White | on banner #3B76BD | 4.65:1 | 4.5:1 |

All values live in `lib/core/design_system/rex_colors.dart`.

Exceptions:
- **Inactive bottom-menu icons** keep the Figma grey (#D2D8E5). Each has a text label that passes contrast.
- **Placeholder bank logos** are only for banks that never appear in the designs. They use colours that give white initials at least 4.5:1.

## What else was done

| Criterion | Measure |
|---|---|
| 1.1.1 Non-text content | The welcome portrait is labelled. Chat avatars, the success illustration, 🎉 and 👋 are marked decorative |
| 1.3.1 Info and relationships | The "Rex Atlas" title is a semantic header. Each message is announced as "Rex Atlas says…" or "You said…" |
| 1.4.4 Resize text | Fixed-height rows became minimum heights, so cards grow with the system text size. Tested at 1.5× and 2× with no overflow |
| 2.1.1 Keyboard, 2.4.7 Focus visible | Every custom button is focusable, shows a 2 pt blue focus ring, and activates with Enter or Space |
| 2.2.2 Pause, stop, hide | The welcome glow and blobs, message pop-ins and press scaling stop when the OS "reduce motion" setting is on |
| 4.1.2 Name, role, value | Every tappable element has a label. The tap-to-dismiss-keyboard area is excluded, because it isn't a control |
| 4.1.3 Status messages | New Atlas messages are live regions, so screen readers announce replies |
| Type size | Card text is at least 11 px. The Figma 8–9 px receipt rows and buttons were raised to a consistent scale (see DESIGN_TOKENS.md) |
| Touch targets | Header icons get 36 × 33 pt areas, the composer "+" 40 × 40, and the fingerprint-sheet close 44 × 44 |

## Automated checks (`test/accessibility_test.dart`)

- Flutter's `textContrastGuideline` runs on the rendered home, welcome, chat, review, confirmation and result screens.
- `labeledTapTargetGuideline` runs on the same screens.
- No overflow with system text at 1.5× and 2×.
- With "reduce motion" on, the welcome sheet schedules no further frames.

## Not verified

- Manual testing with VoiceOver and TalkBack on real devices.
- Colour-blindness simulation (status is never shown by colour alone: "Successful", "Pending" and "Failed" are always written out).
