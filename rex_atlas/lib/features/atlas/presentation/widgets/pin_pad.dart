import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/services/services.dart';

/// Transaction PIN entry: four boxes + an on-screen keypad (no system
/// keyboard, so the PIN never passes through the IME). Digits live only in
/// this widget's memory and are cleared after each attempt.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.onSubmit,
    required this.onUseFingerprint,
    required this.isDemo,
    this.purpose = 'transfer',
  });

  /// Throws [IncorrectPinException] / [PinLockedException] on failure.
  final Future<void> Function(String pin) onSubmit;
  final VoidCallback onUseFingerprint;
  final bool isDemo;
  final String purpose;

  static const length = 4;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _error;
  bool _working = false;
  bool _locked = false;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void dispose() {
    _pin = '';
    _shake.dispose();
    super.dispose();
  }

  void _tapDigit(String d) {
    if (_working || _locked || _pin.length >= PinPad.length) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == PinPad.length) _submit();
  }

  void _backspace() {
    if (_working || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    final pin = _pin;
    setState(() => _working = true);
    try {
      await widget.onSubmit(pin);
    } on IncorrectPinException catch (e) {
      _fail(
        'Incorrect PIN. ${e.attemptsLeft} ${e.attemptsLeft == 1 ? 'attempt' : 'attempts'} left.',
      );
    } on PinLockedException {
      _fail(
        'Too many incorrect attempts. Use your fingerprint instead.',
        lock: true,
      );
    } catch (_) {
      _fail("Couldn't verify your PIN. Please try again.");
    }
  }

  void _fail(String message, {bool lock = false}) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _pin = '';
      _working = false;
      _error = message;
      _locked = lock;
    });
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!reduce) _shake.forward(from: 0);
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Enter your transaction PIN',
              style: RexTypography.sheetTitle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your 4-digit PIN to authorize this ${widget.purpose}',
            style: RexTypography.sheetBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _shake,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value),
                0,
              ),
              child: child,
            ),
            child: Semantics(
              key: const Key('pin-boxes'),
              label: '${_pin.length} of ${PinPad.length} digits entered',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < PinPad.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _PinBox(
                      filled: i < _pin.length,
                      active: i == _pin.length && !_locked,
                      error: _error != null,
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: Center(
              child: _working
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: RexColors.primary,
                      ),
                    )
                  : _error != null
                  ? Text(
                      _error!,
                      key: const Key('pin-error'),
                      style: RexTypography.caption.copyWith(
                        color: RexColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
          ),
          _Keypad(
            enabled: !_working && !_locked,
            onDigit: _tapDigit,
            onBackspace: _backspace,
          ),
          const SizedBox(height: 14),
          Pressable(
            key: const Key('biometric-back'),
            semanticLabel: 'Use fingerprint',
            pressedScale: 1,
            onTap: widget.onUseFingerprint,
            child: Text('Use fingerprint', style: RexTypography.link),
          ),
          if (widget.isDemo) ...[
            const SizedBox(height: 8),
            Text(
              "Demo: any 4 digits work (0000 shows a wrong-PIN error). Don't use your real PIN.",
              style: RexTypography.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: RexColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _PinBox extends StatelessWidget {
  const _PinBox({
    required this.filled,
    required this.active,
    required this.error,
  });
  final bool filled;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final border = error
        ? RexColors.error
        : active
        ? RexColors.primary
        : const Color(0xFFC9D3EA);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 52,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RexColors.fingerprintCircle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: active || error ? 2 : 1.2),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: filled ? 1 : 0,
        child: Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: RexColors.navy,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
  });
  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget key(
      String label, {
      VoidCallback? onTap,
      Widget? child,
      String? semantic,
    }) => Expanded(
      child: Pressable(
        key: Key('pin-key-${semantic ?? label}'),
        semanticLabel: semantic ?? label,
        enabled: enabled,
        haptic: false,
        onTap: onTap,
        child: Container(
          height: 54,
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: child == null ? RexColors.softBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              child ??
              Text(
                label,
                style: RexTypography.sheetTitle.copyWith(
                  fontSize: 22,
                  color: RexColors.navy,
                ),
              ),
        ),
      ),
    );
    Widget row(List<String> ds) =>
        Row(children: [for (final d in ds) key(d, onTap: () => onDigit(d))]);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Column(
          children: [
            row(['1', '2', '3']),
            row(['4', '5', '6']),
            row(['7', '8', '9']),
            Row(
              children: [
                const Expanded(child: SizedBox(height: 62)),
                key('0', onTap: () => onDigit('0')),
                key(
                  '',
                  semantic: 'Delete',
                  onTap: onBackspace,
                  child: const Icon(
                    Icons.backspace_outlined,
                    size: 24,
                    color: RexColors.navy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
