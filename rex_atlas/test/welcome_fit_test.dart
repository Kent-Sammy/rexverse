import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/app/app.dart';
import 'package:rex_atlas/features/atlas/atlas.dart';
import 'package:rex_atlas/features/atlas/presentation/screens/atlas_welcome_view.dart';

/// The Atlas welcome sheet never scrolls: it grows to fit its content, with
/// the same spacing on every phone (only the smallest screens scale down).
const phones = <String, Size>{
  'iPhone SE (2016)': Size(320, 568),
  'small Android': Size(360, 640),
  'iPhone SE / 8': Size(375, 667),
  'Galaxy A': Size(360, 780),
  'iPhone 13 mini': Size(375, 812),
  'iPhone 14': Size(390, 844),
  'iPhone 16 Pro': Size(402, 874),
  'Galaxy S Ultra': Size(412, 892),
  'Pixel 7': Size(412, 915),
  'iPhone 16 Pro Max': Size(440, 956),
};

void main() {
  for (final e in phones.entries) {
    testWidgets('welcome sheet fits without scrolling on ${e.key}', (t) async {
      t.view.physicalSize = e.value;
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 40, bottom: 20);
      addTearDown(t.view.reset);
      await t.pumpWidget(
        RexAtlasDemoApp(
          dependencies: AtlasDependencies.mock(latency: Duration.zero),
        ),
      );
      await t.pump();
      await t.tap(find.byKey(const Key('home-ask-atlas')));
      for (var i = 0; i < 20; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      final view = find.byType(AtlasWelcomeView);

      // No vertical scrolling anywhere in the welcome sheet.
      final vertical = find
          .descendant(of: view, matching: find.byType(Scrollable))
          .evaluate()
          .where(
            (el) =>
                (el.widget as Scrollable).axisDirection == AxisDirection.down,
          );
      expect(vertical, isEmpty);

      // Content shown at full size, except on the very smallest phone.
      final fitted = find
          .descendant(of: view, matching: find.byType(FittedBox))
          .first;
      final space = t.getSize(fitted).height;
      final content = t
          .getSize(
            find.descendant(of: fitted, matching: find.byType(SizedBox)).first,
          )
          .height;
      if (e.value.height >= 640) {
        expect(space, closeTo(content, 1), reason: 'should not shrink');
      } else {
        expect(space / content, greaterThan(0.85));
      }
      expect(t.takeException(), isNull);
    });
  }
}
