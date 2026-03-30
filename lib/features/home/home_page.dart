import 'package:flutter/material.dart';

import '../../app/widgets/app_page_route.dart';
import '../../app/widgets/fade_slide_in.dart';
import '../../models/challenge.dart';
import '../../repositories/challenge_repository.dart';
import '../mode/mode_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.repository});

  final ChallengeRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topColor = theme.brightness == Brightness.dark
        ? const Color(0xFF102033)
        : const Color(0xFFDCEBFF);
    final bottomColor = theme.brightness == Brightness.dark
        ? const Color(0xFF0E1724)
        : const Color(0xFFEAF4FF);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              topColor,
              theme.colorScheme.surface,
              bottomColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(top: -90, right: -30, child: _GlowOrb(size: 220)),
            const Positioned(left: -60, bottom: 10, child: _GlowOrb(size: 180)),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compactHeader = constraints.maxWidth < 760;
                      final compactHeight = constraints.maxHeight < 820;
                      final gridColumns = constraints.maxWidth >= 980 ? 3 : 2;
                      final cardAspectRatio = constraints.maxWidth >= 980
                          ? 1.52
                          : constraints.maxWidth >= 700
                              ? 1.18
                              : 0.96;
                      final titleSize = constraints.maxWidth >= 980 ? 58.0 : 44.0;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          compactHeight ? 20 : 24,
                          24,
                          compactHeight ? 16 : 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeSlideIn(
                              duration: const Duration(milliseconds: 1040),
                              child: compactHeader
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _HeaderBlock(titleSize: titleSize),
                                        const SizedBox(height: 18),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: [
                                            FilledButton.icon(
                                              onPressed: () => _openMode(context, ChallengeMode.text),
                                              icon: const Icon(Icons.auto_awesome_rounded),
                                              label: const Text('开始闯关'),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: () => _showIntroDialog(context),
                                              icon: const Icon(Icons.menu_book_rounded),
                                              label: const Text('了解图灵测试'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _HeaderBlock(titleSize: titleSize)),
                                        const SizedBox(width: 24),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: [
                                            FilledButton.icon(
                                              onPressed: () => _openMode(context, ChallengeMode.text),
                                              icon: const Icon(Icons.auto_awesome_rounded),
                                              label: const Text('开始闯关'),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: () => _showIntroDialog(context),
                                              icon: const Icon(Icons.menu_book_rounded),
                                              label: const Text('了解图灵测试'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                            SizedBox(height: compactHeight ? 14 : 18),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 140),
                              duration: const Duration(milliseconds: 980),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 760),
                                child: Text(
                                  '观察文字、图片和视频里的线索，判断哪一个更像真人创作。这里不是考试，而是一场带着好奇心的观察游戏。',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: compactHeight ? 16 : 22),
                            Expanded(
                              child: FadeSlideIn(
                                delay: const Duration(milliseconds: 220),
                                duration: const Duration(milliseconds: 1020),
                                child: GridView.count(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  crossAxisCount: gridColumns,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: cardAspectRatio,
                                  children: [
                                    _ModeCard(
                                      emoji: '✍️',
                                      title: '文字挑战',
                                      subtitle: '从题库里挑一个问题，进入后判断哪段话更像真人写的。',
                                      onTap: () => _openMode(context, ChallengeMode.text),
                                    ),
                                    _ModeCard(
                                      emoji: '🖼️',
                                      title: '图片挑战',
                                      subtitle: '先挑标题，再进入题目比较两张图片哪张更像真实镜头。',
                                      onTap: () => _openMode(context, ChallengeMode.image),
                                    ),
                                    const _ModeCard(
                                      emoji: '🎬',
                                      title: '视频挑战',
                                      subtitle: '视频版入口先预留，下一阶段会补上更多动态题目。',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: compactHeight ? 10 : 14),
                            const FadeSlideIn(
                              delay: Duration(milliseconds: 320),
                              duration: Duration(milliseconds: 1100),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _FactChip(text: '10 条文字题'),
                                  _FactChip(text: '10 条图片题'),
                                  _FactChip(text: '答题后立即揭晓'),
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

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({required this.titleSize});

  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ARE YOU ROBOT',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '给孩子玩的\n图灵测试小游戏',
          style: theme.textTheme.displaySmall?.copyWith(fontSize: titleSize),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.84,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 14),
                Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 28)),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
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
  const _FactChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: theme.textTheme.labelLarge),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size});

  final double size;

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
              const Color(0xFF74B4FF).withValues(alpha: 0.24),
              const Color(0xFF74B4FF).withValues(alpha: 0.05),
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

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '了解图灵测试',
    barrierColor: Colors.black.withValues(alpha: 0.22),
    transitionDuration: const Duration(milliseconds: 560),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Material(
            color: Colors.transparent,
            child: AlertDialog(
              title: Row(
                children: [
                  const Text('📘'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '了解图灵测试',
                      style: theme.textTheme.headlineSmall?.copyWith(fontSize: 30),
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  child: Text(
                    '图灵测试最早来自英国数学家阿兰·图灵提出的一个经典问题：如果一台机器回答问题的样子非常像人，我们还能分辨出它是不是机器吗？\n\n'
                    '今天这个问题已经不只存在于文字里。AI 还会生成图片、声音和视频，所以我们也会遇到新的挑战：哪一张图更像真实拍到的？哪一段话更像真人口吻？哪一个视频动作更自然？\n\n'
                    '这个小游戏不是要考倒孩子，而是想训练他们的观察力。答题时可以慢一点，看词语是不是太工整、看图片边缘是不是奇怪、看光线和细节是不是自然。能说出“我为什么这样判断”，比只选对答案更重要。',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('知道了'),
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
