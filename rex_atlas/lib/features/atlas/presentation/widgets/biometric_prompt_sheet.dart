import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';

/// Frame 5 "Confirm with your fingerprint" sheet.
///
/// SIMULATION: tapping the fingerprint calls [onAuthorize], which goes to
/// the (mock) AuthorizationService. No biometric hardware is used and no PIN
/// is collected. Returns `true` from the route when authorised.
class BiometricPromptSheet extends StatefulWidget {
  const BiometricPromptSheet({
    super.key,
    required this.onAuthorize,
    required this.isDemo,
    this.purpose = 'transfer',
  });

  final Future<void> Function() onAuthorize;
  final bool isDemo;
  final String purpose;

  static Future<bool> show(
    BuildContext context, {
    required Future<void> Function() onAuthorize,
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
    return SizedBox(
      key: const Key('biometric-sheet'),
      height: 299 + (bottom > 34 ? bottom - 34 : 0),
      child: Stack(
        children: [
          Positioned(
            top: 26,
            right: 30,
            child: Pressable(
              key: const Key('biometric-close'),
              semanticLabel: 'Cancel authorisation',
              onTap: _working ? null : () => Navigator.of(context).pop(false),
              child: const RexSvgIcon(
                RexSvg.close,
                size: 24,
                color: RexColors.headerIcon,
              ),
            ),
          ),
          Positioned.fill(
            top: 38,
            child: _showPinInfo ? _pinInfo() : _fingerprint(),
          ),
        ],
      ),
    );
  }

  Widget _fingerprint() {
    return Column(
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
            style: RexTypography.detailLabel.copyWith(fontSize: 10),
          ),
        ],
      ],
    );
  }

  /// "Use PIN instead" is designed only as a link. The prototype must not
  /// collect PINs, so it explains where PIN entry would happen instead.
  Widget _pinInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 83,
            height: 83,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: RexColors.fingerprintCircle,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dialpad_rounded,
              size: 40,
              color: Color(0xFF000EFF),
            ),
          ),
          const SizedBox(height: 26),
          Text('PIN authorisation', style: RexTypography.sheetTitle),
          const SizedBox(height: 4),
          Text(
            "Rex's secure transaction PIN pad isn't part of this prototype, so no PIN is collected here.",
            style: RexTypography.sheetBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Pressable(
            key: const Key('biometric-back'),
            semanticLabel: 'Use fingerprint',
            onTap: () => setState(() => _showPinInfo = false),
            child: Text('Use fingerprint', style: RexTypography.link),
          ),
        ],
      ),
    );
  }
}
