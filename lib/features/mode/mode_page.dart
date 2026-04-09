import 'package:flutter/material.dart';

import '../../app/widgets/app_page_route.dart';
import '../../app/widgets/fade_slide_in.dart';
import '../../app/widgets/page_header_bar.dart';
import '../../models/challenge.dart';
import '../../repositories/challenge_repository.dart';
import '../challenge/challenge_page.dart';
import '../challenge/challenge_session.dart';

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

  void _handleChallengeExit() {
    setState(() {
      _batchFuture = _loadBatch();
    });
  }

  Future<void> _openRandomChallenge() async {
    final challenge = await widget.repository.randomChallenge(widget.mode);
    if (!mounted || challenge == null) {
      return;
    }

    final preparedChallenge =
        widget.repository.prepareChallengeForPlay(challenge);
    await Navigator.of(context).push(
      AppPageRoute<void>(
        builder: (context) => ChallengePage(
          challenge: preparedChallenge,
          repository: widget.repository,
          onExit: _handleChallengeExit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent =
        widget.mode == ChallengeMode.image ? scheme.secondary : scheme.primary;
    final onAccent = widget.mode == ChallengeMode.image
        ? scheme.onSecondary
        : scheme.onPrimary;
    final accentContainer = widget.mode == ChallengeMode.image
        ? scheme.secondaryContainer
        : scheme.primaryContainer;
    final topColor = theme.brightness == Brightness.dark
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.08),
            scheme.surfaceContainerLowest,
          )
        : Color.alphaBlend(
            accent.withValues(alpha: 0.06),
            scheme.surfaceContainerLow,
          );
    final bottomColor =
        Color.alphaBlend(accent.withValues(alpha: 0.015), scheme.surface);

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
                  final helperText = widget.mode == ChallengeMode.text
                      ? '从下面挑一个题目，进去以后看两段文字，判断哪一段更像真人写的。'
                      : '从下面挑一个题目，进去以后看两张图片，判断哪一张更像真实镜头。';

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideIn(
                          child: compactHeader
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PageHeaderBar(title: widget.mode.label),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: accent,
                                            backgroundColor: accentContainer
                                                .withValues(alpha: 0.28),
                                            side: BorderSide(
                                              color: accent.withValues(
                                                alpha: 0.18,
                                              ),
                                            ),
                                          ),
                                          onPressed: _refreshBatch,
                                          icon:
                                              const Icon(Icons.refresh_rounded),
                                          label: const Text('换一批'),
                                        ),
                                        FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: accent,
                                            foregroundColor: onAccent,
                                          ),
                                          onPressed: _openRandomChallenge,
                                          icon:
                                              const Icon(Icons.casino_outlined),
                                          label: const Text('随机挑战'),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : PageHeaderBar(
                                  title: widget.mode.label,
                                  trailing: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: accent,
                                        backgroundColor: accentContainer
                                            .withValues(alpha: 0.28),
                                        side: BorderSide(
                                          color: accent.withValues(alpha: 0.18),
                                        ),
                                      ),
                                      onPressed: _refreshBatch,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('换一批'),
                                    ),
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: accent,
                                        foregroundColor: onAccent,
                                      ),
                                      onPressed: _openRandomChallenge,
                                      icon: const Icon(Icons.casino_outlined),
                                      label: const Text('随机挑战'),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: FutureBuilder<List<Challenge>>(
                            future: _batchFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
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

                              return LayoutBuilder(
                                builder: (context, bodyConstraints) {
                                  const gridSpacing = 18.0;
                                  final crossAxisCount = wide ? 2 : 1;
                                  final rows =
                                      (challenges.length / crossAxisCount)
                                          .ceil();
                                  final aspectRatio = wide ? 2.72 : 2.18;
                                  final cardWidth = (bodyConstraints.maxWidth -
                                          (crossAxisCount - 1) * gridSpacing) /
                                      crossAxisCount;
                                  final cardHeight = cardWidth / aspectRatio;
                                  final gridHeight = rows * cardHeight +
                                      (rows - 1) * gridSpacing;
                                  final centered = gridHeight + 132 <
                                      bodyConstraints.maxHeight;

                                  Widget buildGrid({required bool scrollable}) {
                                    return GridView.builder(
                                      padding: EdgeInsets.zero,
                                      physics: scrollable
                                          ? const BouncingScrollPhysics()
                                          : const NeverScrollableScrollPhysics(),
                                      itemCount: challenges.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: gridSpacing,
                                        mainAxisSpacing: gridSpacing,
                                        childAspectRatio: aspectRatio,
                                      ),
                                      itemBuilder: (context, index) {
                                        final challenge = challenges[index];
                                        return FadeSlideIn(
                                          delay: Duration(
                                            milliseconds: 50 + index * 32,
                                          ),
                                          child: _ChallengePreviewCard(
                                            challenge: challenge,
                                            onTap: () {
                                              final preparedChallenge = widget
                                                  .repository
                                                  .prepareChallengeForPlay(
                                                challenge,
                                              );
                                              Navigator.of(context).push(
                                                AppPageRoute<void>(
                                                  builder: (context) =>
                                                      ChallengePage(
                                                    challenge:
                                                        preparedChallenge,
                                                    repository:
                                                        widget.repository,
                                                    session:
                                                        const ChallengeSession(),
                                                    onExit:
                                                        _handleChallengeExit,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  }

                                  final helper = FadeSlideIn(
                                    delay: const Duration(milliseconds: 40),
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 800,
                                        ),
                                        child: Text(
                                          helperText,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            height: 1.55,
                                            fontSize: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                                  if (centered) {
                                    return Column(
                                      children: [
                                        const Spacer(),
                                        helper,
                                        const SizedBox(height: 30),
                                        SizedBox(
                                          height: gridHeight,
                                          child: buildGrid(scrollable: false),
                                        ),
                                        const Spacer(),
                                      ],
                                    );
                                  }

                                  return Column(
                                    children: [
                                      helper,
                                      const SizedBox(height: 26),
                                      Expanded(
                                        child: buildGrid(scrollable: true),
                                      ),
                                    ],
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

class _ChallengePreviewCard extends StatefulWidget {
  const _ChallengePreviewCard({
    required this.challenge,
    required this.onTap,
  });

  final Challenge challenge;
  final VoidCallback onTap;

  @override
  State<_ChallengePreviewCard> createState() => _ChallengePreviewCardState();
}

class _ChallengePreviewCardState extends State<_ChallengePreviewCard> {
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final challenge = widget.challenge;
    final hint = challenge.mode == ChallengeMode.text
        ? challenge.prompt
        : '进入后查看两张图片，再判断哪张更像真实镜头。';
    final accent = challenge.mode == ChallengeMode.text
        ? scheme.primary
        : scheme.secondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        scale: _hovering ? 1.008 : 1,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.58),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: -22,
                  bottom: -48,
                  child: IgnorePointer(
                    child: Container(
                      width: 146,
                      height: 146,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.11),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              challenge.title,
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontSize: 28, height: 1.12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        hint,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.62,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
