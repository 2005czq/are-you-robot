import 'package:flutter/material.dart';

class PageHeaderBar extends StatelessWidget {
  const PageHeaderBar({
    super.key,
    required this.title,
    this.trailing = const <Widget>[],
    this.onBack,
  });

  final String title;
  final List<Widget> trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.outlined(
          onPressed: onBack ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.headlineMedium,
          ),
        ),
        if (trailing.isNotEmpty) ...[
          const SizedBox(width: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: trailing,
          ),
        ],
      ],
    );
  }
}
