import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app/app_theme.dart';
import 'features/home/home_page.dart';
import 'repositories/challenge_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AreYouRobotApp());
}

class AreYouRobotApp extends StatefulWidget {
  const AreYouRobotApp({super.key});

  @override
  State<AreYouRobotApp> createState() => _AreYouRobotAppState();
}

class _AreYouRobotAppState extends State<AreYouRobotApp> {
  late final ChallengeRepository _repository;
  late final Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _repository = ChallengeRepository();
    _initializeFuture = _repository.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'Are You Robot',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          home: snapshot.hasError
              ? _AppLoadError(error: snapshot.error)
              : snapshot.connectionState == ConnectionState.done
                  ? HomePage(repository: _repository)
                  : const _AppLoadingScreen(),
        );
      },
    );
  }
}

class _AppLoadingScreen extends StatefulWidget {
  const _AppLoadingScreen();

  @override
  State<_AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<_AppLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final phase = _controller.value;

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.surface,
                  scheme.surfaceContainerLow,
                  scheme.primaryContainer.withValues(alpha: 0.42),
                ],
              ),
            ),
            child: Stack(
              children: [
                _LoadingBackdropOrb(
                  alignment: Alignment.topLeft,
                  size: 320,
                  color: scheme.secondaryContainer.withValues(alpha: 0.42),
                  offset: Offset(-48 + phase * 36, -42 + phase * 18),
                ),
                _LoadingBackdropOrb(
                  alignment: Alignment.bottomRight,
                  size: 380,
                  color: scheme.tertiaryContainer.withValues(alpha: 0.3),
                  offset: Offset(64 - phase * 40, 70 - phase * 28),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLowest.withValues(
                              alpha: 0.9,
                            ),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: scheme.outlineVariant.withValues(
                                alpha: 0.72,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.shadow.withValues(alpha: 0.12),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(28, 28, 28, 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: scheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      '正在启动',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: scheme.onPrimaryContainer,
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  '正在准备首屏与题库资源',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '首次进入时会先完成本地题目数据加载与界面初始化，随后自动进入主页。',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 56,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: List.generate(
                                            5,
                                            (index) => _LoadingBar(
                                              index: index,
                                              progress: phase,
                                              color: index.isEven
                                                  ? scheme.primary
                                                  : scheme.secondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        child: LinearProgressIndicator(
                                          minHeight: 10,
                                          backgroundColor:
                                              scheme.surfaceContainerHighest,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            scheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        '加载中，请稍候片刻',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant,
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
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadingBackdropOrb extends StatelessWidget {
  const _LoadingBackdropOrb({
    required this.alignment,
    required this.size,
    required this.color,
    required this.offset,
  });

  final Alignment alignment;
  final double size;
  final Color color;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({
    required this.index,
    required this.progress,
    required this.color,
  });

  final int index;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final wave = (math.sin(progress * math.pi * 2 - index * 0.72) + 1) / 2;
    final eased = Curves.easeInOut.transform(wave);
    final height = 18 + (eased * 26);
    final opacity = 0.32 + (eased * 0.68);
    final yOffset = (1 - eased) * 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Transform.translate(
        offset: Offset(0, yOffset),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 13,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLoadError extends StatelessWidget {
  const _AppLoadError({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '题库加载失败',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
