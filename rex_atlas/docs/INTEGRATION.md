# Integrating Atlas into the Rex app

The Rex app repository was not available, so nothing here assumes its architecture, state
management, routing, auth or API contracts. The feature is built to be lifted out with minimal coupling.

## What to move

```
lib/core/design_system/   → map onto Rex's existing theme/tokens (or keep as Atlas-local tokens)
lib/core/formatting/      → replace with Rex's shared formatters if they exist
lib/core/widgets/         → small helpers (Pressable, InitialsAvatar, ReplaceableAsset)
lib/features/atlas/       → the feature (move as a folder or a package)
assets/icons, assets/fonts, assets/images
```
`lib/features/host/` and `lib/app/` are prototype-only (stand-in home screen, demo device frame). Do not move them.

## Wiring

```dart
// Somewhere long-lived (DI container, provider, etc.)
final atlas = AtlasController(AtlasDependencies(
  assistant: RexAiAssistantService(...),        // real AI backend
  accounts: RexAccountService(...),
  beneficiaries: RexNameEnquiryService(...),
  transfers: RexTransferService(...),
  airtime: RexAirtimeService(...),
  history: RexTransactionHistoryService(...),
  receipts: RexReceiptService(...),
  authorization: RexStepUpAuthService(...),     // existing biometric/PIN stack
  isDemo: false,
));

// From the home header / service tile:
showRexAtlas(context, controller: atlas);
```

- **State management.** `AtlasController` is a plain `ChangeNotifier` with no package dependency, so it
  can be wrapped by Provider, Riverpod or BLoC, or exposed through `get_it`.
- **Navigation.** Atlas is a `PopupRoute` (`AtlasSheetRoute`) pushed on the host `Navigator`. The receipt
  is a `MaterialPageRoute` pushed from the sheet. If Rex uses go_router or auto_route, keep Atlas as a
  modal route, or replace these two pushes.
- **Dependencies.** `flutter_svg`, `speech_to_text`, `file_picker`, `audioplayers`.

## Device features

`lib/features/atlas/device/device_services.dart` holds three small interfaces, each with a real implementation:

| Interface | Implementation | Package |
|---|---|---|
| `SpeechInputService` | `DeviceSpeechInputService` | `speech_to_text` |
| `AttachmentPicker` | `DeviceAttachmentPicker` | `file_picker` |
| `ChatSoundPlayer` | `DeviceChatSoundPlayer` | `audioplayers` |

Permissions are already declared. Android: `RECORD_AUDIO`, `INTERNET`, and a query for the speech service. iOS
`Info.plist`: microphone, speech recognition and photo library. Production attachments need an upload/analysis
backend; today `AtlasController.sendAttachment` only acknowledges the file.

## Unresolved backend integrations

| Interface | What the Rex team must provide |
|---|---|
| `AtlasAssistantService` | AI endpoint and contract. The contract returns **intents/slots**, never payment results. Decide streaming vs request/response, conversation IDs, safety filtering and logging/PII policy |
| `AccountService` | current customer + source account(s), and account selection if several |
| `BeneficiaryService` | bank directory + NIP name enquiry; saved beneficiaries |
| `TransferService` | fee quote, limits, idempotency key, execution, final status (incl. pending/reversal) |
| `AirtimeService` | biller/network APIs, limits |
| `AuthorizationService` | real biometric (e.g. `local_auth`) **bound to the server-side transaction** + PIN fallback using Rex's secure PIN pad; token passed to the payment call |
| `TransactionHistoryService` / `ReceiptService` | history API, receipt API / PDF share |
| Analytics, feature flags, localisation, accessibility review | not implemented |

## Security notes

- The AI layer must never be the source of truth for a payment outcome. The controller only shows
  results returned by the payment services. Keep it that way.
- The prototype's authorisation is a **simulation**. Do not ship `MockAuthorizationService`.
- Remove `isDemo` labels only after real services are wired. Keep `isSimulated` on any sandbox data.
