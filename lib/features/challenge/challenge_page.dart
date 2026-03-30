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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final challenge = widget.challenge;
    final topColor = theme.brightness == Brightness.dark
        ? const Color(0xFF0D1B2A)
        : const Color(0xFFF4F9FF);
    final bottomColor = theme.brightness == Brightness.dark
        ? const Color(0xFF101927)
        : const Color(0xFFFFFFFF);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              challenge.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 34),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              challenge.prompt,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '选出你觉得更像真人创作的那一个。',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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
                                  delay: Duration(milliseconds: 160 + i * 90),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: horizontal && i == 0 ? 10 : 0,
                                      left: horizontal && i == 1 ? 10 : 0,
                                      bottom: horizontal ? 0 : 12,
                                    ),
                                    child: _OptionCard(
                                      option: option,
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
                      delay: const Duration(milliseconds: 260),
                      child: FilledButton.icon(
                        onPressed: _selectedOptionId == null
                            ? null
                            : () => _showResultDialog(context, challenge),
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('提交判断'),
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

  Future<void> _showResultDialog(BuildContext context, Challenge challenge) {
    final theme = Theme.of(context);
    final selected = challenge.options.firstWhere((option) => option.id == _selectedOptionId);
    final isCorrect = selected.isHuman;

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: isCorrect ? '答对了' : '答错了',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 580),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Material(
              color: Colors.transparent,
              child: AlertDialog(
                backgroundColor: isCorrect
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.98)
                    : theme.colorScheme.errorContainer.withValues(alpha: 0.96),
                title: Row(
                  children: [
                    Text(isCorrect ? '🎉' : '🫶', style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isCorrect ? '答对了' : '这题真的有点像',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    isCorrect
                        ? '你这次判断得很稳，抓到了更接近真人创作的那个选项。\n\n揭晓解释：${challenge.explanation}'
                        : '答错也没关系，这题本来就比较像。真正重要的是慢慢建立自己的判断理由。\n\n揭晓解释：${challenge.explanation}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                actions: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _selectedOptionId = null;
                      });
                    },
                    child: const Text('再试一次'),
                  ),
                  FilledButton(
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
            scale: Tween<double>(begin: 0.93, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ChallengeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: Card(
        color: selected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.68)
            : theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
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
                const SizedBox(height: 16),
                if (option.asset != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(option.asset!, fit: BoxFit.cover, width: double.infinity),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: theme.brightness == Brightness.dark
                              ? [
                                  theme.colorScheme.surfaceContainerHigh,
                                  theme.colorScheme.surfaceContainerHighest,
                                ]
                              : const [Color(0xFFF9FBFF), Color(0xFFEFF5FF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          option.text ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(height: 1.8),
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
