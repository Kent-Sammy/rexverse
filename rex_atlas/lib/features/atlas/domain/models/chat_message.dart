import 'dart:typed_data';

import 'payment.dart';
import 'transaction.dart';

enum ChatAuthor { user, assistant }

/// Everything rendered in the Atlas conversation.
///
/// Structured messages (review, confirmation, result, suggestions, history)
/// are first-class so the UI never has to parse assistant prose.
sealed class ChatMessage {
  ChatMessage({required this.id, required this.author});
  final String id;
  final ChatAuthor author;
}

class TextMessage extends ChatMessage {
  TextMessage({
    required super.id,
    required super.author,
    required this.text,
    this.quickReplies = const [],
  });

  final String text;

  /// Optional tappable replies shown under an assistant message. Not in the
  /// Figma frames – added so a tester can answer "Shall I go ahead?" without
  /// typing (see docs/ASSUMPTIONS.md). Typing the same reply also works.
  final List<String> quickReplies;
}

/// Shown while the assistant is "thinking" or a service call is in flight.
class TypingMessage extends ChatMessage {
  TypingMessage({required super.id, this.label})
    : super(author: ChatAuthor.assistant);
  final String? label;
}

class ErrorMessage extends ChatMessage {
  ErrorMessage({required super.id, required this.text, this.retryText})
    : super(author: ChatAuthor.assistant);

  final String text;

  /// The user message to resend when "Try again" is tapped.
  final String? retryText;
}

/// Review card ("ODELEYE OLAYINKA ANTHONY / Amount / Transfer Fee / Total").
class PaymentReviewMessage extends ChatMessage {
  PaymentReviewMessage({
    required super.id,
    required this.draft,
    this.isActive = true,
  }) : super(author: ChatAuthor.assistant);
  final PaymentDraft draft;
  bool isActive;
}

/// Confirmation card shown with the biometric prompt.
class PaymentConfirmationMessage extends ChatMessage {
  PaymentConfirmationMessage({required super.id, required this.draft})
    : super(author: ChatAuthor.assistant);
  final PaymentDraft draft;
}

class PaymentResultMessage extends ChatMessage {
  PaymentResultMessage({required super.id, required this.result, this.receipt})
    : super(author: ChatAuthor.assistant);
  final PaymentResult result;
  final Receipt? receipt;
}

enum SuggestionAction {
  save,
  payBill,
  rexyDecember,
  buyAirtime,
  sendMoney,

  /// Open RexFlex: start a loan / view the current loan.
  rexflexStart,
  rexflexViewLoan,
}

class Suggestion {
  const Suggestion({
    required this.action,
    required this.title,
    required this.subtitle,
    this.boldSuffix,
  });

  final SuggestionAction action;
  final String title; // "Save "
  final String? boldSuffix; // "₦50,000"
  final String subtitle;
}

/// RexFlex offer shown in the chat before the customer applies.
class LoanOfferMessage extends ChatMessage {
  LoanOfferMessage({
    required super.id,
    required this.principalKobo,
    required this.days,
    required this.interestKobo,
    required this.dueDate,
    this.isActive = true,
  }) : super(author: ChatAuthor.assistant);
  final int principalKobo;
  final int days;
  final int interestKobo;
  final DateTime dueDate;

  /// Dimmed once the customer applies, changes term or cancels.
  bool isActive;

  int get totalKobo => principalKobo + interestKobo;
}

class SuggestionsMessage extends ChatMessage {
  SuggestionsMessage({required super.id, required this.suggestions})
    : super(author: ChatAuthor.assistant);
  final List<Suggestion> suggestions;
}

class TransactionsMessage extends ChatMessage {
  TransactionsMessage({required super.id, required this.transactions})
    : super(author: ChatAuthor.assistant);
  final List<TransactionRecord> transactions;
}

/// A photo or document the user shared with Atlas.
class AttachmentMessage extends ChatMessage {
  AttachmentMessage({
    required super.id,
    required this.fileName,
    required this.sizeBytes,
    required this.isImage,
    this.imageBytes,
  }) : super(author: ChatAuthor.user);

  final String fileName;
  final int sizeBytes;
  final bool isImage;

  /// Thumbnail bytes for images (kept in memory only, never uploaded).
  final Uint8List? imageBytes;
}
