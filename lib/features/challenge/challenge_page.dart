import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/widgets/celebration_overlay.dart';
import '../../app/widgets/fade_slide_in.dart';
import '../../app/widgets/noto_animated_emoji.dart';
import '../../app/widgets/page_header_bar.dart';
import '../../models/challenge.dart';
import '../../repositories/challenge_repository.dart';
import 'challenge_session.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({
    super.key,
    required this.challenge,
    required this.repository,
    this.session = const ChallengeSession(),
  });

  final Challenge challenge;
  final ChallengeRepository repository;
  final ChallengeSession session;

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage>
    with SingleTickerProviderStateMixin {
  static const _correctResults = [
    _ResultPreset(
      title: '答得漂亮',
      descriptionPrefix: '你抓住了更像真人的那一项。',
      asset: 'assets/animations/noto/party_popper.json',
    ),
    _ResultPreset(
      title: '这次很稳',
      descriptionPrefix: '你的判断很准，线索抓得很到位。',
      asset: 'assets/animations/noto/partying_face.json',
    ),
    _ResultPreset(
      title: '观察力不错',
      descriptionPrefix: '这题的细节你看到了。',
      asset: 'assets/animations/noto/glowing_star.json',
    ),
    _ResultPreset(
      title: '你抓到线索了',
      descriptionPrefix: '这个选择更接近真人创作。',
      asset: 'assets/animations/noto/trophy.json',
    ),
  ];

  static const _wrongResults = [
    _ResultPreset(
      title: '这题有点会伪装',
      descriptionPrefix: '这次被它骗到也很正常。',
      asset: 'assets/animations/noto/thinking_face.json',
    ),
    _ResultPreset(
      title: '差一点点',
      descriptionPrefix: '这题本来就挺像，别灰心。',
      asset: 'assets/animations/noto/open_mouth_face.json',
    ),
    _ResultPreset(
      title: '它确实很像',
      descriptionPrefix: '这类题最容易让人犹豫。',
      asset: 'assets/animations/noto/woozy_face.json',
    ),
    _ResultPreset(
      title: '再看一题试试',
      descriptionPrefix: '这次没选中真人创作的那一个。',
      asset: 'assets/animations/noto/dizzy.json',
    ),
  ];

  final Random _random = Random();
  late final AnimationController _streakController;

  String? _selectedOptionId;
  _ResultPresentation? _result;
  CelebrationVariant _celebrationVariant = CelebrationVariant.confetti;
  Color? _celebrationColor;
  bool _loadingNext = false;
  late int _streak;

  @override
  void initState() {
    super.initState();
    _streak = widget.session.streak;
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 860),
    );
  }

  @override
  void dispose() {
    _streakController.dispose();
    super.dispose();
  }

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _exitToHome(clearSession: true);
      },
      child: Scaffold(
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
                            child: PageHeaderBar(
                              title: challenge.mode.label,
                              onBack: () => _exitToHome(clearSession: true),
                            ),
                          ),
                          const SizedBox(height: 18),
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
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
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
                                      height: 0,
                                      width: double.infinity,
                                    )
                                  : _ResultBanner(
                                      key: ValueKey(_result!.title),
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
                                        delay: Duration(
                                            milliseconds: 220 + i * 90),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right:
                                                horizontal && i == 0 ? 10 : 0,
                                            left: horizontal && i == 1 ? 10 : 0,
                                            bottom: horizontal ? 0 : 12,
                                          ),
                                          child: _OptionCard(
                                            option: option,
                                            selected: isSelected,
                                            result: optionResult,
                                            locked: _result != null,
                                            onTap: () =>
                                                _selectOption(option.id),
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
                                        children: optionWidgets,
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: optionWidgets,
                                      );
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 260),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FilledButton.icon(
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
                                      : _confirmResult,
                                  icon: _loadingNext
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                          ),
                                        )
                                      : const Icon(Icons.check_rounded),
                                  label: Text(_loadingNext ? '准备中...' : '确定'),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Text(
                                    '选出你觉得更像真人创作的那一个。',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                if (_streak > 0) ...[
                                  const SizedBox(width: 16),
                                  _StreakBadge(
                                    streak: _streak,
                                    controller: _streakController,
                                  ),
                                ],
                              ],
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
                variant: _celebrationVariant,
                colorSeed: _celebrationColor,
              ),
            ],
          ),
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
    final preset = _pickOne(isCorrect ? _correctResults : _wrongResults);

    setState(() {
      _result = _ResultPresentation(
        isCorrect: isCorrect,
        title: preset.title,
        asset: preset.asset,
        description:
            '${preset.descriptionPrefix}${widget.challenge.explanation}',
      );
      if (isCorrect) {
        _streak += 1;
        _streakController
          ..reset()
          ..forward();
        _celebrationVariant = _pickOne(const [
          CelebrationVariant.confetti,
          CelebrationVariant.balloons,
          CelebrationVariant.fireworks,
        ]);
        _celebrationColor = _pickOne(const [
          Color(0xFFF15C4D),
          Color(0xFFF4B942),
          Color(0xFF5AC18E),
          Color(0xFF56B0F4),
          Color(0xFFF48FB1),
        ]);
      }
    });
  }

  Future<void> _confirmResult() async {
    final result = _result;
    if (result == null) {
      return;
    }

    if (result.isCorrect) {
      await _goToNextRandomChallenge();
      return;
    }

    final streakBeforeReset = _streak;
    await _showGameOverDialog(streakBeforeReset);
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
          session: ChallengeSession(streak: _streak),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
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

  Future<void> _showGameOverDialog(int streak) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = switch (streak) {
      <= 1 => '没关系，可以再试一次。',
      <= 9 => '哎哟，连续对了 $streak 个，不错哦。',
      _ => '哇！你好厉害，比游戏作者对的都多。',
    };

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '游戏结束',
      barrierColor: Colors.black.withValues(alpha: 0.26),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Material(
              color: Colors.transparent,
              child: AlertDialog(
                titlePadding: const EdgeInsets.fromLTRB(28, 28, 28, 10),
                contentPadding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
                actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
                title: Text(
                  '游戏结束',
                  style: theme.textTheme.headlineSmall,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本轮连胜：$streak',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$message\n\n找工作人员领取奖品。',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                    ),
                  ],
                ),
                actions: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    _exitToHome(clearSession: true);
  }

  void _exitToHome({required bool clearSession}) {
    if (!mounted) {
      return;
    }
    if (clearSession) {
      _streak = 0;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  T _pickOne<T>(List<T> values) => values[_random.nextInt(values.length)];
}

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
      _OptionResult.correct => scheme.tertiary,
      _OptionResult.wrong => scheme.error,
      null => selected ? scheme.primary : scheme.outline,
    };

    final background = switch (result) {
      _OptionResult.correct => scheme.tertiaryContainer.withValues(alpha: 0.76),
      _OptionResult.wrong => scheme.errorContainer.withValues(alpha: 0.84),
      null => selected
          ? scheme.primaryContainer.withValues(alpha: 0.74)
          : scheme.surface.withValues(alpha: 0.94),
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
            width: selected || result != null ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          onTap: locked ? null : onTap,
          child: Padding(
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
                      Icon(Icons.radio_button_checked_rounded, color: accent)
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
                          Image.asset(
                            option.asset!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
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
                          color: scheme.outline.withValues(alpha: 0.26),
                        ),
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
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({
    required this.streak,
    required this.controller,
  });

  final int streak;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pulse = 1 + sin(controller.value * pi * 2) * 0.06;
        return Transform.scale(
          scale: pulse,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
            ),
            child: Text(
              '$streak 连胜',
              style:
                  theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
            ),
          ),
        );
      },
    );
  }
}

enum _OptionResult { correct, wrong }

class _ResultPreset {
  const _ResultPreset({
    required this.title,
    required this.descriptionPrefix,
    required this.asset,
  });

  final String title;
  final String descriptionPrefix;
  final String asset;
}

class _ResultPresentation {
  const _ResultPresentation({
    required this.isCorrect,
    required this.title,
    required this.asset,
    required this.description,
  });

  final bool isCorrect;
  final String title;
  final String asset;
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
          NotoAnimatedEmoji(
            asset: result.asset,
            size: 54,
            repeat: true,
          ),
          const SizedBox(width: 16),
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
                    height: 1.65,
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
