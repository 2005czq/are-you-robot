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

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
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
