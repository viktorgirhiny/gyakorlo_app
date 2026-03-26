import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/quiz_provider.dart';
import 'screens/main_menu_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => QuizProvider(),
      child: const SzakmasztarApp(),
    ),
  );
}

class SzakmasztarApp extends StatefulWidget {
  const SzakmasztarApp({super.key});

  @override
  State<SzakmasztarApp> createState() => _SzakmasztarAppState();
}

class _SzakmasztarAppState extends State<SzakmasztarApp> {
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _themeMode = p.getString('themeMode') ?? 'system');
  }

  ThemeMode get _flutterThemeMode {
    switch (_themeMode) {
      case 'dark':  return ThemeMode.dark;
      case 'light': return ThemeMode.light;
      default:      return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Master',
      debugShowCheckedModeBanner: false,
      themeMode: _flutterThemeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple, brightness: Brightness.light),
        fontFamily: 'SF Pro Rounded',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: SplashScreen(onThemeChanged: (mode) {
        setState(() => _themeMode = mode);
      }),
    );
  }
}

// ── Splash Screen ────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  final void Function(String) onThemeChanged;
  const SplashScreen({super.key, required this.onThemeChanged});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  bool _isActive = false;
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _scaleAnim = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..forward(), curve: Curves.elasticOut),
    );

    _opacityAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward(),
        curve: Curves.easeIn,
      ),
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _isActive = true);
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MainMenuScreen(
              onThemeChanged: widget.onThemeChanged,
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  Future<void> _loadTheme() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _themeMode = p.getString('themeMode') ?? 'system');
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' && brightness == Brightness.dark);
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.purple.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spinner
                SizedBox(
                  width: 80,
                  height: 80,
                  child: AnimatedBuilder(
                    animation: _spinController,
                    builder: (_, __) => Stack(
                      alignment: Alignment.center,
                      children: [
                        // Track
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.purple.withOpacity(0.15),
                              width: 5,
                            ),
                          ),
                        ),
                        // Arc
                        Transform.rotate(
                          angle: _spinController.value * 2 * 3.14159,
                          child: CustomPaint(
                            size: const Size(80, 80),
                            painter: _ArcPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // QUIZ text
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, AppColors.purpleSoft],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'QUIZ',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 12,
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.purple, AppColors.purpleLight],
                  ).createShader(bounds),
                  child: const Text(
                    'MASTER',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.purpleLight, AppColors.purple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -1.57,
      4.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
