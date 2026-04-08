import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sembast/sembast.dart';

import '../data/challenge_database.dart';
import '../models/challenge.dart';

typedef ChallengeAssetLoader = Future<String> Function(String assetPath);

class ChallengeStats {
  const ChallengeStats({
    required this.totalCount,
    required this.modeCounts,
  });

  final int totalCount;
  final Map<ChallengeMode, int> modeCounts;

  int countFor(ChallengeMode mode) => modeCounts[mode] ?? 0;
}

class ChallengeRepository {
  ChallengeRepository({
    Random? random,
    Future<Database>? databaseFuture,
    ChallengeAssetLoader? assetLoader,
  })  : _random = random ?? Random(),
        _databaseFuture =
            databaseFuture ?? openChallengeDatabase(_databaseName),
        _assetLoader = assetLoader ?? rootBundle.loadString;

  static const _databaseName = 'are_you_robot.db';
  static const _manifestAsset = 'assets/bootstrap/seed_manifest.json';
  static const _seedSignatureKey = 'seed_signature';

  final Random _random;
  final Future<Database> _databaseFuture;
  final ChallengeAssetLoader _assetLoader;

  final StoreRef<String, Map<String, Object?>> _challengeStore =
      stringMapStoreFactory.store('challenges');
  final StoreRef<String, Map<String, Object?>> _metaStore =
      stringMapStoreFactory.store('meta');

  Future<void>? _initializeFuture;

  Future<Database> get _db async => _databaseFuture;

  Future<void> initialize() {
    final current = _initializeFuture;
    if (current != null) {
      return current;
    }

    final next = _initializeImpl();
    _initializeFuture = next;
    return next.catchError((Object error) {
      _initializeFuture = null;
      throw error;
    });
  }

  Future<void> _initializeImpl() async {
    final manifestRaw = await _assetLoader(_manifestAsset);
    final manifest = SeedManifest.fromRaw(manifestRaw);
    final db = await _db;
    final currentMeta = await _metaStore.record(_seedSignatureKey).get(db);
    final currentSignature = currentMeta?['value'] as String?;
    final existingCount = await _challengeStore.count(db);

    if (currentSignature == manifest.signature && existingCount > 0) {
      return;
    }

    await _seedDatabase(db, manifest);
  }

  Future<void> _seedDatabase(Database db, SeedManifest manifest) async {
    await db.transaction((txn) async {
      await _challengeStore.delete(txn);

      for (final seed in manifest.seeds) {
        final raw = await _assetLoader(seed.assetPath);
        final challenges = Challenge.decodeList(raw);

        for (final challenge in challenges) {
          await _challengeStore
              .record(challenge.id)
              .put(txn, challenge.toJson());
        }
      }

      await _metaStore.record(_seedSignatureKey).put(txn, {
        'value': manifest.signature,
      });
    });
  }

  Future<List<Challenge>> loadAll() async {
    await initialize();
    final db = await _db;
    final snapshots = await _challengeStore.find(
      db,
      finder: Finder(sortOrders: [SortOrder('id')]),
    );
    return snapshots
        .map((snapshot) => Challenge.fromJson(snapshot.value))
        .toList();
  }

  Future<List<Challenge>> loadByMode(ChallengeMode mode) async {
    await initialize();
    final db = await _db;
    final snapshots = await _challengeStore.find(
      db,
      finder: Finder(
        filter: Filter.equals('mode', mode.key),
        sortOrders: [SortOrder('id')],
      ),
    );
    return snapshots
        .map((snapshot) => Challenge.fromJson(snapshot.value))
        .toList();
  }

  Future<Challenge?> loadById(String id) async {
    await initialize();
    final db = await _db;
    final raw = await _challengeStore.record(id).get(db);
    if (raw == null) {
      return null;
    }
    return Challenge.fromJson(raw);
  }

  Future<Challenge?> randomChallenge(
    ChallengeMode mode, {
    Set<String> excludeIds = const {},
  }) async {
    var matches = (await loadByMode(mode))
        .where((challenge) => !excludeIds.contains(challenge.id))
        .toList();

    if (matches.isEmpty && excludeIds.isNotEmpty) {
      matches = await loadByMode(mode);
    }

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

  Future<ChallengeStats> loadStats() async {
    final all = await loadAll();
    final modeCounts = <ChallengeMode, int>{
      for (final mode in ChallengeMode.values) mode: 0,
    };

    for (final challenge in all) {
      modeCounts[challenge.mode] = (modeCounts[challenge.mode] ?? 0) + 1;
    }

    return ChallengeStats(
      totalCount: all.length,
      modeCounts: modeCounts,
    );
  }

  Challenge prepareChallengeForPlay(Challenge challenge) {
    return challenge.shuffledOptions(_random);
  }

  @visibleForTesting
  Future<void> seedFromManifest(SeedManifest manifest) async {
    final db = await _db;
    await _seedDatabase(db, manifest);
  }
}

class SeedManifest {
  const SeedManifest({
    required this.signature,
    required this.seeds,
  });

  final String signature;
  final List<SeedAsset> seeds;

  factory SeedManifest.fromRaw(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return SeedManifest.fromJson(decoded);
  }

  factory SeedManifest.fromJson(Map<String, dynamic> json) {
    return SeedManifest(
      signature: json['signature'] as String,
      seeds: (json['seeds'] as List<dynamic>)
          .map((item) => SeedAsset.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signature': signature,
      'seeds': seeds.map((seed) => seed.toJson()).toList(),
    };
  }
}

class SeedAsset {
  const SeedAsset({
    required this.assetPath,
    required this.kind,
    this.checksum,
  });

  final String assetPath;
  final String kind;
  final String? checksum;

  factory SeedAsset.fromJson(Map<String, dynamic> json) {
    return SeedAsset(
      assetPath: json['assetPath'] as String,
      kind: json['kind'] as String,
      checksum: json['checksum'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetPath': assetPath,
      'kind': kind,
      if (checksum != null) 'checksum': checksum,
    };
  }
}
