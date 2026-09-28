import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_radius.dart';

import '../../../../core/theme/app_spacing.dart';

import '../../data/models/question_answer_result_model.dart';
import '../../data/models/question_model.dart';
import '../providers/question_provider.dart';

import '../../data/models/question_option_model.dart';

class QuestionPracticeScreen extends ConsumerStatefulWidget {

  const QuestionPracticeScreen({

    required this.questions,
    required this.examId,

    this.title = 'Practice',

    this.duration = const Duration(minutes: 30),

    super.key,

  });

  final List<Question> questions;

  final String title;

  final String examId;

  final Duration duration;

  @override
ConsumerState<QuestionPracticeScreen> createState() =>
    _QuestionPracticeScreenState();

}

class _QuestionPracticeScreenState extends ConsumerState<QuestionPracticeScreen> {

  late final List<Question> _questions;

  final Map<String, String> _selectedAnswers = <String, String>{};

  final Set<String> _bookmarkedQuestionIds = <String>{};

  final Set<String> _checkedQuestionIds = <String>{};
  final Set<String> _checkingQuestionIds = <String>{};
  final Map<String, QuestionAnswerResult> _answerResults =
      <String, QuestionAnswerResult>{};

  late Duration _remainingTime;

  Timer? _timer;

  int _currentIndex = 0;

  bool _isSubmitting = false;

  Question get _currentQuestion => _questions[_currentIndex];

  bool get _isLastQuestion => _currentIndex == _questions.length - 1;

  bool get _isFirstQuestion => _currentIndex == 0;

  int get _answeredCount => _selectedAnswers.length;

  String? get _selectedOptionId => _selectedAnswers[_currentQuestion.id];

  bool get _isCurrentChecked =>

      _checkedQuestionIds.contains(_currentQuestion.id);

  @override

  void initState() {

    super.initState();

    _questions = List<Question>.from(widget.questions);

    _remainingTime = widget.duration;

    if (_questions.isNotEmpty) {

      _startTimer();

    }

  }

  @override

  void dispose() {

    _timer?.cancel();

    super.dispose();

  }

