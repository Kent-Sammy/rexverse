import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../../core/design_system/design_system.dart';
import '../../application/atlas_controller.dart';
import '../../domain/models/models.dart';
import '../../domain/services/services.dart';
import '../screens/atlas_chat_view.dart';
import '../screens/atlas_receipt_screen.dart';
import '../screens/atlas_welcome_view.dart';
import '../widgets/biometric_prompt_sheet.dart';

enum AtlasSheetMode { collapsed, expanded, fullscreen }

/// The Atlas bottom sheet: collapsed (welcome, frame 2), expanded (chat,
/// frames 3–9) and full screen (header "maximize" button).
class AtlasSheet extends StatefulWidget {
  const AtlasSheet({super.key, required this.controller, this.now});

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
  late AtlasSheetMode _mode = widget.controller.hasConversation
      ? AtlasSheetMode.expanded
      : AtlasSheetMode.collapsed;
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
    widget.controller.addListener(_onControllerChange);
    _events = widget.controller.events.listen(_onEvent);
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

  void _onControllerChange() {
    if (widget.controller.hasConversation &&
        _mode == AtlasSheetMode.collapsed) {
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
          isDemo: widget.controller.deps.isDemo,
          purpose: draft.kind == PaymentKind.transfer ? 'transfer' : 'purchase',
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
  void _onAttach() =>
      showNotice('Attachments aren’t available in this prototype yet');
  void _onVoice() =>
      showNotice('Voice input isn’t available in this prototype yet');

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

    final Widget content = c.hasConversation
        ? AtlasChatView(
            key: const ValueKey('chat'),
            controller: c,
            isFullscreen: full,
            showHandle: !full,
            topInset: full ? top : 0,
            onToggleFullscreen: _toggleFullscreen,
            onClose: _close,
            onAttach: _onAttach,
            onVoice: _onVoice,
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
                  onVoice: _onVoice,
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
        builder: (context, child) => SizedBox(
          key: const Key('atlas-sheet'),
          width: size.width,
          height: _height.value,
          child: child,
        ),
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
