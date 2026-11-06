# Receipts and sharing

Built from Figma frame `24691:40110` (Transaction Details → Share Receipt).

## Transaction Details (`AtlasReceiptScreen`)

Opened from **View Receipt** on a result card or from a transaction row.

- Summary card with the Rex badge on its top edge, amount and status.
- The Transaction Details panel (same rows as the in-chat card).
- Action bar:
  - **Repeat Transfer** (transfers) / **Buy Again** (airtime): closes the page and sends the same
    request to Atlas, e.g. `Send ₦3000 to GTBank 0004218716`. Atlas still asks for review and
    fingerprint. Hidden for other transaction types.
  - **Share Receipt**: opens Share Receipt.
  - **Report**: a sheet to pick what went wrong. In the prototype nothing is sent; the
    confirmation says so.
- A **Demo receipt** banner for simulated data.

## Share Receipt (`ShareReceiptScreen`)

- Ticket-style receipt: Rex logo, amount, status, Recipient Details, Sender Details (account
  numbers masked as `703****815`), Transaction Type, Transaction No., Transaction Date, and Token
  for bills.
- **Share as image**: captures the ticket as a PNG (3× resolution) and opens the device share
  sheet.
- **Share as PDF**: builds a one-page A5 PDF (`receipt_pdf.dart`) and opens the share sheet.
- Files are named `Rex-Receipt-<transaction no>.png/.pdf`.
- Simulated receipts carry a **DEMO RECEIPT** note inside the image and PDF, so a shared copy
  can't pass as proof of payment.

Sharing goes through `ReceiptSharer` (`share_plus` on device; a download on the web), so tests
and the host app can replace it.

## Not taken from Figma

- Figma's "Session ID" row is left out: the mock services have no NIP session ID, and the app
  doesn't make one up.
- The Report reasons are assumed copy.
