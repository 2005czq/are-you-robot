import 'package:flutter/material.dart';

import '../../app/widgets/app_page_route.dart';
import '../../app/widgets/emoji_pattern.dart';
import '../../app/widgets/emoji_text.dart';
import '../../app/widgets/fade_slide_in.dart';
import '../../models/challenge.dart';
import '../../repositories/challenge_repository.dart';
import '../mode/mode_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});

  final ChallengeRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<ChallengeStats> _statsFuture;

  static const _heroEmojis = ['🤖', '🧠', '🧐', '✨', '🫧', '💭'];

  @override
  void initState() {
    super.initState();
    _statsFuture = widget.repository.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final topColor = theme.brightness == Brightness.dark
        ? const Color(0xFF211813)
        : const Color(0xFFF7E7D8);
    final midColor = theme.brightness == Brightness.dark
        ? const Color(0xFF17120F)
        : const Color(0xFFFDF7F0);
    final bottomColor = theme.brightness == Brightness.dark
        ? const Color(0xFF110D0B)
        : const Color(0xFFF2E6D8);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [topColor, midColor, bottomColor],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: EmojiPattern(
                emojis: ['✨', '🫧', '🧠', '🤖', '💡'],
                size: 26,
                spacing: 26,
                opacity: 0.07,
                rotation: -0.15,
                padding: EdgeInsets.all(8),
              ),
            ),
            Positioned(
              top: -60,
              right: -30,
              child: _GlowOrb(
                size: 230,
                color: scheme.secondary.withValues(alpha: 0.22),
              ),
            ),
            Positioned(
              left: -30,
              bottom: 20,
              child: _GlowOrb(
                size: 180,
                color: scheme.primary.withValues(alpha: 0.18),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 920;
                      final cardColumns = constraints.maxWidth >= 860 ? 2 : 1;
                      final heroSize = constraints.maxWidth >= 1080
                          ? 82.0
                          : constraints.maxWidth >= 760
                              ? 66.0
                              : 54.0;
                      final titleSize = constraints.maxWidth >= 1080
                          ? 66.0
                          : constraints.maxWidth >= 760
                              ? 56.0
                              : 44.0;

                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          compact ? 22 : 30,
                          24,
                          28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeSlideIn(
                              duration: const Duration(milliseconds: 980),
                              child: compact
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _HeroBlock(
                                          titleSize: titleSize,
                                          heroSize: heroSize,
                                          heroEmojis: _heroEmojis,
                                        ),
                                        const SizedBox(height: 24),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: OutlinedButton.icon(
                                            onPressed: () =>
                                                _showIntroDialog(context),
                                            icon: const Icon(
                                                Icons.menu_book_rounded),
                                            label: const Text('了解图灵测试'),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _HeroBlock(
                                            titleSize: titleSize,
                                            heroSize: heroSize,
                                            heroEmojis: _heroEmojis,
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _showIntroDialog(context),
                                          icon: const Icon(
                                              Icons.menu_book_rounded),
                                          label: const Text('了解图灵测试'),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 28),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 120),
                              duration: const Duration(milliseconds: 980),
                              child: FutureBuilder<ChallengeStats>(
                                future: _statsFuture,
                                builder: (context, snapshot) {
                                  final stats = snapshot.data;
                                  return Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _FactChip(
                                        emoji: '📝',
                                        text:
                                            '${stats?.countFor(ChallengeMode.text) ?? '--'} 条文字题',
                                      ),
                                      _FactChip(
                                        emoji: '🖼️',
                                        text:
                                            '${stats?.countFor(ChallengeMode.image) ?? '--'} 条图片题',
                                      ),
                                      const _FactChip(
                                        emoji: '🎯',
                                        text: '每次都会随机出题',
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 26),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 220),
                              duration: const Duration(milliseconds: 1040),
                              child: GridView.count(
                                crossAxisCount: cardColumns,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio:
                                    cardColumns == 2 ? 1.12 : 0.96,
                                children: [
                                  _ModeCard(
                                    emoji: '✍️',
                                    pattern: const ['✍️', '📝', '💬', '🔎'],
                                    title: '文字挑战',
                                    subtitle: '看语气、停顿、细节和表达习惯，判断哪一段更像真人写出来的。',
                                    accent: scheme.primary,
                                    onTap: () =>
                                        _openMode(context, ChallengeMode.text),
                                  ),
                                  _ModeCard(
                                    emoji: '🖼️',
                                    pattern: const ['🖼️', '📸', '✨', '🫧'],
                                    title: '图片挑战',
                                    subtitle: '从光线、边缘、质感和构图里找线索，看看哪张更接近真实镜头。',
                                    accent: scheme.secondary,
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
        builder: (context) =>
            ModePage(mode: mode, repository: widget.repository),
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({
    required this.titleSize,
    required this.heroSize,
    required this.heroEmojis,
  });

  final double titleSize;
  final double heroSize;
  final List<String> heroEmojis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 4,
                children: [
                  for (var i = 0; i < heroEmojis.length; i++)
                    Transform.translate(
                      offset: Offset(i.isOdd ? 0 : 0, i.isOdd ? 2 : -1),
                      child: AnimatedEmoji(
                        heroEmojis[i],
                        size: 24,
                        motion: EmojiMotion.loop,
                        duration: Duration(milliseconds: 1600 + i * 130),
                        scaleBoost: 0.07,
                        lift: 4,
                        turns: 0.008,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Text(
                '一起找线索',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedEmoji(
              '🤖',
              size: heroSize,
              motion: EmojiMotion.hover,
              duration: const Duration(milliseconds: 1300),
              scaleBoost: 0.12,
              lift: 10,
              turns: 0.018,
              shadows: [
                Shadow(
                  color: scheme.primary.withValues(alpha: 0.18),
                  blurRadius: 24,
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                '你是人类还是机器人？',
                style:
                    theme.textTheme.displaySmall?.copyWith(fontSize: titleSize),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          '图灵测试小游戏',
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            '从文字和图片里找出更像真人创作的那一个。慢一点观察也没关系，答案揭晓后会立刻进入下一道随机题。',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatefulWidget {
  const _ModeCard({
    required this.emoji,
    required this.pattern,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final String emoji;
  final List<String> pattern;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        scale: _hovering ? 1.012 : 1,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.accent.withValues(alpha: 0.18),
                          scheme.surface.withValues(alpha: 0.94),
                          scheme.surface.withValues(alpha: 0.98),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: EmojiPattern(
                    emojis: widget.pattern,
                    size: 22,
                    spacing: 20,
                    opacity: 0.08,
                    rotation: widget.title == '文字挑战' ? -0.14 : 0.12,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: widget.accent.withValues(alpha: 0.26),
                              ),
                            ),
                            child: AnimatedEmoji(
                              widget.emoji,
                              size: 40,
                              motion: EmojiMotion.hover,
                              duration: const Duration(milliseconds: 1280),
                              scaleBoost: 0.12,
                              lift: 7,
                              turns: 0.016,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_outward_rounded,
                            color: widget.accent,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.title,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: 0.46),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            EmojiText(widget.emoji, size: 18),
                            const SizedBox(width: 8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmojiText(emoji, size: 18),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.06),
              Colors.transparent,
            ],
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
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Material(
            color: Colors.transparent,
            child: AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(26, 24, 26, 8),
              contentPadding: const EdgeInsets.fromLTRB(26, 6, 26, 0),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AnimatedEmoji(
                    '📘',
                    size: 34,
                    motion: EmojiMotion.loop,
                    duration: Duration(milliseconds: 1700),
                    scaleBoost: 0.08,
                    lift: 4,
                    turns: 0.01,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '了解图灵测试',
                      style:
                          theme.textTheme.headlineSmall?.copyWith(fontSize: 30),
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  child: Text(
                    '图灵测试最早来自阿兰·图灵提出的一个经典问题：如果机器的回答已经很像人，我们还能分辨出它是不是机器吗？\n\n'
                    '今天这个问题不只出现在文字里。AI 也会生成图片、声音和视频，所以我们的观察方式也要一起升级。\n\n'
                    '这个小游戏更像一场观察训练。看语气是不是太整齐、看细节是不是太滑顺、看光线和边缘是不是自然。能慢慢说出自己的判断理由，比只答对更重要。',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.72),
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
