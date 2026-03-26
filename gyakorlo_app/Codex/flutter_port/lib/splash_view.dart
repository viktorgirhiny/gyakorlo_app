import 'dart:async';

import 'package:flutter/material.dart';

import 'app_style.dart';
import 'main_menu_view.dart';
import 'quiz_models.dart';

class SplashView extends StatefulWidget {
  const SplashView({
    super.key,
    required this.themeController,
    required this.statsManager,
  });

  final ThemeController themeController;
  final StatsManager statsManager;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  Timer? _fadeTimer;
  Timer? _switchTimer;

  double _scale = 0.7;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _scale = 1;
        _opacity = 1;
      });
    });

    _fadeTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _opacity = 0;
        _scale = 1.1;
      });
      _switchTimer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (context, animation, secondaryAnimation) {
              return MainMenuView(
                themeController: widget.themeController,
                statsManager: widget.statsManager,
              );
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: child,
              );
            },
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _switchTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: palette.bg),
          ),
          Center(
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.accent.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotationTransition(
                      turns: _spinController,
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: palette.accent.withOpacity(0.15),
                                  width: 5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.5),
                              child: CustomPaint(
                                painter: _SplashArcPainter(
                                  gradient: palette.accentGradient,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _GradientText(
                      'QUIZ',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 12,
                        color: palette.primaryText,
                      ),
                      gradient: LinearGradient(
                        colors: [palette.primaryText, palette.accentSoft],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    _GradientText(
                      'MASTER',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                        color: palette.accent,
                      ),
                      gradient: palette.primaryGradient,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashArcPainter extends CustomPainter {
  const _SplashArcPainter({required this.gradient});

  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 5.0;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      -1.6,
      4.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashArcPainter oldDelegate) {
    return oldDelegate.gradient != gradient;
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(
    this.text, {
    required this.style,
    required this.gradient,
  });

  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
