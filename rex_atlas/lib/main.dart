import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/design_scenes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Design-review scenes (web only): ?scene=3 reproduces Figma frame 3.
  final scene = kIsWeb
      ? int.tryParse(Uri.base.queryParameters['scene'] ?? '')
      : null;
  runApp(
    scene == null ? const RexAtlasDemoApp() : await buildDesignScene(scene),
  );
}
