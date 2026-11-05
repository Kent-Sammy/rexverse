import 'package:flutter/material.dart';

import '../core/design_system/design_system.dart';
import '../features/atlas/atlas.dart';
import '../features/host/presentation/rex_home_screen.dart';
import '../features/rexflex/rexflex.dart';
import 'demo_device_frame.dart';

class RexAtlasDemoApp extends StatefulWidget {
  const RexAtlasDemoApp({
    super.key,
    this.dependencies,
    this.now,
    this.controller,
    this.openAtlasOnStart = false,
  });

  /// Defaults to [AtlasDependencies.mock]. Tests inject faster mocks.
  final AtlasDependencies? dependencies;
  final DateTime? now;

  /// Pre-built controller (design scenes). Overrides [dependencies].
  final AtlasController? controller;

  /// Opens Atlas immediately (design scenes).
  final bool openAtlasOnStart;

  @override
  State<RexAtlasDemoApp> createState() => _RexAtlasDemoAppState();
}

class _RexAtlasDemoAppState extends State<RexAtlasDemoApp> {
  late final AtlasController _atlas =
      widget.controller ??
      AtlasController(widget.dependencies ?? AtlasDependencies.mock());
  final _navigator = GlobalKey<NavigatorState>();
  late final RexFlexController _rexflex = RexFlexController(
    service: MockRexFlexService(),
    authorization: _atlas.deps.authorization,
    accounts: _atlas.deps.accounts,
    clock: widget.now == null ? null : () => widget.now!,
  );

  @override
  void initState() {
    super.initState();
    if (widget.openAtlasOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _navigator.currentContext;
        if (ctx != null) {
          showRexAtlas(
            ctx,
            controller: _atlas,
            now: widget.now,
            resumeConversation: _atlas.hasConversation,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _rexflex.dispose();
    _atlas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
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
      home: RexHomeScreen(atlas: _atlas, rexflex: _rexflex, now: widget.now),
    );
  }
}
