import 'package:flutter/material.dart';

import 'app_style.dart';
import 'quiz_models.dart';

class StatsView extends StatefulWidget {
  const StatsView({
    super.key,
    required this.statsManager,
  });

  final StatsManager statsManager;

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  bool _appear = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _appear = true);
      }
    });
  }

  Future<void> _confirmReset() async {
    final palette = AppPalette.of(context);
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Statisztikák törlése'),
          content: const Text('Biztosan törlöd az összes statisztikát?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Mégsem'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: palette.error),
              child: const Text('Törlés'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      await widget.statsManager.resetAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.statsManager,
      builder: (context, _) {
        final palette = AppPalette.of(context);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: palette.bg),
              ),
              Positioned(
                left: -20,
                right: -20,
                top: -160,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 420,
                      height: 420,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            palette.accent.withOpacity(0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DelayedReveal(
                            visible: _appear,
                            delay: const Duration(milliseconds: 100),
                            child: _SectionHeader(title: 'Napi Sorozat'),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DelayedReveal(
                                  visible: _appear,
                                  delay: const Duration(milliseconds: 100),
                                  child: _StreakCard(
                                    value: '${widget.statsManager.currentStreak}',
                                    label: 'Jelenlegi\nsorozat',
                                    color: palette.orange,
                                    icon: Icons.local_fire_department_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DelayedReveal(
                                  visible: _appear,
                                  delay: const Duration(milliseconds: 200),
                                  child: _StreakCard(
                                    value: '${widget.statsManager.bestStreak}',
                                    label: 'Leghosszabb\nsorozat',
                                    color: palette.warning,
                                    icon: Icons.emoji_events_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          DelayedReveal(
                            visible: _appear,
                            delay: const Duration(milliseconds: 100),
                            child: _SectionHeader(title: 'Összesített'),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DelayedReveal(
                                  visible: _appear,
                                  delay: const Duration(milliseconds: 150),
                                  child: _StatCard(
                                    value: '${widget.statsManager.totalQuizzes}',
                                    label: 'Elvégzett\nteszt',
                                    color: palette.accentSecondary,
                                    icon: Icons.check_circle_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DelayedReveal(
                                  visible: _appear,
                                  delay: const Duration(milliseconds: 200),
                                  child: _StatCard(
                                    value: '${widget.statsManager.totalQuestions}',
                                    label: 'Összes\nkérdés',
                                    color: palette.info,
                                    icon: Icons.question_mark_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DelayedReveal(
                                  visible: _appear,
                                  delay: const Duration(milliseconds: 250),
                                  child: _StatCard(
                                    value:
                                        '${(widget.statsManager.averageScore * 100).toInt()}%',
                                    label: 'Átlagos\nteljesítmény',
                                    color: palette.success,
                                    icon: Icons.trending_up_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DelayedReveal(
                                  visible: _appear,
                                  delay: const Duration(milliseconds: 300),
                                  child: _StatCard(
                                    value: '${(widget.statsManager.bestScore * 100).toInt()}%',
                                    label: 'Legjobb\neredmény',
                                    color: palette.error,
                                    icon: Icons.star_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          DelayedReveal(
                            visible: _appear,
                            delay: const Duration(milliseconds: 100),
                            child: _SectionHeader(
                              title: 'Legjobb eredmény módok szerint',
                            ),
                          ),
                          const SizedBox(height: 16),
                          DelayedReveal(
                            visible: _appear,
                            delay: const Duration(milliseconds: 200),
                            child: _ModeRow(
                              label: '10 Kérdés',
                              color: colorFromHex('FF6B6B'),
                              icon: Icons.directions_run_rounded,
                              best: widget.statsManager.bestScoreForMode(10),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DelayedReveal(
                            visible: _appear,
                            delay: const Duration(milliseconds: 250),
                            child: _ModeRow(
                              label: '25 Kérdés',
                              color: palette.success,
                              icon: Icons.flash_on_rounded,
                              best: widget.statsManager.bestScoreForMode(25),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DelayedReveal(
                            visible: _appear,
                            delay: const Duration(milliseconds: 300),
                            child: _ModeRow(
                              label: '50 Kérdés',
                              color: palette.info,
                              icon: Icons.directions_walk_rounded,
                              best: widget.statsManager.bestScoreForMode(50),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DelayedReveal(
                            visible: _appear,
                            delay: const Duration(milliseconds: 350),
                            child: _ModeRow(
                              label: '100 Kérdés',
                              color: palette.accentSecondary,
                              icon: Icons.school_rounded,
                              best: widget.statsManager.bestScoreForMode(100),
                            ),
                          ),
                          const SizedBox(height: 24),
                          DelayedReveal(
                            visible: _appear,
                            delay: const Duration(milliseconds: 400),
                            child: GestureDetector(
                              onTap: _confirmReset,
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: palette.error.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: palette.error.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_rounded,
                                      size: 14,
                                      color: palette.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Statisztikák törlése',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: palette.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: palette.surfaceBg,
                                  border: Border.all(color: palette.surfaceBorder),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: palette.secondaryText,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Statisztikák',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: palette.primaryText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 36),
                          ],
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
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: palette.secondaryText,
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: palette.surfaceBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.surfaceBorder),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: palette.primaryText,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: palette.secondaryText,
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

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.best,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double best;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: palette.primaryText,
              ),
            ),
          ),
          if (best > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${(best * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            )
          else
            Text(
              '-',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: palette.secondaryText,
              ),
            ),
        ],
      ),
    );
  }
}
