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
| "Use PIN instead" | no design | demo PIN pad (4 boxes + on-screen keypad, no system keyboard). Labelled "Demo: any 4 digits work… Don't use your real PIN". The PIN is verified by the mock service in memory and never stored or sent. Production must use Rex's secure PIN entry |
| Composer "+" and microphone | no design | show a short notice ("…isn't available in this prototype yet") rather than doing nothing |
| Send button with empty text | | focuses the input. The button is dimmed only while Atlas is responding |
| Processing / typing state | not drawn | three-dot indicator in an assistant bubble with a status label ("Checking account details…", "Processing your transfer…") |
| Confirmation card after success | frames 4 → 6 | the confirmation card is replaced by the result card, as in frame 6 |
| "View Receipt" | **Transaction Details** and **Share Receipt** frames (`24691:40110`) | Transaction Details page (summary card, details panel, **Repeat Transfer / Share Receipt / Report**) and the Share Receipt ticket with **Share as image / Share as PDF**. See docs/RECEIPTS.md |
| "Make another transfer" | | restarts the transfer flow ("Which account do you want to send money to?") |
| Transaction rows, welcome recent-transfer card | | open that transaction's receipt |
| "See All" (welcome) | | asks Atlas "Show my recent transactions" (frame 9) |
| Suggestion tiles, "Save Money", "Pay Bills" quick actions | no flows designed | Atlas replies that the feature isn't available in this prototype |
| "Buy Airtime", "Save Money", "Pay Bills", suggestions, home RexSave / RexVault / Electricity / Airtime tiles | only entry points are designed | flows **assumed** (airtime, RexSave + Rexy December, RexVault, electricity / cable TV / internet bills), all reusing the designed review → confirmation → fingerprint → result → receipt components. Choices (bill type, provider, package, lock period, amounts) appear as reply chips |
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

## Second round of product-owner requests

