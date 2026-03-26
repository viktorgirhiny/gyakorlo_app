import 'package:flutter/material.dart';
import '../models/stats_manager.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatefulWidget {
  final String themeMode;
  const StatsScreen({super.key, required this.themeMode});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _appear = false;
  bool _showResetConfirm = false;

  int _totalQuizzes = 0;
  int _totalQuestions = 0;
  double _averageScore = 0;
  double _bestScore = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  double _best10 = 0, _best25 = 0, _best50 = 0, _best100 = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _appear = true);
    });
  }

  Future<void> _loadStats() async {
    final s = StatsManager.shared;
    final results = await Future.wait([
      s.totalQuizzes,
      s.totalQuestions,
      s.averageScore,
      s.bestScore,
      s.currentStreak,
      s.bestStreak,
      s.bestScoreForMode(10),
      s.bestScoreForMode(25),
      s.bestScoreForMode(50),
      s.bestScoreForMode(100),
    ]);
    if (mounted) {
      setState(() {
        _totalQuizzes    = results[0] as int;
        _totalQuestions  = results[1] as int;
        _averageScore    = results[2] as double;
        _bestScore       = results[3] as double;
        _currentStreak   = results[4] as int;
        _bestStreak      = results[5] as int;
        _best10          = results[6] as double;
        _best25          = results[7] as double;
        _best50          = results[8] as double;
        _best100         = results[9] as double;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context, widget.themeMode);
    final bg = AppTheme.bg(isDark);
    final primaryText = AppTheme.primaryText(isDark);
    final secondaryText = AppTheme.secondaryText(isDark);
    final surfaceBg = AppTheme.surfaceBg(isDark);
    final surfaceBorder = AppTheme.surfaceBorder(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -160,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.purple.withOpacity(0.18), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: surfaceBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: surfaceBorder),
                          ),
                          child: Icon(Icons.close, size: 16, color: secondaryText),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Statisztikák',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: primaryText, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Streak
                        _sectionHeader('🔥 Napi Sorozat', secondaryText),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _streakCard(value: '$_currentStreak', label: 'Jelenlegi\nsorozat', color: AppColors.orange, icon: Icons.local_fire_department, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText, delay: 0.1)),
                            const SizedBox(width: 12),
                            Expanded(child: _streakCard(value: '$_bestStreak', label: 'Leghosszabb\nsorozat', color: AppColors.yellow, icon: Icons.emoji_events, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText, delay: 0.2)),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _sectionHeader('📊 Összesített', secondaryText),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _statCard(value: '$_totalQuizzes', label: 'Elvégzett\nteszt', color: AppColors.purpleLight, icon: Icons.check_circle, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText, delay: 0.15)),
                            const SizedBox(width: 10),
                            Expanded(child: _statCard(value: '$_totalQuestions', label: 'Összes\nkérdés', color: AppColors.blue, icon: Icons.help, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText, delay: 0.2)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _statCard(value: '${(_averageScore * 100).toInt()}%', label: 'Átlagos\nteljesítmény', color: AppColors.green, icon: Icons.trending_up, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText, delay: 0.25)),
                            const SizedBox(width: 10),
                            Expanded(child: _statCard(value: '${(_bestScore * 100).toInt()}%', label: 'Legjobb\neredmény', color: AppColors.red, icon: Icons.star, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText, delay: 0.3)),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _sectionHeader('🏆 Legjobb eredmény módok szerint', secondaryText),
                        const SizedBox(height: 12),
                        _modeRow(label: '10 Kérdés', icon: Icons.directions_run, color: const Color(0xFFFF6B6B), best: _best10, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText),
                        const SizedBox(height: 10),
                        _modeRow(label: '25 Kérdés', icon: Icons.speed, color: AppColors.green, best: _best25, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText),
                        const SizedBox(height: 10),
                        _modeRow(label: '50 Kérdés', icon: Icons.directions_walk, color: AppColors.blue, best: _best50, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText),
                        const SizedBox(height: 10),
                        _modeRow(label: '100 Kérdés', icon: Icons.school, color: AppColors.purpleLight, best: _best100, surfaceBg: surfaceBg, surfaceBorder: surfaceBorder, primaryText: primaryText, secondaryText: secondaryText),

                        const SizedBox(height: 24),

                        // Reset button
                        AnimatedOpacity(
                          opacity: _appear ? 1 : 0,
                          duration: const Duration(milliseconds: 500),
                          child: GestureDetector(
                            onTap: () => setState(() => _showResetConfirm = true),
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.red.withOpacity(0.2)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete, color: AppColors.red, size: 16),
                                  SizedBox(width: 8),
                                  Text('Statisztikák törlése', style: TextStyle(color: AppColors.red, fontSize: 15, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reset confirm dialog
          if (_showResetConfirm)
            AlertDialog(
              title: const Text('Statisztikák törlése'),
              content: const Text('Biztosan törlöd az összes statisztikát?'),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _showResetConfirm = false),
                  child: const Text('Mégsem'),
                ),
                TextButton(
                  onPressed: () async {
                    await StatsManager.shared.resetAll();
                    await _loadStats();
                    if (mounted) setState(() => _showResetConfirm = false);
                  },
                  child: const Text('Törlés', style: TextStyle(color: AppColors.red)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color secondaryText) {
    return AnimatedOpacity(
      opacity: _appear ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      child: Text(title, style: TextStyle(color: secondaryText, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _streakCard({required String value, required String label, required Color color, required IconData icon, required Color surfaceBg, required Color surfaceBorder, required Color primaryText, required Color secondaryText, required double delay}) {
    return AnimatedOpacity(
      opacity: _appear ? 1 : 0,
      duration: Duration(milliseconds: (400 + delay * 1000).toInt()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: surfaceBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: surfaceBorder)),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(color: primaryText, fontSize: 36, fontWeight: FontWeight.w900)),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: secondaryText, fontSize: 12, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _statCard({required String value, required String label, required Color color, required IconData icon, required Color surfaceBg, required Color surfaceBorder, required Color primaryText, required Color secondaryText, required double delay}) {
    return AnimatedOpacity(
      opacity: _appear ? 1 : 0,
      duration: Duration(milliseconds: (400 + delay * 1000).toInt()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: surfaceBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: surfaceBorder)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: primaryText, fontSize: 22, fontWeight: FontWeight.w900)),
                Text(label, style: TextStyle(color: secondaryText, fontSize: 11, height: 1.3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeRow({required String label, required IconData icon, required Color color, required double best, required Color surfaceBg, required Color surfaceBorder, required Color primaryText, required Color secondaryText}) {
    return AnimatedOpacity(
      opacity: _appear ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: surfaceBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: surfaceBorder)),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: primaryText, fontSize: 15, fontWeight: FontWeight.w600))),
            if (best > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('${(best * 100).toInt()}%', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
              )
            else
              Text('–', style: TextStyle(color: secondaryText, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
