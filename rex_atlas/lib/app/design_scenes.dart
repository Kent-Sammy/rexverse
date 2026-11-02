// Design-review harness (prototype only). Opens the app in the exact state of
// a Figma frame so screenshots can be overlaid on the design:
//   http://localhost:8000/?frame=1&scene=3
// Scenes: 2 welcome, 3 review, 4 confirmation, 5 fingerprint, 6 result,
// 8 suggestions, 9 transactions. Not used by the normal app.
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';

import '../features/atlas/atlas.dart';
import '../features/atlas/domain/models/models.dart';
import 'app.dart';

final _now = DateTime(2026, 10, 29, 9, 41);

Future<Widget> buildDesignScene(int scene) async {
  final deps = AtlasDependencies.mock(latency: Duration.zero);
  final c = AtlasController(deps);
  await Future<void>.delayed(Duration.zero);

  TextMessage plain(TextMessage m) =>
      TextMessage(id: m.id, author: m.author, text: m.text);
  List<ChatMessage> visible() =>
      c.messages.map((m) => m is TextMessage ? plain(m) : m).toList();
  T last<T>() => c.messages.whereType<T>().last;
  TextMessage say(String id, String text, {bool user = false}) => TextMessage(
    id: id,
    author: user ? ChatAuthor.user : ChatAuthor.assistant,
    text: text,
  );

  if (scene >= 3 && scene <= 6) {
    await c.send('Send Money');
    await c.send('Send ₦3000 to GTB 0004218716');
  }
  switch (scene) {
    case 3:
      c.debugSetMessages([
        ...visible(),
        say('s1', 'Yes, continue please', user: true),
      ]);
      c.debugInitialScrollOffset = 0;
    case 4 || 5:
      await c.send('Yes, continue please');
      final all = visible();
      final shall = all.indexWhere(
        (m) => m is TextMessage && m.text == 'Shall I go ahead?',
      );
      c.debugSetMessages(all.sublist(shall));
      c.debugInitialScrollOffset = 7;
      if (scene == 4) c.authorizationDismissed();
      if (scene == 4) c.debugSetMessages(all.sublist(shall));
    case 6:
      await c.send('Yes, continue please');
      await c.authorizeWithBiometrics();
      await Future<void>.delayed(const Duration(milliseconds: 600));
      c.debugSetMessages([
        say(
          's1',
          'Please confirm with your biometrics to complete this transfer',
        ),
        last<PaymentResultMessage>(),
        say(
          's2',
          'Is there anything else i can help you with? You can also ask me to:',
        ),
      ]);
      c.debugInitialScrollOffset = 5;
    case 8:
      c.debugSetMessages([
        say('s1', 'Here are a few things you might want to do next.'),
        SuggestionsMessage(
          id: 's2',
          suggestions: AtlasController.defaultSuggestions,
        ),
      ]);
      c.debugInitialScrollOffset = 3;
    case 9:
      await c.send('Show my recent transactions');
      c.debugSetMessages([
        SuggestionsMessage(
          id: 's0',
          suggestions: AtlasController.defaultSuggestions,
        ),
        ...visible(),
      ]);
      c.debugInitialScrollOffset = 0;
  }
  return RexAtlasDemoApp(
    controller: c,
    now: _now,
    openAtlasOnStart: scene >= 2,
  );
}
