import '../data/mock/mock_account_services.dart';
import '../device/device_services.dart';
import '../data/mock/mock_atlas_assistant_service.dart';
import '../data/mock/mock_history_services.dart';
import '../data/mock/mock_data.dart';
import '../data/mock/mock_payment_services.dart';
import '../data/mock/mock_product_services.dart';
import '../domain/services/services.dart';

/// Everything Atlas needs from the outside world. The host app builds one
/// of these and passes it to `showRexAtlas`. Swap the mocks for production
/// implementations here – no UI code changes are required.
class AtlasDependencies {
  const AtlasDependencies({
    required this.assistant,
    required this.accounts,
    required this.beneficiaries,
    required this.transfers,
    required this.airtime,
    required this.history,
    required this.receipts,
    required this.authorization,
    required this.savings,
    required this.vault,
    required this.bills,
    required this.speech,
    required this.attachments,
    required this.sounds,
    this.isDemo = false,
  });

  final AtlasAssistantService assistant;
  final AccountService accounts;
  final BeneficiaryService beneficiaries;
  final TransferService transfers;
  final AirtimeService airtime;
  final TransactionHistoryService history;
  final ReceiptService receipts;
  final AuthorizationService authorization;
  final SavingsService savings;
  final VaultService vault;
  final BillsService bills;

  /// Device features (real implementations even in the demo).
  final SpeechInputService speech;
  final AttachmentPicker attachments;
  final ChatSoundPlayer sounds;

  /// When true the UI shows "Demo" labels on results and receipts.
  final bool isDemo;

  /// Fully simulated wiring used by the prototype and the widget tests.
  factory AtlasDependencies.mock({
    Duration? latency,
    SpeechInputService? speech,
    AttachmentPicker? attachments,
    ChatSoundPlayer? sounds,
  }) {
    Duration l(int ms) => latency ?? Duration(milliseconds: ms);
    final history = MockTransactionHistoryService(latency: l(600));
    return AtlasDependencies(
      assistant: MockAtlasAssistantService(latency: l(700)),
      accounts: MockAccountService(),
      beneficiaries: MockBeneficiaryService(latency: l(600)),
      transfers: MockTransferService(history: history, latency: l(1500)),
      airtime: MockAirtimeService(history: history, latency: l(1200)),
      history: history,
      receipts: MockReceiptService(history: history, sender: MockData.user),
      authorization: MockAuthorizationService(latency: l(500)),
      savings: MockSavingsService(history: history, latency: l(1200)),
      vault: MockVaultService(history: history, latency: l(1200)),
      bills: MockBillsService(
        history: history,
        customerName: MockData.user.holderName,
        latency: l(1200),
      ),
      speech: speech ?? DeviceSpeechInputService(),
      attachments: attachments ?? DeviceAttachmentPicker(),
      sounds: sounds ?? DeviceChatSoundPlayer(),
      isDemo: true,
    );
  }
}
