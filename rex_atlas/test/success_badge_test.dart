import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_atlas/core/widgets/success_badge.dart';

void main() {
  testWidgets('success badge plays once and settles', (t) async {
    await t.pumpWidget(const Center(child: SuccessBadge()));
    expect(t.binding.hasScheduledFrame, isTrue);
    await t.pumpAndSettle();
    expect(t.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('success badge shows the final frame with reduce motion', (
    t,
  ) async {
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.pumpWidget(
      MediaQuery.fromView(
        view: t.view,
        child: const Center(child: SuccessBadge()),
      ),
    );
    expect(t.binding.hasScheduledFrame, isFalse);
  });
}
