import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../../core/design_system/design_system.dart';
import '../../application/atlas_controller.dart';
import '../../domain/models/models.dart';
import '../../domain/services/services.dart';
import '../../device/device_services.dart';
import '../screens/atlas_chat_view.dart';
import '../screens/atlas_receipt_screen.dart';
import '../screens/atlas_welcome_view.dart';
import '../widgets/attachment_options_sheet.dart';
import '../widgets/biometric_prompt_sheet.dart';
import '../widgets/payment_parties.dart';

enum AtlasSheetMode { collapsed, expanded, fullscreen }

/// The Atlas bottom sheet: collapsed (welcome, frame 2), expanded (chat,
/// frames 3–9) and full screen (header "maximize" button).
class AtlasSheet extends StatefulWidget {
  const AtlasSheet({
    super.key,
    required this.controller,
    this.now,
    this.resumeConversation = false,
    this.initialMessage,
  });

  /// Open straight into the chat (design scenes only).
  final bool resumeConversation;

  /// Started immediately (e.g. tapping the RexSave tile sends "Save Money").
  final String? initialMessage;

  final AtlasController controller;
  final DateTime? now;

  @override
  State<AtlasSheet> createState() => AtlasSheetState();
}

class AtlasSheetState extends State<AtlasSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _height = AnimationController.unbounded(
    vsync: this,
  );

  /// Atlas always opens on the welcome screen. The chat (with the full
  /// history) appears once the user does something in this session.
  late bool _showChat =
      widget.resumeConversation ||
      widget.controller.stage == ConversationStage.awaitingAuthorization;
  late AtlasSheetMode _mode = _showChat
      ? AtlasSheetMode.expanded
      : AtlasSheetMode.collapsed;

  /// Messages that existed when Atlas opened: shown without entrance animation.
  late final Set<String> _openedIds = widget.controller.messages
      .map((m) => m.id)
      .toSet();
  StreamSubscription<AtlasEvent>? _events;
  Size? _lastSize;
  double _lastTop = 0;
  String? _notice;
  Timer? _noticeTimer;
  bool _closing = false;

  AtlasSheetMode get mode => _mode;

  @override
  void initState() {
    super.initState();
    _seenIds = widget.controller.messages.map((m) => m.id).toSet();
    widget.controller.addListener(_onControllerChange);
    _events = widget.controller.events.listen(_onEvent);
    final start = widget.initialMessage;
    if (start != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.controller.send(start);
      });
    }
    // Reopened while a payment waits for authorisation: ask again.
    final pending = widget.controller.pendingPayment;
    if (pending != null &&
        widget.controller.stage == ConversationStage.awaitingAuthorization) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _onEvent(RequestAuthorizationEvent(pending)),
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _events?.cancel();
    _noticeTimer?.cancel();
    _height.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- geometry

  double _collapsed(Size s, double top) => math.min(
    s.height * RexDimens.collapsedSheetHeight / RexDimens.designHeight,
    _expanded(s, top),
  );
  double _expanded(Size s, double top) => s.height - math.max(top, 24);
  double _heightFor(AtlasSheetMode m, Size s, double top) => switch (m) {
    AtlasSheetMode.collapsed => _collapsed(s, top),
    AtlasSheetMode.expanded => _expanded(s, top),
    AtlasSheetMode.fullscreen => s.height,
  };

  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 34,
  );

  void _goTo(AtlasSheetMode m, {bool animate = true, double velocity = 0}) {
    final s = _lastSize;
    if (s == null) {
      _mode = m;
      return;
    }
    setState(() => _mode = m);
    final target = _heightFor(m, s, _lastTop);
    if (animate) {
      // Spring snap: follows the finger's release velocity (pt/s, upward +).
      _height.animateWith(
        SpringSimulation(_spring, _height.value, target, velocity),
      );
    } else {
      _height.value = target;
    }
  }

  // ---------------------------------------------------------- behaviours

  /// Messages already on screen when Atlas opened (no sound for those).
  late final Set<String> _seenIds;
  DateTime _lastReceivedSound = DateTime(2000);

  /// iMessage-style feedback sounds for new messages.
  void _playSoundsForNewMessages() {
    final fresh = widget.controller.messages
        .where((m) => _seenIds.add(m.id))
        .toList();
    if (fresh.isEmpty) return;
    final sounds = widget.controller.deps.sounds;
    final success = fresh.any(
      (m) => m is PaymentResultMessage && m.result.isSuccessful,
    );
    final received = fresh.any(
      (m) => m.author == ChatAuthor.assistant && m is! TypingMessage,
    );
    final sent = fresh.any((m) => m.author == ChatAuthor.user);
    if (success) {
      sounds.play(ChatSound.success);
    } else if (received) {
      // One chime per burst of replies (e.g. intro + card + question).
      final now = DateTime.now();
      if (now.difference(_lastReceivedSound) >
          const Duration(milliseconds: 1200)) {
        _lastReceivedSound = now;
        sounds.play(ChatSound.received);
      }
    } else if (sent) {
      sounds.play(ChatSound.sent);
    }
  }

  void _onControllerChange() {
    if (widget.controller.messages.any((m) => !_seenIds.contains(m.id))) {
      _showChat = true;
    }
    _playSoundsForNewMessages();
    if (_showChat && _mode == AtlasSheetMode.collapsed) {
      _goTo(AtlasSheetMode.expanded);
    }
    if (mounted) setState(() {});
  }

  Future<void> _onEvent(AtlasEvent e) async {
    if (!mounted) return;
    switch (e) {
      case RequestAuthorizationEvent(:final draft):
        FocusScope.of(context).unfocus();
        final ok = await BiometricPromptSheet.show(
          context,
          onAuthorize: widget.controller.authorizeWithBiometrics,
          onAuthorizePin: widget.controller.authorizeWithPin,
          isDemo: widget.controller.deps.isDemo,
          purpose: RecipientInfo.of(draft).purpose,
        );
        if (!ok) widget.controller.authorizationDismissed();
      case OpenReceiptEvent(:final reference):
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AtlasReceiptScreen(
              reference: reference,
              receipts: widget.controller.deps.receipts,
            ),
          ),
        );
      case NoticeEvent(:final message):
        showNotice(message);
    }
  }

  void showNotice(String message) {
    _noticeTimer?.cancel();
    setState(() => _notice = message);
    _noticeTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _notice = null);
    });
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _toggleFullscreen() => _goTo(
    _mode == AtlasSheetMode.fullscreen
        ? AtlasSheetMode.expanded
        : AtlasSheetMode.fullscreen,
  );

  // Controls whose behaviour is not specified in Figma (docs/ASSUMPTIONS.md).
  Future<void> _onAttach() async {
    final kind = await AttachmentOptionsSheet.show(context);
    if (kind == null || !mounted) return;
    try {
      final file = await widget.controller.deps.attachments.pick(kind);
      if (file == null) return;
      await widget.controller.sendAttachment(
        fileName: file.name,
        sizeBytes: file.sizeBytes,
        isImage: file.kind == AttachmentKind.image,
        imageBytes: file.bytes,
      );
    } on AttachmentTooLargeException {
      showNotice('That file is over 10 MB. Please choose a smaller one.');
    } catch (_) {
      showNotice("Couldn't open that file. Please try another.");
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final s = _lastSize;
    if (s == null) return;
    _height.value = (_height.value - d.delta.dy).clamp(0.0, s.height);
  }

  void _onDragEnd(DragEndDetails d) {
    final s = _lastSize;
    if (s == null) return;
    final v = d.velocity.pixelsPerSecond.dy;
    final h = _height.value;
    final order = AtlasSheetMode.values;
    final collapsedH = _collapsed(s, _lastTop);

    if (v > 900) {
      final lower = order.lastWhere(
        (m) => _heightFor(m, s, _lastTop) < h - 1,
        orElse: () => AtlasSheetMode.collapsed,
      );
      if (h <= collapsedH + 1) return _close();
      return _goTo(lower, velocity: -v);
    }
    if (v < -900) {
      final higher = order.firstWhere(
        (m) => _heightFor(m, s, _lastTop) > h + 1,
        orElse: () => AtlasSheetMode.fullscreen,
      );
      return _goTo(higher, velocity: -v);
    }
    if (h < collapsedH * 0.7) return _close();
    final nearest = order.reduce(
      (a, b) =>
          (_heightFor(a, s, _lastTop) - h).abs() <=
              (_heightFor(b, s, _lastTop) - h).abs()
          ? a
          : b,
    );
    _goTo(nearest, velocity: -v);
  }

  Widget _dragZone(Widget child) => GestureDetector(
    key: const Key('atlas-drag-zone'),
    behavior: HitTestBehavior.translucent,
    onVerticalDragUpdate: _onDragUpdate,
    onVerticalDragEnd: _onDragEnd,
    child: child,
  );

  // --------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final top = MediaQuery.paddingOf(context).top;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (_lastSize != size || _lastTop != top) {
      final first = _lastSize == null;
      _lastSize = size;
      _lastTop = top;
      final target = _heightFor(_mode, size, top);
      if (first || !_height.isAnimating) _height.value = target;
    }
    if (keyboardOpen && _mode == AtlasSheetMode.collapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _mode == AtlasSheetMode.collapsed) {
          _goTo(AtlasSheetMode.expanded);
        }
      });
    }

    final c = widget.controller;
    final full = _mode == AtlasSheetMode.fullscreen;
    final radius = full ? 0.0 : RexDimens.sheetRadius;

    final Widget content = _showChat && c.hasConversation
        ? AtlasChatView(
            key: const ValueKey('chat'),
            controller: c,
            isFullscreen: full,
            showHandle: !full,
            topInset: full ? top : 0,
            onToggleFullscreen: _toggleFullscreen,
            initiallyVisibleIds: _openedIds,
            soundOn: c.deps.sounds.enabled,
            onToggleSound: () {
              setState(() => c.deps.sounds.enabled = !c.deps.sounds.enabled);
              showNotice(c.deps.sounds.enabled ? 'Sounds on' : 'Sounds off');
            },
            onClose: _close,
            onAttach: _onAttach,
            onNotice: showNotice,
            dragHandleBuilder: _dragZone,
          )
        : Stack(
            key: const ValueKey('welcome'),
            children: [
              Positioned.fill(
                child: AtlasWelcomeView(
                  controller: c,
                  now: widget.now,
                  onAttach: _onAttach,
                  onNotice: showNotice,
                  onComposerFocus: () {
                    if (_mode == AtlasSheetMode.collapsed) {
                      _goTo(AtlasSheetMode.expanded);
                    }
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 46,
                child: _dragZone(const SizedBox.expand()),
              ),
            ],
          );

    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: _height,
        builder: (context, child) {
          // While dragging below its resting height the content keeps its
          // size and slides down (clipped by the screen) instead of squashing.
          final contentH = math.max(_height.value, _collapsed(size, top));
          return SizedBox(
            key: const Key('atlas-sheet'),
            width: size.width,
            height: _height.value.clamp(0.0, size.height),
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: contentH,
              maxHeight: contentH,
              child: child,
            ),
          );
        },
        child: Material(
          type: MaterialType.transparency,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: content,
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom:
                      math.max(
                        RexDimens.composerBottomInset,
                        MediaQuery.viewInsetsOf(context).bottom + 12,
                      ) +
                      RexDimens.composerHeight +
                      12,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _notice == null ? 0 : 1,
                      child: Center(
                        child: Container(
                          key: const Key('atlas-notice'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: RexColors.textStrong.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            _notice ?? '',
                            textAlign: TextAlign.center,
                            style: RexTypography.caption.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
