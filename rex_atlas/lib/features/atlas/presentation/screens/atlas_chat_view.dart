import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/widgets/appear.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../application/atlas_controller.dart';
import '../../domain/models/models.dart';
import '../widgets/atlas_composer.dart';
import '../widgets/atlas_header.dart';
import '../widgets/chat_message_tile.dart';

/// Frames 3–9: the conversation sheet, with an iMessage-style feel:
/// bounce scrolling, grouped bubbles and a pop-in for new messages.
class AtlasChatView extends StatefulWidget {
  const AtlasChatView({
    super.key,
    required this.controller,
    required this.isFullscreen,
    required this.showHandle,
    required this.onToggleFullscreen,
    this.initiallyVisibleIds,
    this.soundOn = true,
    this.onToggleSound,
    required this.onClose,
    required this.onAttach,
    required this.onNotice,
    required this.dragHandleBuilder,
    this.topInset = 0,
  });

  final AtlasController controller;
  final bool isFullscreen;
  final bool showHandle;
  final VoidCallback onToggleFullscreen;

  /// Messages that were already there when Atlas opened (no pop-in).
  final Set<String>? initiallyVisibleIds;
  final bool soundOn;
  final VoidCallback? onToggleSound;
  final VoidCallback onClose;
  final VoidCallback onAttach;
  final ValueChanged<String> onNotice;

  /// Wraps the handle + header so the sheet can be dragged by it.
  final Widget Function(Widget child) dragHandleBuilder;
  final double topInset;

  @override
  State<AtlasChatView> createState() => _AtlasChatViewState();
}

class _AtlasChatViewState extends State<AtlasChatView> {
  final _scroll = ScrollController();
  int _lastCount = 0;

  /// Messages present when the view opened render without an entrance.
  late final Set<String> _initialIds =
      widget.initiallyVisibleIds ??
      widget.controller.messages.map((m) => m.id).toSet();

