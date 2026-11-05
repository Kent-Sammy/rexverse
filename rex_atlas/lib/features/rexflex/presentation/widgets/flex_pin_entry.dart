import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../atlas/domain/services/services.dart';
import 'flex_ui.dart';

/// "Confirm Payment" PIN entry from the RexFlex designs: four boxes showing
/// `*` and an on-screen keypad (no system keyboard). Digits live only in
/// this widget's memory and are cleared after every attempt.
class FlexPinEntry extends StatefulWidget {
  const FlexPinEntry({super.key, required this.onComplete, this.isDemo = true});

  /// Throws [IncorrectPinException] / [PinLockedException] on failure.
  final Future<void> Function(String pin) onComplete;
  final bool isDemo;

  @override
  State<FlexPinEntry> createState() => _FlexPinEntryState();
}

class _FlexPinEntryState extends State<FlexPinEntry> {
  static const _length = 4;
  String _pin = '';
  String? _error;
  bool _working = false;
  bool _locked = false;

  @override
  void dispose() {
    _pin = '';
    super.dispose();
  }

  void _digit(String d) {
    if (_working || _locked || _pin.length >= _length) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == _length) _submit();
  }

  void _backspace() {
    if (_working || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _working = true);
    final pin = _pin;
    try {
      await widget.onComplete(pin);
    } on IncorrectPinException catch (e) {
      _fail(
        'Incorrect PIN. ${e.attemptsLeft} '
        '${e.attemptsLeft == 1 ? 'attempt' : 'attempts'} left.',
      );
    } on PinLockedException {
      _locked = true;
      _fail('Too many wrong attempts. PIN entry is locked for this demo.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _pin = '';
      _error = message;
    });
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {Widget? child, VoidCallback? onTap}) => Expanded(
      child: Pressable(
        key: Key('flex-pin-key-$label'),
        semanticLabel: label == 'back' ? 'Delete' : label,
        onTap: onTap ?? () => _digit(label),
        child: SizedBox(
          height: 56,
          child: Center(
            child:
                child ??
                Text(
                  label,
                  style: RexTypography.host(
                    22,
                    weight: FontWeight.w500,
                    color: RexColors.textStrong,
                  ),
                ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Please enter your transaction pin to proceed.',
          style: RexTypography.host(13, color: FlexColors.label),
        ),
        const SizedBox(height: 18),
        Semantics(
          label: 'PIN, ${_pin.length} of $_length digits entered',
          child: ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < _length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: FlexColors.panel,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _error != null
                              ? RexColors.error
                              : i == _pin.length && !_working
                              ? FlexColors.selectedBorder
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        i < _pin.length ? '*' : '',
                        style: RexTypography.host(
                          22,
                          weight: FontWeight.w600,
                          color: RexColors.textStrong,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
          child: Center(
            child: _working
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _error != null
                ? Text(
                    _error!,
                    key: const Key('flex-pin-error'),
                    textAlign: TextAlign.center,
                    style: RexTypography.host(
                      12,
                      weight: FontWeight.w500,
                      color: RexColors.error,
                    ),
                  )
                : null,
          ),
        ),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(children: [for (final d in row) key(d)]),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            key('0'),
            key(
              'back',
              onTap: _backspace,
              child: const Icon(
                Icons.backspace_outlined,
                size: 22,
                color: RexColors.textStrong,
              ),
            ),
          ],
        ),
        if (widget.isDemo)
          const FlexDemoLabel(
            text:
                "Demo: any 4 digits work (0000 shows a wrong-PIN error). "
                "Don't use your real PIN.",
          ),
      ],
    );
  }
}