  void _startTimer() {

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {

      if (!mounted) {

        return;

      }

      if (_remainingTime.inSeconds <= 1) {

        _timer?.cancel();

        setState(() {

          _remainingTime = Duration.zero;

        });

        _showTimeUpDialog();

        return;

      }

      setState(() {

        _remainingTime -= const Duration(seconds: 1);

      });

    });

  }

  Future<void> _showTimeUpDialog() async {

    if (!mounted || _isSubmitting) {

      return;

    }

    await showDialog<void>(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: const Text('Time is up'),

          content: const Text(

            'Your practice timer has ended. Review the questions you '

            'answered and submit your practice.',

          ),

          actions: [

            FilledButton(

              onPressed: () {

                Navigator.of(context).pop();

                _showSubmitConfirmation();

              },

              child: const Text('Submit'),

            ),

          ],

        );

      },

    );

  }

  void _selectOption(String optionId) {

    if (_isCurrentChecked) {

      return;

    }

    setState(() {

      _selectedAnswers[_currentQuestion.id] = optionId;

    });

  }

  void _clearSelection() {

    if (_isCurrentChecked) {

      return;

    }

    setState(() {

      _selectedAnswers.remove(_currentQuestion.id);

    });

  }

  Future<void> _checkAnswer() async {
    final selectedOptionId = _selectedOptionId;

    if (selectedOptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an answer first.'),
        ),
      );
      return;
    }

    final questionId = _currentQuestion.id;

    if (_answerResults.containsKey(questionId) ||
        _checkingQuestionIds.contains(questionId)) {
      return;
    }

    setState(() {
      _checkingQuestionIds.add(questionId);
    });

    try {
      final result = await ref
          .read(questionRepositoryProvider)
          .checkAnswer(
            questionId: questionId,
            selectedOptionId: selectedOptionId,
            examId: widget.examId,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _checkingQuestionIds.remove(questionId);
        _answerResults[questionId] = result;
        _checkedQuestionIds.add(questionId);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _checkingQuestionIds.remove(questionId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _toggleBookmark() {

    setState(() {

      if (_bookmarkedQuestionIds.contains(_currentQuestion.id)) {

        _bookmarkedQuestionIds.remove(_currentQuestion.id);

      } else {

        _bookmarkedQuestionIds.add(_currentQuestion.id);

      }

    });

  }

  void _goToNext() {

    if (_isLastQuestion) {

      _showSubmitConfirmation();

      return;

    }

    setState(() {

      _currentIndex++;

    });

  }

  void _goToPrevious() {

    if (_isFirstQuestion) {

      return;

    }

    setState(() {

      _currentIndex--;

    });

  }

  void _goToQuestion(int index) {

    if (index < 0 || index >= _questions.length) {

      return;

    }

    setState(() {

      _currentIndex = index;

    });

    Navigator.of(context).maybePop();

  }

  Future<void> _openQuestionPalette() async {

    await showModalBottomSheet<void>(

      context: context,

      showDragHandle: true,

      backgroundColor: Colors.white,

      builder: (context) {

        return SafeArea(

          child: Padding(

            padding: const EdgeInsets.fromLTRB(

              AppSpacing.lg,

              AppSpacing.sm,

              AppSpacing.lg,

              AppSpacing.lg,

            ),

            child: Column(

              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(

                  children: [

                    Text(

                      'Question Navigator',

                      style: Theme.of(context).textTheme.titleLarge?.copyWith(

                            color: AppColors.textPrimary,

                            fontWeight: FontWeight.w800,

                          ),

                    ),

                    const Spacer(),

                    Text(

                      '$_answeredCount/${_questions.length} answered',

                      style: Theme.of(context).textTheme.bodySmall?.copyWith(

                            color: AppColors.textSecondary,

                            fontWeight: FontWeight.w600,

                          ),

                    ),

                  ],

                ),

                const SizedBox(height: AppSpacing.md),

                Row(

                  children: [

                    _PaletteLegend(

                      color: AppColors.primary,

                      label: 'Current',

                    ),

                    const SizedBox(width: AppSpacing.md),

                    _PaletteLegend(

                      color: AppColors.primary.withValues(alpha: 0.15),

                      label: 'Answered',

                    ),

                    const SizedBox(width: AppSpacing.md),

                    _PaletteLegend(

                      color: AppColors.surface,

                      label: 'Unanswered',

                    ),

                  ],

                ),

                const SizedBox(height: AppSpacing.lg),

                ConstrainedBox(

                  constraints: BoxConstraints(

                    maxHeight: MediaQuery.sizeOf(context).height * 0.55,

                  ),

                  child: SingleChildScrollView(

                    child: Wrap(

                      spacing: AppSpacing.sm,

                      runSpacing: AppSpacing.sm,

                      children: List.generate(

                        _questions.length,

                        (index) {

                          final question = _questions[index];

                          final isCurrent = index == _currentIndex;

                          final isAnswered =

                              _selectedAnswers.containsKey(question.id);

                          final isBookmarked =

                              _bookmarkedQuestionIds.contains(question.id);

                          return _PaletteButton(

                            number: index + 1,

                            isCurrent: isCurrent,

                            isAnswered: isAnswered,

                            isBookmarked: isBookmarked,

                            onTap: () => _goToQuestion(index),

                          );

                        },

                      ),

                    ),

                  ),

                ),

              ],

            ),

          ),

        );

      },

    );

  }

  Future<void> _showSubmitConfirmation() async {

    if (_isSubmitting) {

      return;

    }

    final unansweredCount = _questions.length - _answeredCount;

    final shouldSubmit = await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text('Submit practice?'),

          content: Text(

            unansweredCount == 0

                ? 'You have answered all ${_questions.length} questions.'

                : 'You have $unansweredCount unanswered '

                    '${unansweredCount == 1 ? 'question' : 'questions'}. '

                    'Do you want to submit anyway?',

          ),

          actions: [

            TextButton(

              onPressed: () => Navigator.of(context).pop(false),

              child: const Text('Continue'),

            ),

            FilledButton(

              onPressed: () => Navigator.of(context).pop(true),

              child: const Text('Submit'),

            ),

          ],

        );

      },

    );

    if (shouldSubmit == true && mounted) {

      _submitPractice();

    }

  }

  Future<void> _submitPractice() async {

    if (_isSubmitting) {

      return;

    }

    _timer?.cancel();

    setState(() {

      _isSubmitting = true;

    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) {

      return;

    }

    setState(() {

      _isSubmitting = false;

    });

    await showDialog<void>(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: const Text('Practice submitted'),

          content: Text(

            'You answered $_answeredCount of ${_questions.length} questions.\n\n'

            'The practice scoring endpoint is not part of the current '

            'question-bank API yet.',

          ),

          actions: [

            FilledButton(

              onPressed: () {

                Navigator.of(context).pop();

                Navigator.of(context).pop();

              },

              child: const Text('Done'),

            ),

          ],

        );

      },

    );

  }

  String _formatDuration(Duration duration) {

    final hours = duration.inHours;

    final minutes = duration.inMinutes.remainder(60);

    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {

      return '${hours.toString().padLeft(2, '0')}:'

          '${minutes.toString().padLeft(2, '0')}:'

          '${seconds.toString().padLeft(2, '0')}';

    }

    return '${minutes.toString().padLeft(2, '0')}:'

        '${seconds.toString().padLeft(2, '0')}';

  }

  @override

  Widget build(BuildContext context) {

    if (_questions.isEmpty) {

      return const Scaffold(

        body: Center(

          child: Text('No questions available for practice.'),

        ),

      );

    }

    final currentQuestion = _currentQuestion;

    final selectedOptionId = _selectedOptionId;
    final answerResult = _answerResults[currentQuestion.id];
    final isChecking =
        _checkingQuestionIds.contains(currentQuestion.id);

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(

        leading: IconButton(

          tooltip: 'Back',

          onPressed: () => Navigator.of(context).maybePop(),

          icon: const Icon(Icons.arrow_back_rounded),

        ),

        title: Text(widget.title),

        actions: [

          IconButton(

            tooltip: _bookmarkedQuestionIds.contains(currentQuestion.id)

                ? 'Remove bookmark'

                : 'Bookmark',

            onPressed: _toggleBookmark,

            icon: Icon(

              _bookmarkedQuestionIds.contains(currentQuestion.id)

                  ? Icons.bookmark_rounded

                  : Icons.bookmark_border_rounded,

            ),

          ),

          IconButton(

            tooltip: 'More',

            onPressed: _showPracticeMenu,

            icon: const Icon(Icons.more_vert_rounded),

          ),

        ],

      ),

      body: SafeArea(

        child: Column(

          children: [

            _PracticeHeader(

              question: currentQuestion,

              questionNumber: _currentIndex + 1,

              totalQuestions: _questions.length,

              remainingTime: _formatDuration(_remainingTime),

              answeredCount: _answeredCount,

            ),

            Expanded(

              child: SingleChildScrollView(

                padding: const EdgeInsets.fromLTRB(

                  AppSpacing.md,

                  AppSpacing.md,

                  AppSpacing.md,

                  AppSpacing.lg,

                ),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    _QuestionCard(

                      question: currentQuestion,

                      questionNumber: _currentIndex + 1,

                      totalQuestions: _questions.length,

                    ),

                    const SizedBox(height: AppSpacing.md),

                    _OptionsSection(
                        question: currentQuestion,
                        selectedOptionId: selectedOptionId,
                        correctOptionId: answerResult?.correctOptionId,
                        checked: _isCurrentChecked,
                        onOptionSelected: _selectOption,
                      ),

                    const SizedBox(height: AppSpacing.md),

                    _AnswerActions(
                        hasSelection: selectedOptionId != null,
                        checked: _isCurrentChecked,
                        isChecking: isChecking,
                        onClear: _clearSelection,
                        onCheck: _checkAnswer,
                      ),

                    if (_isCurrentChecked) ...[
                      const SizedBox(height: AppSpacing.md),
                      _AnswerResultCard(
                        result: answerResult,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ExplanationCard(
                        explanation:
                            answerResult?.explanation ??
                            currentQuestion.explanation,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                  ],

                ),

              ),

            ),

            _PracticeBottomBar(

              isFirstQuestion: _isFirstQuestion,

              isLastQuestion: _isLastQuestion,

              isSubmitting: _isSubmitting,

              onPrevious: _goToPrevious,

              onPalette: _openQuestionPalette,

              onNext: _goToNext,

            ),

          ],

        ),

      ),

    );

  }

  Future<void> _showPracticeMenu() async {

    await showModalBottomSheet<void>(

      context: context,

      showDragHandle: true,

      backgroundColor: Colors.white,

      builder: (context) {

        return SafeArea(

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              ListTile(

                leading: const Icon(Icons.grid_view_rounded),

                title: const Text('Question navigator'),

                onTap: () {

                  Navigator.of(context).pop();

                  _openQuestionPalette();

                },

              ),

              ListTile(

                leading: const Icon(Icons.flag_outlined),

                title: const Text('Submit practice'),

                onTap: () {

                  Navigator.of(context).pop();

                  _showSubmitConfirmation();

                },

              ),

              const SizedBox(height: AppSpacing.sm),

            ],

          ),

        );

      },

    );

  }

}

