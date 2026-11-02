import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/pressable.dart';
import '../../application/atlas_controller.dart';
import '../../domain/models/models.dart';
import 'atlas_brand.dart';
import 'attachment_bubble.dart';
import 'chat_bubble.dart';
import 'payment_confirmation_card.dart';
import 'payment_result_card.dart';
import 'payment_review_card.dart';
import 'suggestion_tile.dart';
import 'transactions_card.dart';
import 'typing_indicator.dart';

/// Renders one [ChatMessage] with the Figma row geometry.
class ChatMessageTile extends StatelessWidget {
  const ChatMessageTile({
    super.key,
    required this.message,
    required this.controller,
    required this.userInitials,
    required this.onNotice,
    this.lastInGroup = true,
  });

  final ChatMessage message;
  final AtlasController controller;
  final String userInitials;
  final ValueChanged<String> onNotice;

  /// iMessage-style grouping: only the last bubble in a run from the same
  /// author shows the avatar and the tail.
  final bool lastInGroup;

  static const _maxBubble = 264.0;

  /// Cards sit between the two avatar columns: they start after the Atlas
  /// avatar and stop before the user's avatar, aligned with the bubbles.
  static const _cardInsets = EdgeInsets.only(
    left: RexDimens.avatarSize + RexDimens.avatarGap,
    right: RexDimens.avatarSize + RexDimens.userAvatarGap,
  );

  @override
  Widget build(BuildContext context) {
    final content = _content();
    final isCard =
        message is PaymentReviewMessage ||
        message is PaymentConfirmationMessage ||
        message is PaymentResultMessage ||
        message is SuggestionsMessage ||
        message is TransactionsMessage;
    return isCard ? Padding(padding: _cardInsets, child: content) : content;
  }

  Widget _content() {
    final m = message;
    return switch (m) {
      TextMessage(author: ChatAuthor.user) => _userRow(m.text),
      AttachmentMessage() => _userRowWith(
        AttachmentBubble(message: m),
        'You shared ${m.fileName}',
      ),
      TextMessage() => _assistantRow(
        Text(m.text, style: RexTypography.bubble),
        below: m.quickReplies.isEmpty
            ? null
            : _QuickReplies(
                replies: m.quickReplies,
                enabled: !controller.isBusy,
                onTap: controller.send,
              ),
      ),
      TypingMessage(:final label) => _assistantRow(
        TypingIndicator(label: label),
      ),
      ErrorMessage() => _assistantRow(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(m.text, style: RexTypography.bubble),
            if (m.retryText != null) ...[
              const SizedBox(height: 6),
              Pressable(
                key: const Key('atlas-retry'),
                semanticLabel: 'Try again',
                onTap: controller.isBusy ? null : () => controller.retry(m),
                child: Text(
                  'Try again',
                  style: RexTypography.link.copyWith(fontSize: 13),
                ),
              ),
            ],
          ],
        ),
        color: RexColors.errorSoft,
      ),
      PaymentReviewMessage(:final draft, :final isActive) => PaymentReviewCard(
        draft: draft,
        isActive: isActive,
      ),
      PaymentConfirmationMessage(:final draft) => PaymentConfirmationCard(
        draft: draft,
      ),
      PaymentResultMessage(:final result, :final receipt) => Padding(
        padding: EdgeInsets.zero,
        child: PaymentResultCard(
          result: result,
          detailRows: receipt?.rows ?? const [],
          onViewReceipt: () => controller.viewReceipt(result.reference),
          onRepeat: controller.isBusy
              ? () {}
              : (result.draft.kind == PaymentKind.transfer
                    ? controller.makeAnotherTransfer
                    : () => controller.send('Buy more airtime')),
          onCopied: (label) => onNotice('$label copied'),
        ),
      ),
      SuggestionsMessage(:final suggestions) => Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < suggestions.length; i++) ...[
              if (i > 0) const SizedBox(height: 7),
              SuggestionTile(
                suggestion: suggestions[i],
                onTap: () => controller.sendSuggestion(suggestions[i]),
              ),
            ],
          ],
        ),
      ),
      TransactionsMessage(:final transactions) => TransactionsCard(
        transactions: transactions,
        onTap: (r) => controller.viewReceipt(r.reference),
      ),
    };
  }

  Widget _userRowWith(Widget bubble, String label) {
    return Semantics(
      container: true,
      label: label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(child: bubble),
          const SizedBox(width: RexDimens.userAvatarGap),
          InitialsAvatar(initials: userInitials),
        ],
      ),
    );
  }

  Widget _userRow(String text) {
    return Semantics(
      container: true,
      label: 'You said',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxBubble),
              child: UserBubble(text: text, tail: lastInGroup),
            ),
          ),
          const SizedBox(width: RexDimens.userAvatarGap),
          lastInGroup
              ? InitialsAvatar(initials: userInitials)
              : const SizedBox(width: RexDimens.avatarSize),
        ],
      ),
    );
  }

  Widget _assistantRow(Widget content, {Widget? below, Color? color}) {
    final bubble = AssistantBubble(
      color: color ?? RexColors.bubbleAssistant,
      tail: lastInGroup,
      child: content,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
          liveRegion: true,
          label: 'Rex Atlas says',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              lastInGroup
                  ? const AtlasBotAvatar()
                  : const SizedBox(width: RexDimens.avatarSize),
              const SizedBox(width: RexDimens.avatarGap),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxBubble),
                  child: bubble,
                ),
              ),
            ],
          ),
        ),
        if (below != null)
          Padding(
            padding: const EdgeInsets.only(
              left: RexDimens.avatarSize + RexDimens.avatarGap,
              top: 16,
            ),
            child: below,
          ),
      ],
    );
  }
}

/// Reply chips under "Shall I go ahead?" (prototype addition, see
/// docs/ASSUMPTIONS.md). Styled with existing tokens.
class _QuickReplies extends StatelessWidget {
  const _QuickReplies({
    required this.replies,
    required this.onTap,
    required this.enabled,
  });

  final List<String> replies;
  final ValueChanged<String> onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final r in replies)
          Pressable(
            key: Key('quick-reply-$r'),
            semanticLabel: r,
            enabled: enabled,
            onTap: () => onTap(r),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: RexColors.primary),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                r,
                style: RexTypography.bubble.copyWith(
                  fontSize: 13,
                  color: RexColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
