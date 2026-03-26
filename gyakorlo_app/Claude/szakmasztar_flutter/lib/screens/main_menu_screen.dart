import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';
import 'stats_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final void Function(String) onThemeChanged;
  const MainMenuScreen({super.key, required this.onThemeChanged});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  bool _appear = false;
  bool _showMenu = false;
  String _themeMode = 'system';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _appear = true);
    });

    context.read<QuizProvider>().loadQuestions();
  }

  Future<void> _loadTheme() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _themeMode = p.getString('themeMode') ?? 'system');
  }

  Future<void> _saveTheme(String mode) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('themeMode', mode);
    setState(() => _themeMode = mode);
    widget.onThemeChanged(mode);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context, _themeMode);
    final bg = AppTheme.bg(isDark);
    final primaryText = AppTheme.primaryText(isDark);
    final secondaryText = AppTheme.secondaryText(isDark);
    final surfaceBg = AppTheme.surfaceBg(isDark);
    final surfaceBorder = AppTheme.surfaceBorder(isDark);
    final quiz = context.watch<QuizProvider>();

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -80,
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

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(),

                  // Brain icon with pulse
                  AnimatedOpacity(
                    opacity: _appear ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) {
                        final scale = 1.1 + (_pulseController.value * 0.2);
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  color: AppColors.purple.withOpacity(0.18),
                                  border: Border.all(
                                    color: AppColors.purple.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [AppColors.purpleLight, AppColors.purple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Icon(
                                Icons.psychology,
                                size: 44,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Title
                  AnimatedSlide(
                    offset: _appear ? Offset.zero : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      opacity: _appear ? 1 : 0,
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [primaryText, AppColors.purpleSoft],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'QUIZ',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 12,
                                color: primaryText,
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
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  AnimatedOpacity(
                    opacity: _appear ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: secondaryText,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Vágj bele a kérdésekbe és\n légy '),
                          TextSpan(
                            text: 'TE',
                            style: TextStyle(
                              color: AppColors.purpleLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' a szakma legjobbja!'),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Stat pills
                  AnimatedOpacity(
                    opacity: _appear ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatPill(
                          icon: Icons.help,
                          label: '${quiz.questions.length}\nkérdés',
                          surfaceBg: surfaceBg,
                          surfaceBorder: surfaceBorder,
                        ),
                        const SizedBox(width: 12),
                        _StatPill(
                          icon: Icons.bolt,
                          label: 'Véletlenszerű\nsorrend',
                          surfaceBg: surfaceBg,
                          surfaceBorder: surfaceBorder,
                        ),
                        const SizedBox(width: 12),
                        _StatPill(
                          icon: Icons.star,
                          label: 'Válaszaid\nellenőrizheted',
                          surfaceBg: surfaceBg,
                          surfaceBorder: surfaceBorder,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Start button
                  AnimatedOpacity(
                    opacity: _appear ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: GestureDetector(
                      onTap: () => _showModePicker(context, isDark, primaryText, secondaryText),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppTheme.purpleGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple.withOpacity(0.55),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Quiz indítása',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 52),
                ],
              ),
            ),
          ),

          // Hamburger button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => setState(() => _showMenu = true),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (_) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Container(
                        width: 22,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: primaryText.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                ),
              ),
            ),
          ),

          // Side menu overlay
          if (_showMenu) ...[
            GestureDetector(
              onTap: () => setState(() => _showMenu = false),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _SideMenu(
                themeMode: _themeMode,
                isDark: isDark,
                primaryText: primaryText,
                secondaryText: secondaryText,
                surfaceBg: surfaceBg,
                surfaceBorder: surfaceBorder,
                onClose: () => setState(() => _showMenu = false),
                onThemeChanged: _saveTheme,
                onStats: () {
                  setState(() => _showMenu = false);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => StatsScreen(themeMode: _themeMode),
                      ));
                    }
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showModePicker(BuildContext context, bool isDark, Color primaryText, Color secondaryText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ModePickerSheet(
        isDark: isDark,
        primaryText: primaryText,
        secondaryText: secondaryText,
        onModeSelected: (count) {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted) {
              context.read<QuizProvider>().restart(limit: count);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => QuizScreen(themeMode: _themeMode),
              ));
            }
          });
        },
      ),
    );
  }
}

