import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreference { system, light, dark }

ThemePreference themePreferenceFromStorage(String? value) {
  switch (value) {
    case 'light':
      return ThemePreference.light;
    case 'dark':
      return ThemePreference.dark;
    default:
      return ThemePreference.system;
  }
}

String themePreferenceToStorage(ThemePreference preference) {
  switch (preference) {
    case ThemePreference.light:
      return 'light';
    case ThemePreference.dark:
      return 'dark';
    case ThemePreference.system:
      return 'system';
  }
}

class ThemeController extends ChangeNotifier {
  ThemeController(this._preferences)
      : _preference = themePreferenceFromStorage(
          _preferences.getString(_themeModeKey),
        );

  static const _themeModeKey = 'themeMode';

  final SharedPreferences _preferences;
  ThemePreference _preference;

  ThemePreference get preference => _preference;

  ThemeMode get themeMode {
    switch (_preference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  Future<void> setPreference(ThemePreference preference) async {
    if (_preference == preference) {
      return;
    }
    _preference = preference;
    notifyListeners();
    await _preferences.setString(
      _themeModeKey,
      themePreferenceToStorage(preference),
    );
  }
}

class AppPalette {
  const AppPalette._({
    required this.isDark,
    required this.bg,
    required this.sheetBg,
    required this.panelBg,
    required this.primaryText,
    required this.secondaryText,
    required this.surfaceBg,
    required this.surfaceBorder,
    required this.accent,
    required this.accentSecondary,
    required this.accentSoft,
    required this.success,
    required this.successText,
    required this.warning,
    required this.warningText,
    required this.error,
    required this.errorText,
    required this.info,
    required this.orange,
  });

  final bool isDark;
  final Color bg;
  final Color sheetBg;
  final Color panelBg;
  final Color primaryText;
  final Color secondaryText;
  final Color surfaceBg;
  final Color surfaceBorder;
  final Color accent;
  final Color accentSecondary;
  final Color accentSoft;
  final Color success;
  final Color successText;
  final Color warning;
  final Color warningText;
  final Color error;
  final Color errorText;
  final Color info;
  final Color orange;

  factory AppPalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppPalette.dark() : AppPalette.light();
  }

  factory AppPalette.dark() {
    return AppPalette._(
      isDark: true,
      bg: colorFromHex('0D0D14'),
      sheetBg: colorFromHex('13131F'),
      panelBg: colorFromHex('13131F'),
      primaryText: Colors.white,
      secondaryText: Colors.white.withOpacity(0.45),
      surfaceBg: Colors.white.withOpacity(0.06),
      surfaceBorder: Colors.white.withOpacity(0.10),
      accent: colorFromHex('5B5BF6'),
      accentSecondary: colorFromHex('9898FF'),
      accentSoft: colorFromHex('ADADFF'),
      success: colorFromHex('34D399'),
      successText: colorFromHex('6EE7B7'),
      warning: colorFromHex('FBBF24'),
      warningText: colorFromHex('FDE68A'),
      error: colorFromHex('F87171'),
      errorText: colorFromHex('FCA5A5'),
      info: colorFromHex('60A5FA'),
      orange: colorFromHex('F97316'),
    );
  }

  factory AppPalette.light() {
    return AppPalette._(
      isDark: false,
      bg: colorFromHex('F2F2F7'),
      sheetBg: colorFromHex('F2F2F7'),
      panelBg: Colors.white,
      primaryText: colorFromHex('1C1C1E'),
      secondaryText: colorFromHex('1C1C1E').withOpacity(0.55),
      surfaceBg: colorFromHex('1C1C1E').withOpacity(0.06),
      surfaceBorder: colorFromHex('1C1C1E').withOpacity(0.10),
      accent: colorFromHex('5B5BF6'),
      accentSecondary: colorFromHex('9898FF'),
      accentSoft: colorFromHex('ADADFF'),
      success: colorFromHex('34D399'),
      successText: colorFromHex('065F46'),
      warning: colorFromHex('FBBF24'),
      warningText: colorFromHex('B45309'),
      error: colorFromHex('F87171'),
      errorText: colorFromHex('991B1B'),
      info: colorFromHex('60A5FA'),
      orange: colorFromHex('F97316'),
    );
  }

  LinearGradient get primaryGradient => LinearGradient(
        colors: [accent, colorFromHex('8B5CF6')],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  LinearGradient get accentGradient => LinearGradient(
        colors: [accentSecondary, accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

ThemeData buildLightTheme() {
  final palette = AppPalette.light();
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: Brightness.light,
    ).copyWith(
      surface: palette.bg,
      primary: palette.accent,
      secondary: palette.accentSecondary,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: palette.bg,
    dividerColor: palette.surfaceBorder,
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

ThemeData buildDarkTheme() {
  final palette = AppPalette.dark();
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: Brightness.dark,
    ).copyWith(
      surface: palette.bg,
      primary: palette.accent,
      secondary: palette.accentSecondary,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: palette.bg,
    dividerColor: palette.surfaceBorder,
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

Color colorFromHex(String hex) {
  final cleaned = hex.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
  if (cleaned.length == 3) {
    final r = cleaned[0];
    final g = cleaned[1];
    final b = cleaned[2];
    return colorFromHex('FF$r$r$g$g$b$b');
  }
  if (cleaned.length == 6) {
    return colorFromHex('FF$cleaned');
  }
  final value = int.tryParse(cleaned, radix: 16) ?? 0xFF000000;
  return Color(value);
}

class DelayedReveal extends StatefulWidget {
  const DelayedReveal({
    super.key,
    required this.child,
    required this.visible,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, 0.08),
    this.beginScale = 1,
    this.endScale = 1,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final bool visible;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final double beginScale;
  final double endScale;
  final Curve curve;

  @override
  State<DelayedReveal> createState() => _DelayedRevealState();
}

class _DelayedRevealState extends State<DelayedReveal> {
  bool _show = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant DelayedReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      _schedule();
    }
  }

  void _schedule() {
    _generation += 1;
    final generation = _generation;
    if (!widget.visible) {
      setState(() => _show = false);
      return;
    }
    Future<void>.delayed(widget.delay, () {
      if (!mounted || generation != _generation) {
        return;
      }
      setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      curve: widget.curve,
      opacity: _show ? 1 : 0,
      child: AnimatedSlide(
        duration: widget.duration,
        curve: widget.curve,
        offset: _show ? Offset.zero : widget.beginOffset,
        child: AnimatedScale(
          duration: widget.duration,
          curve: widget.curve,
          scale: _show ? widget.endScale : widget.beginScale,
          child: widget.child,
        ),
      ),
    );
  }
}
