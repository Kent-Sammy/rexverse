import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:rex_atlas/features/atlas/device/device_services.dart';

/// Loads the bundled Inter font so widget tests measure real text sizes
/// (the default test font would make overflow checks meaningless).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final loader = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Inter-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
  // No platform audio in widget tests.
  DeviceChatSoundPlayer.debugMuted = true;
  await testMain();
}
