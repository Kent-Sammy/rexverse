import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/app/app.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';
import 'package:rex_atlas/features/atlas/presentation/bottom_sheet/atlas_sheet.dart';
import 'package:rex_atlas/features/atlas/device/device_services.dart';

class FakeSpeech implements SpeechInputService {
  FakeSpeech({this.available = true});
  final bool available;
  ValueChanged<String>? onText;
  VoidCallback? onDone;
  bool stopped = false;

  @override
  Future<bool> start({
    required ValueChanged<String> onText,
    required VoidCallback onDone,
    required ValueChanged<String> onError,
  }) async {
    this.onText = onText;
    this.onDone = onDone;
    return available;
  }

  @override
  Future<void> stop() async => stopped = true;
}

class FakePicker implements AttachmentPicker {
  @override
  Future<PickedAttachment?> pick(AttachmentKind kind) async =>
      const PickedAttachment(
        name: 'payslip.pdf',
        sizeBytes: 245760,
        kind: AttachmentKind.document,
      );
}

class RecordingSounds implements ChatSoundPlayer {
  final played = <ChatSound>[];
  @override
  bool enabled = true;
  @override
  void play(ChatSound sound) {
    if (enabled) played.add(sound);
  }
}

Future<void> pumpFor(WidgetTester t, [int ms = 1500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> openAtlas(WidgetTester t, AtlasDependencies deps) async {
  t.view.physicalSize = const Size(402, 874);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(RexAtlasDemoApp(dependencies: deps));
  await t.pump();
  await t.tap(find.byKey(const Key('home-ask-atlas')));
  await pumpFor(t, 600);
}

Future<void> sendText(WidgetTester t, String text) async {
  await t.enterText(find.byKey(const Key('atlas-composer-field')), text);
  await t.pump();
  await t.tap(find.byKey(const Key('atlas-send-button')));
  await pumpFor(t);
}

void main() {
  testWidgets('welcome sheet no longer shows recent transactions', (t) async {
    await openAtlas(t, AtlasDependencies.mock(latency: Duration.zero));
    expect(find.text('How can I help you today?'), findsOneWidget);
    // Home now has its own Recent Transactions card; the sheet must not.
    Finder inSheet(String text) =>
        find.descendant(of: find.byType(AtlasSheet), matching: find.text(text));
    expect(inSheet('Recent Transactions'), findsNothing);
    expect(inSheet('Tunde Adeyemi'), findsNothing);
  });

  testWidgets('voice input fills the text box for review (not auto-sent)', (
    t,
  ) async {
    final speech = FakeSpeech();
    await openAtlas(
      t,
      AtlasDependencies.mock(latency: Duration.zero, speech: speech),
    );
    await t.tap(find.byKey(const Key('atlas-mic-button')));
    await t.pump();
    expect(find.bySemanticsLabel('Stop voice input'), findsOneWidget);
    speech.onText!('send money to my sister');
    speech.onDone!();
    await t.pump();
    expect(find.text('send money to my sister'), findsOneWidget);
    expect(
      find.text('Which account do you want to send money to?'),
      findsNothing,
    );
    await t.tap(find.byKey(const Key('atlas-send-button')));
    await pumpFor(t);
    expect(
      find.text('Which account do you want to send money to?'),
      findsOneWidget,
    );
  });

  testWidgets('voice input without permission explains why', (t) async {
    await openAtlas(
      t,
      AtlasDependencies.mock(
        latency: Duration.zero,
        speech: FakeSpeech(available: false),
      ),
    );
    await t.tap(find.byKey(const Key('atlas-mic-button')));
    await t.pump();
    expect(find.textContaining('microphone permission'), findsOneWidget);
    await pumpFor(t, 3000);
  });

  testWidgets(
    'uploading a document shows it in the chat with an honest reply',
    (t) async {
      await openAtlas(
        t,
        AtlasDependencies.mock(
          latency: Duration.zero,
          attachments: FakePicker(),
        ),
      );
      await t.tap(find.bySemanticsLabel('Add attachment').first);
      await pumpFor(t, 600);
      expect(find.text('Share with Rex Atlas'), findsOneWidget);
      await t.tap(find.byKey(const Key('attach-document')));
      await pumpFor(t, 1500);
      expect(find.text('payslip.pdf'), findsOneWidget);
      expect(find.text('240 KB'), findsOneWidget);
      expect(
        find.textContaining(
          "isn't available in this prototype yet, so nothing was processed",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'chat sounds: sent, received (once per burst), success, and mute',
    (t) async {
      final sounds = RecordingSounds();
      await openAtlas(
        t,
        AtlasDependencies.mock(latency: Duration.zero, sounds: sounds),
      );
      await sendText(t, 'Send ₦3000 to GTB 0004218716');
      expect(sounds.played, [ChatSound.sent, ChatSound.received]);
      await sendText(t, 'yes');
      await t.tap(find.byKey(const Key('biometric-fingerprint')));
      await pumpFor(t, 3000);
      expect(sounds.played.last, ChatSound.success);

      await t.tap(find.byKey(const Key('atlas-sound-toggle')));
      await t.pump();
      final count = sounds.played.length;
      await sendText(t, 'Show my recent transactions');
      expect(sounds.played.length, count);
      expect(sounds.enabled, isFalse);
      await pumpFor(t, 3000);
    },
  );

  test('device sound player is muted in tests', () {
    expect(DeviceChatSoundPlayer.debugMuted, isTrue);
    expect(kIsWeb, isFalse);
  });
}