class _PracticeHeader extends StatelessWidget {

  const _PracticeHeader({

    required this.question,

    required this.questionNumber,

    required this.totalQuestions,

    required this.remainingTime,

    required this.answeredCount,

  });

  final Question question;

  final int questionNumber;

  final int totalQuestions;

  final String remainingTime;

  final int answeredCount;

  @override

  Widget build(BuildContext context) {

    final progress =

        totalQuestions == 0 ? 0.0 : questionNumber / totalQuestions;

    return Container(

      width: double.infinity,

      color: Colors.white,

      padding: const EdgeInsets.fromLTRB(

        AppSpacing.md,

        AppSpacing.xs,

        AppSpacing.md,

        AppSpacing.md,

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Wrap(

            spacing: AppSpacing.xs,

            runSpacing: AppSpacing.xs,

            children: [

              _BreadcrumbItem(label: question.subjectName),

              const _BreadcrumbSeparator(),

              _BreadcrumbItem(label: question.chapterName),

              const _BreadcrumbSeparator(),

              _BreadcrumbItem(label: question.topicName),

            ],

          ),

          const SizedBox(height: AppSpacing.md),

          Row(

            children: [

              Text(

                'Question $questionNumber of $totalQuestions',

                style: Theme.of(context).textTheme.bodySmall?.copyWith(

                      color: AppColors.textSecondary,

                      fontWeight: FontWeight.w600,

                    ),

              ),

              const Spacer(),

              Icon(

                Icons.timer_outlined,

                size: 19,

                color: remainingTime == '00:00'

                    ? Colors.redAccent

                    : AppColors.primary,

              ),

              const SizedBox(width: AppSpacing.xs),

              Text(

                remainingTime,

                style: Theme.of(context).textTheme.labelLarge?.copyWith(

                      color: remainingTime == '00:00'

                          ? Colors.redAccent

                          : AppColors.textPrimary,

                      fontWeight: FontWeight.w800,

                    ),

              ),

            ],

          ),

          const SizedBox(height: AppSpacing.sm),

          ClipRRect(

            borderRadius: BorderRadius.circular(100),

            child: LinearProgressIndicator(

              value: progress,

              minHeight: 6,

              backgroundColor: AppColors.border,

            ),

          ),

          const SizedBox(height: AppSpacing.xs),

          Align(

            alignment: Alignment.centerRight,

            child: Text(

              '$answeredCount answered',

              style: Theme.of(context).textTheme.labelSmall?.copyWith(

                    color: AppColors.textSecondary,

                    fontWeight: FontWeight.w600,

                  ),

            ),

          ),

        ],

      ),

    );

  }

}

