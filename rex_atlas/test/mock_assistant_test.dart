import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/features/atlas/data/mock/mock_atlas_assistant_service.dart';
import 'package:rex_atlas/features/atlas/domain/models/models.dart';
import 'package:rex_atlas/features/atlas/domain/services/services.dart';

void main() {
  final ai = MockAtlasAssistantService(latency: Duration.zero);
  Future<AssistantIntent> ask(
    String t, [
    ConversationStage s = ConversationStage.idle,
  ]) => ai.interpret(AssistantRequest(utterance: t, stage: s));

  test('parses the designed transfer request', () async {
    final i = await ask('Send ₦3000 to GTB 0004218716');
    expect(i, isA<StartTransferIntent>());
    i as StartTransferIntent;
    expect(i.amountKobo, 300000);
    expect(i.bankQuery, 'gtb');
    expect(i.accountNumber, '0004218716');
    expect(i.isComplete, isTrue);
  });

  test('understands amounts with k, commas and N prefix', () async {
    final a =
        await ask('transfer 5k to access 0123456789') as StartTransferIntent;
    expect(a.amountKobo, 500000);
    final b = await ask(
      'send N12,500.50 to zenith 1234567890',
    ) as StartTransferIntent;
    expect(b.amountKobo, 1250050);
  });

  test('"Send Money" starts an empty transfer', () async {
    final i = await ask('Send Money') as StartTransferIntent;
    expect(i.amountKobo, isNull);
    expect(i.accountNumber, isNull);
  });

  test('confirmation, cancel and amount change depend on stage', () async {
    const s = ConversationStage.awaitingPaymentConfirmation;
    expect(await ask('Yes, continue please', s), isA<ConfirmIntent>());
    expect(await ask('Cancel', s), isA<CancelIntent>());
    final c = await ask('change the amount to 5000', s);
    expect(c, isA<ChangeAmountIntent>());
    expect((c as ChangeAmountIntent).amountKobo, 500000);
  });

  test('airtime with phone number and amount', () async {
    final i =
        await ask('Buy ₦500 airtime for 08031234567') as StartAirtimeIntent;
    expect(i.amountKobo, 50000);
    expect(i.phoneNumber, '08031234567');
  });

  test('bills, savings and vault are recognised (not transfers)', () async {
    final bill = await ask('Pay Bills');
    expect(bill, isA<StartBillIntent>());
    final save = await ask('Save ₦50,000') as StartSavingsIntent;
    expect(save.amountKobo, 5000000);
    expect(save.plan, SavingsPlan.rexSave);
    final rexy =
        await ask('Get Started With Rexy December') as StartSavingsIntent;
    expect(rexy.plan, SavingsPlan.rexyDecember);
    final vault =
        await ask('Lock ₦100,000 in RexVault for 90 days') as StartVaultIntent;
    expect(vault.amountKobo, 10000000);
    expect(vault.tenorDays, 90);
  });

  test('a full electricity request is parsed in one go', () async {
    final i = await ask(
      'Pay IKEDC prepaid meter 45031234567 ₦5,000',
    ) as StartBillIntent;
    expect(i.category, BillCategory.electricity);
    expect(i.billerQuery, 'ikedc');
    expect(i.customerId, '45031234567');
    expect(i.amountKobo, 500000);
  });

  test('short replies stay in the current flow', () async {
    const vaultStage = ConversationStage.awaitingVaultDetails;
    final t = await ask('1 year · 20% p.a.', vaultStage) as StartVaultIntent;
    expect(t.tenorDays, 365);
    expect(t.amountKobo, isNull);
    const billStage = ConversationStage.awaitingBillDetails;
    final pkg = await ask('Compact · ₦19,000', billStage) as StartBillIntent;
    expect(pkg.packageQuery, 'Compact · ₦19,000');
    final id = await ask('1234567890', billStage) as StartBillIntent;
    expect(id.customerId, '1234567890');
  });

  test('transactions intent', () async {
    expect(
      await ask('Show my recent transactions'),
      isA<ShowTransactionsIntent>(),
    );
  });

  test('simulated outage throws', () async {
    expect(
      () => ask('simulate error'),
      throwsA(isA<AssistantUnavailableException>()),
    );
  });
}