| Change | Detail |
|---|---|
| Welcome sheet | The "Recent Transactions" card was removed. The collapsed sheet shrank from 631 to 484 pt to fit |
| Open behaviour | Atlas **always opens on the welcome screen**. The first action (quick action, typing, voice or upload) switches to the chat, which keeps the **full history** for the session. If a payment is waiting for the fingerprint, Atlas reopens in the chat and asks again |
| Voice input | The microphone does speech-to-text through the device recogniser. The words appear in the text box for the user to check; they are **never sent automatically**. On Android and in Chrome, audio may be processed by Google's speech service. Rex's privacy/compliance team should review this before production |
| Uploads | "+" opens Photo or Document (≤ 10 MB). The file appears in the chat (image thumbnail or file chip). The mock assistant says plainly that reading files isn't available in the prototype; files stay on the device and are not uploaded anywhere |
| Chat sounds | Original sounds (not Apple's): a whoosh on send, a chime on reply (once per burst), a brighter chime on payment success. They respect the iOS silent switch, mix with other audio, and can be muted with the speaker icon in the header |
| Home "Ask RexAtlas" bar | Animated cyan→purple gradient outline with a soft glow (holds still with reduce motion) |

## Third round

| Change | Detail |
|---|---|
| RexSave / Rexy December | Rates and bonus are demo values. Rexy December follows the Figma suggestion copy "Get 5% upfront on deposits" |
| RexVault | Worded as saving ("How much do you want to save?"). Flat 22% p.a. and RexSave 16% p.a. per the product owner; 1/3/6/12-month periods are demo values. Atlas works out the earnings for each period. Early withdrawal isn't offered |
| Bills | Providers are real Nigerian billers, but **prices, packages and tokens are illustrative**. Electricity tokens are random 20-digit numbers. TV/internet amounts come from the chosen package and can't be changed |
| Home tiles | RexSave, RexVault, Electricity and Airtime open Atlas and start that flow. Data, Budgets and RexFlex still show the "part of the main Rex app" notice |
| PIN pad | See the "Use PIN instead" row above |
| Amount format | Amounts of ₦10,000 and above show thousands separators (₦100,000); smaller amounts keep the Figma style (₦3000) |

## Welcome sheet layout (v5)

- The welcome sheet has two balanced rows of four quick actions:
  - Row 1: Send Money, Save Money, Pay Bills, Buy Airtime.
  - Row 2: Fixed Deposit (opens the RexVault flow), Electricity, Cable TV, Recent Activity.
- The collapsed sheet height is 608 pt, so both rows fit on a 402×874 screen. On shorter screens the tile area scrolls.
- The composer sits 24 pt below the tiles. The pill, mic and send buttons are 10 pt apart.
- A translucent white card peeks 10 pt above the top of the collapsed blue sheet, for depth. It is hidden in fullscreen.

## Welcome sheet: hero card + quick-action pills (v6)

- The 8-tile grid is replaced by:
  - a swipeable "Suggested for you" hero card that auto-advances every 5 s;
  - two rows of glass quick-action pills that scroll sideways together.
- The hero card cycles through product tips: RexVault 22%, RexSave 16% and electricity tokens. It never shows past transactions, so it makes sense for a first-time user. The tips are static demo copy, not personalised offers.
- Auto-advance stops when the OS "reduce motion" setting is on. The card height grows with the system text size.
- The pills keep the same actions and utterances as the old tiles. Fixed Deposit still starts the RexVault flow.
- Phones shorter than 800 pt get a 64 pt avatar and a 22 pt greeting. Taller phones get a 92 pt avatar. The greeting sits on one line when it fits.

## Bottom navigation (feedback round 3)

- Tabs: Home · RexSave · RexAtlas · RexInvest · More, from the shared design.
- RexAtlas is a raised round button in the centre and opens Atlas.
- Borrow is no longer a tab. RexFlex opens from its tile on Home.
- Inactive labels use `navInactive` (#5F76A1), a little darker than the design, so they meet WCAG contrast.

## All Transactions

- Rex is a single wallet. There is no account switcher and no business or POS accounts.
- Opens from "Transactions >" on the Home balance card.
- The list combines three sources (all entries are simulated):
  - payments made in Atlas (transfers, airtime, RexSave, RexVault, bills);
  - RexFlex loans and repayments;
  - demo wallet activity dated relative to today (money received, top ups, physical and virtual card payments, RexSave and RexVault deposits and interest, data, cables, utility, education, a pending transfer and a failed, reversed data purchase).
- Tabs: All · RexSave · RexFlex · RexVault.
- The filter button opens the "Transaction filter" sheet from the design, without the Source row:
  - Date Filter (start and end date);
  - Quick Filter (Top Up, Transfer, Card Debit, Virtual or Physical Card Debit);
  - Bill Payments (Airtime, Data, Cables, Utility, Education);
  - Amount Range (₦0–₦1M, where ₦1M means "and above").
- Active filters show as chips you can tap to clear.
- Received / Spent shows today's totals, or the chosen date range's totals. Failed transactions are not counted.
- Selected chips use navy with white text instead of the design's light blue, so they meet WCAG contrast.
- Tapping a row opens Transaction Details with Share Receipt and Report. Transfers made in Atlas also offer Repeat Transfer.
- Empty states reuse the RexFlex empty-state card and illustration:
  - **No transactions found** (search or filters hid everything), with "Clear filters";
  - **No RexFlex transactions yet**, with "Get a RexFlex loan";
  - **No RexSave transactions yet**, with "Start saving" in Atlas;
  - **No RexVault transactions yet**, with "Save in RexVault" in Atlas;
  - **No transactions yet**, for an empty wallet.

## Home dashboard (Figma 25461:79708)

- **Recent Transactions** card under the balance card:
  - it shows your latest wallet transaction, live from the same feed as All Transactions, so a payment you just made appears there;
  - "See All" opens All Transactions;
  - tapping the row opens its Transaction Details.
- The demo's latest transaction is a ₦5,000 transfer to JIDE KOSOKO ALIU, as in the design. Once you make a payment in Atlas, that payment shows instead.
- The RexAtlas tile is now **RexGO** (RexAtlas has the centre button in the bottom bar).
  - Its icon is the designer's Iconly Bold "Send" export (`assets/icons/rexgo.svg`).
  - RexGO isn't in this prototype, so it shows a "main Rex app" notice.

## Atlas welcome sheet sizing

- The welcome sheet never scrolls. It measures its content and opens to exactly that height (up to the full screen), so the spacing between avatar, greeting, suggestion card, quick actions and message bar is identical on every phone.
- The compact layout (smaller avatar and greeting) is used only when the full layout can't fit a full-height sheet. On the very smallest screens (e.g. iPhone SE 2016) the content scales down slightly instead of scrolling.
- Checked on 10 phone sizes by `test/welcome_fit_test.dart`.
- On the 402 × 874 design phone the sheet is 586 pt tall (Figma frame: 608), because it now matches its content exactly.
