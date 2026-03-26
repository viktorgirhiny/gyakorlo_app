import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_style.dart';
import 'quiz_models.dart';
import 'splash_view.dart';

class Szakmasztar2App extends StatefulWidget {
  const Szakmasztar2App({
    super.key,
    required this.preferences,
  });

  final SharedPreferences preferences;

  @override
  State<Szakmasztar2App> createState() => _Szakmasztar2AppState();
}

class _Szakmasztar2AppState extends State<Szakmasztar2App> {
  late final ThemeController _themeController;
  late final StatsManager _statsManager;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController(widget.preferences);
    _statsManager = StatsManager(widget.preferences);
  }

  @override
  void dispose() {
    _themeController.dispose();
    _statsManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quiz Master',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: _themeController.themeMode,
          home: SplashView(
            themeController: _themeController,
            statsManager: _statsManager,
          ),
        );
      },
    );
  }
}
