import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Question {
  const Question({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  final int id;
  final String question;
  final List<String> answers;
  final String correctAnswer;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      question: json['question'] as String,
      answers: List<String>.from(json['answers'] as List<dynamic>),
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}

enum AnswerState { idle, selected, correct, wrong }

class StatsManager extends ChangeNotifier {
  StatsManager(this._preferences);

  static const _totalQuizzesKey = 'stats_totalQuizzes';
  static const _totalCorrectKey = 'stats_totalCorrect';
  static const _totalQuestionsKey = 'stats_totalQuestions';
  static const _bestScoreKey = 'stats_bestScore';
  static const _lastPlayedKey = 'stats_lastPlayed';
  static const _streakKey = 'stats_streak';
  static const _bestStreakKey = 'stats_bestStreak';
  static const _mode10BestKey = 'stats_mode10best';
  static const _mode25BestKey = 'stats_mode25best';
  static const _mode50BestKey = 'stats_mode50best';
  static const _mode100BestKey = 'stats_mode100best';

  final SharedPreferences _preferences;

  int get totalQuizzes => _preferences.getInt(_totalQuizzesKey) ?? 0;
  int get totalCorrect => _preferences.getInt(_totalCorrectKey) ?? 0;
  int get totalQuestions => _preferences.getInt(_totalQuestionsKey) ?? 0;
  int get currentStreak => _preferences.getInt(_streakKey) ?? 0;
  int get bestStreak => _preferences.getInt(_bestStreakKey) ?? 0;
  double get bestScore => _preferences.getDouble(_bestScoreKey) ?? 0;

  double get averageScore {
    if (totalQuestions == 0) {
      return 0;
    }
    return totalCorrect / totalQuestions;
  }

  double bestScoreForMode(int mode) {
    switch (mode) {
      case 10:
        return _preferences.getDouble(_mode10BestKey) ?? 0;
      case 25:
        return _preferences.getDouble(_mode25BestKey) ?? 0;
      case 50:
        return _preferences.getDouble(_mode50BestKey) ?? 0;
      case 100:
        return _preferences.getDouble(_mode100BestKey) ?? 0;
      default:
        return 0;
    }
  }

  void saveResult({
    required int score,
    required int total,
  }) {
    _preferences.setInt(_totalQuizzesKey, totalQuizzes + 1);
    _preferences.setInt(_totalCorrectKey, totalCorrect + score);
    _preferences.setInt(_totalQuestionsKey, totalQuestions + total);

    final percentage = total > 0 ? score / total : 0.0;
    if (percentage > bestScore) {
      _preferences.setDouble(_bestScoreKey, percentage);
    }

    final modeKey = switch (total) {
      10 => _mode10BestKey,
      25 => _mode25BestKey,
      50 => _mode50BestKey,
      100 => _mode100BestKey,
      _ => '',
    };

    if (modeKey.isNotEmpty &&
        percentage > (_preferences.getDouble(modeKey) ?? 0)) {
      _preferences.setDouble(modeKey, percentage);
    }

    if (percentage >= 0.0) {
      _updateStreak();
    }

    notifyListeners();
  }

  Future<void> resetAll() async {
    await Future.wait([
      _preferences.remove(_totalQuizzesKey),
      _preferences.remove(_totalCorrectKey),
      _preferences.remove(_totalQuestionsKey),
      _preferences.remove(_bestScoreKey),
      _preferences.remove(_lastPlayedKey),
      _preferences.remove(_streakKey),
      _preferences.remove(_bestStreakKey),
      _preferences.remove(_mode10BestKey),
      _preferences.remove(_mode25BestKey),
      _preferences.remove(_mode50BestKey),
      _preferences.remove(_mode100BestKey),
    ]);
    notifyListeners();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPlayedMillis = _preferences.getInt(_lastPlayedKey);

    if (lastPlayedMillis != null) {
      final lastPlayed = DateTime.fromMillisecondsSinceEpoch(lastPlayedMillis);
      final last = DateTime(lastPlayed.year, lastPlayed.month, lastPlayed.day);
      final diff = today.difference(last).inDays;
      if (diff == 1) {
        final newStreak = currentStreak + 1;
        _preferences.setInt(_streakKey, newStreak);
        if (newStreak > bestStreak) {
          _preferences.setInt(_bestStreakKey, newStreak);
        }
      } else if (diff > 1) {
        _preferences.setInt(_streakKey, 1);
      }
    } else {
      _preferences.setInt(_streakKey, 1);
      _preferences.setInt(_bestStreakKey, 1);
    }

    _preferences.setInt(_lastPlayedKey, now.millisecondsSinceEpoch);
  }
}

class QuizViewModel extends ChangeNotifier {
  QuizViewModel(this._statsManager);

  final StatsManager _statsManager;

  List<Question> questions = <Question>[];
  List<Question> _allQuestions = <Question>[];
  int currentIndex = 0;
  String? selectedAnswer;
  bool isChecked = false;
  int score = 0;
  bool isFinished = false;
  List<String> shuffledAnswers = <String>[];
  int elapsedSeconds = 0;
  int finalTime = 0;
  int restartCount = 0;
  int? _lastLimit;
  Timer? _timer;

  Question? get currentQuestion {
    if (currentIndex < 0 || currentIndex >= questions.length) {
      return null;
    }
    return questions[currentIndex];
  }

  double get progress {
    if (questions.isEmpty) {
      return 0;
    }
    return currentIndex / questions.length;
  }

  String get progressText {
    if (questions.isEmpty) {
      return '0 / 0';
    }
    return '${currentIndex + 1} / ${questions.length}';
  }

  String get timerText => _formatTime(elapsedSeconds);
  String get finalTimerText => _formatTime(finalTime);

  Future<void> loadQuestions() async {
    try {
      final raw = await rootBundle.loadString('assets/questions.json');
      final decoded = jsonDecode(raw) as List<dynamic>;
      _allQuestions = decoded
          .map((item) => Question.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      debugPrint('Failed to load questions.json, using fallback questions.');
      _allQuestions = _fallbackQuestions();
    }

    questions = List<Question>.from(_allQuestions)..shuffle();
    _refreshShuffledAnswers();
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (isChecked) {
      return;
    }
    selectedAnswer = answer;
    notifyListeners();
  }

  void checkAnswer() {
    if (selectedAnswer == null) {
      return;
    }
    isChecked = true;
    if (selectedAnswer == currentQuestion?.correctAnswer) {
      score += 1;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex + 1 >= questions.length) {
      stopTimer();
      finalTime = elapsedSeconds;
      isFinished = true;
      _statsManager.saveResult(score: score, total: questions.length);
      notifyListeners();
      return;
    }

    currentIndex += 1;
    selectedAnswer = null;
    isChecked = false;
    _refreshShuffledAnswers();
    notifyListeners();
  }

  void restart({int? limit}) {
    final resolvedLimit = limit ?? _lastLimit;
    _lastLimit = resolvedLimit;

    final pool = List<Question>.from(_allQuestions)..shuffle();
    questions = resolvedLimit == null
        ? pool
        : pool.take(resolvedLimit).toList(growable: false);

    restartCount += 1;
    currentIndex = 0;
    selectedAnswer = null;
    isChecked = false;
    score = 0;
    isFinished = false;
    elapsedSeconds = 0;
    finalTime = 0;
    _refreshShuffledAnswers();
    startTimer();
    notifyListeners();
  }

  void startTimer() {
    stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds += 1;
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  AnswerState answerStateFor(String answer) {
    if (!isChecked || currentQuestion == null) {
      return selectedAnswer == answer ? AnswerState.selected : AnswerState.idle;
    }
    if (answer == currentQuestion!.correctAnswer) {
      return AnswerState.correct;
    }
    if (answer == selectedAnswer) {
      return AnswerState.wrong;
    }
    return AnswerState.idle;
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void _refreshShuffledAnswers() {
    shuffledAnswers = List<String>.from(currentQuestion?.answers ?? <String>[])
      ..shuffle();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  List<Question> _fallbackQuestions() {
    return const [
      Question(
        id: 1,
        question: 'What is 2 + 2?',
        answers: ['3', '4', '5', '6'],
        correctAnswer: '4',
      ),
      Question(
        id: 2,
        question: 'What color is the sky?',
        answers: ['Green', 'Red', 'Blue', 'Yellow'],
        correctAnswer: 'Blue',
      ),
      Question(
        id: 3,
        question: 'How many days in a week?',
        answers: ['5', '6', '7', '8'],
        correctAnswer: '7',
      ),
    ];
  }
}
