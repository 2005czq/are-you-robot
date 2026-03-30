import 'package:flutter/material.dart';

import 'app/app_theme.dart';
import 'features/home/home_page.dart';
import 'repositories/challenge_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AreYouRobotApp());
}

class AreYouRobotApp extends StatelessWidget {
  const AreYouRobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ChallengeRepository();

    return MaterialApp(
      title: 'Are You Robot',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      home: HomePage(repository: repository),
    );
  }
}
