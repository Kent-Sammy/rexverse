/// Public entry point for the Rex Atlas feature.
///
/// Host apps only need this file:
/// ```dart
/// final atlas = AtlasController(AtlasDependencies.mock());
/// showRexAtlas(context, controller: atlas);
/// ```
library;

import 'package:flutter/widgets.dart';

import 'application/atlas_controller.dart';
import 'presentation/bottom_sheet/atlas_sheet_route.dart';

export 'application/atlas_controller.dart';
export 'application/atlas_dependencies.dart';

/// Opens Atlas over the current screen. The [controller] owns the
/// conversation, so reopening Atlas resumes where the user left off.
Future<void> showRexAtlas(
  BuildContext context, {
  required AtlasController controller,
  DateTime? now,
}) {
  return Navigator.of(context)
      .push(AtlasSheetRoute(atlas: controller, now: now));
}