class _BreadcrumbItem extends StatelessWidget {

  const _BreadcrumbItem({

    required this.label,

  });

  final String label;

  @override

  Widget build(BuildContext context) {

    return Text(

      label,

      maxLines: 1,

      overflow: TextOverflow.ellipsis,

      style: Theme.of(context).textTheme.bodySmall?.copyWith(

            color: AppColors.textSecondary,

            fontWeight: FontWeight.w600,

          ),

    );

  }

}

class _BreadcrumbSeparator extends StatelessWidget {

  const _BreadcrumbSeparator();

  @override

  Widget build(BuildContext context) {

    return const Icon(

      Icons.chevron_right_rounded,

      size: 16,

      color: AppColors.textSecondary,

    );

  }

}

class _QuestionCard extends StatelessWidget {

  const _QuestionCard({

    required this.question,

    required this.questionNumber,

    required this.totalQuestions,

  });

  final Question question;

  final int questionNumber;

  final int totalQuestions;

  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(AppSpacing.md),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(AppRadius.lg),

        border: Border.all(color: AppColors.border),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              _DifficultyBadge(difficulty: question.difficulty),

              const Spacer(),

              Text(

                '+${question.marks} / -${question.negativeMarks}',

                style: Theme.of(context).textTheme.labelMedium?.copyWith(

                      color: AppColors.textSecondary,

                      fontWeight: FontWeight.w700,

                    ),

              ),

            ],

          ),

          const SizedBox(height: AppSpacing.md),

          Text(

            question.questionText,

            style: Theme.of(context).textTheme.titleLarge?.copyWith(

                  color: AppColors.textPrimary,

                  fontWeight: FontWeight.w800,

                  height: 1.45,

                ),

          ),

          if (question.imageUrl != null &&

              question.imageUrl!.trim().isNotEmpty) ...[

            const SizedBox(height: AppSpacing.md),

            ClipRRect(

              borderRadius: BorderRadius.circular(AppRadius.md),

              child: Image.network(

                question.imageUrl!,

                width: double.infinity,

                fit: BoxFit.contain,

                errorBuilder: (_, __, ___) {

                  return Container(

                    height: 120,

                    alignment: Alignment.center,

                    decoration: BoxDecoration(

                      color: AppColors.surface,

                      borderRadius: BorderRadius.circular(AppRadius.md),

                    ),

                    child: const Text('Unable to load question image'),

                  );

                },

              ),

            ),

          ],

          const SizedBox(height: AppSpacing.md),

          Text(

            'Question $questionNumber of $totalQuestions',

            style: Theme.of(context).textTheme.labelSmall?.copyWith(

                  color: AppColors.textSecondary,

                ),

          ),

        ],

      ),

    );

  }

}

