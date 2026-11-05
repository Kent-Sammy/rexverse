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
3. **Application Received.**
   - The four review steps tick off one by one, then "Loan Approved!" appears.
   - Closing the sheet early leaves the loan as Pending on the dashboard until the review finishes.
4. **RexFlex Loan.**
   - Shows the balance card, amount repaid, total, progress bar, days remaining and the latest transactions.
   - Support rows: Loan Information, Loan Agreement and Get Help.
5. **Repay.**
   - Choose Full or Partial. For Partial, enter an amount or tap ₦500–₦2,500.
   - Then: review, PIN (Confirm Payment), Processing, and Payment/Repayment Successful.
   - Download Receipt opens a receipt marked **DEMO**.
6. **Settled loan.**
   - The "Well done!" sheet offers See My Flex Journey or Take Another Loan.
   - Also available: Transaction History (All / Repayments / Disbursement), Your Flex Journey and How Progression Works.

## Rules used by the mock

| Rule | Value |
| --- | --- |
| Interest | 8% per 30 days, pro-rated by day: ₦3,000 → ₦112 for 14 days, ₦240 for 30 days |
| First offer | ₦3,000 |
| Next offer | 2× the highest fully repaid principal, capped at ₦100,000. After repaying ₦3,000 the next offer is ₦6,000. |
| Eligibility | Always eligible (demo) |
| Review | Four stages, about 1.1 s each |
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
