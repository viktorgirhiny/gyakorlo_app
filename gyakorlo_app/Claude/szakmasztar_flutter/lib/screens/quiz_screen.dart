import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String themeMode;
  const QuizScreen({super.key, required this.themeMode});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  bool _isTransitioning = false;
  late AnimationController _cardController;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardScale = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    _cardOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
    );
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
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

    if (quiz.isFinished) {
      return ResultScreen(
        key: ValueKey(quiz.restartCount),
        themeMode: widget.themeMode,
        onMainMenu: () => Navigator.pop(context),
      );
    }

    final question = quiz.currentQuestion;
    if (question == null) return const SizedBox();

    return Scaffold(
      backgroundColor: bg,
      body: AnimatedBuilder(
        animation: _cardController,
        builder: (_, child) => Opacity(
          opacity: _cardOpacity.value,
          child: Transform.scale(scale: _cardScale.value, child: child),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, quiz, isDark, primaryText, secondaryText, surfaceBg, surfaceBorder),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProgress(quiz, secondaryText, surfaceBg),
                      const SizedBox(height: 24),
                      _buildQuestionCard(question.question, quiz, primaryText, surfaceBg, surfaceBorder),
                      const SizedBox(height: 24),
                      _buildAnswers(quiz, isDark),
                      const SizedBox(height: 24),
                      _buildActionButtons(quiz, primaryText, secondaryText, surfaceBg, surfaceBorder),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QuizProvider quiz, bool isDark, Color primaryText, Color secondaryText, Color surfaceBg, Color surfaceBorder) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(Icons.chevron_left, size: 20, color: secondaryText),
                Text('Menü', style: TextStyle(color: secondaryText, fontSize: 15)),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: surfaceBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 11, color: AppColors.purpleLight),
                const SizedBox(width: 5),
                Text(
                  quiz.timerText,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(QuizProvider quiz, Color secondaryText, Color surfaceBg) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kérdések', style: TextStyle(color: secondaryText, fontSize: 13)),
            Text(quiz.progressText, style: const TextStyle(color: AppColors.purpleLight, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: quiz.progress,
            backgroundColor: surfaceBg,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(String text, QuizProvider quiz, Color primaryText, Color surfaceBg, Color surfaceBorder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kérdés  ${quiz.currentIndex + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.purpleLight.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswers(QuizProvider quiz, bool isDark) {
    return Column(
      children: quiz.shuffledAnswers.map((answer) {
        final state = quiz.answerStateFor(answer);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AnswerButton(
            text: answer,
            state: state,
            isDisabled: quiz.isChecked || _isTransitioning,
            isDark: isDark,
            onTap: () => setState(() => quiz.selectAnswer(answer)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(QuizProvider quiz, Color primaryText, Color secondaryText, Color surfaceBg, Color surfaceBorder) {
    final isLastQuestion = quiz.currentIndex + 1 >= quiz.questions.length;

    return Row(
      children: [
        // Check button
        Expanded(
          child: GestureDetector(
            onTap: (quiz.selectedAnswer == null || quiz.isChecked || _isTransitioning)
                ? null
                : () => setState(() => quiz.checkAnswer()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                color: quiz.isChecked
                    ? AppColors.green
                    : quiz.selectedAnswer != null
                        ? null
                        : surfaceBg,
                gradient: !quiz.isChecked && quiz.selectedAnswer != null
                    ? AppTheme.purpleGradient
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: quiz.selectedAnswer == null ? surfaceBorder : Colors.transparent,
                ),
              ),
              child: Opacity(
                opacity: quiz.selectedAnswer == null ? 0.45 : 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      quiz.isChecked ? Icons.verified : Icons.verified_outlined,
                      size: 16,
                      color: quiz.isChecked
                          ? const Color(0xFF0D0D14)
                          : quiz.selectedAnswer != null ? Colors.white : primaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ellenőrzés',
                      style: TextStyle(
                        color: quiz.isChecked
                            ? const Color(0xFF0D0D14)
                            : quiz.selectedAnswer != null ? Colors.white : primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Next button
        Expanded(
          child: GestureDetector(
            onTap: (quiz.selectedAnswer == null && !quiz.isChecked) || _isTransitioning
                ? null
                : () {
                    if (_isTransitioning) return;
                    setState(() {
                      _isTransitioning = true;
                      quiz.nextQuestion();
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) setState(() => _isTransitioning = false);
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                gradient: quiz.selectedAnswer != null ? AppTheme.purpleGradient : null,
                color: quiz.selectedAnswer == null ? surfaceBg : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: quiz.selectedAnswer != null ? Colors.transparent : surfaceBorder,
                ),
                boxShadow: quiz.selectedAnswer != null
                    ? [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastQuestion ? 'Befejezés' : 'Következő',
                    style: TextStyle(
                      color: quiz.selectedAnswer != null ? Colors.white : secondaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastQuestion ? Icons.flag : Icons.arrow_forward,
                    size: 16,
                    color: quiz.selectedAnswer != null ? Colors.white : secondaryText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Answer Button ────────────────────────────────────────────────────────────

class _AnswerButton extends StatefulWidget {
  final String text;
  final AnswerState state;
  final bool isDisabled;
  final bool isDark;
  final VoidCallback onTap;
  const _AnswerButton({required this.text, required this.state, required this.isDisabled, required this.isDark, required this.onTap});

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton> {
  bool _pressed = false;

  Color get _bg {
    switch (widget.state) {
      case AnswerState.idle:     return widget.isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF1C1C1E).withOpacity(0.04);
      case AnswerState.selected: return const Color(0xFFFBBF24).withOpacity(0.15);
      case AnswerState.correct:  return const Color(0xFF34D399).withOpacity(0.18);
      case AnswerState.wrong:    return const Color(0xFFF87171).withOpacity(0.18);
    }
  }

  Color get _border {
    switch (widget.state) {
      case AnswerState.idle:     return widget.isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF1C1C1E).withOpacity(0.12);
      case AnswerState.selected: return const Color(0xFFFBBF24).withOpacity(0.8);
      case AnswerState.correct:  return const Color(0xFF34D399);
      case AnswerState.wrong:    return const Color(0xFFF87171);
    }
  }

  Color get _textColor {
    switch (widget.state) {
      case AnswerState.idle:     return widget.isDark ? Colors.white.withOpacity(0.75) : const Color(0xFF1C1C1E).withOpacity(0.85);
      case AnswerState.selected: return widget.isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309);
      case AnswerState.correct:  return widget.isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);
      case AnswerState.wrong:    return widget.isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.isDisabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.isDisabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _border,
              width: widget.state == AnswerState.idle ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _bg.withOpacity(2),
                  shape: BoxShape.circle,
                  border: Border.all(color: _border.withOpacity(0.6)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.state == AnswerState.correct)
                const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 18),
              if (widget.state == AnswerState.wrong)
                const Icon(Icons.cancel, color: Color(0xFFF87171), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
