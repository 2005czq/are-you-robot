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
    this.onExit,
  });

  final Challenge challenge;
  final ChallengeRepository repository;
  final ChallengeSession session;
  final VoidCallback? onExit;

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage>
    with SingleTickerProviderStateMixin {
  static const _correctResults = [
    _ResultPreset(
      title: '这下看准了',
      descriptionPrefix: '你一下就盯住了更像真人的细节。',
      asset: 'assets/animations/noto/party_popper.json',
    ),
    _ResultPreset(
      title: '这题被你拿下了',
      descriptionPrefix: '这次判断很稳，关键线索基本没漏。',
      asset: 'assets/animations/noto/partying_face.json',
    ),
    _ResultPreset(
      title: '观察力在线',
      descriptionPrefix: '这题最容易骗人的地方，你刚好看到了。',
      asset: 'assets/animations/noto/glowing_star.json',
    ),
    _ResultPreset(
      title: '这波挺漂亮',
      descriptionPrefix: '你抓到的那个选项，确实更接近真人创作。',
      asset: 'assets/animations/noto/trophy.json',
    ),
    _ResultPreset(
      title: '你闻到题眼了',
      descriptionPrefix: '说明你已经开始形成自己的判断节奏了。',
      asset: 'assets/animations/noto/party_popper.json',
    ),
    _ResultPreset(
      title: '这一手很稳',
      descriptionPrefix: '不是瞎蒙，是真的把不自然的地方抓出来了。',
      asset: 'assets/animations/noto/partying_face.json',
    ),
  ];

  static const _wrongResults = [
    _ResultPreset(
      title: '这题有点会装',
      descriptionPrefix: '这次被它晃一下，真的很正常。',
      asset: 'assets/animations/noto/thinking_face.json',
    ),
    _ResultPreset(
      title: '就差一口气',
      descriptionPrefix: '这题本来就很像，犹豫一下很正常。',
      asset: 'assets/animations/noto/open_mouth_face.json',
    ),
    _ResultPreset(
      title: '它确实挺像的',
      descriptionPrefix: '这类题最会拿捏人的第一眼判断。',
      asset: 'assets/animations/noto/woozy_face.json',
    ),
    _ResultPreset(
      title: '先别急着怀疑自己',
      descriptionPrefix: '这次没选中真人创作的那一个，但离线索并不远。',
      asset: 'assets/animations/noto/dizzy.json',
    ),
    _ResultPreset(
      title: '它把细节藏住了',
      descriptionPrefix: '这题的伪装确实做得深一点。',
      asset: 'assets/animations/noto/pleading_face.json',
    ),
    _ResultPreset(
      title: '下一题找回来',
      descriptionPrefix: '这一题先记住感觉，后面会越来越顺。',
      asset: 'assets/animations/noto/thinking_face.json',
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
  late Set<String> _playedIds;

  @override
  void initState() {
    super.initState();
    _streak = widget.session.streak;
    _playedIds = {...widget.session.playedIds, widget.challenge.id};
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
        ? scheme.surfaceContainerLowest
        : scheme.surfaceContainerLow;
    final bottomColor =
        theme.brightness == Brightness.dark ? scheme.surface : scheme.surface;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _exitToMode(clearSession: true);
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
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeSlideIn(
                            child: PageHeaderBar(
                              title: challenge.mode.label,
                              onBack: () => _exitToMode(clearSession: true),
                            ),
                          ),
                          const SizedBox(height: 22),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 120),
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 820),
                                  child: Column(
                                    children: [
                                      Text(
                                        challenge.title,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.headlineLarge
                                            ?.copyWith(fontSize: 38),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        challenge.prompt,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          height: 1.55,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 180),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
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
                                          milliseconds: 220 + i * 90,
                                        ),
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
                            delay: const Duration(milliseconds: 220),
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
            '${preset.descriptionPrefix}\n\n${widget.challenge.explanation}',
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

    final allChallenges =
        await widget.repository.loadByMode(widget.challenge.mode);
    final remaining = allChallenges
        .where((challenge) => !_playedIds.contains(challenge.id))
        .toList();

    if (!mounted) {
      return;
    }

    if (remaining.isEmpty) {
      setState(() {
        _loadingNext = false;
      });
      await _showSessionCompleteDialog(_streak);
      return;
    }

    final next = remaining[_random.nextInt(remaining.length)];
    final prepared = widget.repository.prepareChallengeForPlay(next);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) => ChallengePage(
          challenge: prepared,
          repository: widget.repository,
          session: ChallengeSession(
            streak: _streak,
            playedIds: {..._playedIds, next.id},
          ),
          onExit: widget.onExit,
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
    final message = _buildGameOverCopy(streak);
    final rewardHint = _buildRewardHint(streak);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '游戏结束',
      barrierColor: Colors.black.withValues(alpha: 0.26),
      transitionDuration: const Duration(milliseconds: 220),
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
                  '😵 这轮先停一下',
                  style: theme.textTheme.headlineSmall,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _buildStreakSummary(streak),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$message\n\n$rewardHint',
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
                    child: const Text('回到题单'),
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

    _exitToMode(clearSession: true);
  }

  Future<void> _showSessionCompleteDialog(int streak) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = _buildDeckClearedCopy(streak);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '本轮通关',
      barrierColor: Colors.black.withValues(alpha: 0.26),
      transitionDuration: const Duration(milliseconds: 220),
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
                  '🎉 这一轮被你刷空了',
                  style: theme.textTheme.headlineSmall,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak > 0 ? '🏁 本轮最好成绩：$streak 连胜' : '📚 这一轮能出的题都被你刷完了。',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$message\n\n✨ 回去缓一口气，换一轮题再来继续打也很酷。',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                    ),
                  ],
                ),
                actions: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.tertiary,
                      foregroundColor: scheme.onTertiary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('回到题单'),
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
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    _exitToMode(clearSession: true);
  }

  String _buildGameOverCopy(int streak) {
    final low = [
      '🙂 没关系，这题本来就挺会迷惑人。',
      '🌱 这次先记住线索，下次会更稳。',
      '🫶 一道题说明不了什么，继续玩才会越来越厉害。',
      '👀 先把这种感觉记下来，下一次你会更快认出来。',
    ];
    final medium = [
      '👏 已经连续答对 $streak 题了，这波很可以。',
      '😎 连着抓到 $streak 题的线索，状态不错。',
      '✨ 一口气答对 $streak 题，观察力已经在线了。',
      '🔥 连着过了 $streak 题，说明你已经找到一点门道了。',
    ];
    final high = [
      '🤯 你居然连着拿下了 $streak 题，真的很强。',
      '🏆 连胜 $streak 题，这已经不是随便玩玩的水平了。',
      '🚀 一路冲到 $streak 连胜，这手感有点夸张了。',
      '🌟 能把连胜顶到 $streak，已经是很能打的状态了。',
    ];

    return switch (streak) {
      < 3 => _pickOne(low),
      < 8 => _pickOne(medium),
      _ => _pickOne(high),
    };
  }

  String _buildDeckClearedCopy(int streak) {
    final low = [
      '😄 你把这一轮题库刷空了，已经很棒了。',
      '🌟 题目都被你看完了，这轮收工得很体面。',
      '🧩 这一轮已经被你整个清掉了，节奏很好。',
    ];
    final medium = [
      '🚀 一路刷到题库见底，这状态真的顺。',
      '🥳 你把这一轮一路打穿了，收尾相当漂亮。',
      '📚 题目已经不够出了，这轮你是真的玩明白了。',
    ];
    final high = [
      '🚀 你不只是通关，简直像在清图。',
      '🏅 能把题库一路刷空，还保持连胜，真的离谱。',
      '😳 这轮题已经不够你打了，厉害。',
      '👑 能这样一路刷空题库，已经有点高手味道了。',
    ];

    return switch (streak) {
      < 4 => _pickOne(low),
      < 10 => _pickOne(medium),
      _ => _pickOne(high),
    };
  }

  String _buildStreakSummary(int streak) {
    if (streak <= 0) {
      return '🏁 这一轮还没攒起连胜，不过题眼已经摸到一点了。';
    }

    return '🏁 本轮连胜停在 $streak 题';
  }

  String _buildRewardHint(int streak) {
    final gentle = [
      '🎁 回到现场转一圈，说不定有一份小惊喜在等你。',
      '🎈 带着这轮的感觉去找现场老师聊聊，也许会有额外彩蛋。',
    ];
    final strong = [
      '🎁 带着这个成绩去找现场老师看看，说不定真有惊喜等着你。',
      '🏅 这波表现已经很能打了，去现场看看有没有属于你的奖励吧。',
    ];

    return streak >= 6 ? _pickOne(strong) : _pickOne(gentle);
  }

  void _exitToMode({required bool clearSession}) {
    if (!mounted) {
      return;
    }
    if (clearSession) {
      _streak = 0;
      _playedIds = <String>{};
    }
    widget.onExit?.call();
    Navigator.of(context).pop();
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
      null => selected ? scheme.primary : scheme.outlineVariant,
    };

    final background = switch (result) {
      _OptionResult.correct => scheme.tertiaryContainer.withValues(alpha: 0.74),
      _OptionResult.wrong => scheme.errorContainer.withValues(alpha: 0.78),
      null => selected
          ? scheme.primaryContainer.withValues(alpha: 0.48)
          : scheme.surfaceContainerLowest,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(
                alpha: selected || result != null ? 0.11 : 0.028),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: accent.withValues(
                alpha: selected || result != null ? 0.44 : 0.28),
            width: selected || result != null ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: locked ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.11),
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
                        color: scheme.surface.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.34),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Text(
              '🔥 $streak 连胜',
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
        ? scheme.tertiaryContainer.withValues(alpha: 0.76)
        : scheme.errorContainer.withValues(alpha: 0.82);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
            size: 62,
            repeat: true,
          ),
          const SizedBox(width: 18),
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
