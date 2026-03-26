import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_style.dart';
import 'quiz_models.dart';
import 'result_view.dart';

class QuizView extends StatefulWidget {
  const QuizView({
    super.key,
    required this.viewModel,
  });

  final QuizViewModel viewModel;

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  double _cardScale = 0.96;
  double _cardOpacity = 0;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cardScale = 1;
        _cardOpacity = 1;
      });
    });
  }

  Future<void> _checkAnswer() async {
    if (_isTransitioning) {
      return;
    }

    widget.viewModel.checkAnswer();
    if (widget.viewModel.selectedAnswer ==
        widget.viewModel.currentQuestion?.correctAnswer) {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _nextQuestion() async {
    if (_isTransitioning) {
      return;
    }

    setState(() => _isTransitioning = true);
    widget.viewModel.nextQuestion();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isTransitioning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final palette = AppPalette.of(context);

        if (widget.viewModel.isFinished) {
          return ResultView(
            viewModel: widget.viewModel,
            onMainMenu: () => Navigator.of(context).pop(),
          );
        }

        final question = widget.viewModel.currentQuestion;
        if (question == null) {
          return Scaffold(
            body: ColoredBox(
              color: palette.bg,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Scaffold(
          body: AnimatedOpacity(
            duration: const Duration(milliseconds: 350),
            opacity: _cardOpacity,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              scale: _cardScale,
              child: ColoredBox(
                color: palette.bg,
                child: SafeArea(
                  child: Column(
                    children: [
                      _HeaderBar(
                        timerText: widget.viewModel.timerText,
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ProgressSection(
                                progressText: widget.viewModel.progressText,
                                progress: widget.viewModel.progress,
                              ),
                              const SizedBox(height: 24),
                              _QuestionCard(
                                index: widget.viewModel.currentIndex + 1,
                                text: question.question,
                              ),
                              const SizedBox(height: 24),
                              Column(
                                children: [
                                  for (final answer
                                      in widget.viewModel.shuffledAnswers) ...[
                                    AnswerButton(
                                      text: answer,
                                      state: widget.viewModel.answerStateFor(
                                        answer,
                                      ),
                                      isChecked:
                                          widget.viewModel.isChecked || _isTransitioning,
                                      onTap: () => widget.viewModel.selectAnswer(
                                        answer,
                                      ),
                                    ),
                                    if (answer !=
                                        widget.viewModel.shuffledAnswers.last)
                                      const SizedBox(height: 12),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'Ellenőrzés',
                                      icon: widget.viewModel.isChecked
                                          ? Icons.verified_rounded
                                          : Icons.verified_outlined,
                                      enabled: widget.viewModel.selectedAnswer != null &&
                                          !widget.viewModel.isChecked &&
                                          !_isTransitioning,
                                      variant: widget.viewModel.isChecked
                                          ? _ActionButtonVariant.success
                                          : widget.viewModel.selectedAnswer != null
                                              ? _ActionButtonVariant.gradient
                                              : _ActionButtonVariant.surface,
                                      foregroundColor: widget.viewModel.isChecked
                                          ? palette.bg
                                          : widget.viewModel.selectedAnswer != null
                                              ? Colors.white
                                              : palette.primaryText,
                                      onTap: _checkAnswer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ActionButton(
                                      label: widget.viewModel.currentIndex + 1 >=
                                              widget.viewModel.questions.length
                                          ? 'Befejezés'
                                          : 'Következő',
                                      icon: widget.viewModel.currentIndex + 1 >=
                                              widget.viewModel.questions.length
                                          ? Icons.flag_rounded
                                          : Icons.arrow_forward_rounded,
                                      enabled: !((widget.viewModel.selectedAnswer == null &&
                                              !widget.viewModel.isChecked) ||
                                          _isTransitioning),
                                      variant: widget.viewModel.selectedAnswer != null
                                          ? _ActionButtonVariant.gradient
                                          : _ActionButtonVariant.surface,
                                      foregroundColor:
                                          widget.viewModel.selectedAnswer != null
                                              ? Colors.white
                                              : palette.secondaryText,
                                      onTap: _nextQuestion,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.timerText,
    required this.onBack,
  });

  final String timerText;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Row(
              children: [
                Icon(
                  Icons.chevron_left_rounded,
                  size: 18,
                  color: palette.secondaryText,
                ),
                Text(
                  'Menü',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: palette.surfaceBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: palette.surfaceBorder),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 11,
                  color: palette.accentSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  timerText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: palette.primaryText,
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

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.progressText,
    required this.progress,
  });

  final String progressText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Kérdések',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.secondaryText,
              ),
            ),
            const Spacer(),
            Text(
              progressText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.accentSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(color: palette.surfaceBg),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0).toDouble(),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: palette.primaryGradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surfaceBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kérdés  $index',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: palette.accentSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: palette.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class AnswerButton extends StatefulWidget {
  const AnswerButton({
    super.key,
    required this.text,
    required this.state,
    required this.isChecked,
    required this.onTap,
  });

  final String text;
  final AnswerState state;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    final idleBg = palette.isDark
        ? Colors.white.withOpacity(0.05)
        : colorFromHex('1C1C1E').withOpacity(0.04);
    final idleBorder = palette.isDark
        ? Colors.white.withOpacity(0.10)
        : colorFromHex('1C1C1E').withOpacity(0.12);
    final idleText = palette.isDark
        ? Colors.white.withOpacity(0.75)
        : colorFromHex('1C1C1E').withOpacity(0.85);

    final backgroundColor = switch (widget.state) {
      AnswerState.idle => idleBg,
      AnswerState.selected => palette.warning.withOpacity(0.15),
      AnswerState.correct => palette.success.withOpacity(0.18),
      AnswerState.wrong => palette.error.withOpacity(0.18),
    };

    final borderColor = switch (widget.state) {
      AnswerState.idle => idleBorder,
      AnswerState.selected => palette.warning.withOpacity(0.8),
      AnswerState.correct => palette.success,
      AnswerState.wrong => palette.error,
    };

    final textColor = switch (widget.state) {
      AnswerState.idle => idleText,
      AnswerState.selected => palette.warningText,
      AnswerState.correct => palette.successText,
      AnswerState.wrong => palette.errorText,
    };

    final IconData? trailingIcon = switch (widget.state) {
      AnswerState.correct => Icons.check_circle_rounded,
      AnswerState.wrong => Icons.cancel_rounded,
      _ => null,
    };

    return GestureDetector(
      onTapDown: widget.isChecked
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: widget.isChecked
          ? null
          : (_) => setState(() => _pressed = false),
      onTap: widget.isChecked ? null : widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.97 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: widget.state == AnswerState.idle ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor.withOpacity(0.9),
                  border: Border.all(color: borderColor.withOpacity(0.6)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  size: 18,
                  color: widget.state == AnswerState.correct
                      ? palette.success
                      : palette.error,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ActionButtonVariant { surface, gradient, success }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.variant,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final _ActionButtonVariant variant;
  final Color foregroundColor;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    final gradient = switch (variant) {
      _ActionButtonVariant.gradient => palette.primaryGradient,
      _ActionButtonVariant.success => LinearGradient(
          colors: [palette.success, palette.success],
        ),
      _ActionButtonVariant.surface => null,
    };

    final backgroundColor =
        variant == _ActionButtonVariant.surface ? palette.surfaceBg : null;

    final shadow = variant == _ActionButtonVariant.gradient && enabled
        ? [
            BoxShadow(
              color: palette.accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
        : const <BoxShadow>[];

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? () => onTap?.call() : null,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled && variant != _ActionButtonVariant.surface
                  ? Colors.transparent
                  : palette.surfaceBorder,
            ),
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