class _OptionsSection extends StatelessWidget {
  const _OptionsSection({
    required this.question,
    required this.selectedOptionId,
    required this.correctOptionId,
    required this.checked,
    required this.onOptionSelected,
  });

  final Question question;
  final String? selectedOptionId;
  final String? correctOptionId;
  final bool checked;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          checked ? 'Answer' : 'Choose your answer',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...question.options.map(
          (option) {
            final isSelected = option.id == selectedOptionId;
            final isCorrect = checked && option.id == correctOptionId;
            final isIncorrect =
                checked &&
                option.id == selectedOptionId &&
                option.id != correctOptionId;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OptionCard(
                option: option,
                isSelected: isSelected,
                isCorrect: isCorrect,
                isIncorrect: isIncorrect,
                enabled: !checked,
                onTap: () => onOptionSelected(option.id),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isIncorrect,
    required this.enabled,
    required this.onTap,
  });

  final QuestionOption option;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = String.fromCharCode(64 + option.optionOrder);

    Color backgroundColor = Colors.white;
    Color borderColor = AppColors.border;
    Color labelBackground = AppColors.primary.withValues(alpha: 0.08);
    Color labelColor = AppColors.primary;
    IconData? trailingIcon;
    Color? trailingColor;

    if (isCorrect) {
      backgroundColor = Colors.green.withValues(alpha: 0.08);
      borderColor = Colors.green.shade600;
      labelBackground = Colors.green.shade600;
      labelColor = Colors.white;
      trailingIcon = Icons.check_circle_rounded;
      trailingColor = Colors.green.shade700;
    } else if (isIncorrect) {
      backgroundColor = Colors.red.withValues(alpha: 0.08);
      borderColor = Colors.red.shade600;
      labelBackground = Colors.red.shade600;
      labelColor = Colors.white;
      trailingIcon = Icons.cancel_rounded;
      trailingColor = Colors.red.shade700;
    } else if (isSelected) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.06);
      borderColor = AppColors.primary;
      labelBackground = AppColors.primary;
      labelColor = Colors.white;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: borderColor,
              width:
                  isSelected || isCorrect || isIncorrect ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: labelBackground,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    option.optionText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight:
                              isSelected || isCorrect || isIncorrect
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                          height: 1.4,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (trailingIcon != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(
                    trailingIcon,
                    color: trailingColor,
                    size: 22,
                  ),
                )
              else
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 23,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerActions extends StatelessWidget {
  const _AnswerActions({
    required this.hasSelection,
    required this.checked,
    required this.isChecking,
    required this.onClear,
    required this.onCheck,
  });

  final bool hasSelection;
  final bool checked;
  final bool isChecking;
  final VoidCallback onClear;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                hasSelection && !checked && !isChecking
                    ? onClear
                    : null,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Clear Selection'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: FilledButton.icon(
            onPressed:
                hasSelection && !checked && !isChecking
                    ? onCheck
                    : null,
            icon: isChecking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    checked
                        ? Icons.check_circle_outline_rounded
                        : Icons.check_rounded,
                  ),
            label: Text(
              isChecking
                  ? 'Checking...'
                  : checked
                      ? 'Checked'
                      : 'Check Answer',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswerResultCard extends StatelessWidget {
  const _AnswerResultCard({
    required this.result,
  });

  final QuestionAnswerResult? result;

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'Answer checked, but result details are unavailable.',
        ),
      );
    }

    final isCorrect = result!.isCorrect;
    final resultColor =
        isCorrect ? Colors.green.shade700 : Colors.red.shade700;
    final backgroundColor =
        isCorrect
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.red.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: resultColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: resultColor,
            size: 30,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect
                      ? 'Correct answer'
                      : 'Incorrect answer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: resultColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  isCorrect
                      ? 'You earned +${result!.marksAwarded} marks.'
                      : 'You received ${result!.marksAwarded} marks.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
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

