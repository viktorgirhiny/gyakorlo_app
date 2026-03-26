import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatefulWidget {
  final String themeMode;
  final VoidCallback onMainMenu;
  const ResultScreen({super.key, required this.themeMode, required this.onMainMenu});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  bool _appear = false;
  double _ringProgress = 0;
  late AnimationController _ringController;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _ringAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _appear = true);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        final quiz = context.read<QuizProvider>();
        final pct = quiz.questions.isEmpty ? 0.0 : quiz.score / quiz.questions.length;
        _ringController.animateTo(pct);
      }
    });
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  ({String label, Color color, IconData icon}) _grade(double pct) {
    if (pct >= 0.8) return (label: 'Kiváló!', color: AppColors.green, icon: Icons.emoji_events);
    if (pct >= 0.6) return (label: 'Szép munka!', color: AppColors.blue, icon: Icons.star);
    if (pct >= 0.3) return (label: 'Jó kezdés!', color: AppColors.yellow, icon: Icons.local_fire_department);
    return (label: 'Tanulj még!', color: AppColors.red, icon: Icons.menu_book);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context, widget.themeMode);
    final bg = AppTheme.bg(isDark);
    final primaryText = AppTheme.primaryText(isDark);
    final secondaryText = AppTheme.secondaryText(isDark);
    final surfaceBg = AppTheme.surfaceBg(isDark);
    final surfaceBorder = AppTheme.surfaceBorder(isDark);
    final quiz = context.watch<QuizProvider>();
    final pct = quiz.questions.isEmpty ? 0.0 : quiz.score / quiz.questions.length;
    final grade = _grade(pct);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [grade.color.withOpacity(0.22), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 52),

                // Score ring
                AnimatedOpacity(
                  opacity: _appear ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedScale(
                    scale: _appear ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: AnimatedBuilder(
                        animation: _ringAnim,
                        builder: (_, __) => CustomPaint(
                          painter: _RingPainter(
                            progress: _ringAnim.value,
                            color: grade.color,
                            trackColor: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFF1C1C1E).withOpacity(0.15),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(grade.icon, color: grade.color, size: 30),
                                const SizedBox(height: 4),
                                Text(
                                  '${quiz.score}/${quiz.questions.length}',
                                  style: TextStyle(color: primaryText, fontSize: 28, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Grade label
                AnimatedOpacity(
                  opacity: _appear ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      Text(grade.label, style: TextStyle(color: grade.color, fontSize: 32, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('${(pct * 100).toInt()}% helyes', style: TextStyle(color: secondaryText, fontSize: 15)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, color: AppColors.purpleLight, size: 13),
                            const SizedBox(width: 6),
                            Text(
                              'Felhasznált idő ${quiz.finalTimerText}',
                              style: const TextStyle(color: AppColors.purpleLight, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
                const SizedBox(height: 20),

                // Answers list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VÁLASZAID',
                        style: TextStyle(color: secondaryText, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 12),
                      ...quiz.questions.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AnimatedOpacity(
                          opacity: _appear ? 1 : 0,
                          duration: Duration(milliseconds: 500 + e.key * 40),
                          child: _ResultRow(
                            index: e.key + 1,
                            question: e.value,
                            surfaceBg: surfaceBg,
                            surfaceBorder: surfaceBorder,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                        ),
                      )),
                      const SizedBox(height: 160),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky bottom buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              opacity: _appear ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bg.withOpacity(0), bg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Restart button
                    GestureDetector(
                      onTap: () => context.read<QuizProvider>().restart(),
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppTheme.purpleGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.replay, color: Colors.white, size: 18),
                            SizedBox(width: 10),
                            Text('Újrakezdés', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Main menu button
                    GestureDetector(
                      onTap: widget.onMainMenu,
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: surfaceBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: surfaceBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, color: secondaryText, size: 16),
                            const SizedBox(width: 10),
                            Text('Vissza a főmenübe', style: TextStyle(color: secondaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
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

// ── Ring Painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  const _RingPainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;

    // Track
    canvas.drawCircle(center, radius, Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14);

    // Arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..shader = LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Result Row ────────────────────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final int index;
  final question;
  final Color surfaceBg, surfaceBorder, primaryText, secondaryText;
  const _ResultRow({required this.index, required this.question, required this.surfaceBg, required this.surfaceBorder, required this.primaryText, required this.secondaryText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(color: surfaceBg, shape: BoxShape.circle),
                child: Center(
                  child: Text('$index', style: TextStyle(color: secondaryText, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(question.question, style: TextStyle(color: primaryText, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.green, size: 13),
                const SizedBox(width: 6),
                Text(question.correctAnswer, style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
