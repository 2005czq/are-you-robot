import 'dart:async';
import 'dart:math' as math;

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
  static const _questionTimeLimit = Duration(minutes: 2);

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

  static const _timeoutResults = [
    _ResultPreset(
      title: '时间到，这题先封盘',
      descriptionPrefix: '你已经盯得够久了，这题按超时处理。',
      asset: 'assets/animations/noto/dizzy.json',
    ),
    _ResultPreset(
      title: '两分钟用完了',
      descriptionPrefix: '这题确实很会拖住人，超时也算它有点本事。',
      asset: 'assets/animations/noto/open_mouth_face.json',
    ),
    _ResultPreset(
      title: '这一题先被时间拿下了',
      descriptionPrefix: '你已经观察到后半程了，只是计时先一步结束。',
      asset: 'assets/animations/noto/thinking_face.json',
    ),
    _ResultPreset(
      title: '倒计时归零了',
      descriptionPrefix: '这题的迷惑性不低，拖到最后一秒也很常见。',
      asset: 'assets/animations/noto/woozy_face.json',
    ),
    _ResultPreset(
      title: '这题先超时了',
      descriptionPrefix: '先把这次感觉记住，时间到也算一种线索。',
      asset: 'assets/animations/noto/pleading_face.json',
    ),
  ];

  final math.Random _random = math.Random();
  late final AnimationController _streakController;
  Timer? _countdownTimer;

  String? _selectedOptionId;
  _ResultPresentation? _result;
  CelebrationVariant _celebrationVariant = CelebrationVariant.confetti;
  Color? _celebrationColor;
  bool _loadingNext = false;
  late int _streak;
  late Set<String> _playedIds;
  late DateTime _deadline;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _streak = widget.session.streak;
    _playedIds = {...widget.session.playedIds, widget.challenge.id};
    _deadline = DateTime.now().add(_questionTimeLimit);
    _remainingSeconds = _questionTimeLimit.inSeconds;
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 860),
    );
    _startCountdown();
  }

  @override
  void dispose() {
    _stopCountdown();
    _streakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final challenge = widget.challenge;
    final accent = challenge.mode == ChallengeMode.image
        ? scheme.secondary
        : scheme.primary;
    final onAccent = challenge.mode == ChallengeMode.image
        ? scheme.onSecondary
        : scheme.onPrimary;
    final topColor = theme.brightness == Brightness.dark
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.08),
            scheme.surfaceContainerLowest,
          )
        : Color.alphaBlend(
            accent.withValues(alpha: 0.055),
            scheme.surfaceContainerLow,
          );
    final bottomColor =
        Color.alphaBlend(accent.withValues(alpha: 0.018), scheme.surface);

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
                          const SizedBox(height: 12),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final horizontal = constraints.maxWidth >= 920;
                                final optionPanelHeight = horizontal
                                    ? (constraints.maxHeight * 0.54)
                                        .clamp(320.0, 520.0)
                                    : (constraints.maxHeight * 0.74)
                                        .clamp(560.0, 900.0);

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
                                          milliseconds: 60 + i * 50,
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
                                            accent: accent,
                                            onTap: () =>
                                                _selectOption(option.id),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final content = Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FadeSlideIn(
                                      delay: const Duration(milliseconds: 50),
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 820),
                                          child: Column(
                                            children: [
                                              Text(
                                                challenge.title,
                                                textAlign: TextAlign.center,
                                                style: theme
                                                    .textTheme.headlineLarge
                                                    ?.copyWith(fontSize: 38),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                challenge.prompt,
                                                textAlign: TextAlign.center,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                  height: 1.55,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 26),
                                    FadeSlideIn(
                                      delay: const Duration(milliseconds: 100),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 220),
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
                                    if (_result != null)
                                      const SizedBox(height: 18),
                                    SizedBox(
                                      height: optionPanelHeight,
                                      child: horizontal
                                          ? Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: optionWidgets,
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: optionWidgets,
                                            ),
                                    ),
                                    const SizedBox(height: 18),
                                    FadeSlideIn(
                                      delay: const Duration(milliseconds: 130),
                                      child: LayoutBuilder(
                                        builder: (context, actionConstraints) {
                                          final compactActions =
                                              actionConstraints.maxWidth < 860;
                                          final badges = <Widget>[
                                            if (_result == null)
                                              _CountdownBadge(
                                                remainingSeconds:
                                                    _remainingSeconds,
                                                accent: accent,
                                              ),
                                            if (_streak > 0)
                                              _StreakBadge(
                                                streak: _streak,
                                                controller: _streakController,
                                                accent: accent,
                                              ),
                                          ];

                                          final actionButton =
                                              FilledButton.icon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: _result == null
                                                  ? accent
                                                  : _result!.isCorrect
                                                      ? scheme.tertiary
                                                      : scheme.error,
                                              foregroundColor: _result == null
                                                  ? onAccent
                                                  : _result!.isCorrect
                                                      ? scheme.onTertiary
                                                      : scheme.onError,
                                            ),
                                            onPressed: _loadingNext
                                                ? null
                                                : _result == null
                                                    ? _selectedOptionId == null
                                                        ? null
                                                        : _submitSelection
                                                    : _confirmResult,
                                            icon: _loadingNext
                                                ? const SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.2,
                                                    ),
                                                  )
                                                : Icon(
                                                    _result == null
                                                        ? Icons.check_rounded
                                                        : Icons
                                                            .arrow_forward_rounded,
                                                  ),
                                            label: Text(
                                              _loadingNext
                                                  ? '准备中...'
                                                  : _result == null
                                                      ? '确定'
                                                      : '继续',
                                            ),
                                          );

                                          final helperText = Text(
                                            _result == null
                                                ? '先选中一个你觉得更像真人创作的选项，再点确定。'
                                                : _result!.isCorrect
                                                    ? '看完这道题的反馈后，点继续进入下一题。'
                                                    : '这题会结束本轮，点继续查看结算。',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          );

                                          if (compactActions) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                actionButton,
                                                const SizedBox(height: 12),
                                                helperText,
                                                if (badges.isNotEmpty) ...[
                                                  const SizedBox(height: 14),
                                                  Wrap(
                                                    spacing: 12,
                                                    runSpacing: 12,
                                                    children: badges,
                                                  ),
                                                ],
                                              ],
                                            );
                                          }

                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              actionButton,
                                              const SizedBox(width: 18),
                                              Expanded(child: helperText),
                                              if (badges.isNotEmpty)
                                                const SizedBox(width: 16),
                                              for (var i = 0;
                                                  i < badges.length;
                                                  i++) ...[
                                                if (i > 0)
                                                  const SizedBox(width: 12),
                                                badges[i],
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );

                                return SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: Center(child: content),
                                  ),
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
  }

  void _submitSelection() {
    final selectedId = _selectedOptionId;
    if (selectedId == null || _result != null) {
      return;
    }

    _revealSelection();
  }

  void _revealSelection() {
    final selectedId = _selectedOptionId;
    if (selectedId == null || _result != null) {
      return;
    }

    _stopCountdown();

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

  void _startCountdown() {
    _stopCountdown();
    _tickCountdown();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickCountdown(),
    );
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _tickCountdown() {
    if (!mounted || _result != null) {
      _stopCountdown();
      return;
    }

    final remainingMs = _deadline.difference(DateTime.now()).inMilliseconds;
    final nextRemaining = remainingMs <= 0
        ? 0
        : (remainingMs / Duration.millisecondsPerSecond).ceil();

    if (nextRemaining != _remainingSeconds) {
      setState(() {
        _remainingSeconds = nextRemaining;
      });
    }

    if (nextRemaining == 0) {
      _stopCountdown();
      _handleTimeout();
    }
  }

  void _handleTimeout() {
    if (_result != null) {
      return;
    }

    final preset = _pickOne(_timeoutResults);
    setState(() {
      _selectedOptionId = null;
      _result = _ResultPresentation(
        isCorrect: false,
        title: preset.title,
        asset: preset.asset,
        description:
            '${preset.descriptionPrefix}${widget.challenge.explanation}',
      );
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
    _stopCountdown();

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
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 140),
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
                begin: const Offset(0.014, 0),
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
    final streakHint = _buildStreakSummary(streak);
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
            constraints: const BoxConstraints(maxWidth: 720),
            child: Material(
              color: Colors.transparent,
              child: AlertDialog(
                titlePadding: const EdgeInsets.fromLTRB(30, 28, 30, 12),
                contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                actionsPadding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 46,
                      height: 46,
                      child: NotoAnimatedEmoji(
                        asset: 'assets/animations/noto/dizzy.json',
                        size: 46,
                        repeat: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '这轮先停一下',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$streakHint\n$message\n$rewardHint',
                          style:
                              theme.textTheme.bodyLarge?.copyWith(height: 1.82),
                        ),
                      ],
                    ),
                  ),
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
    final streakHint =
        streak > 0 ? '🏁 本轮最好成绩：$streak 连胜' : '📚 这一轮能出的题都被你刷完了。';
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
            constraints: const BoxConstraints(maxWidth: 720),
            child: Material(
              color: Colors.transparent,
              child: AlertDialog(
                titlePadding: const EdgeInsets.fromLTRB(30, 28, 30, 12),
                contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                actionsPadding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 46,
                      height: 46,
                      child: NotoAnimatedEmoji(
                        asset: 'assets/animations/noto/trophy.json',
                        size: 46,
                        repeat: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '这一轮被你刷空了',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$streakHint\n$message\n✨ 回去缓一口气，换一轮题再来继续打也很酷。',
                          style:
                              theme.textTheme.bodyLarge?.copyWith(height: 1.82),
                        ),
                      ],
                    ),
                  ),
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
      '🎈 带着这轮的感觉去找工作人员聊聊，也许会有小惊喜。',
    ];
    final strong = [
      '🎁 带着这个成绩去找工作人员看看，有一份小惊喜等着你。',
      '🏅 这波表现已经很能打了，去找工作人员领取属于你的奖励吧。',
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
    required this.accent,
    required this.onTap,
  });

  final ChallengeOption option;
  final bool selected;
  final _OptionResult? result;
  final bool locked;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activeAccent = switch (result) {
      _OptionResult.correct => scheme.tertiary,
      _OptionResult.wrong => scheme.error,
      null => selected ? accent : scheme.outlineVariant,
    };

    final background = switch (result) {
      _OptionResult.correct => scheme.tertiaryContainer.withValues(alpha: 0.74),
      _OptionResult.wrong => scheme.errorContainer.withValues(alpha: 0.78),
      null => selected
          ? Color.alphaBlend(
              accent.withValues(alpha: 0.14),
              scheme.surfaceContainerLowest,
            )
          : scheme.surfaceContainerLowest,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: activeAccent.withValues(
              alpha: selected || result != null ? 0.11 : 0.028,
            ),
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
            color: activeAccent.withValues(
              alpha: selected || result != null ? 0.44 : 0.28,
            ),
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
                        color: activeAccent.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          option.label,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: activeAccent),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (selected && result == null)
                      Icon(Icons.radio_button_checked_rounded,
                          color: activeAccent)
                    else if (result == _OptionResult.correct)
                      Icon(Icons.check_circle_rounded, color: activeAccent)
                    else if (result == _OptionResult.wrong)
                      Icon(Icons.cancel_rounded, color: activeAccent),
                  ],
                ),
                const SizedBox(height: 16),
                if (option.asset != null)
                  Expanded(
                    child: RepaintBoundary(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              option.asset!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              cacheWidth: 1800,
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
                    ),
                  )
                else
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = constraints.maxWidth;
                        final isCompact = cardWidth < 280;
                        final contentPadding = EdgeInsets.symmetric(
                          horizontal: isCompact ? 2 : 6,
                          vertical: isCompact ? 2 : 6,
                        );
                        final textStyle = theme.textTheme.titleMedium?.copyWith(
                          fontSize: isCompact ? 18 : 20,
                          height: isCompact ? 1.78 : 1.72,
                        );

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: contentPadding,
                          child: Text(
                            option.text ?? '',
                            style: textStyle,
                          ),
                        );
                      },
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
    required this.accent,
  });

  final int streak;
  final AnimationController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pulse = 1 + math.sin(controller.value * math.pi * 2) * 0.06;
        return Transform.scale(
          scale: pulse,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const NotoAnimatedEmoji(
                  asset: 'assets/animations/noto/fire.json',
                  size: 28,
                  repeat: true,
                ),
                const SizedBox(width: 8),
                Text(
                  '$streak 连胜',
                  style: theme.textTheme.labelLarge?.copyWith(color: accent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({
    required this.remainingSeconds,
    required this.accent,
  });

  final int remainingSeconds;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activeColor = remainingSeconds <= 20
        ? scheme.error
        : remainingSeconds <= 45
            ? scheme.secondary
            : accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: activeColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: activeColor, size: 22),
          const SizedBox(width: 8),
          Text(
            _formatRemainingTime(remainingSeconds),
            style: theme.textTheme.labelLarge?.copyWith(color: activeColor),
          ),
        ],
      ),
    );
  }

  String _formatRemainingTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
