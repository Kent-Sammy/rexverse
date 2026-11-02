import 'package:flutter/material.dart';

import '../core/design_system/design_system.dart';
import '../features/atlas/atlas.dart';
import '../features/host/presentation/rex_home_screen.dart';
import 'demo_device_frame.dart';

class RexAtlasDemoApp extends StatefulWidget {
  const RexAtlasDemoApp({super.key, this.dependencies, this.now});

  /// Defaults to [AtlasDependencies.mock]. Tests inject faster mocks.
  final AtlasDependencies? dependencies;
  final DateTime? now;

  @override
  State<RexAtlasDemoApp> createState() => _RexAtlasDemoAppState();
}

class _RexAtlasDemoAppState extends State<RexAtlasDemoApp> {
  late final AtlasController _atlas = AtlasController(
    widget.dependencies ?? AtlasDependencies.mock(),
  );

  @override
  void dispose() {
    _atlas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rex Atlas Prototype',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: RexTypography.fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: RexColors.primary,
          primary: RexColors.primary,
        ),
        scaffoldBackgroundColor: RexColors.appBackground,
        splashFactory: NoSplash.splashFactory,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: RexColors.primary,
        ),
      ),
      builder: (context, child) => DemoDeviceFrame(child: child!),
      home: RexHomeScreen(atlas: _atlas, now: widget.now),
    );
  }
}
