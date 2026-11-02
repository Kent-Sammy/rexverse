import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/app/app.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';

Future<void> pumpFor(WidgetTester t, [int ms = 1500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> sendText(WidgetTester t, String text) async {
  await t.enterText(find.byKey(const Key('atlas-composer-field')), text);
  await t.pump();
  await t.tap(find.byKey(const Key('atlas-send-button')));
  await pumpFor(t);
}

Future<void> openAtlas(WidgetTester t, {double textScale = 1}) async {
  t.view.physicalSize = const Size(402, 874);
  t.view.devicePixelRatio = 1;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(t.view.reset);
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  await t.pumpWidget(
    RexAtlasDemoApp(
      dependencies: AtlasDependencies.mock(latency: Duration.zero),
    ),
  );
  await t.pump();
  await t.tap(find.byKey(const Key('home-ask-atlas')));
  await pumpFor(t, 600);
}

void main() {
  // WCAG 2.0 AA 1.4.3 contrast and 4.1.2 name/role, checked by Flutter's
  // accessibility guidelines on the real rendered output.
  testWidgets('home + welcome: text contrast and labelled buttons', (t) async {
    final handle = t.ensureSemantics();
    await openAtlas(t);
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('chat, review and result: text contrast and labelled buttons', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    await openAtlas(t);
    await sendText(t, 'Send ₦3000 to GTB 0004218716');
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    await sendText(t, 'yes');
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await t.tap(find.byKey(const Key('biometric-fingerprint')));
    await pumpFor(t, 3000);
    await expectLater(t, meetsGuideline(textContrastGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  // WCAG 1.4.4: text can be enlarged without loss of content.
  for (final scale in const [1.5, 2.0]) {
    testWidgets('no overflow with system text at ${scale}x', (t) async {
      await openAtlas(t, textScale: scale);
      await sendText(t, 'Send ₦3000 to GTB 0004218716');
      await sendText(t, 'yes');
      await t.tap(find.byKey(const Key('biometric-fingerprint')));
      await pumpFor(t, 3000);
      await sendText(t, 'Show my recent transactions');
      expect(t.takeException(), isNull);
    });
  }

  // WCAG 2.2.2: decorative animation stops when the OS asks for less motion.
  testWidgets('reduce motion: welcome animations settle', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await openAtlas(t);
    expect(t.binding.hasScheduledFrame, isFalse);
  });
}
