import 'package:shared_preferences/shared_preferences.dart';

class StatsManager {
  static final StatsManager shared = StatsManager._();
  StatsManager._();

  static const _totalQuizzesKey   = 'stats_totalQuizzes';
  static const _totalCorrectKey   = 'stats_totalCorrect';
  static const _totalQuestionsKey = 'stats_totalQuestions';
  static const _bestScoreKey      = 'stats_bestScore';
  static const _lastPlayedKey     = 'stats_lastPlayed';
  static const _streakKey         = 'stats_streak';
  static const _bestStreakKey     = 'stats_bestStreak';
  static const _mode10BestKey     = 'stats_mode10best';
  static const _mode25BestKey     = 'stats_mode25best';
  static const _mode50BestKey     = 'stats_mode50best';
  static const _mode100BestKey    = 'stats_mode100best';

  Future<int> get totalQuizzes async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_totalQuizzesKey) ?? 0;
  }

  Future<int> get totalCorrect async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_totalCorrectKey) ?? 0;
  }

  Future<int> get totalQuestions async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_totalQuestionsKey) ?? 0;
  }

  Future<int> get currentStreak async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_streakKey) ?? 0;
  }

  Future<int> get bestStreak async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_bestStreakKey) ?? 0;
  }

  Future<double> get averageScore async {
    final total = await totalQuestions;
    if (total == 0) return 0;
    final correct = await totalCorrect;
    return correct / total;
  }

  Future<double> get bestScore async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble(_bestScoreKey) ?? 0;
  }

  Future<double> bestScoreForMode(int mode) async {
    final p = await SharedPreferences.getInstance();
    final key = _modeKey(mode);
    return key.isEmpty ? 0 : (p.getDouble(key) ?? 0);
  }

  String _modeKey(int mode) {
    switch (mode) {
      case 10:  return _mode10BestKey;
      case 25:  return _mode25BestKey;
      case 50:  return _mode50BestKey;
      case 100: return _mode100BestKey;
      default:  return '';
    }
  }

  Future<void> saveResult({required int score, required int total}) async {
    final p = await SharedPreferences.getInstance();
    final pct = total > 0 ? score / total : 0.0;

    p.setInt(_totalQuizzesKey, (p.getInt(_totalQuizzesKey) ?? 0) + 1);
    p.setInt(_totalCorrectKey, (p.getInt(_totalCorrectKey) ?? 0) + score);
    p.setInt(_totalQuestionsKey, (p.getInt(_totalQuestionsKey) ?? 0) + total);

    final best = p.getDouble(_bestScoreKey) ?? 0;
    if (pct > best) p.setDouble(_bestScoreKey, pct);

    final modeKey = _modeKey(total);
    if (modeKey.isNotEmpty) {
      final modeBest = p.getDouble(modeKey) ?? 0;
      if (pct > modeBest) p.setDouble(modeKey, pct);
    }

    if (pct >= 0.3) await _updateStreak(p);
  }

  Future<void> _updateStreak(SharedPreferences p) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastMs = p.getInt(_lastPlayedKey);

    if (lastMs != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 0) {
        // already played today
      } else if (diff == 1) {
        final newStreak = (p.getInt(_streakKey) ?? 0) + 1;
        p.setInt(_streakKey, newStreak);
        final bestS = p.getInt(_bestStreakKey) ?? 0;
        if (newStreak > bestS) p.setInt(_bestStreakKey, newStreak);
      } else {
        p.setInt(_streakKey, 1);
      }
    } else {
      p.setInt(_streakKey, 1);
      p.setInt(_bestStreakKey, 1);
    }

    p.setInt(_lastPlayedKey, today.millisecondsSinceEpoch);
  }

  Future<void> resetAll() async {
    final p = await SharedPreferences.getInstance();
    for (final key in [
      _totalQuizzesKey, _totalCorrectKey, _totalQuestionsKey,
      _bestScoreKey, _lastPlayedKey, _streakKey, _bestStreakKey,
      _mode10BestKey, _mode25BestKey, _mode50BestKey, _mode100BestKey,
    ]) {
      p.remove(key);
    }
  }
}