class _ExplanationCard extends StatelessWidget {

  const _ExplanationCard({

    required this.explanation,

  });

  final String? explanation;

  @override

  Widget build(BuildContext context) {

    final hasExplanation =

        explanation != null && explanation!.trim().isNotEmpty;

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(AppSpacing.md),

      decoration: BoxDecoration(

        color: AppColors.primary.withValues(alpha: 0.06),

        borderRadius: BorderRadius.circular(AppRadius.lg),

        border: Border.all(

          color: AppColors.primary.withValues(alpha: 0.12),

        ),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                width: 36,

                height: 36,

                alignment: Alignment.center,

                decoration: BoxDecoration(

                  color: AppColors.primary.withValues(alpha: 0.10),

                  shape: BoxShape.circle,

                ),

                child: const Icon(

                  Icons.lightbulb_outline_rounded,

                  color: AppColors.primary,

                  size: 20,

                ),

              ),

              const SizedBox(width: AppSpacing.sm),

              Text(

                'Explanation',

                style: Theme.of(context).textTheme.titleMedium?.copyWith(

                      color: AppColors.textPrimary,

                      fontWeight: FontWeight.w800,

                    ),

              ),

            ],

          ),

          const SizedBox(height: AppSpacing.md),

          Text(

            hasExplanation

                ? explanation!

                : 'No explanation is available for this question yet.',

            style: Theme.of(context).textTheme.bodyLarge?.copyWith(

                  color: AppColors.textPrimary,

                  height: 1.55,

                ),

          ),

        ],

      ),

    );

  }

}

class _PracticeBottomBar extends StatelessWidget {

  const _PracticeBottomBar({

    required this.isFirstQuestion,

    required this.isLastQuestion,

    required this.isSubmitting,

    required this.onPrevious,

    required this.onPalette,

    required this.onNext,

  });

  final bool isFirstQuestion;

  final bool isLastQuestion;

  final bool isSubmitting;

  final VoidCallback onPrevious;

  final VoidCallback onPalette;

  final VoidCallback onNext;

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.fromLTRB(

        AppSpacing.md,

        AppSpacing.sm,

        AppSpacing.md,

        AppSpacing.md,

      ),

      decoration: BoxDecoration(

        color: Colors.white,

        border: Border(

          top: BorderSide(color: AppColors.border),

        ),

      ),

      child: Row(

        children: [

          Expanded(

            child: OutlinedButton.icon(

              onPressed: isFirstQuestion || isSubmitting ? null : onPrevious,

              icon: const Icon(Icons.arrow_back_rounded),

              label: const Text('Previous'),

              style: OutlinedButton.styleFrom(

                minimumSize: const Size.fromHeight(52),

              ),

            ),

          ),

          const SizedBox(width: AppSpacing.sm),

          SizedBox(

            width: 58,

            height: 52,

            child: OutlinedButton(

              onPressed: isSubmitting ? null : onPalette,

              style: OutlinedButton.styleFrom(

                padding: EdgeInsets.zero,

                backgroundColor: AppColors.primary.withValues(alpha: 0.05),

                side: BorderSide(

                  color: AppColors.primary.withValues(alpha: 0.08),

                ),

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(AppRadius.md),

                ),

              ),

              child: const Icon(

                Icons.grid_view_rounded,

                color: AppColors.primary,

              ),

            ),

          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(

            child: FilledButton.icon(

              onPressed: isSubmitting ? null : onNext,

              icon: Icon(

                isLastQuestion

                    ? Icons.check_rounded

                    : Icons.arrow_forward_rounded,

              ),

              label: Text(isLastQuestion ? 'Submit' : 'Next'),

              style: FilledButton.styleFrom(

                minimumSize: const Size.fromHeight(52),

              ),

            ),

          ),

        ],

      ),

    );

  }

}

