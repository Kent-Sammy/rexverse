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

/// Opens Atlas over the current screen. It always starts on the welcome
/// screen; the [controller] keeps the conversation, which reappears after the
/// user's first action. [initialMessage] starts a flow straight away (e.g. the
/// home "RexSave" tile sends "Save Money").
Future<void> showRexAtlas(
  BuildContext context, {
  required AtlasController controller,
  DateTime? now,
  bool resumeConversation = false,
  String? initialMessage,
}) {
  return Navigator.of(context).push(
    AtlasSheetRoute(
      atlas: controller,
      now: now,
      resumeConversation: resumeConversation,
      initialMessage: initialMessage,
    ),
  );
}
