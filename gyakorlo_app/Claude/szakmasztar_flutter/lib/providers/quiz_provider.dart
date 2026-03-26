import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/stats_manager.dart';

class QuizProvider extends ChangeNotifier {
  List<Question> questions = [];
  int currentIndex = 0;
  String? selectedAnswer;
  bool isChecked = false;
  int score = 0;
  bool isFinished = false;
  List<String> shuffledAnswers = [];
  int elapsedSeconds = 0;
  int finalTime = 0;
  int restartCount = 0;

  List<Question> _allQuestions = [];
  int? _lastLimit;
  Timer? _timer;

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  double get progress =>
      questions.isEmpty ? 0 : currentIndex / questions.length;

  String get progressText => '${currentIndex + 1} / ${questions.length}';

  String get timerText => _formatTime(elapsedSeconds);
  String get finalTimerText => _formatTime(finalTime);

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  AnswerState answerStateFor(String answer) {
    if (!isChecked) {
      return selectedAnswer == answer ? AnswerState.selected : AnswerState.idle;
    }
    if (answer == currentQuestion?.correctAnswer) return AnswerState.correct;
    if (answer == selectedAnswer) return AnswerState.wrong;
    return AnswerState.idle;
  }

  Future<void> loadQuestions() async {
    try {
      final data = await rootBundle.loadString('assets/questions.json');
      final list = jsonDecode(data) as List;
      _allQuestions = list.map((e) => Question.fromJson(e)).toList();
      _allQuestions.shuffle();
      questions = List.from(_allQuestions);
      _refreshShuffled();
      notifyListeners();
    } catch (e) {
      _allQuestions = _fallback();
      questions = List.from(_allQuestions);
      _refreshShuffled();
      notifyListeners();
    }
  }

  void selectAnswer(String answer) {
    if (isChecked) return;
    selectedAnswer = answer;
    notifyListeners();
  }

  void checkAnswer() {
    if (selectedAnswer == null) return;
    isChecked = true;
    if (selectedAnswer == currentQuestion?.correctAnswer) score++;
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex + 1 >= questions.length) {
      _stopTimer();
      finalTime = elapsedSeconds;
      isFinished = true;
      StatsManager.shared.saveResult(score: score, total: questions.length);
      notifyListeners();
    } else {
      currentIndex++;
      selectedAnswer = null;
      isChecked = false;
      _refreshShuffled();
      notifyListeners();
    }
  }

  void restart({int? limit}) {
    final resolvedLimit = limit ?? _lastLimit;
    _lastLimit = resolvedLimit;
    final pool = List<Question>.from(_allQuestions)..shuffle();
    questions = resolvedLimit != null
        ? pool.take(resolvedLimit).toList()
        : pool;
    restartCount++;
    currentIndex = 0;
    selectedAnswer = null;
    isChecked = false;
    score = 0;
    isFinished = false;
    elapsedSeconds = 0;
    finalTime = 0;
    _refreshShuffled();
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _refreshShuffled() {
    shuffledAnswers = List<String>.from(currentQuestion?.answers ?? [])..shuffle();
  }

  List<Question> _fallback() => [
    Question(id: 1, question: 'Mi a 2+2?', answers: ['3','4','5','6'], correctAnswer: '4'),
    Question(id: 2, question: 'Az ég színe?', answers: ['Zöld','Piros','Kék','Sárga'], correctAnswer: 'Kék'),
  ];

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