  static const _groupGap = RexDimens.messageGap; // between different speakers
  static const _bubbleGap = 4.0; // within a run from the same speaker
  static const _chromeHeight =
      33.0 + 33.0 + 16.0 + 1.0; // handle, header, gap, divider

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
    _lastCount = widget.controller.messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offset = widget.controller.debugInitialScrollOffset;
      if (offset != null && _scroll.hasClients) {
        _scroll.jumpTo(offset);
      } else {
        _scrollToEnd(animate: false);
      }
    });
  }

  @override
  void didUpdateWidget(AtlasChatView old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _scroll.dispose();
    super.dispose();
  }

  void _onChange() {
    final n = widget.controller.messages.length;
    if (n != _lastCount) {
      _lastCount = n;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  /// Scrolls to the newest message. The list builds lazily, so its total
  /// height is only an estimate until items are laid out; keep going until
  /// the end is really reached (a few frames at most).
  void _scrollToEnd({bool animate = true, int attempts = 4}) {
    if (!_scroll.hasClients) return;
    final target = _scroll.position.maxScrollExtent;
    if (animate) {
      _scroll
          .animateTo(
            target,
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
          )
          .then((_) => _settleAtEnd(attempts));
    } else {
      _scroll.jumpTo(target);
      _settleAtEnd(attempts);
    }
  }

  void _settleAtEnd(int attempts) {
    if (attempts <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final p = _scroll.position;
      if (p.maxScrollExtent - p.pixels > 1) {
        _scroll.jumpTo(p.maxScrollExtent);
        _settleAtEnd(attempts - 1);
      }
    });
  }

  static bool _isBubble(ChatMessage m) =>
      m is TextMessage || m is TypingMessage || m is ErrorMessage;

  static bool _sameRun(ChatMessage? a, ChatMessage? b) =>
      a != null &&
      b != null &&
      _isBubble(a) &&
      _isBubble(b) &&
      a.author == b.author &&
      !(a is TextMessage && a.quickReplies.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final msgs = c.messages;
    final bottom = RexDimens.composerBottom(context);
    final composerArea = 12 + RexDimens.composerHeight + bottom;
    final headerArea = widget.topInset + _chromeHeight;
    final initials = InitialsAvatar.fromName(c.account?.holderName ?? '');
    final started = c.conversationStartedAt;

    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: [
          // Messages sit between the header and the input bar. (They used to
          // scroll under translucent chrome, but text half-hidden behind it
          // failed WCAG contrast.)
          Positioned(
            left: 0,
            right: 0,
            top: headerArea,
            bottom: composerArea,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              // Tap-to-dismiss-keyboard is a convenience, not a control.
              excludeFromSemantics: true,
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView.builder(
                key: const Key('atlas-message-list'),
                controller: _scroll,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  RexDimens.pagePadding,
                  20,
                  RexDimens.pagePadding,
                  16,
                ),
                itemCount: msgs.length + (started == null ? 0 : 1),
                itemBuilder: (context, index) {
                  if (started != null && index == 0) {
                    return _TimeHeader(time: started);
                  }
                  final i = started == null ? index : index - 1;
                  final m = msgs[i];
                  final prev = i > 0 ? msgs[i - 1] : null;
                  final next = i + 1 < msgs.length ? msgs[i + 1] : null;
                  final tile = ChatMessageTile(
                    key: ValueKey(m.id),
                    message: m,
                    controller: c,
                    userInitials: initials,
                    onNotice: widget.onNotice,
                    lastInGroup: !_sameRun(m, next),
                  );
                  final gap = i == 0
                      ? 0.0
                      : (_sameRun(prev, m) ? _bubbleGap : _groupGap);
                  final child = _initialIds.contains(m.id)
                      ? tile
                      : Appear(
                          key: ValueKey('appear-${m.id}'),
                          alignment: m.author == ChatAuthor.user
                              ? Alignment.bottomRight
                              : Alignment.bottomLeft,
                          child: tile,
                        );
                  return Padding(
                    padding: EdgeInsets.only(top: gap),
                    child: child,
                  );
                },
              ),
            ),
          ),
          // Frosted header.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _Frosted(
              child: widget.dragHandleBuilder(
                Padding(
                  padding: EdgeInsets.only(top: widget.topInset),
                  child: Column(
                    children: [
                      Container(
                        height: 33,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(
                          top: RexDimens.chatHandleTop,
                        ),
                        child: widget.showHandle ? const SheetHandle() : null,
                      ),
                      Padding(
                        // Right inset 10: the 36 pt tap boxes keep the icons
                        // at their Figma positions.
                        padding: const EdgeInsets.only(
                          left: RexDimens.pagePadding,
                          right: 10,
                        ),
                        child: AtlasHeader(
                          isFullscreen: widget.isFullscreen,
                          onToggleFullscreen: widget.onToggleFullscreen,
                          onClose: widget.onClose,
                          soundOn: widget.soundOn,
                          onToggleSound: widget.onToggleSound,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(
                        height: 1,
                        width: double.infinity,
                        child: ColoredBox(color: RexColors.divider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Frosted input bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _Frosted(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  RexDimens.composerHorizontalInset,
                  12,
                  RexDimens.composerHorizontalInset,
                  bottom,
                ),
                child: AtlasComposer(
                  enabled: !c.isBusy,
                  onSend: c.send,
                  onAttach: widget.onAttach,
                  speech: c.deps.speech,
                  onNotice: widget.onNotice,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header / input-bar background.
class _Frosted extends StatelessWidget {
  const _Frosted({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Colors.white, child: child);
}

/// "Today 9:41 AM" above the first message, as in iMessage.
class _TimeHeader extends StatelessWidget {
  const _TimeHeader({required this.time});
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Today ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(text: RexDates.clock(time)),
            ],
          ),
          style: RexTypography.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: RexColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
