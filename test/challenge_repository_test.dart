import 'dart:math';

import 'package:are_you_robot/models/challenge.dart';
import 'package:are_you_robot/repositories/challenge_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database database;

  const manifestJson = '''
{
  "signature": "test-seed-signature",
  "seeds": [
    {
      "assetPath": "assets/bootstrap/challenges.json",
      "kind": "bootstrap"
    },
    {
      "assetPath": "assets/bootstrap/generated_image_challenges.json",
      "kind": "generated-image"
    },
    {
      "assetPath": "assets/bootstrap/generated_text_challenges.json",
      "kind": "generated-text"
    }
  ]
}
''';

  const bootstrapJson = '''
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
  }
]
''';

  const generatedJson = '''
[
  {
    "id": "generated-text-001",
    "mode": "text",
    "title": "Generated",
    "prompt": "Say more?",
    "difficulty": "hard",
    "explanation": "Generated explanation.",
    "options": [
      {"id": "g-a", "label": "A", "sourceType": "ai", "text": "Long ai text"},
      {"id": "g-b", "label": "B", "sourceType": "human", "text": "Long human text"}
    ]
  }
]
''';

  const generatedImageJson = '''
[
  {
    "id": "image-1",
    "mode": "image",
    "title": "Image",
    "prompt": "Which is human?",
    "difficulty": "normal",
    "explanation": "Details.",
    "options": [
      {"id": "c", "label": "A", "sourceType": "human", "asset": "pic/true1.jpg"},
      {"id": "d", "label": "B", "sourceType": "ai", "asset": "pic/false1.png"}
    ]
  }
]
''';

  setUp(() async {
    database = await newDatabaseFactoryMemory().openDatabase('challenge-test.db');
  });

  tearDown(() async {
    await database.close();
  });

  ChallengeRepository buildRepository({Random? random}) {
    return ChallengeRepository(
      random: random,
      databaseFuture: Future<Database>.value(database),
      assetLoader: (assetPath) async {
        return switch (assetPath) {
          'assets/bootstrap/seed_manifest.json' => manifestJson,
          'assets/bootstrap/challenges.json' => bootstrapJson,
          'assets/bootstrap/generated_image_challenges.json' => generatedImageJson,
          'assets/bootstrap/generated_text_challenges.json' => generatedJson,
          _ => throw StateError('Unexpected asset path: $assetPath'),
        };
      },
    );
  }

  test('loads seeded challenges from manifest and filters by mode', () async {
    final repository = buildRepository(random: Random(1));

    final all = await repository.loadAll();
    final text = await repository.loadByMode(ChallengeMode.text);
    final image = await repository.loadByMode(ChallengeMode.image);
    final stats = await repository.loadStats();

    expect(all, hasLength(3));
    expect(text, hasLength(2));
    expect(image.single.id, 'image-1');
    expect(stats.countFor(ChallengeMode.text), 2);
    expect(stats.countFor(ChallengeMode.image), 1);
  });

  test('returns random challenge and batch', () async {
    final repository = buildRepository(random: Random(3));

    final challenge = await repository.randomChallenge(ChallengeMode.text);
    final batch = await repository.randomBatch(ChallengeMode.image, count: 10);

    expect(challenge, isNotNull);
    expect(challenge!.mode, ChallengeMode.text);
    expect(batch, hasLength(1));
    expect(batch.single.mode, ChallengeMode.image);
  });

  test('prepareChallengeForPlay reshuffles labels without changing source types', () async {
    final repository = buildRepository(random: Random(5));
    final original = (await repository.loadById('generated-text-001'))!;

    final prepared = repository.prepareChallengeForPlay(original);

    expect(prepared.options.map((option) => option.label), orderedEquals(['A', 'B']));
    expect(
      prepared.options.map((option) => option.sourceType).toSet(),
      equals({'human', 'ai'}),
    );
    expect(
      prepared.options.map((option) => option.id).toSet(),
      equals(original.options.map((option) => option.id).toSet()),
    );
  });

  test('prepareChallengeForPlay normalizes A/B explanation wording before shuffling', () {
    final repository = buildRepository(random: Random(1));
    const original = Challenge(
      id: 'text-order-a-b',
      mode: ChallengeMode.text,
      title: 'Order wording',
      prompt: 'Pick one',
      difficulty: 'normal',
      explanation: 'A段像临场回忆，B段更像整理过。',
      options: [
        ChallengeOption(
          id: 'opt-a',
          label: 'A',
          sourceType: 'ai',
          text: 'AI text',
        ),
        ChallengeOption(
          id: 'opt-b',
          label: 'B',
          sourceType: 'human',
          text: 'Human text',
        ),
      ],
    );

    final prepared = repository.prepareChallengeForPlay(original);

    expect(prepared.explanation, 'AI回答像临场回忆，真人回答更像整理过。');
  });

  test('prepareChallengeForPlay preserves explicit explanation wording before shuffling', () {
    final repository = buildRepository(random: Random(1));
    const original = Challenge(
      id: 'text-explicit-wording',
      mode: ChallengeMode.text,
      title: 'Explicit wording',
      prompt: 'Pick one',
      difficulty: 'normal',
      explanation: '真人回答更像想到哪写到哪，AI回答更完整。',
      options: [
        ChallengeOption(
          id: 'opt-a',
          label: 'A',
          sourceType: 'human',
          text: 'Human text',
        ),
        ChallengeOption(
          id: 'opt-b',
          label: 'B',
          sourceType: 'ai',
          text: 'AI text',
        ),
      ],
    );

    final prepared = repository.prepareChallengeForPlay(original);

    expect(prepared.explanation, '真人回答更像想到哪写到哪，AI回答更完整。');
  });
}
