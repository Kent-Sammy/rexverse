import '../../domain/models/models.dart';
import '../../domain/services/services.dart';
import 'mock_data.dart';

/// Rule-based stand-in for the Rex AI backend.
///
/// Understands a small, documented vocabulary (see docs/DEMO_SCRIPT.md).
/// Type "simulate error" to exercise the assistant-unavailable state.
class MockAtlasAssistantService implements AtlasAssistantService {
  MockAtlasAssistantService({this.latency = const Duration(milliseconds: 700)});

  final Duration latency;

  static final _account = RegExp(r'(?<!\d)(\d{10})(?!\d)');
  static final _phone = RegExp(r'(?<!\d)((?:\+?234|0)[789][01]\d{8})(?!\d)');
  static final _amount = RegExp(
    r'(?:₦|ngn|naira|\bn)?\s?(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d{1,2}))?\s*(k\b|thousand)?',
    caseSensitive: false,
  );

  @override
  Future<AssistantIntent> interpret(AssistantRequest request) async {
    await Future<void>.delayed(latency);
    final raw = request.utterance.trim();
    final text = raw.toLowerCase();

    if (text.contains('simulate error')) {
      throw const AssistantUnavailableException('Simulated outage');
    }

    final stage = request.stage;

    if (_isCancel(text) && stage != ConversationStage.idle) {
      return const CancelIntent();
    }

    if (stage == ConversationStage.awaitingPaymentConfirmation) {
      if (_isAffirmative(text)) return const ConfirmIntent();
      final amount = _parseAmount(_stripNumbers(raw));
      if (amount != null &&
          (text.contains('change') ||
              text.contains('make it') ||
              text.contains('amount') ||
              RegExp(r'^\s*(₦|n)?[\d,\.]+k?\s*$').hasMatch(text))) {
        return ChangeAmountIntent(amount);
      }
    }

    if (stage == ConversationStage.awaitingAuthorization &&
        _isAffirmative(text)) {
      return const ConfirmIntent();
    }

    if (_has(text, ['transaction', 'history', 'statement', 'recent'])) {
      return const ShowTransactionsIntent();
    }

    final collectingDetails =
        stage == ConversationStage.awaitingTransferDetails ||
        stage == ConversationStage.awaitingAirtimeDetails;
    if (!collectingDetails || !RegExp(r'\d').hasMatch(text)) {
      if (_has(text, [
        'bill',
        'bills',
        'electricity',
        'dstv',
        'gotv',
        'internet',
        'cable',
      ])) {
        return const UnsupportedFeatureIntent('Bill payments');
      }
      if (_has(text, ['rexy', 'december'])) {
        return const UnsupportedFeatureIntent('Rexy December');
      }
      if (_has(text, ['save', 'rexsave', 'savings'])) {
        return const UnsupportedFeatureIntent('Saving with RexSave');
      }
    }

    final isAirtime = _has(text, [
      'airtime',
      'recharge',
      'top up',
      'top-up',
      'topup',
      'credit',
    ]);
    if (isAirtime ||
        stage == ConversationStage.awaitingAirtimeDetails &&
            !_looksLikeTransfer(text)) {
      final phone = _phone.firstMatch(raw)?.group(1);
      return StartAirtimeIntent(
        amountKobo: _parseAmount(_stripNumbers(raw)),
        phoneNumber: phone == null ? null : _normalisePhone(phone),
        network: _network(text),
      );
    }

    if (_looksLikeTransfer(text) ||
        stage == ConversationStage.awaitingTransferDetails) {
      return StartTransferIntent(
        amountKobo: _parseAmount(_stripNumbers(raw)),
        accountNumber: _account.firstMatch(raw)?.group(1),
        bankQuery: _bank(text),
      );
    }

    if (_has(text, ['help', 'what can you do', 'options', 'menu'])) {
      return const ShowSuggestionsIntent();
    }
    if (_has(text, [
      'hi',
      'hello',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
    ])) {
      return ReplyIntent(
        'Hi ${MockData.user.firstName}! I can send money, buy airtime or show your recent transactions.',
      );
    }
    if (_has(text, ['thank'])) {
      return const ReplyIntent(
        "You're welcome! Anything else I can help with?",
      );
    }
    return const ReplyIntent(
      "Sorry, I can't help with that yet. I can send money, buy airtime or show your recent transactions.",
    );
  }

  bool _looksLikeTransfer(String t) =>
      _has(t, ['send', 'transfer']) || _account.hasMatch(t) || _bank(t) != null;

  static bool _has(String text, List<String> words) => words.any((w) {
    if (w.contains(' ') || w.length > 4) return text.contains(w);
    return RegExp('\\b${RegExp.escape(w)}\\b').hasMatch(text);
  });

  static bool _isAffirmative(String t) =>
      _has(t, [
        'yes',
        'yeah',
        'yep',
        'yup',
        'ok',
        'okay',
        'sure',
        'continue',
        'proceed',
        'confirm',
        'go ahead',
        'do it',
        'please do',
      ]) &&
      !_isCancel(t);

  static bool _isCancel(String t) => _has(t, [
    'no',
    'nope',
    'cancel',
    'stop',
    'abort',
    "don't",
    'dont',
    'never mind',
    'nevermind',
  ]);

  static String? _bank(String t) {
    final sorted = MockData.bankAliases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final alias in sorted) {
      if (RegExp('\\b${RegExp.escape(alias)}\\b').hasMatch(t)) return alias;
    }
    return null;
  }

  static String? _network(String t) {
    for (final n in ['mtn', 'airtel', 'glo', '9mobile']) {
      if (RegExp('\\b$n\\b').hasMatch(t)) {
        return n == '9mobile' ? '9mobile' : n.toUpperCase();
      }
    }
    return null;
  }

  String _stripNumbers(String raw) =>
      raw.replaceAll(_phone, ' ').replaceAll(_account, ' ');

  static int? _parseAmount(String text) {
    for (final m in _amount.allMatches(text)) {
      final whole = int.tryParse(m.group(1)!.replaceAll(',', ''));
      if (whole == null || whole == 0) continue;
      final fraction = m.group(2);
      var kobo =
          whole * 100 +
          (fraction == null ? 0 : int.parse(fraction.padRight(2, '0')));
      if (m.group(3) != null) kobo *= 1000;
      return kobo;
    }
    return null;
  }

  static String _normalisePhone(String p) {
    if (p.startsWith('+234')) return '0${p.substring(4)}';
    if (p.startsWith('234')) return '0${p.substring(3)}';
    return p;
  }
}
