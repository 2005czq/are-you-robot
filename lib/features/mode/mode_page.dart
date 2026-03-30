import 'package:flutter/material.dart';

import '../../app/widgets/fade_slide_in.dart';
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
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F7FF), Color(0xFFF8FBFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideIn(
                      child: Row(
                        children: [
                          IconButton.outlined(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.mode.label, style: theme.textTheme.headlineMedium),
                                const SizedBox(height: 4),
                                Text(
                                  widget.mode == ChallengeMode.text
                                      ? '从题库里抽一题，试着找出哪一句更像真人的声音。'
                                      : '看清光线、边缘和细节，判断哪一张更像真实拍摄。',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.mode == ChallengeMode.text ? '✍️ 文字侦探桌' : '🖼️ 图片侦探桌',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '你可以随机开始，也可以先从下面的题目卡片里挑一题。',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
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

                          return GridView.builder(
                            itemCount: challenges.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: wide ? 2 : 1,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: wide ? 1.42 : 1.24,
                            ),
                            itemBuilder: (context, index) {
                              final challenge = challenges[index];
                              return FadeSlideIn(
                                delay: Duration(milliseconds: 160 + index * 45),
                                child: _ChallengePreviewCard(
                                  challenge: challenge,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (context) => ChallengePage(challenge: challenge),
                                      ),
                                    );
                                  },
                                ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    avatar: Text(challenge.mode == ChallengeMode.text ? '✍️' : '🖼️'),
                    label: Text(challenge.difficulty.toUpperCase()),
                  ),
                  const Spacer(),
                  Icon(
                    challenge.mode == ChallengeMode.text
                        ? Icons.chat_bubble_outline_rounded
                        : Icons.image_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (previewImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(previewImage, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(challenge.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  challenge.prompt,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEDF5FF), Color(0xFFF7FBFF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      '点击开始判断',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
