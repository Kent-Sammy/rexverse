import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import '../../device/device_services.dart';

enum ComposerTone { light, onDark }

/// "Ask Rex Atlas..." input bar (366 x 48, pill).
class AtlasComposer extends StatefulWidget {
  const AtlasComposer({
    super.key,
    required this.onSend,
    required this.onAttach,
    required this.speech,
    required this.onNotice,
    this.tone = ComposerTone.light,
    this.enabled = true,
    this.focusNode,
    this.onFocus,
  });

  final ValueChanged<String> onSend;
  final VoidCallback onAttach;

  /// Speech-to-text for the microphone button.
  final SpeechInputService speech;

  /// Short status messages (e.g. microphone unavailable).
  final ValueChanged<String> onNotice;
  final ComposerTone tone;

  /// False while the assistant is responding; typing is still allowed.
  final bool enabled;
  final FocusNode? focusNode;
  final VoidCallback? onFocus;

  @override
  State<AtlasComposer> createState() => _AtlasComposerState();
}

class _AtlasComposerState extends State<AtlasComposer>
    with SingleTickerProviderStateMixin {
  final _text = TextEditingController();
  bool _listening = false;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
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
    if (_listening) widget.speech.stop();
    _pulse.dispose();
    _text.dispose();
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  /// Tap once to dictate, tap again to stop. The transcript lands in the
  /// text field so the user can check it before sending (never auto-sent).
  Future<void> _toggleListening() async {
    if (_listening) {
      await widget.speech.stop();
      _setListening(false);
      return;
    }
    HapticFeedback.mediumImpact();
    _setListening(true);
    final started = await widget.speech.start(
      onText: (words) {
        if (!mounted) return;
        _text.value = TextEditingValue(
          text: words,
          selection: TextSelection.collapsed(offset: words.length),
        );
      },
      onDone: () {
        if (mounted) _setListening(false);
      },
      onError: (_) {
        if (!mounted) return;
        _setListening(false);
        widget.onNotice("Sorry, I didn't catch that. Please try again.");
      },
    );
    if (!started && mounted) {
      _setListening(false);
      widget.onNotice(
        'Voice input needs microphone permission. You can allow it in your phone settings.',
      );
    }
  }

  void _setListening(bool v) {
    if (_listening == v) return;
    setState(() => _listening = v);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (v && !reduce) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  bool get _canSend => widget.enabled && _text.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSend) {
      // Empty input: focus the field rather than doing nothing.
      _focus.requestFocus();
      return;
    }
    if (_listening) {
      widget.speech.stop();
      _setListening(false);
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
                        hintText: _listening
                            ? 'Listening…'
                            : 'Ask Rex Atlas...',
                        hintStyle: hint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Voice: its own round button. Red and pulsing while listening.
          Pressable(
            key: const Key('atlas-mic-button'),
            semanticLabel: _listening ? 'Stop voice input' : 'Voice input',
            pressedScale: 0.92,
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) => Container(
                width: h,
                height: h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _listening ? RexColors.error : fieldColor,
                  shape: BoxShape.circle,
                  boxShadow: _listening
                      ? [
                          BoxShadow(
                            color: RexColors.error.withValues(alpha: 0.35),
                            blurRadius: 6 + 10 * _pulse.value,
                            spreadRadius: 1 + 5 * _pulse.value,
                          ),
                        ]
                      : null,
                ),
                child: child,
              ),
              // Figma export is #323DFF; tinted white on dark or while listening.
              child: RexSvgIcon(
                RexSvg.mic,
                size: 24,
                color: (dark || _listening) ? Colors.white : null,
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
