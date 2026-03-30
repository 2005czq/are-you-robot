import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text(challenge.title),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Chip(label: Text(challenge.mode.label)),
                      Chip(label: Text(challenge.difficulty.toUpperCase())),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    challenge.prompt,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '选出你觉得更像真人创作的那一个。',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final horizontal = constraints.maxWidth >= 860;
                        final firstOptionId = challenge.options.isNotEmpty
                            ? challenge.options.first.id
                            : null;
                        final children = challenge.options
                            .map(
                              (option) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: horizontal && option.id == firstOptionId ? 10 : 0,
                                    left: horizontal && option.id != firstOptionId ? 10 : 0,
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
                            )
                            .toList();

                        if (horizontal) {
                          return Row(children: children);
                        }

                        return Column(children: children);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
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
                        icon: const Icon(Icons.psychology_alt_outlined),
                        label: Text(_revealed ? '已揭晓' : '提交判断'),
                      ),
                      if (_revealed)
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedOptionId = null;
                              _revealed = false;
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('再试一次'),
                        ),
                    ],
                  ),
                  if (_revealed) ...[
                    const SizedBox(height: 20),
                    _ResultPanel(
                      selectedOptionId: _selectedOptionId!,
                      challenge: challenge,
                    ),
                  ],
                ],
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
    final correctColor = theme.colorScheme.primaryContainer;
    final selectedColor = theme.colorScheme.primary.withValues(alpha: 0.08);

    return Card(
      color: selected
          ? selectedColor
          : revealed && option.isHuman
              ? correctColor
              : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: revealed ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    child: Text(option.label),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (option.asset != null)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      option.asset!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      option.text ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(height: 1.55),
                    ),
                  ),
                ),
              if (option.credit != null) ...[
                const SizedBox(height: 12),
                Text(
                  option.credit!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
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
    final selected = challenge.options.firstWhere(
      (option) => option.id == selectedOptionId,
    );
    final isCorrect = selected.isHuman;

    return Card(
      color: isCorrect
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.95)
          : theme.colorScheme.errorContainer.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect ? Icons.celebration_outlined : Icons.search,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? '答对了，侦探观察力很不错。' : '这题 AI 伪装得很像，再观察一下也很正常。',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '正确答案是“更像真人创作”的那个选项。${challenge.explanation}',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
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
