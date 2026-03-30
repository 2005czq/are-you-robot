import 'package:flutter/material.dart';

import '../../models/challenge.dart';
import '../../repositories/challenge_repository.dart';
import '../mode/mode_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.repository});

  final ChallengeRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.92),
              theme.colorScheme.surface,
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.72),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'are-you-robot',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '给孩子玩的\n图灵测试小游戏',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Text(
                        '观察文字、图片和视频里的线索，判断哪一个更像真人创作。答对会有夸张一点的庆祝，答错也会给提示，让孩子在玩里慢慢学会辨别 AI 内容。',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
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
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('先玩文字挑战'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('什么是图灵测试？'),
                                content: const Text(
                                  '它是一个经典问题：如果机器的回答看起来很像人写的，我们还能分辨出来吗？在这个小游戏里，我们把这个问题换成孩子更容易上手的文字和图片挑战。',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('知道了'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.school_outlined),
                          label: const Text('了解图灵测试'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: MediaQuery.sizeOf(context).width >= 900 ? 3 : 1,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: MediaQuery.sizeOf(context).width >= 900 ? 1.08 : 1.45,
                        children: [
                          _ModeCard(
                            title: '文字',
                            subtitle: '看两段回答，猜哪一个更像真人说的话。',
                            icon: Icons.chat_bubble_outline_rounded,
                            accent: theme.colorScheme.primary,
                            onTap: () => _openMode(context, ChallengeMode.text),
                          ),
                          _ModeCard(
                            title: '图片',
                            subtitle: '比较真实照片和 AI 风格图片里的细节。',
                            icon: Icons.image_outlined,
                            accent: theme.colorScheme.tertiary,
                            onTap: () => _openMode(context, ChallengeMode.image),
                          ),
                          _ModeCard(
                            title: '视频',
                            subtitle: '先预留入口，后面会加入真实短视频和生成视频对比。',
                            icon: Icons.smart_display_outlined,
                            accent: theme.colorScheme.secondary,
                            enabled: false,
                            onTap: null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
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
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: enabled ? 0.14 : 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: enabled ? accent : theme.disabledColor),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: enabled ? null : theme.disabledColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    enabled ? '进入挑战' : '即将开放',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: enabled ? accent : theme.disabledColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
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
