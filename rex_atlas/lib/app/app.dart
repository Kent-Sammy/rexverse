import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design_system/design_system.dart';
import '../core/formatting/naira.dart';
import '../features/atlas/atlas.dart';
import '../features/atlas/device/device_services.dart' show ChatSound;
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
    this.rexflexService,
  });

  /// Defaults to [MockRexFlexService] (about a minute of background review).
  /// Tests inject a faster one.
  final RexFlexService? rexflexService;

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
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<FlexLoan>? _approvals;
  late final RexFlexController _rexflex = RexFlexController(
    service: widget.rexflexService ?? MockRexFlexService(),
    authorization: _atlas.deps.authorization,
    accounts: _atlas.deps.accounts,
    clock: widget.now == null ? null : () => widget.now!,
  );

  @override
  void initState() {
    super.initState();
    _approvals = _rexflex.approvals.listen(_onLoanApproved);
    // Atlas knows about the customer's RexFlex loan and can open RexFlex.
    _atlas
      ..loans = RexFlexLoanOverview(_rexflex)
      ..onOpenRexFlex = (destination) {
        final nav = _navigator.currentState;
        if (nav == null) return;
        switch (destination) {
          case RexFlexDestination.start:
            startRexFlexFromAtlas(nav, _rexflex);
          case RexFlexDestination.loan:
            viewRexFlexLoanFromAtlas(nav, _rexflex);
        }
      };
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

  /// A RexFlex review finished in the background: tell the customer
  /// wherever they are (unless they're already watching that loan).
  void _onLoanApproved(FlexLoan loan) {
    // Already on screen: the loan's own page, or Atlas (which posts the
    // approval in the chat).
    if (_rexflex.watchingLoanId == loan.id || _atlas.sheetVisible) return;
    HapticFeedback.mediumImpact();
    _atlas.deps.sounds.play(ChatSound.success);
    _messenger.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('rexflex-approved-notice'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: RexColors.navy,
          duration: const Duration(seconds: 6),
          persist: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4DCA7C),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your RexFlex loan of '
                  '${Naira.groupedWhole(loan.principalKobo)} was approved',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'View',
            textColor: const Color(0xFFB9D0FF),
            onPressed: () {
              final nav = _navigator.currentState;
              if (nav != null) openRexFlexLoan(nav, _rexflex, loan);
            },
          ),
        ),
      );
  }

  @override
  void dispose() {
    _approvals?.cancel();
    _rexflex.dispose();
    _atlas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
      scaffoldMessengerKey: _messenger,
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
