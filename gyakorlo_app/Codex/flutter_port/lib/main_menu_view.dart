import 'dart:async';

import 'package:flutter/material.dart';

import 'app_style.dart';
import 'quiz_models.dart';
import 'quiz_view.dart';
import 'stats_view.dart';

class MainMenuView extends StatefulWidget {
  const MainMenuView({
    super.key,
    required this.themeController,
    required this.statsManager,
  });

  final ThemeController themeController;
  final StatsManager statsManager;

  @override
  State<MainMenuView> createState() => _MainMenuViewState();
}

class _MainMenuViewState extends State<MainMenuView>
    with SingleTickerProviderStateMixin {
  late final QuizViewModel _viewModel;
  late final AnimationController _pulseController;

  bool _appear = false;
  bool _showMenu = false;

  @override
  void initState() {
    super.initState();
    _viewModel = QuizViewModel(widget.statsManager);
    _viewModel.loadQuestions();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _appear = true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openModePicker() async {
    if (_viewModel.questions.isEmpty) {
      await _viewModel.loadQuestions();
    }

    final palette = AppPalette.of(context);
    final count = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _AppSheet(
          height: 500,
          backgroundColor: palette.sheetBg,
          child: ModePickerSheet(
            primaryText: palette.primaryText,
            secondaryText: palette.secondaryText,
          ),
        );
      },
    );

    if (count == null || !mounted) {
      return;
    }

    _viewModel.restart(limit: count);

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) {
          return QuizView(viewModel: _viewModel);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _openInfoSheet() async {
    final palette = AppPalette.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _AppSheet(
          height: 430,
          backgroundColor: palette.sheetBg,
          child: InfoSheet(
            primaryText: palette.primaryText,
            secondaryText: palette.secondaryText,
          ),
        );
      },
    );
  }

  Future<void> _openStatsSheet() async {
    final palette = AppPalette.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: _AppSheet(
            backgroundColor: palette.bg,
            child: StatsView(statsManager: widget.statsManager),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _viewModel,
        _pulseController,
        widget.themeController,
      ]),
      builder: (context, _) {
        final palette = AppPalette.of(context);
        final pulseScale = Tween<double>(begin: 1.1, end: 1.3).transform(
          _pulseController.value,
        );

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: palette.bg),
              ),
              Positioned(
                left: -20,
                right: -20,
                top: -80,
                child: IgnorePointer(
                  child: Center(
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
              ),
              SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                        child: DelayedReveal(
                          visible: _appear,
                          delay: const Duration(milliseconds: 600),
                          beginOffset: const Offset(0, -0.08),
                          child: GestureDetector(
                            onTap: () => setState(() => _showMenu = true),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: palette.surfaceBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: palette.surfaceBorder,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  3,
                                  (_) => Container(
                                    width: 22,
                                    height: 2.5,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: palette.primaryText.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const Spacer(),
                            DelayedReveal(
                              visible: _appear,
                              delay: const Duration(milliseconds: 100),
                              beginScale: 0.9,
                              child: Transform.scale(
                                scale: pulseScale,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: palette.accent.withOpacity(0.18),
                                    border: Border.all(
                                      color: palette.accent.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) {
                                        return palette.accentGradient.createShader(
                                          Rect.fromLTWH(
                                            0,
                                            0,
                                            bounds.width,
                                            bounds.height,
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.psychology_alt_rounded,
                                        size: 44,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            DelayedReveal(
                              visible: _appear,
                              delay: const Duration(milliseconds: 220),
                              beginOffset: const Offset(0, 0.1),
                              child: Column(
                                children: [
                                  _GradientText(
                                    'QUIZ',
                                    style: TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 12,
                                      color: palette.primaryText,
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        palette.primaryText,
                                        palette.accentSoft,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  _GradientText(
                                    'MASTER',
                                    style: TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 8,
                                      color: palette.accent,
                                    ),
                                    gradient: palette.primaryGradient,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            DelayedReveal(
                              visible: _appear,
                              delay: const Duration(milliseconds: 340),
                              beginOffset: const Offset(0, 0.08),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Vágj bele a kérdésekbe és \n légy ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: palette.secondaryText,
                                    height: 1.35,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'TE',
                                      style: TextStyle(
                                        color: palette.accentSecondary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' a szakma legjobbja!',
                                      style: TextStyle(
                                        color: palette.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Spacer(),
                            DelayedReveal(
                              visible: _appear,
                              delay: const Duration(milliseconds: 440),
                              beginOffset: const Offset(0, 0.08),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  StatPill(
                                    icon: Icons.question_mark_rounded,
                                    label: '${_viewModel.questions.length} \n kérdés',
                                  ),
                                  const StatPill(
                                    icon: Icons.bolt_rounded,
                                    label: 'Véletlenszerű \n sorrend',
                                  ),
                                  const StatPill(
                                    icon: Icons.star_rounded,
                                    label: 'Válaszaid \n ellenőrizheted',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            DelayedReveal(
                              visible: _appear,
                              delay: const Duration(milliseconds: 540),
                              beginOffset: const Offset(0, 0.1),
                              child: _PrimaryButton(
                                label: 'Quiz indítása',
                                icon: Icons.arrow_forward_rounded,
                                onTap: _openModePicker,
                              ),
                            ),
                            const SizedBox(height: 52),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_showMenu,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _showMenu ? 1 : 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _showMenu = false),
                      child: ColoredBox(color: Colors.black.withOpacity(0.4)),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                right: _showMenu ? 0 : -300,
                top: 0,
                bottom: 0,
                child: SafeArea(
                  child: SizedBox(
                    width: 280,
                    child: SideMenuView(
                      themeController: widget.themeController,
                      onClose: () => setState(() => _showMenu = false),
                      onInfo: () async {
                        setState(() => _showMenu = false);
                        await Future<void>.delayed(
                          const Duration(milliseconds: 400),
                        );
                        if (mounted) {
                          await _openInfoSheet();
                        }
                      },
                      onStats: () async {
                        setState(() => _showMenu = false);
                        await Future<void>.delayed(
                          const Duration(milliseconds: 400),
                        );
                        if (mounted) {
                          await _openStatsSheet();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SideMenuView extends StatelessWidget {
  const SideMenuView({
    super.key,
    required this.themeController,
    required this.onClose,
    required this.onInfo,
    required this.onStats,
  });

  final ThemeController themeController;
  final VoidCallback onClose;
  final Future<void> Function() onInfo;
  final Future<void> Function() onStats;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      color: palette.panelBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.surfaceBg,
                      border: Border.all(color: palette.surfaceBorder),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: palette.primaryText.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Készítette',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: palette.secondaryText.withOpacity(0.7),
                  ),
                ),
                Text(
                  'Girhiny Viktor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            height: 1,
            color: palette.surfaceBorder,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _MenuButton(
                  icon: Icons.bar_chart_rounded,
                  iconColor: palette.success,
                  label: 'Statisztikák',
                  onTap: onStats,
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.info_rounded,
                  iconColor: palette.info,
                  label: 'Az alkalmazásról',
                  onTap: onInfo,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: palette.surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: palette.warning.withOpacity(0.15),
                              child: Icon(
                                Icons.tonality_rounded,
                                color: palette.warning,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Megjelenés',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: palette.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: palette.surfaceBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: palette.surfaceBorder),
                          ),
                          child: Row(
                            children: [
                              _ThemeOption(
                                label: 'Rendszer',
                                icon: Icons.smartphone_rounded,
                                selected:
                                    themeController.preference == ThemePreference.system,
                                onTap: () => themeController.setPreference(
                                  ThemePreference.system,
                                ),
                              ),
                              _ThemeOption(
                                label: 'Világos',
                                icon: Icons.wb_sunny_rounded,
                                selected:
                                    themeController.preference == ThemePreference.light,
                                onTap: () => themeController.setPreference(
                                  ThemePreference.light,
                                ),
                              ),
                              _ThemeOption(
                                label: 'Sötét',
                                icon: Icons.dark_mode_rounded,
                                selected:
                                    themeController.preference == ThemePreference.dark,
                                onTap: () => themeController.setPreference(
                                  ThemePreference.dark,
                                ),
                              ),
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
          const Spacer(),
        ],
      ),
    );
  }
}

class InfoSheet extends StatelessWidget {
  const InfoSheet({
    super.key,
    required this.primaryText,
    required this.secondaryText,
  });

  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          CircleAvatar(
            radius: 32,
            backgroundColor: palette.accent.withOpacity(0.15),
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => palette.accentGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: const Icon(Icons.psychology_alt_rounded, size: 28),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Az alkalmazásról',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ez az app egy csapat lelkes diák számára készült, akik szeretnének az évvégi vizsgájukon a lehető legjobb eredményt elérni. Ha úgy érzed, hogy te közéjük tartozol, akkor üdvözöllek az appomon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 32),
          _PrimaryButton(
            label: 'Bezárás',
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class ModePickerSheet extends StatefulWidget {
  const ModePickerSheet({
    super.key,
    required this.primaryText,
    required this.secondaryText,
  });

  final Color primaryText;
  final Color secondaryText;

  @override
  State<ModePickerSheet> createState() => _ModePickerSheetState();
}

class _ModePickerSheetState extends State<ModePickerSheet> {
  bool _appear = false;
  int? _selected;

  final List<_ModeOption> _modes = const [
    _ModeOption(
      count: 10,
      label: '10 kérdés',
      sublabel: 'Szuper gyors teszt',
      icon: Icons.directions_run_rounded,
      colorHex: 'FF0000',
    ),
    _ModeOption(
      count: 25,
      label: '25 kérdés',
      sublabel: 'Gyors teszt',
      icon: Icons.flash_on_rounded,
      colorHex: '34D399',
    ),
    _ModeOption(
      count: 50,
      label: '50 kérdés',
      sublabel: 'Közepes teszt',
      icon: Icons.directions_walk_rounded,
      colorHex: '60A5FA',
    ),
    _ModeOption(
      count: 100,
      label: '100 kérdés',
      sublabel: 'Teljes vizsga',
      icon: Icons.school_rounded,
      colorHex: '9898FF',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _appear = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Column(
      children: [
        Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(top: 14, bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        DelayedReveal(
          visible: _appear,
          delay: const Duration(milliseconds: 50),
          child: Column(
            children: [
              Text(
                'Teszt kiválasztása',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: widget.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Válaszd ki hány kérdést szeretnél!',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.secondaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (var i = 0; i < _modes.length; i++) ...[
                DelayedReveal(
                  visible: _appear,
                  delay: Duration(milliseconds: 100 + i * 70),
                  child: ModeCard(
                    mode: _modes[i],
                    isSelected: _selected == _modes[i].count,
                    primaryText: widget.primaryText,
                    secondaryText: widget.secondaryText,
                    onTap: () => setState(() => _selected = _modes[i].count),
                  ),
                ),
                if (i != _modes.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DelayedReveal(
            visible: _appear,
            delay: const Duration(milliseconds: 350),
            child: Opacity(
              opacity: _selected == null ? 0.75 : 1,
              child: GestureDetector(
                onTap: _selected == null
                    ? null
                    : () => Navigator.of(context).pop(_selected),
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: _selected != null ? palette.primaryGradient : null,
                    color:
                        _selected == null ? Colors.white.withOpacity(0.06) : null,
                    boxShadow: _selected == null
                        ? const []
                        : [
                            BoxShadow(
                              color: palette.accent.withOpacity(0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _selected == null ? 'Válassz egy módot' : 'Kezdés ->',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _selected == null
                          ? widget.secondaryText
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.primaryText,
    required this.secondaryText,
    required this.onTap,
  });

  final _ModeOption mode;
  final bool isSelected;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = colorFromHex(mode.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? color.withOpacity(0.08)
              : primaryText.withOpacity(0.04),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : primaryText.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: color.withOpacity(isSelected ? 0.25 : 0.1),
              child: Icon(mode.icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                    ),
                  ),
                  Text(
                    mode.sublabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : primaryText.withOpacity(0.15),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: palette.accentSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.accentSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    this.icon,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final FutureOr<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          gradient: palette.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: palette.accent.withOpacity(0.55),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: palette.surfaceBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.surfaceBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.primaryText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: palette.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: 48,
          decoration: BoxDecoration(
            color: selected ? palette.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : palette.secondaryText,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : palette.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppSheet extends StatelessWidget {
  const _AppSheet({
    required this.child,
    required this.backgroundColor,
    this.height,
  });

  final Widget child;
  final Color backgroundColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: child,
    );

    if (height == null) {
      content = ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: DecoratedBox(
          decoration: BoxDecoration(color: backgroundColor),
          child: SizedBox(width: double.infinity, child: child),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: content,
      ),
    );
  }
}

class _ModeOption {
  const _ModeOption({
    required this.count,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.colorHex,
  });

  final int count;
  final String label;
  final String sublabel;
  final IconData icon;
  final String colorHex;
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
