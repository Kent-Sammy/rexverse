import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';

enum ComposerTone { light, onDark }

/// "Ask Rex Atlas..." input bar (366 x 48, pill).
class AtlasComposer extends StatefulWidget {
  const AtlasComposer({
    super.key,
    required this.onSend,
    required this.onAttach,
    required this.onVoice,
    this.tone = ComposerTone.light,
    this.enabled = true,
    this.focusNode,
    this.onFocus,
  });

  final ValueChanged<String> onSend;
  final VoidCallback onAttach;
  final VoidCallback onVoice;
  final ComposerTone tone;

  /// False while the assistant is responding; typing is still allowed.
  final bool enabled;
  final FocusNode? focusNode;
  final VoidCallback? onFocus;

  @override
  State<AtlasComposer> createState() => _AtlasComposerState();
}

class _AtlasComposerState extends State<AtlasComposer> {
  final _text = TextEditingController();
  late final FocusNode _focus = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
    _focus.addListener(() {
      if (_focus.hasFocus) widget.onFocus?.call();
    });
  }

  @override
  void dispose() {
    _text.dispose();
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  bool get _canSend => widget.enabled && _text.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSend) {
      // Empty input: focus the field rather than doing nothing.
      _focus.requestFocus();
      return;
    }
    widget.onSend(_text.text.trim());
    _text.clear();
    _focus.requestFocus(); // keep the keyboard up for the next reply
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.tone == ComposerTone.onDark;
    final barColor = dark
        ? Colors.white.withValues(alpha: 0.3)
        : RexColors.softBlue;
    final accent = dark ? Colors.white : RexColors.primary;
    final hint = RexTypography.composerHint.copyWith(
      color: dark ? Colors.white : null,
    );
    final input = RexTypography.composerInput.copyWith(
      color: dark ? Colors.white : null,
    );

    return Container(
      height: RexDimens.composerHeight,
      padding: const EdgeInsets.only(left: 10, right: 13),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Pressable(
            semanticLabel: 'Add attachment',
            onTap: widget.onAttach,
            child: Container(
              width: 26.8,
              height: 26.8,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: RexColors.navy),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              key: const Key('atlas-composer-field'),
              controller: _text,
              focusNode: _focus,
              style: input,
              cursorColor: accent,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              onTapOutside: (_) {},
              minLines: 1,
              maxLines: 1,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Ask Rex Atlas...',
                hintStyle: hint,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Pressable(
            semanticLabel: 'Voice input',
            onTap: widget.onVoice,
            child: SizedBox(
              width: 27,
              height: 27,
              child: Center(
                child: RexSvgIcon(RexSvg.audioFilled, size: 25, color: accent),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Pressable(
            key: const Key('atlas-send-button'),
            semanticLabel: 'Send message',
            onTap: _submit,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              // Dimmed only while Atlas is responding (Figma shows the idle
              // send button at full strength even with an empty field).
              opacity: widget.enabled ? 1 : 0.5,
              child: Container(
                width: 26.8,
                height: 26.8,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const RexSvgIcon(
                  RexSvg.sendAltFilled,
                  size: 14,
                  color: RexColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
