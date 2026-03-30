import 'dart:math';

import 'package:are_you_robot/models/challenge.dart';
import 'package:are_you_robot/repositories/challenge_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleJson = '''
[
  {
    "id": "text-1",
    "mode": "text",
    "title": "Sample",
    "prompt": "Question?",
    "difficulty": "easy",
    "explanation": "Because.",
    "options": [
      {"id": "a", "label": "A", "sourceType": "human", "text": "Hello"},
      {"id": "b", "label": "B", "sourceType": "ai", "text": "Hi"}
    ]
  },
  {
    "id": "image-1",
    "mode": "image",
    "title": "Image",
    "prompt": "Which is human?",
    "difficulty": "normal",
    "explanation": "Details.",
    "options": [
      {"id": "c", "label": "A", "sourceType": "human", "asset": "foo.jpg"},
      {"id": "d", "label": "B", "sourceType": "ai", "asset": "bar.jpg"}
    ]
  }
]
''';

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = const StringCodec().decodeMessage(message);
      if (key == 'assets/bootstrap/challenges.json') {
        return const StringCodec().encodeMessage(sampleJson);
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  test('loads and filters challenges by mode', () async {
    final repository = ChallengeRepository(random: Random(1));

    final all = await repository.loadAll();
    final text = await repository.loadByMode(ChallengeMode.text);
    final image = await repository.loadByMode(ChallengeMode.image);

    expect(all, hasLength(2));
    expect(text.single.id, 'text-1');
    expect(image.single.id, 'image-1');
  });

  test('returns random challenge and batch', () async {
    final repository = ChallengeRepository(random: Random(3));

    final challenge = await repository.randomChallenge(ChallengeMode.text);
    final batch = await repository.randomBatch(ChallengeMode.image, count: 10);

    expect(challenge, isNotNull);
    expect(challenge!.mode, ChallengeMode.text);
    expect(batch, hasLength(1));
    expect(batch.single.mode, ChallengeMode.image);
  });
}
