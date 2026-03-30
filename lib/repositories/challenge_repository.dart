import 'dart:math';

import 'package:flutter/services.dart';

import '../models/challenge.dart';

class ChallengeRepository {
  ChallengeRepository({Random? random}) : _random = random ?? Random();

  final Random _random;
  List<Challenge>? _cache;

  Future<List<Challenge>> loadAll() async {
    if (_cache != null) {
      return _cache!;
    }

    final raw = await rootBundle.loadString('assets/bootstrap/challenges.json');
    _cache = Challenge.decodeList(raw);
    return _cache!;
  }

  Future<List<Challenge>> loadByMode(ChallengeMode mode) async {
    final all = await loadAll();
    return all.where((challenge) => challenge.mode == mode).toList();
  }

  Future<Challenge?> randomChallenge(ChallengeMode mode) async {
    final matches = await loadByMode(mode);
    if (matches.isEmpty) {
      return null;
    }
    return matches[_random.nextInt(matches.length)];
  }

  Future<List<Challenge>> randomBatch(
    ChallengeMode mode, {
    int count = 6,
    Set<String> excludeIds = const {},
  }) async {
    final matches = (await loadByMode(mode))
        .where((challenge) => !excludeIds.contains(challenge.id))
        .toList()
      ..shuffle(_random);

    if (matches.length <= count) {
      return matches;
    }
    return matches.take(count).toList();
  }
}
