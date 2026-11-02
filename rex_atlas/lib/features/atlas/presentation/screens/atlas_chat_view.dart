import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../application/atlas_controller.dart';
import '../widgets/atlas_composer.dart';
import '../widgets/atlas_header.dart';
import '../widgets/chat_message_tile.dart';

/// Frames 3–9: the white conversation sheet.
class AtlasChatView extends StatefulWidget {
  const AtlasChatView({
    super.key,
    required this.controller,
    required this.isFullscreen,
    required this.showHandle,
    required this.onToggleFullscreen,
    required this.onClose,
    required this.onAttach,
    required this.onVoice,
    required this.onNotice,
    required this.dragHandleBuilder,
    this.topInset = 0,
  });

  final AtlasController controller;
  final bool isFullscreen;
  final bool showHandle;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onClose;
  final VoidCallback onAttach;
  final VoidCallback onVoice;
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

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
    _lastCount = widget.controller.messages.length;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToEnd(animate: false),
    );
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

  void _scrollToEnd({bool animate = true}) {
    if (!_scroll.hasClients) return;
    final target = _scroll.position.maxScrollExtent;
    if (animate) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final bottom = math.max(RexDimens.composerBottomInset, keyboard + 12);
    final initials = InitialsAvatar.fromName(c.account?.holderName ?? '');

    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          widget.dragHandleBuilder(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: RexDimens.pagePadding,
                    ),
                    child: AtlasHeader(
                      isFullscreen: widget.isFullscreen,
                      onToggleFullscreen: widget.onToggleFullscreen,
                      onClose: widget.onClose,
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
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView.separated(
                key: const Key('atlas-message-list'),
                controller: _scroll,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  RexDimens.pagePadding,
                  20,
                  RexDimens.pagePadding,
                  24,
                ),
                itemCount: c.messages.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: RexDimens.messageGap),
                itemBuilder: (context, i) => ChatMessageTile(
                  key: ValueKey(c.messages[i].id),
                  message: c.messages[i],
                  controller: c,
                  userInitials: initials,
                  onNotice: widget.onNotice,
                ),
              ),
            ),
          ),
          Padding(
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
              onVoice: widget.onVoice,
            ),
          ),
        ],
      ),
    );
  }
}
