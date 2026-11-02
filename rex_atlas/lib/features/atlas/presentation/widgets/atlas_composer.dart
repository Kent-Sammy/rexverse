import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    HapticFeedback.lightImpact();
    widget.onSend(_text.text.trim());
    _text.clear();
    _focus.requestFocus(); // keep the keyboard up for the next reply
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.tone == ComposerTone.onDark;
    final fieldColor = dark
        ? Colors.white.withValues(alpha: 0.3)
        : RexColors.softBlue;
    final accent = dark ? Colors.white : RexColors.primary;
    final hint = RexTypography.composerHint.copyWith(
      color: dark ? Colors.white : null,
    );
    final input = RexTypography.composerInput.copyWith(
      color: dark ? Colors.white : null,
    );
    const h = RexDimens.composerHeight;

    return SizedBox(
      height: h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text pill with the "+" button inside.
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 3, right: 16),
              decoration: BoxDecoration(
                color: fieldColor,
                borderRadius: BorderRadius.circular(h / 2),
              ),
              child: Row(
                children: [
                  Pressable(
                    semanticLabel: 'Add attachment',
                    onTap: widget.onAttach,
                    focusRadius: 20,
                    // 40 pt tap area around the 26.8 pt Figma button.
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Container(
                          width: 26.8,
                          height: 26.8,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: RexColors.navy,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
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
                        semanticCounterText: '',
                        border: InputBorder.none,
                        hintText: 'Ask Rex Atlas...',
                        hintStyle: hint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Voice: its own round button.
          Pressable(
            semanticLabel: 'Voice input',
            pressedScale: 0.92,
            onTap: widget.onVoice,
            child: Container(
              width: h,
              height: h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fieldColor,
                shape: BoxShape.circle,
              ),
              // Figma export is #323DFF; tinted white on the dark welcome sheet.
              child: RexSvgIcon(
                RexSvg.mic,
                size: 24,
                color: dark ? Colors.white : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send: its own round button in solid Rex blue.
          Pressable(
            key: const Key('atlas-send-button'),
            semanticLabel: 'Send message',
            pressedScale: 0.92,
            onTap: _submit,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              // Dimmed only while Atlas is responding.
              opacity: widget.enabled ? 1 : 0.5,
              child: Container(
                width: h,
                height: h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dark ? Colors.white : RexColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (dark ? Colors.black : RexColors.primary)
                          .withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: RexSvgIcon(
                  RexSvg.iconlySend,
                  size: 18,
                  color: dark ? RexColors.primary : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
