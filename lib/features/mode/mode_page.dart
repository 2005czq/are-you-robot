import 'package:flutter/material.dart';

import '../../models/challenge.dart';
import '../../repositories/challenge_repository.dart';
import '../challenge/challenge_page.dart';

class ModePage extends StatefulWidget {
  const ModePage({
    super.key,
    required this.mode,
    required this.repository,
  });

  final ChallengeMode mode;
  final ChallengeRepository repository;

  @override
  State<ModePage> createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  late Future<List<Challenge>> _batchFuture;
  final Set<String> _lastBatchIds = <String>{};

  @override
  void initState() {
    super.initState();
    _batchFuture = _loadBatch();
  }

  Future<List<Challenge>> _loadBatch() async {
    final batch = await widget.repository.randomBatch(
      widget.mode,
      count: 10,
      excludeIds: _lastBatchIds,
    );

    if (batch.isEmpty) {
      return widget.repository.randomBatch(widget.mode, count: 10);
    }

    _lastBatchIds
      ..clear()
      ..addAll(batch.map((challenge) => challenge.id));
    return batch;
  }

  void _refreshBatch() {
    setState(() {
      _batchFuture = _loadBatch();
    });
  }

  Future<void> _openRandomChallenge() async {
    final challenge = await widget.repository.randomChallenge(widget.mode);
    if (!mounted || challenge == null) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChallengePage(challenge: challenge),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode.label),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mode == ChallengeMode.text
                        ? '从题库里随机选一题，看看你能不能找出 AI 的伪装。'
                        : '先从几张占位样本开始，观察真实图和 AI 风格图在细节上的不同。',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: _openRandomChallenge,
                        icon: const Icon(Icons.casino_outlined),
                        label: const Text('随机挑战'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _refreshBatch,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('换一批'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: FutureBuilder<List<Challenge>>(
                      future: _batchFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final challenges = snapshot.data ?? <Challenge>[];
                        if (challenges.isEmpty) {
                          return Center(
                            child: Text(
                              '这个模式暂时还没有可玩的题目。',
                              style: theme.textTheme.titleMedium,
                            ),
                          );
                        }

                        final width = MediaQuery.sizeOf(context).width;
                        final crossAxisCount = width >= 880 ? 2 : 1;

                        return GridView.builder(
                          itemCount: challenges.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: crossAxisCount == 2 ? 1.55 : 1.35,
                          ),
                          itemBuilder: (context, index) {
                            final challenge = challenges[index];
                            return _ChallengePreviewCard(
                              challenge: challenge,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => ChallengePage(
                                      challenge: challenge,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChallengePreviewCard extends StatelessWidget {
  const _ChallengePreviewCard({
    required this.challenge,
    required this.onTap,
  });

  final Challenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? previewImage;
    for (final option in challenge.options) {
      if (option.asset != null) {
        previewImage = option.asset;
        break;
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(label: Text(challenge.difficulty.toUpperCase())),
                  const Spacer(),
                  Icon(
                    challenge.mode == ChallengeMode.text
                        ? Icons.chat_bubble_outline_rounded
                        : Icons.image_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (previewImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(previewImage, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Text(
                challenge.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  challenge.prompt,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '点击开始判断',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