class _PaletteButton extends StatelessWidget {

  const _PaletteButton({

    required this.number,

    required this.isCurrent,

    required this.isAnswered,

    required this.isBookmarked,

    required this.onTap,

  });

  final int number;

  final bool isCurrent;

  final bool isAnswered;

  final bool isBookmarked;

  final VoidCallback onTap;

  @override

  Widget build(BuildContext context) {

    Color backgroundColor;

    Color textColor;

    Color borderColor;

    if (isCurrent) {

      backgroundColor = AppColors.primary;

      textColor = Colors.white;

      borderColor = AppColors.primary;

    } else if (isAnswered) {

      backgroundColor = AppColors.primary.withValues(alpha: 0.12);

      textColor = AppColors.primary;

      borderColor = AppColors.primary.withValues(alpha: 0.20);

    } else {

      backgroundColor = AppColors.surface;

      textColor = AppColors.textSecondary;

      borderColor = AppColors.border;

    }

    return Stack(

      clipBehavior: Clip.none,

      children: [

        Material(

          color: Colors.transparent,

          child: InkWell(

            onTap: onTap,

            borderRadius: BorderRadius.circular(AppRadius.sm),

            child: Container(

              width: 46,

              height: 46,

              alignment: Alignment.center,

              decoration: BoxDecoration(

                color: backgroundColor,

                borderRadius: BorderRadius.circular(AppRadius.sm),

                border: Border.all(color: borderColor),

              ),

              child: Text(

                '$number',

                style: Theme.of(context).textTheme.labelLarge?.copyWith(

                      color: textColor,

                      fontWeight: FontWeight.w800,

                    ),

              ),

            ),

          ),

        ),

        if (isBookmarked)

          const Positioned(

            right: -3,

            top: -5,

            child: Icon(

              Icons.bookmark_rounded,

              size: 15,

              color: AppColors.primary,

            ),

          ),

      ],

    );

  }

}

class _PaletteLegend extends StatelessWidget {

  const _PaletteLegend({

    required this.color,

    required this.label,

  });

  final Color color;

  final String label;

  @override

  Widget build(BuildContext context) {

    return Row(

      mainAxisSize: MainAxisSize.min,

      children: [

        Container(

          width: 9,

          height: 9,

          decoration: BoxDecoration(

            color: color,

            shape: BoxShape.circle,

          ),

        ),

        const SizedBox(width: 5),

        Text(

          label,

          style: Theme.of(context).textTheme.labelSmall?.copyWith(

                color: AppColors.textSecondary,

              ),

        ),

      ],

    );

  }

}

class _DifficultyBadge extends StatelessWidget {

  const _DifficultyBadge({

    required this.difficulty,

  });

  final String difficulty;

  @override

  Widget build(BuildContext context) {

    final normalized = difficulty.toLowerCase();

    return Container(

      padding: const EdgeInsets.symmetric(

        horizontal: AppSpacing.sm,

        vertical: AppSpacing.xs,

      ),

      decoration: BoxDecoration(

        color: _backgroundColor(normalized),

        borderRadius: BorderRadius.circular(AppRadius.sm),

      ),

      child: Text(

        difficulty.toUpperCase(),

        style: Theme.of(context).textTheme.labelSmall?.copyWith(

              color: _textColor(normalized),

              fontWeight: FontWeight.w800,

              letterSpacing: 0.4,

            ),

      ),

    );

  }

  Color _backgroundColor(String difficulty) {

    switch (difficulty) {

      case 'easy':

        return Colors.green.withValues(alpha: 0.10);

      case 'hard':

        return Colors.red.withValues(alpha: 0.10);

      default:

        return Colors.orange.withValues(alpha: 0.10);

    }

  }

  Color _textColor(String difficulty) {

    switch (difficulty) {

      case 'easy':

        return Colors.green.shade700;

      case 'hard':

        return Colors.red.shade700;

      default:

        return Colors.orange.shade700;

    }

  }

}