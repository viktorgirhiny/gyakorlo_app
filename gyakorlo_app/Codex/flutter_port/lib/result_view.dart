import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_style.dart';
import 'quiz_models.dart';

class ResultView extends StatefulWidget {
  const ResultView({
    super.key,
    required this.viewModel,
    required this.onMainMenu,
  });

  final QuizViewModel viewModel;
  final VoidCallback onMainMenu;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final ScrollController _scrollController = ScrollController();

  bool _appear = false;
  double _ringProgress = 0;
  double _scrollOffset = 0;

  double get _percentage {
    if (widget.viewModel.questions.isEmpty) {
      return 0;
    }
    return widget.viewModel.score / widget.viewModel.questions.length;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!mounted) {
        return;
      }
      setState(() => _scrollOffset = _scrollController.offset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _appear = true);
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _ringProgress = _percentage);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final palette = AppPalette.of(context);
        final grade = _grade(palette);
        final headerFade = (_scrollOffset / 160).clamp(0.0, 1.0).toDouble();
        final headerSlide = (headerFade * 60).clamp(0.0, 60.0).toDouble();

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: palette.bg),
              ),
              Positioned(
                left: -20,
                right: -20,
                top: -120 + headerSlide,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 380,
                      height: 380,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            grade.color.withOpacity(0.22 * (1 - headerFade)),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 160),
                      child: Column(
                        children: [
                          const SizedBox(height: 52),
                          Opacity(
                            opacity: 1 - headerFade,
                            child: Transform.translate(
                              offset: Offset(0, -headerSlide),
                              child: Column(
                                children: [
                                  DelayedReveal(
                                    visible: _appear,
                                    delay: const Duration(milliseconds: 100),
                                    beginScale: 0.6,
                                    child: _ScoreRing(
                                      score: widget.viewModel.score,
                                      total: widget.viewModel.questions.length,
                                      progress: _ringProgress,
                                      color: grade.color,
                                      icon: grade.icon,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  DelayedReveal(
                                    visible: _appear,
                                    delay: const Duration(milliseconds: 280),
                                    beginOffset: const Offset(0, 0.08),
                                    child: Column(
                                      children: [
                                        Text(
                                          grade.label,
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: grade.color,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${(_percentage * 100).toInt()}% helyes',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: palette.secondaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: palette.accent.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(
                                              color: palette.accent.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.access_time_filled_rounded,
                                                size: 13,
                                                color: palette.accentSecondary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Felhasznált idő ${widget.viewModel.finalTimerText}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: palette.accentSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  DelayedReveal(
                                    visible: _appear,
                                    delay: const Duration(milliseconds: 350),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: palette.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Válaszaid',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                        color: palette.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                for (final entry
                                    in widget.viewModel.questions.asMap().entries) ...[
                                  DelayedReveal(
                                    visible: _appear,
                                    delay: Duration(
                                      milliseconds: 380 + (entry.key * 40),
                                    ),
                                    beginOffset: const Offset(0, 0.08),
                                    child: ResultRow(
                                      index: entry.key + 1,
                                      question: entry.value,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: DelayedReveal(
                        visible: _appear,
                        delay: const Duration(milliseconds: 500),
                        beginOffset: const Offset(0, 0.1),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                palette.bg.withOpacity(0),
                                palette.bg,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GlassActionButton(
                                label: 'Újrakezdés',
                                icon: Icons.refresh_rounded,
                                tinted: true,
                                onTap: () => widget.viewModel.restart(),
                              ),
                              const SizedBox(height: 12),
                              GlassActionButton(
                                label: 'Vissza a főmenübe',
                                icon: Icons.home_rounded,
                                onTap: widget.onMainMenu,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _Grade _grade(AppPalette palette) {
    if (_percentage >= 0.8) {
      return _Grade('Kiváló!', palette.success, Icons.emoji_events_rounded);
    }
    if (_percentage >= 0.6) {
      return _Grade('Szép munka!', palette.info, Icons.star_rounded);
    }
    if (_percentage >= 0.3) {
      return _Grade('Jó kezdés!', palette.warning, Icons.local_fire_department_rounded);
    }
    return _Grade('Tanulj még!', palette.error, Icons.menu_book_rounded);
  }
}

class _Grade {
  const _Grade(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.score,
    required this.total,
    required this.progress,
    required this.color,
    required this.icon,
  });

  final int score;
  final int total;
  final double progress;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return SizedBox(
      width: 170,
      height: 170,
      child: CustomPaint(
        painter: _ScoreRingPainter(
          progress: progress,
          trackColor: palette.isDark
              ? Colors.white.withOpacity(0.07)
              : colorFromHex('1C1C1E').withOpacity(0.15),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: color),
              Text(
                '$score/$total',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: palette.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({
    required this.progress,
    required this.trackColor,
    required this.gradient,
  });

  final double progress;
  final Color trackColor;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Offset.zero & size);

    canvas.drawCircle(size.center(Offset.zero), (size.width - strokeWidth) / 2, trackPaint);
    canvas.drawArc(
      rect,
      -1.5708,
      6.28318 * progress.clamp(0.0, 1.0).toDouble(),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.gradient != gradient;
  }
}

class ResultRow extends StatelessWidget {
  const ResultRow({
    super.key,
    required this.index,
    required this.question,
  });

  final int index;
  final Question question;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.surfaceBorder),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.surfaceBg,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: palette.secondaryText,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: palette.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: palette.success,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    question.correctAnswer,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: palette.isDark
                          ? colorFromHex('6EE7B7')
                          : palette.successText,
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

class GlassActionButton extends StatelessWidget {
  const GlassActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.tinted = false,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool tinted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final radius = BorderRadius.circular(18);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: tinted ? 60 : 56,
            decoration: BoxDecoration(
              color: tinted
                  ? palette.accent.withOpacity(0.35)
                  : Colors.white.withOpacity(palette.isDark ? 0.06 : 0.35),
              borderRadius: radius,
              border: Border.all(
                color: tinted
                    ? palette.accent.withOpacity(0.45)
                    : palette.surfaceBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: tinted ? 16 : 15,
                  color: tinted ? Colors.white : palette.primaryText.withOpacity(0.85),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: tinted ? 17 : 16,
                    fontWeight: tinted ? FontWeight.w800 : FontWeight.w700,
                    color: tinted ? Colors.white : palette.primaryText.withOpacity(0.85),
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
