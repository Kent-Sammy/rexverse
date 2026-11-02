import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/design_system/design_system.dart';

/// Optional "iPhone 16 Pro" frame for demos in a desktop browser and for
/// screenshot comparison against the 402 x 874 Figma artboards.
///
/// Enabled on web when the window is wider than a phone, or forced with the
/// `?frame=1` URL parameter. It injects the device's safe-area insets
/// (top 62, bottom 34) and draws a mock status bar. On real devices it is a
/// no-op: the OS provides the insets and status bar.
class DemoDeviceFrame extends StatelessWidget {
  const DemoDeviceFrame({super.key, required this.child});
  final Widget child;

  static const _topInset = 62.0;
  static const _bottomInset = 34.0;

  static bool _forced() => kIsWeb && Uri.base.queryParameters['frame'] == '1';

  static bool showsStatusBar(BuildContext context) =>
      context.findAncestorWidgetOfExactType<_FrameMarker>() != null;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = kIsWeb && size.width > 600;
    if (!_forced() && !wide) return child;

    final mq = MediaQuery.of(context);
    final phone = MediaQuery(
      data: mq.copyWith(
        size: const Size(RexDimens.designWidth, RexDimens.designHeight),
        padding: const EdgeInsets.only(top: _topInset, bottom: _bottomInset),
        viewPadding: const EdgeInsets.only(
          top: _topInset,
          bottom: _bottomInset,
        ),
      ),
      child: _FrameMarker(child: child),
    );

    if (!wide) return phone;
    return ColoredBox(
      color: const Color(0xFFECECEC),
      child: Center(
        child: FittedBox(
          child: Container(
            width: RexDimens.designWidth,
            height: RexDimens.designHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 30),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: phone,
          ),
        ),
      ),
    );
  }
}

class _FrameMarker extends StatelessWidget {
  const _FrameMarker({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
}

/// Mock iOS status bar (Figma "Bottom Tab, Molecules", y 6–41).
class DemoStatusBar extends StatelessWidget {
  const DemoStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 13, 22, 0),
        child: Row(
          children: [
            Text(
              '9:41',
              style: RexTypography.host(
                17,
                weight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.near_me, size: 14, color: Colors.black),
            const Spacer(),
            const Icon(
              Icons.signal_cellular_alt_rounded,
              size: 17,
              color: Colors.black,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.wifi_rounded, size: 17, color: Colors.black),
            const SizedBox(width: 4),
            const Icon(
              Icons.battery_full_rounded,
              size: 20,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
