# RexFlex (short-term loans)

Built from the Figma section "rexflex" (node `25300:45094`, 30 frames).

## Where it opens

- Home → **RexFlex** tile, or the **Borrow** tab.
- First-time customers see the "Earn your flex" intro. Anyone with a loan lands on the RexFlex dashboard.

## Flow

1. **Intro → Check Your Eligibility → You're Eligible!**
   - The offer is shown with both terms: 14 days (repay ₦3,112) and 30 days (repay ₦3,240).
2. **Choose a Repayment Term → Review Your Offer.**
   - Key terms open in a sheet.
   - The consent checkbox must be ticked before "Confirm Application" works.
3. **Application Received → pending → approved (realistic, about 1 minute).**
   - The review runs in the background in three 20-second steps: Eligibility & Risk Checks, Final Decisions, Disbursement. Each step records when it finished.
   - The sheet shows the live timeline (done ✓ with time / in progress with a pulsing dot / waiting) and "This usually takes about a minute… we'll let you know". **Got it** closes it and opens the dashboard.
   - The dashboard shows the loan as **Pending**, "Under review · Step 2 of 4", updating live.
   - Loan cards: a header (icon, "RexFlex Loan" / "14-day loan", status pill), a full-width divider, then three left-aligned columns sized to their text with equal gaps, flush with both card edges: Amount, plus Due date · Outstanding (active), Review progress · To repay (pending) or Settled on · Total repaid (settled).
   - Dashboard tabs are **All · Pending · Active · Settled**. Each loan sits in exactly one: Pending while under review, Active once approved, Settled once repaid.
   - Empty tabs show a placeholder (`FlexEmptyState`: the design owner's folder illustration, gently floating and still with reduce motion, plus a title and one helpful line). "All" and "Active" offer **Get a loan** when nothing is in progress. Transaction History tabs (All / Repayments / Disbursement) and a loan's empty Transactions section use the same placeholder.
   - Tapping it opens **Loan Status**:
     - an "Under review · Step n of 4" header with a progress bar;
     - the application summary (amount, tenor, interest, total, applied time, proposed due date);
     - the live timeline and a "you can leave this page" note.
   - When the review finishes:
     - On Loan Status or the sheet: that view switches in place to "Loan Approved!" with **View Loan**.
     - Anywhere else (even the home screen): a notice slides up, "Your RexFlex loan of ₦3,000 was approved", with a success sound, a haptic and **View**, which opens the loan. It dismisses itself after 6 seconds.
4. **RexFlex Loan.**
   - Shows the balance card, amount repaid, total, progress bar, days remaining and the latest transactions.
   - Support rows: Loan Information, Loan Agreement and Get Help.
5. **Repay.**
   - Choose Full or Partial. For Partial, enter an amount or tap ₦500–₦2,500.
   - Then: review, PIN (Confirm Payment), Processing, and Payment/Repayment Successful.
   - Download Receipt opens a receipt marked **DEMO**.
6. **Settled loan.**
   - The "Well done!" sheet offers See My Flex Journey or Take Another Loan.
   - "Take Another Loan" (here and on the dashboard) pops up "Check Your Eligibility" over the current screen. It does not go back to the intro.
   - Also available: Transaction History (All / Repayments / Disbursement), Your Flex Journey and How Progression Works.
7. **Your Flex Journey (premium layout).**
   - The banner shows "Level 2 of 3", the current level's name as the title and one line of copy. The progress track was removed at the product owner's request.
   - The hands illustration is large and runs off the banner's right and bottom edges, so its cropped sleeves blend in.
   - "Your levels" is one grouped white panel. Each level row has its icon tile, name, range and a single status line.
   - Icon tiles are joined by a continuous rail.
   - Each row has one status marker: a green tick (done), a "● Current" pill with a pulsing dot that stops with reduce motion, or nothing (locked, with a lock tile). The current row has a soft blue highlight.
   - The "You're on track!" card was removed at the product owner's request.
8. **Choose a Repayment Term (summarised).**
   - The card caption reads "Pick a term that suits you".
   - Each option shows the tenor ("14 days"), "Repay ₦3,112.00 by <due date>" and a green "+₦112 interest" pill. The principal is already on the card above.
9. **Success animation.**
   - Every success badge (Atlas transfers and payments, RexFlex approval and repayments) is an animated vector version of the Figma Lottie badge: the halo blooms, the disc pops, the tick draws and confetti bursts, in about 1.2 s.
   - It plays once and shows the final frame straight away with "reduce motion".

## Rules used by the mock

| Rule | Value |
| --- | --- |
| Interest | 8% per 30 days, pro-rated by day: ₦3,000 → ₦112 for 14 days, ₦240 for 30 days |
| First offer | ₦3,000 |
| Next offer | 2× the highest fully repaid principal, capped at ₦100,000. After repaying ₦3,000 the next offer is ₦6,000. |
| Eligibility | Always eligible (demo) |
| Review | About 60 s in the background: received at once, then 3 steps × 20 s (`MockRexFlexService.stageDelay`) |
| PIN | Any 4 digits; `0000` is wrong; locked after 3 failures. The PIN is never stored. |
| Dates | Start is "now". Due is start + tenor. |

## Honesty and safety

- Every result is simulated:
  - references start with `DEMO-`;
  - success sheets say "Demo data · simulated, no real money moved";
  - the receipt is stamped DEMO.
- `RexFlexService` is the seam for the real lending APIs. No endpoints are assumed.

## Differences from Figma (deliberate)

- The partial "Payment Successful!" subtitle in Figma says the loan is fully repaid. The app says the loan remains active.
- "You has been disbursed" is corrected to "Your loan has been disbursed".
- Secondary buttons (Download Receipt, Take Another Loan) use navy text on light blue instead of white on light blue, to meet WCAG contrast.
- Small grey text uses medium weight, as elsewhere in the app, for contrast.
- The RexFlex screens are pushed full-screen with a back arrow. The Figma bottom navigation is not repeated on them.

## Assets to replace

The Figma export quota was used up. These two images were cut from the section screenshot and are soft on high-density screens. Export them from Figma at 3× with the same file names:

- `assets/images/rexflex/rexflex_hero.png`: the hand-to-hand cash illustration (intro).
- `assets/images/rexflex/rexflex_cash.png`: the cash stack (balance cards), with a transparent background.

## RexFlex in Atlas

Atlas knows RexFlex and can take a loan entirely in the chat.

- **Questions** (`RexFlexIntent`). Atlas recognises "loan", "borrow", "RexFlex" and similar words, and answers:
  - what RexFlex is;
  - eligibility (the three requirements);
  - cost (8% per 30 days, worked out for 14 and 30 days on the customer's offer);
  - limits (start at ₦3,000, up to 2× the highest repaid loan, ₦100,000 maximum);
  - how to repay;
  - status, from the live loan: "under review: step 2 of 4", or "₦X left to repay by <date>".
- **Follow-ups.** Right after a RexFlex answer (`ConversationStage.discussingRexFlex`), short follow-ups such as "How much does it cost?", "Am I eligible?" or "How do I repay?" stay on RexFlex. Other requests ("send money") still work.
- **Getting a loan in the chat.** "Get a RexFlex loan", the welcome **Get a Loan** pill, or the RexFlex hero slide all start it:
  1. Atlas runs the eligibility check, then shows the offer with **14 days · repay ₦3,112** / **30 days · repay ₦3,240**. Typed replies such as "two weeks" or "a month" also work.
  2. A **RexFlex offer card** shows the amount, interest, due date and total to repay. Consent copy follows, with **Yes, apply / Change term / Cancel**.
  3. Applying submits the loan through the same RexFlex controller, so it appears on the RexFlex dashboard as Pending. Atlas says "Application received…" with a **View my loan** card.
  4. When the background review finishes, Atlas posts "🎉 Great news! Your RexFlex loan of ₦3,000 was approved…" in the chat. The app-wide notice is skipped while Atlas is open.
- **Cards.**
  - **Get started with RexFlex**: opens the intro for first-timers, or the eligibility check over the dashboard for returning customers.
  - **View my loan**: opens the loan, or its Loan Status page while pending.
  - Both close Atlas first.
- **Architecture.**
  - Atlas depends only on `LoanOverviewService` (snapshot, eligibility, apply, approvals) in its own domain layer.
  - `RexFlexLoanOverview` adapts the RexFlex controller to it.
  - The host app wires both together (`AtlasController.loans`, `onOpenRexFlex`).
