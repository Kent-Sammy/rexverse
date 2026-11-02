import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../application/atlas_controller.dart';
import 'atlas_sheet.dart';

/// Presents Atlas over the host app with the Figma scrim (#090D1E @ 75%).
class AtlasSheetRoute extends PopupRoute<void> {
  AtlasSheetRoute({required this.atlas, this.now});

  final AtlasController atlas;
  final DateTime? now;

  @override
  Color? get barrierColor => RexColors.scrim;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Close Rex Atlas';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 240);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return AtlasSheet(controller: atlas, now: now);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}
