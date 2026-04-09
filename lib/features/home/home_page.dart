import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/widgets/app_page_route.dart';
import '../../app/widgets/emoji_pattern.dart';
import '../../app/widgets/fade_slide_in.dart';
import '../../app/widgets/noto_animated_emoji.dart';
import '../../models/challenge.dart';
import '../../repositories/challenge_repository.dart';
import '../mode/mode_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.repository});

  final ChallengeRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final topColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1C1611)
        : const Color(0xFFF4E7D8);
    final bottomColor = theme.brightness == Brightness.dark
        ? const Color(0xFF100C09)
        : const Color(0xFFFBF5ED);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [topColor, bottomColor],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: const Alignment(0.82, -0.2),
                  child: Transform.rotate(
                    angle: 0.34,
                    child: Opacity(
                      opacity: theme.brightness == Brightness.dark ? 0.12 : 0.1,
                      child: const SizedBox(
                        width: 520,
                        height: 520,
                        child: NotoAnimatedEmoji(
                          asset: 'assets/animations/noto/thinking_face.json',
                          size: 520,
                          repeat: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 920;
                      final titleSize = constraints.maxWidth >= 1050
                          ? 72.0
                          : constraints.maxWidth >= 760
                              ? 60.0
                              : 46.0;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeSlideIn(
                              child: compact
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _HeroBlock(titleSize: titleSize),
                                        const SizedBox(height: 28),
                                        FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: scheme.primary,
                                            foregroundColor: scheme.onPrimary,
                                          ),
                                          onPressed: () =>
                                              _showIntroDialog(context),
                                          icon: const Icon(
                                              Icons.menu_book_rounded),
                                          label: const Text('了解图灵测试'),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child:
                                              _HeroBlock(titleSize: titleSize),
                                        ),
                                        const SizedBox(width: 20),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: FilledButton.icon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: scheme.primary,
                                              foregroundColor: scheme.onPrimary,
                                            ),
                                            onPressed: () =>
                                                _showIntroDialog(context),
                                            icon: const Icon(
                                                Icons.menu_book_rounded),
                                            label: const Text('了解图灵测试'),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 40),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 120),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: compact ? 1 : 2,
                                crossAxisSpacing: 22,
                                mainAxisSpacing: 22,
                                childAspectRatio: compact ? 1.08 : 1.18,
                                children: [
                                  _ModeCard(
                                    title: '文字挑战',
                                    subtitle: '看语气、停顿和细节，判断哪一段更像真人写出来的。',
                                    accent: scheme.primary,
                                    emojiChoices: const [
                                      '✍️',
                                      '📖',
                                      '📝',
                                      '💬',
                                      '🔤',
                                      '📚',
                                      '🖋️',
                                      '📓',
                                    ],
                                    heroAsset:
                                        'assets/animations/noto/writing_hand.json',
                                    onTap: () =>
                                        _openMode(context, ChallengeMode.text),
                                  ),
                                  _ModeCard(
                                    title: '图片挑战',
                                    subtitle: '看光线、边缘和质感，判断哪一张更接近真实镜头。',
                                    accent: scheme.secondary,
                                    emojiChoices: const [
                                      '📸',
                                      '🖼️',
                                      '🌤️',
                                      '🔍',
                                      '🎞️',
                                      '🌈',
                                      '🧿',
                                      '🪄',
                                    ],
                                    heroAsset:
                                        'assets/animations/noto/camera.json',
                                    onTap: () =>
                                        _openMode(context, ChallengeMode.image),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }

  void _openMode(BuildContext context, ChallengeMode mode) {
    Navigator.of(context).push(
      AppPageRoute<void>(
        builder: (context) => ModePage(mode: mode, repository: repository),
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.titleSize});

  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '你是人类还是机器人？',
          style: theme.textTheme.displaySmall?.copyWith(fontSize: titleSize),
        ),
        const SizedBox(height: 12),
        Text(
          '图灵测试小游戏',
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            '从文字和图片里找出更像真人创作的那一个。放慢一点观察细节，很多线索都藏在看似普通的地方。',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.75,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatefulWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.emojiChoices,
    required this.heroAsset,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<String> emojiChoices;
  final String heroAsset;
  final VoidCallback onTap;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  late final List<String> _pattern;
  var _hovering = false;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _pattern = List.generate(48, (index) {
      return widget.emojiChoices[random.nextInt(widget.emojiChoices.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.54),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -36,
                  bottom: -46,
                  child: IgnorePointer(
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.accent.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: EmojiPattern(
                    emojis: _pattern,
                    size: 44,
                    spacing: 28,
                    opacity: 0.032,
                    rotation: widget.title == '文字挑战' ? -0.08 : 0.08,
                    padding: const EdgeInsets.all(18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          width: 118,
                          height: 118,
                          child: NotoAnimatedEmoji(
                            asset: widget.heroAsset,
                            size: 118,
                            repeat: _hovering,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.title,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontSize: 34),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        '进入挑战',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: widget.accent,
                        ),
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

Future<void> _showIntroDialog(BuildContext context) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '了解图灵测试',
    barrierColor: Colors.black.withValues(alpha: 0.24),
    transitionDuration: const Duration(milliseconds: 240),
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
                    width: 44,
                    height: 44,
                    child: NotoAnimatedEmoji(
                      asset: 'assets/animations/noto/robot.json',
                      size: 44,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '了解图灵测试',
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
                  child: Text(
                    '🤖 图灵测试最早来自阿兰·图灵提出的一个经典问题：如果机器的回答已经很像人，我们还能不能分辨出它是不是机器？\n\n'
                    '🧠 今天这个问题不只出现在文字里。AI 也会生成图片和声音，所以我们的观察方式也得一起升级。\n\n'
                    '🔍 这个小游戏更像一场观察训练。看看语气是不是太整齐，看看细节是不是太滑顺，看看光线和边缘是不是自然。慢一点没关系，能说出理由比只选对更重要。',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.82),
                  ),
                ),
              ),
              actions: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('继续看看'),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
