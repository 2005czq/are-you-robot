import 'package:flutter/material.dart';

import '../../app/widgets/app_page_route.dart';
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
      count: 6,
      excludeIds: _lastBatchIds,
    );

    if (batch.isEmpty) {
      return widget.repository.randomBatch(widget.mode, count: 6);
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
      AppPageRoute<void>(
        builder: (context) => ChallengePage(challenge: challenge),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topColor = theme.brightness == Brightness.dark
        ? const Color(0xFF0F1F31)
        : const Color(0xFFF0F7FF);
    final bottomColor = theme.brightness == Brightness.dark
        ? const Color(0xFF0B1522)
        : const Color(0xFFF8FBFF);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  final compactHeader = constraints.maxWidth < 820;

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideIn(
                          child: compactHeader
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton.outlined(
                                          onPressed: () => Navigator.of(context).pop(),
                                          icon: const Icon(Icons.arrow_back_rounded),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            widget.mode.label,
                                            style: theme.textTheme.headlineMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        alignment: WrapAlignment.end,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: _refreshBatch,
                                            icon: const Icon(Icons.refresh_rounded),
                                            label: const Text('换一批'),
                                          ),
                                          FilledButton.icon(
                                            onPressed: _openRandomChallenge,
                                            icon: const Icon(Icons.casino_outlined),
                                            label: const Text('随机挑战'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    IconButton.outlined(
                                      onPressed: () => Navigator.of(context).pop(),
                                      icon: const Icon(Icons.arrow_back_rounded),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.mode.label,
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: _refreshBatch,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('换一批'),
                                    ),
                                    const SizedBox(width: 12),
                                    FilledButton.icon(
                                      onPressed: _openRandomChallenge,
                                      icon: const Icon(Icons.casino_outlined),
                                      label: const Text('随机挑战'),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.mode == ChallengeMode.text
                              ? '从下面 6 个问题里挑一个，点进去再判断哪一段更像真人写的。'
                              : '从下面 6 个标题里挑一个，点进去之后再看图片。',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                padding: EdgeInsets.zero,
                                itemCount: challenges.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: wide ? 2 : 1,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: wide ? 3.2 : 2.85,
                                ),
                                itemBuilder: (context, index) {
                                  final challenge = challenges[index];
                                  return FadeSlideIn(
                                    delay: Duration(milliseconds: 90 + index * 40),
                                    child: _ChallengePreviewCard(
                                      challenge: challenge,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          AppPageRoute<void>(
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
                  );
                },
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
    final hint = challenge.mode == ChallengeMode.text
        ? challenge.prompt
        : '进入后查看两张图片，再判断哪张更像真实镜头。';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                challenge.title,
                style: theme.textTheme.headlineSmall?.copyWith(fontSize: 26),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                hint,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
