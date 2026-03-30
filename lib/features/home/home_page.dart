import 'package:flutter/material.dart';

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
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 980;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFDCEBFF),
              theme.colorScheme.surface,
              const Color(0xFFEAF4FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -80,
              right: -40,
              child: _GlowOrb(size: 220),
            ),
            const Positioned(
              left: -70,
              bottom: 90,
              child: _GlowOrb(size: 180),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideIn(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: theme.colorScheme.outlineVariant),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🤖', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'are-you-robot',
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
                        const SizedBox(height: 24),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 11,
                                child: _HeroPanel(
                                  repository: repository,
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Expanded(
                                flex: 9,
                                child: _IntroPanel(),
                              ),
                            ],
                          )
                        else ...[
                          _HeroPanel(repository: repository),
                          const SizedBox(height: 18),
                          const _IntroPanel(),
                        ],
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 160),
                          child: Text(
                            '挑一个入口开始观察线索 ✨',
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: wide ? 3 : 1,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          childAspectRatio: wide ? 1.02 : 1.28,
                          children: [
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 240),
                              child: _ModeCard(
                                emoji: '✍️',
                                title: '文字挑战',
                                subtitle: '两段回答看起来都像人写的，但只有一段真的来自真人。',
                                footer: '试试找出更自然的小停顿和生活细节',
                                icon: Icons.chat_bubble_outline_rounded,
                                accent: theme.colorScheme.primary,
                                onTap: () => _openMode(context, ChallengeMode.text),
                              ),
                            ),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 340),
                              child: _ModeCard(
                                emoji: '🖼️',
                                title: '图片挑战',
                                subtitle: '看看真实照片和 AI 风格图片在光线、边缘和质感上的差别。',
                                footer: '先用占位图练手，后面会接真实题库',
                                icon: Icons.image_outlined,
                                accent: theme.colorScheme.tertiary,
                                onTap: () => _openMode(context, ChallengeMode.image),
                              ),
                            ),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 440),
                              child: _ModeCard(
                                emoji: '🎬',
                                title: '视频挑战',
                                subtitle: '下一阶段会加入真实短视频和 AI 视频，练习观察动作和时序。',
                                footer: '入口先留好，内容正在准备中',
                                icon: Icons.smart_display_outlined,
                                accent: theme.colorScheme.secondary,
                                enabled: false,
                                onTap: null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
      MaterialPageRoute<void>(
        builder: (context) => ModePage(mode: mode, repository: repository),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.repository});

  final ChallengeRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeSlideIn(
      delay: const Duration(milliseconds: 80),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F7AE0), Color(0xFF5AA8FF)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Blue Lab 01',
                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                '让孩子像小侦探一样\n观察 AI 的伪装 🕵️',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 46,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '这里不是要考倒孩子，而是让他们在轻松的挑战里，慢慢学会一件重要的事：看起来像真的，不一定就是真的。',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => ModePage(
                            mode: ChallengeMode.text,
                            repository: repository,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('开始闯关'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => ModePage(
                            mode: ChallengeMode.image,
                            repository: repository,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.image_search_rounded),
                    label: const Text('先看图片线索'),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FactChip(icon: Icons.lightbulb_outline_rounded, text: '即装即玩'),
                  _FactChip(icon: Icons.celebration_outlined, text: '答对有奖励'),
                  _FactChip(icon: Icons.menu_book_rounded, text: '每题都会解释'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeSlideIn(
      delay: const Duration(milliseconds: 180),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📘', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text('了解图灵测试', style: theme.textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '图灵测试是一个很有名的问题：如果一台机器回答问题的样子特别像人，我们还能认出来它是机器吗？这个想法最早来自英国数学家阿兰·图灵。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '今天，AI 不只是会回答文字问题，还会生成图片、声音和视频。所以现在的“图灵测试”也可以变成新的样子：哪一张图更像真实拍到的？哪一段话更像真人口吻？哪一段视频更符合真实世界的动作？',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              const _StoryPoint(
                emoji: '🧠',
                title: '它不是考试',
                text: '更像一次练习观察力的冒险，孩子会边玩边建立对 AI 内容的感觉。',
              ),
              const SizedBox(height: 12),
              const _StoryPoint(
                emoji: '🔎',
                title: '重点是找线索',
                text: '看语气、看细节、看光线、看边缘，学会问“为什么我会这样判断？”。',
              ),
              const SizedBox(height: 12),
              const _StoryPoint(
                emoji: '🌊',
                title: '为什么现在要学',
                text: '因为未来会遇到越来越多 AI 生成内容，早点学会辨别，孩子会更有底气。',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.footer,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.enabled = true,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String footer;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 62,
                    width: 62,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.24),
                          accent.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const Spacer(),
                  Icon(icon, color: enabled ? accent : theme.disabledColor),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: enabled ? theme.colorScheme.onSurface : theme.disabledColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  footer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    enabled ? '进入挑战' : '即将开放',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: enabled ? accent : theme.disabledColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: enabled ? accent : theme.disabledColor,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _StoryPoint extends StatelessWidget {
  const _StoryPoint({
    required this.emoji,
    required this.title,
    required this.text,
  });

  final String emoji;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
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
              const Color(0xFF74B4FF).withValues(alpha: 0.34),
              const Color(0xFF74B4FF).withValues(alpha: 0.06),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
