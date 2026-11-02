# Assumptions and deviations from Figma

Every behaviour that is not specified in the designs is listed here, along with what the prototype does.

## Interaction assumptions

| Control / situation | Not specified in Figma | Prototype behaviour |
|---|---|---|
| Opening Atlas | which entry points | "Ask RexAtlas….." pill and the RexAtlas service tile open the collapsed sheet (frame 2) |
| Collapsed ↔ expanded | trigger | The sheet expands automatically when a conversation starts or the keyboard opens. Dragging the handle snaps it to collapsed/expanded/full screen. Dragging below ~70% of the collapsed height (or a fast flick down) closes it |
| Expand icon (⤢) | behaviour | toggles **full screen** (no rounded corners, header below the status bar). The icon changes to "exit full screen" |
| Close (×), tapping the scrim, Android back | | closes Atlas. The conversation is kept for the session; reopening resumes it |
| "Yes, continue please" | how the user answers | typed replies work ("yes", "continue", "cancel", "change the amount to 5000"). **Addition:** tappable reply chips under "Shall I go ahead?" ("Yes, continue please" / "Cancel"), styled with existing tokens, so testers don't have to type |
| Fingerprint sheet | how authorisation completes | Tapping the fingerprint runs the **simulated** `AuthorizationService`. A small "Demo: tap the fingerprint to simulate approval" caption is added |
| Closing the fingerprint sheet | | the transfer is paused: "No problem, I haven't sent anything…" with Continue/Cancel chips |
| "Use PIN instead" | no design | shows an explanation that the Rex PIN pad isn't part of the prototype. **No PIN is ever collected** |
| Composer "+" and microphone | no design | show a short notice ("…isn't available in this prototype yet") rather than doing nothing |
| Send button with empty text | | focuses the input. The button is dimmed only while Atlas is responding |
| Processing / typing state | not drawn | three-dot indicator in an assistant bubble with a status label ("Checking account details…", "Processing your transfer…") |
| Confirmation card after success | frames 4 → 6 | the confirmation card is replaced by the result card, as in frame 6 |
| "View Receipt" | no receipt screen | full-screen receipt reusing the Transaction Details panel, with a **DEMO RECEIPT** banner |
| "Make another transfer" | | restarts the transfer flow ("Which account do you want to send money to?") |
| Transaction rows, welcome recent-transfer card | | open that transaction's receipt |
| "See All" (welcome) | | asks Atlas "Show my recent transactions" (frame 9) |
| Suggestion tiles, "Save Money", "Pay Bills" quick actions | no flows designed | Atlas replies that the feature isn't available in this prototype |
| "Buy Airtime" | only the tile is designed | airtime flow **assumed**, reusing the designed review → confirm → fingerprint → result components |
| Errors | not designed | AI outage → light-red assistant bubble with "Try again". Unknown account → explanation and re-ask. Payment failure → result card in a failed state ("No money left your account") |
| Host home controls other than the Atlas entry points | out of scope | a SnackBar explains they belong to the main Rex app |

## Visual and content deviations

- **Placeholders** for the avatar, Atlas mark, bank logos, the success Lottie and host illustrations (see `ASSETS.md`).
- **Font** is Inter (unconfirmed family, see `DESIGN_TOKENS.md`).
- Recipient avatar initials are computed from the name ("OA" for ODELEYE OLAYINKA ANTHONY). Figma shows the placeholder "OM".
- The confirmation card's "from" row shows the signed-in user (OLOLADE MR. MONEY, REXMFB ******1921). Figma reuses the recipient's name as a placeholder.
- Greeting follows the time of day ("Good morning/afternoon/evening"). Figma shows "Good morning".
- Typo fixed: "Here are you recent transactions" → "Here are your recent transactions".
- The duplicate "Pay A Bill" suggestion from frame 8 was removed.
- Receipt "Description" reads "Transfer from OLOLADE MR. MONEY | <account>". Figma has a placeholder value.
- Welcome recent-transfer time shows "19:30". Figma has "19:30am".
- Long titles (for example, "Get Started With Rexy December") scale down to fit, because the Figma text box overflows its tile.
- Bubble widths hug their content (max 264). Some Figma bubbles have fixed widths, so line breaks can differ.
- "Demo" labels are added to the result card, receipt and fingerprint sheet, so simulated results can't be mistaken for real banking records.

## Requested by the design owner after the first review

These go **beyond** the Figma frames on purpose, at the product owner's request ("premium" polish and an iMessage-like chat):

| Change | Detail |
|---|---|
| iMessage-style bubbles | 18pt corners with a curled tail (Figma: 10pt corners, triangular tail). Consecutive bubbles from the same speaker stack 4pt apart and only the last one shows the avatar and tail |
| Chrome | Solid white header and input bar (an earlier frosted version let text sit half-hidden under the bar, failing WCAG contrast). iOS-style bounce scrolling |
| Conversation time stamp | "Today 9:41 AM" above the first message |
| Message entrance | New bubbles/cards pop in (fade, rise, slight scale from the sender's side) |
| Input bar | The "+" stays inside the text pill. **Microphone and send are separate round buttons** next to it; send is solid Rex blue |
| Cards inset | Review, confirmation, result, suggestion and transaction cards sit between the two avatar columns (start after the Atlas avatar, stop before the user's avatar). Long names wrap to two lines |
| Welcome motion | The three blue glows drift slowly; a breathing, rotating cyan→purple glow surrounds the robot avatar |
| Feedback | Buttons scale down slightly when pressed; haptics on taps, send, fingerprint and result |
| Sheet physics | Snapping uses a spring that follows the release velocity |
| Success badge | Pops in once per payment |

| Card type scale | Card text raised to a consistent scale (minimum 11 px) to suit the narrower cards and WCAG legibility |
| Accessible colours | Failing text colours darkened (see ACCESSIBILITY.md) |
