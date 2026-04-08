import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/widgets/celebration_overlay.dart';
import '../../app/widgets/emoji_text.dart';
import '../../app/widgets/fade_slide_in.dart';
import '../../models/challenge.dart';
import '../../repositories/challenge_repository.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({
    super.key,
    required this.challenge,
    required this.repository,
  });

  final Challenge challenge;
  final ChallengeRepository repository;

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  static const _correctEmojis = ['🎉', '✨', '🥳', '🌟'];
  static const _wrongEmojis = ['🫢', '🤏', '🙃', '😵‍💫'];
  static const _correctTitles = ['答得漂亮', '这次很稳', '观察力不错', '你抓到线索了'];
  static const _wrongTitles = ['这题有点会伪装', '差一点点', '它确实很像', '再看一题试试'];

  final Random _random = Random();
  String? _selectedOptionId;
  _ResultPresentation? _result;
  var _loadingNext = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final challenge = widget.challenge;
    final topColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1A1411)
        : const Color(0xFFF9EFE2);
    final bottomColor = theme.brightness == Brightness.dark
        ? const Color(0xFF100D0B)
        : const Color(0xFFFFFBF5);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1220),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                              EmojiText(challenge.mode.emoji, size: 28),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 120),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Text(
                                  challenge.title,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(fontSize: 36),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  challenge.prompt,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '选出你觉得更像真人创作的那一个。',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 180),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: _result == null
                                ? const SizedBox(
                                    height: 0, width: double.infinity)
                                : _ResultBanner(
                                    key: ValueKey(
                                        '${_result!.title}-${_result!.emoji}'),
                                    result: _result!,
                                  ),
                          ),
                        ),
                        if (_result != null) const SizedBox(height: 16),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final horizontal = constraints.maxWidth >= 920;
                              final optionWidgets = <Widget>[];

                              for (var i = 0;
                                  i < challenge.options.length;
                                  i++) {
                                final option = challenge.options[i];
                                final isSelected =
                                    _selectedOptionId == option.id;
                                final optionResult =
                                    _result == null || !isSelected
                                        ? null
                                        : _result!.isCorrect
                                            ? _OptionResult.correct
                                            : _OptionResult.wrong;

                                optionWidgets.add(
                                  Expanded(
                                    child: FadeSlideIn(
                                      delay:
                                          Duration(milliseconds: 220 + i * 90),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: horizontal && i == 0 ? 10 : 0,
                                          left: horizontal && i == 1 ? 10 : 0,
                                          bottom: horizontal ? 0 : 12,
                                        ),
                                        child: _OptionCard(
                                          option: option,
                                          selected: isSelected,
                                          result: optionResult,
                                          locked: _result != null,
                                          onTap: () {
                                            _selectOption(option.id);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return horizontal
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: optionWidgets)
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: optionWidgets);
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 260),
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: _result == null
                                  ? null
                                  : _result!.isCorrect
                                      ? scheme.tertiary
                                      : scheme.error,
                              foregroundColor: _result == null
                                  ? null
                                  : _result!.isCorrect
                                      ? scheme.onTertiary
                                      : scheme.onError,
                            ),
                            onPressed: _result == null || _loadingNext
                                ? null
                                : _goToNextRandomChallenge,
                            icon: _loadingNext
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline_rounded),
                            label: Text(_loadingNext ? '准备中...' : '确定'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            CelebrationOverlay(
              play: _result?.isCorrect ?? false,
            ),
          ],
        ),
      ),
    );
  }

  void _selectOption(String optionId) {
    if (_result != null) {
      return;
    }

    setState(() {
      _selectedOptionId = optionId;
    });
    _revealSelection();
  }

  void _revealSelection() {
    final selectedId = _selectedOptionId;
    if (selectedId == null || _result != null) {
      return;
    }

    final selected = widget.challenge.options
        .firstWhere((option) => option.id == selectedId);
    final isCorrect = selected.isHuman;

    setState(() {
      _result = _ResultPresentation(
        isCorrect: isCorrect,
        emoji: _pickOne(isCorrect ? _correctEmojis : _wrongEmojis),
        title: _pickOne(isCorrect ? _correctTitles : _wrongTitles),
        description: isCorrect
            ? '你选中了更像真人创作的选项。${widget.challenge.explanation}'
            : '这次没有选中真人创作的选项。${widget.challenge.explanation}',
      );
    });
  }

  Future<void> _goToNextRandomChallenge() async {
    setState(() {
      _loadingNext = true;
    });

    final next = await widget.repository.randomChallenge(
      widget.challenge.mode,
      excludeIds: {widget.challenge.id},
    );

    if (!mounted) {
      return;
    }

    if (next == null) {
      setState(() {
        _loadingNext = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂时没有下一题了。')),
      );
      return;
    }

    final prepared = widget.repository.prepareChallengeForPlay(next);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) => ChallengePage(
          challenge: prepared,
          repository: widget.repository,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  String _pickOne(List<String> values) =>
      values[_random.nextInt(values.length)];
}

enum _OptionResult { correct, wrong }

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.result,
    required this.locked,
    required this.onTap,
  });

  final ChallengeOption option;
  final bool selected;
  final _OptionResult? result;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = switch (result) {
      _OptionResult.correct => theme.colorScheme.tertiary,
      _OptionResult.wrong => theme.colorScheme.error,
      null => selected ? theme.colorScheme.primary : theme.colorScheme.outline,
    };

    final background = switch (result) {
      _OptionResult.correct =>
        theme.colorScheme.tertiaryContainer.withValues(alpha: 0.76),
      _OptionResult.wrong =>
        theme.colorScheme.errorContainer.withValues(alpha: 0.84),
      null => selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.74)
          : theme.colorScheme.surface.withValues(alpha: 0.94),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(
                alpha: selected || result != null ? 0.12 : 0.04),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Card(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
              color: accent.withValues(alpha: 0.42),
              width: selected || result != null ? 1.6 : 1),
        ),
        child: InkWell(
          onTap: locked ? null : onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              option.label,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: accent),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (selected && result == null)
                          Icon(Icons.radio_button_checked_rounded,
                              color: accent)
                        else if (result == _OptionResult.correct)
                          Icon(Icons.check_circle_rounded, color: accent)
                        else if (result == _OptionResult.wrong)
                          Icon(Icons.cancel_rounded, color: accent),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (option.asset != null)
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(option.asset!,
                                  fit: BoxFit.cover, width: double.infinity),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.08),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: scheme.outline.withValues(alpha: 0.26)),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              option.text ?? '',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(height: 1.8),
                            ),
                          ),
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

class _ResultPresentation {
  const _ResultPresentation({
    required this.isCorrect,
    required this.emoji,
    required this.title,
    required this.description,
  });

  final bool isCorrect;
  final String emoji;
  final String title;
  final String description;
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({super.key, required this.result});

  final _ResultPresentation result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = result.isCorrect ? scheme.tertiary : scheme.error;
    final background = result.isCorrect
        ? scheme.tertiaryContainer.withValues(alpha: 0.86)
        : scheme.errorContainer.withValues(alpha: 0.9);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accent.withValues(alpha: 0.46), width: 1.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedEmoji(
            result.emoji,
            size: 38,
            motion: EmojiMotion.loop,
            duration: const Duration(milliseconds: 1420),
            scaleBoost: 0.12,
            lift: 5,
            turns: 0.012,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: theme.textTheme.titleLarge?.copyWith(color: accent),
                ),
                const SizedBox(height: 6),
                Text(
                  result.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: result.isCorrect
                        ? scheme.onTertiaryContainer
                        : scheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
