import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import 'pin_pad.dart';

/// Frame 5 "Confirm with your fingerprint" sheet.
///
/// SIMULATION: tapping the fingerprint calls [onAuthorize], which goes to
/// the (mock) AuthorizationService. No biometric hardware is used. "Use PIN
/// instead" opens a demo PIN pad; the PIN is checked by the mock service and
/// never stored. Returns `true` from the route when authorised.
class BiometricPromptSheet extends StatefulWidget {
  const BiometricPromptSheet({
    super.key,
    required this.onAuthorize,
    required this.onAuthorizePin,
    required this.isDemo,
    this.purpose = 'transfer',
  });

  final Future<void> Function() onAuthorize;

  /// Verifies a transaction PIN; throws on a wrong PIN.
  final Future<void> Function(String pin) onAuthorizePin;
  final bool isDemo;
  final String purpose;

  static Future<bool> show(
    BuildContext context, {
    required Future<void> Function() onAuthorize,
    required Future<void> Function(String pin) onAuthorizePin,
    required bool isDemo,
    String purpose = 'transfer',
  }) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      barrierColor: RexColors.scrim,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useSafeArea: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RexDimens.sheetRadius),
        ),
      ),
      builder: (_) => BiometricPromptSheet(
        onAuthorize: onAuthorize,
        onAuthorizePin: onAuthorizePin,
        isDemo: isDemo,
        purpose: purpose,
      ),
    );
    return ok ?? false;
  }

  @override
  State<BiometricPromptSheet> createState() => _BiometricPromptSheetState();
}

class _BiometricPromptSheetState extends State<BiometricPromptSheet> {
  bool _working = false;
  bool _showPinInfo = false;

  Future<void> _authorize() async {
    if (_working) return;
    HapticFeedback.mediumImpact();
    setState(() => _working = true);
    try {
      await widget.onAuthorize();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    // Figma: 299 tall. Min height so it grows with larger system text.
    return ConstrainedBox(
      key: const Key('biometric-sheet'),
      constraints: BoxConstraints(
        minHeight: 299 + (bottom > 34 ? bottom - 34 : 0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 38,
              bottom: 24 + (bottom > 34 ? bottom - 34 : 0),
            ),
            child: SizedBox(
              width: double.infinity,
              child: _showPinInfo ? _pinInfo() : _fingerprint(),
            ),
          ),
          Positioned(
            top: 16,
            right: 20,
            child: Pressable(
              key: const Key('biometric-close'),
              semanticLabel: 'Cancel authorisation',
              onTap: _working ? null : () => Navigator.of(context).pop(false),
              // 44pt touch target around the 24pt icon.
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: RexSvgIcon(
                    RexSvg.close,
                    size: 24,
                    color: RexColors.headerIcon,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fingerprint() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Pressable(
          key: const Key('biometric-fingerprint'),
          semanticLabel: 'Authorise with fingerprint',
          onTap: _authorize,
          child: Container(
            width: 83,
            height: 83,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: RexColors.fingerprintCircle,
              shape: BoxShape.circle,
            ),
            child: _working
                ? const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: RexColors.primary,
                    ),
                  )
                : const RexSvgIcon(
                    RexSvg.fingerprint,
                    size: 48,
                    color: Color(0xFF000EFF),
                  ),
          ),
        ),
        const SizedBox(height: 26),
        Text('Confirm with your fingerprint', style: RexTypography.sheetTitle),
        const SizedBox(height: 4),
        SizedBox(
          width: 220,
          child: Text(
            'Use your fingerprint to authorize this ${widget.purpose}',
            style: RexTypography.sheetBody,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 26),
        Pressable(
          key: const Key('biometric-use-pin'),
          semanticLabel: 'Use PIN instead',
          onTap: _working ? null : () => setState(() => _showPinInfo = true),
          child: Text('Use PIN instead', style: RexTypography.link),
        ),
        if (widget.isDemo) ...[
          const SizedBox(height: 10),
          Text(
            'Demo: tap the fingerprint to simulate approval',
            style: RexTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: RexColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// "Use PIN instead" → transaction PIN pad (demo verification; the PIN
  /// is never stored or sent anywhere).
  Widget _pinInfo() {
    return PinPad(
      key: const Key('pin-pad'),
      isDemo: widget.isDemo,
      purpose: widget.purpose,
      onUseFingerprint: () => setState(() => _showPinInfo = false),
      onSubmit: (pin) async {
        await widget.onAuthorizePin(pin);
        if (mounted) Navigator.of(context).pop(true);
      },
    );
  }
}
