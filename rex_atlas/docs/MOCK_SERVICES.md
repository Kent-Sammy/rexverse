# Mock services and demo script

All mocks live in `lib/features/atlas/data/mock/` and implement the interfaces in
`lib/features/atlas/domain/services/`. They are wired in `AtlasDependencies.mock()`.
**Nothing connects to a network, a bank or a real AI model.**

| Interface | Mock | Simulated behaviour |
|---|---|---|
| `AtlasAssistantService` | `MockAtlasAssistantService` | Rule-based intent parser, 700 ms latency. Returns *intents* only; it never reports payment outcomes |
| `AccountService` | `MockAccountService` | signed-in user OLOLADE MR. MONEY, REXMFB 11028281921 |
| `BeneficiaryService` | `MockBeneficiaryService` | bank aliases (GTB, Access, Zenith, UBA, First Bank, Fidelity, Wema, Kuda, OPay, Moniepoint). GTB 0004218716 → ODELEYE OLAYINKA ANTHONY. Other 10-digit numbers → a demo name. Numbers starting `000000` → "not found" |
| `TransferService` | `MockTransferService` | fee ₦0. 1.5 s processing. **> ₦5,000,000 fails** (limit). Successful transfers are added to history |
| `AirtimeService` | `MockAirtimeService` | network detected from prefix (MTN/Airtel/Glo/9mobile). ₦50–₦50,000 allowed |
| `AuthorizationService` | `MockAuthorizationService` | returns a `demo-…` token after 500 ms. **Not a security control** |
| `TransactionHistoryService` | `MockTransactionHistoryService` | seeded with the Figma rows; in-memory |
| `ReceiptService` | `MockReceiptService` | builds receipts in the Figma "Transaction Details" row order, flagged `isSimulated` |

Every `PaymentResult`, `TransactionRecord` and `Receipt` carries `isSimulated = true` from the mocks.
The UI shows demo labels whenever that flag is set.

## Demo script (reproduces frames 2 → 9)

1. Tap **Ask RexAtlas…..** on the home screen. The welcome sheet appears (frame 2).
2. Tap **Send Money**. Atlas asks "Which account do you want to send money to?"
3. Type **`Send ₦3000 to GTB 0004218716`**. You get the review card and "Shall I go ahead?" (frame 3).
4. Tap **Yes, continue please** (or type it). The confirmation card and fingerprint sheet appear (frames 4–5).
5. Tap the **fingerprint**. Processing runs, then the result card shows "Transfer Successful!" and suggestions follow (frames 6–8).
6. Tap **View Receipt** to see the demo receipt, then go back.
7. Type **`Show my recent transactions`** to see the list (frame 9). Tap a row to open its receipt.

## More things to try

| Type this | What happens |
|---|---|
| `Send Money` → `0004218716` → `GTB` → `3000` | collects details one at a time |
| at review: `change the amount to 4500` | new review card; the old one is greyed out |
| at review: `cancel` | transfer cancelled, nothing sent |
| close the fingerprint sheet, then `continue` | paused, then resumed |
| `Send ₦6,000,000 to GTB 0004218716` → yes → fingerprint | failed result (limit) |
| `Send ₦3000 to GTB 0000001234` | account not found |
| `Buy ₦500 airtime for 08031234567` | airtime flow |
| `simulate error` | AI outage state with **Try again** |
| `pay bills`, `save`, `rexy december` | "not available in this prototype" |
