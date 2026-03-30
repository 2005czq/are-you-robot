import 'package:flutter/material.dart';

import '../../app/widgets/fade_slide_in.dart';
import '../../models/challenge.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key, required this.challenge});

  final Challenge challenge;

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  String? _selectedOptionId;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final challenge = widget.challenge;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F9FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1220),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(challenge.title, style: theme.textTheme.headlineMedium),
                                const SizedBox(height: 4),
                                Text(
                                  '从两张卡片里选出你觉得更像真人创作的那一个。',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  Chip(
                                    avatar: Text(challenge.mode == ChallengeMode.text ? '✍️' : '🖼️'),
                                    label: Text(challenge.mode.label),
                                  ),
                                  Chip(label: Text(challenge.difficulty.toUpperCase())),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                challenge.prompt,
                                style: theme.textTheme.displaySmall?.copyWith(fontSize: 34),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '小提示：别急着选，可以先看语气、边缘、光线、纹理，或者哪里“太完美”了。 🔎',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final horizontal = constraints.maxWidth >= 920;
                          final optionWidgets = <Widget>[];
                          for (var i = 0; i < challenge.options.length; i++) {
                            final option = challenge.options[i];
                            optionWidgets.add(
                              Expanded(
                                child: FadeSlideIn(
                                  delay: Duration(milliseconds: 180 + i * 90),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: horizontal && i == 0 ? 10 : 0,
                                      left: horizontal && i == 1 ? 10 : 0,
                                      bottom: horizontal ? 0 : 12,
                                    ),
                                    child: _OptionCard(
                                      option: option,
                                      revealed: _revealed,
                                      selected: _selectedOptionId == option.id,
                                      onTap: () {
                                        setState(() {
                                          _selectedOptionId = option.id;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return horizontal
                              ? Row(children: optionWidgets)
                              : Column(children: optionWidgets);
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 280),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: _selectedOptionId == null
                                ? null
                                : () {
                                    setState(() {
                                      _revealed = true;
                                    });
                                  },
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: Text(_revealed ? '答案已揭晓' : '提交判断'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedOptionId = null;
                                _revealed = false;
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('重新看看'),
                          ),
                        ],
                      ),
                    ),
                    if (_revealed) ...[
                      const SizedBox(height: 18),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: _ResultPanel(
                          selectedOptionId: _selectedOptionId!,
                          challenge: challenge,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.revealed,
    required this.selected,
    required this.onTap,
  });

  final ChallengeOption option;
  final bool revealed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cardColor = selected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.62)
        : revealed && option.isHuman
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.9)
            : theme.colorScheme.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Card(
        color: cardColor,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: revealed ? null : onTap,
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          option.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (selected)
                      Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 18),
                if (option.asset != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(option.asset!, fit: BoxFit.cover),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  option.sourceType == 'human' ? '看起来像真人？' : '会不会是 AI？',
                                  style: theme.textTheme.labelLarge,
                                ),
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
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF9FBFF), Color(0xFFEFF5FF)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          option.text ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(height: 1.7),
                        ),
                      ),
                    ),
                  ),
                if (option.credit != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '素材说明：${option.credit!}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.selectedOptionId,
    required this.challenge,
  });

  final String selectedOptionId;
  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = challenge.options.firstWhere((option) => option.id == selectedOptionId);
    final isCorrect = selected.isHuman;

    return Card(
      color: isCorrect
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.96)
          : theme.colorScheme.errorContainer.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  isCorrect ? '🎉' : '🫶',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? '答对了，你抓到了关键线索。' : '这题真的有点像，能犹豫很正常。',
                    style: theme.textTheme.headlineSmall?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCorrect
                        ? '这次你的判断更接近“真人创作”。继续保持这种慢慢观察的节奏。'
                        : '别急着把答错当成失败，这其实正是学习观察力的时候。',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '揭晓解释：${challenge.explanation}',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