// ── Stat Pill ────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color surfaceBg;
  final Color surfaceBorder;
  const _StatPill({required this.icon, required this.label, required this.surfaceBg, required this.surfaceBorder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.purpleLight),
          const SizedBox(width: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.purpleLight.withOpacity(0.8),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Side Menu ────────────────────────────────────────────────────────────────

class _SideMenu extends StatelessWidget {
  final String themeMode;
  final bool isDark;
  final Color primaryText, secondaryText, surfaceBg, surfaceBorder;
  final VoidCallback onClose, onStats;
  final void Function(String) onThemeChanged;

  const _SideMenu({
    required this.themeMode,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.surfaceBg,
    required this.surfaceBorder,
    required this.onClose,
    required this.onStats,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      width: 280,
      height: double.infinity,
      color: bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: onClose,
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
              ),
              const SizedBox(height: 24),

              // Stats button
              _menuItem(
                icon: Icons.bar_chart,
                iconColor: AppColors.green,
                label: 'Statisztikák',
                primaryText: primaryText,
                secondaryText: secondaryText,
                surfaceBg: surfaceBg,
                surfaceBorder: surfaceBorder,
                onTap: onStats,
              ),
              const SizedBox(height: 12),

              // Info button
              _menuItem(
                icon: Icons.info,
                iconColor: AppColors.blue,
                label: 'Az alkalmazásról',
                primaryText: primaryText,
                secondaryText: secondaryText,
                surfaceBg: surfaceBg,
                surfaceBorder: surfaceBorder,
                onTap: () => _showInfo(context),
              ),
              const SizedBox(height: 20),

              // Theme picker
              Container(
                decoration: BoxDecoration(
                  color: surfaceBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.circle_outlined, color: Color(0xFFFBBF24), size: 18),
                          ),
                          const SizedBox(width: 14),
                          Text('Megjelenés', style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: surfaceBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            _themeSegment('system', Icons.phone_iphone, 'iPhone', themeMode, onThemeChanged),
                            _themeSegment('light', Icons.wb_sunny, 'Világos', themeMode, onThemeChanged),
                            _themeSegment('dark', Icons.dark_mode, 'Sötét', themeMode, onThemeChanged),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Az alkalmazásról'),
        content: const Text('IT Vizsga kvíz alkalmazás hálózati kérdésekkel.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bezárás')),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color primaryText,
    required Color secondaryText,
    required Color surfaceBg,
    required Color surfaceBorder,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, color: secondaryText, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _themeSegment(String value, IconData icon, String label, String current, void Function(String) onChange) {
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 14, color: selected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mode Picker ───────────────────────────────────────────────────────────────

class _ModePickerSheet extends StatefulWidget {
  final bool isDark;
  final Color primaryText, secondaryText;
  final void Function(int) onModeSelected;
  const _ModePickerSheet({required this.isDark, required this.primaryText, required this.secondaryText, required this.onModeSelected});

  @override
  State<_ModePickerSheet> createState() => _ModePickerSheetState();
}

class _ModePickerSheetState extends State<_ModePickerSheet> {
  int? _selected;

  static const _modes = [
    (count: 10,  label: '10 Kérdés',  sub: 'Szuper gyors teszt', icon: Icons.directions_run,  color: Color(0xFFFF6B6B)),
    (count: 25,  label: '25 Kérdés',  sub: 'Gyors teszt',        icon: Icons.speed,            color: Color(0xFF34D399)),
    (count: 50,  label: '50 Kérdés',  sub: 'Közepes teszt',      icon: Icons.directions_walk,  color: Color(0xFF60A5FA)),
    (count: 100, label: '100 Kérdés', sub: 'Teljes vizsga',      icon: Icons.school,           color: Color(0xFF9898FF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 24),
          Text('Teszt kiválasztása', style: TextStyle(color: widget.primaryText, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('Válaszd ki hány kérdést szeretnél!', style: TextStyle(color: widget.secondaryText, fontSize: 14)),
          const SizedBox(height: 24),
          for (final mode in _modes) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: GestureDetector(
                onTap: () => setState(() => _selected = mode.count),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _selected == mode.count ? mode.color.withOpacity(0.08) : widget.primaryText.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _selected == mode.count ? mode.color.withOpacity(0.5) : widget.primaryText.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: mode.color.withOpacity(_selected == mode.count ? 0.25 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(mode.icon, color: mode.color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mode.label, style: TextStyle(color: widget.primaryText, fontSize: 17, fontWeight: FontWeight.bold)),
                            Text(mode.sub, style: TextStyle(color: widget.secondaryText, fontSize: 13)),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _selected == mode.count ? mode.color : widget.primaryText.withOpacity(0.15), width: 2),
                        ),
                        child: _selected == mode.count
                            ? Center(child: Container(width: 14, height: 14, decoration: BoxDecoration(color: mode.color, shape: BoxShape.circle)))
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: _selected == null ? null : () => widget.onModeSelected(_selected!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 58,
                decoration: BoxDecoration(
                  gradient: _selected != null ? AppTheme.purpleGradient : null,
                  color: _selected == null ? Colors.white.withOpacity(0.06) : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _selected != null ? [BoxShadow(color: AppColors.purple.withOpacity(0.45), blurRadius: 16, offset: const Offset(0, 6))] : null,
                ),
                child: Center(
                  child: Text(
                    _selected == null ? 'Válassz egy módot' : 'Kezdés →',
                    style: TextStyle(
                      color: _selected == null ? widget.secondaryText : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
