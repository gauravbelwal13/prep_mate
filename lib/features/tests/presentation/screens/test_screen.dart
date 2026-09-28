import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_radius.dart';

import '../../../../core/theme/app_spacing.dart';

import '../../data/models/attempt_model.dart';
import '../../data/models/test_question_model.dart';

import '../../data/repositories/test_repository.dart';

import '../providers/test_provider.dart';
import '../../../../routing/app_router.dart';

class TestScreen extends ConsumerStatefulWidget {

  const TestScreen({

    required this.testId,

    required this.attemptId,

    this.title = 'Test',

    super.key,

  });

  final String testId;

  final String attemptId;

  final String title;

  @override

  ConsumerState<TestScreen> createState() => _TestScreenState();

}

class _TestScreenState extends ConsumerState<TestScreen> {

  List<TestQuestionModel> _questions = [];

  final Map<String, String> _selectedAnswers = {};

  int _currentIndex = 0;

  int _remainingSeconds = 0;

  Timer? _timer;

  bool _isLoading = true;

  bool _isSubmitting = false;

  String? _errorMessage;

  TestQuestionModel get _currentQuestion =>

      _questions[_currentIndex];

  bool get _isLastQuestion =>

      _currentIndex == _questions.length - 1;

  bool get _isFirstQuestion =>

      _currentIndex == 0;

  int get _answeredCount =>

      _selectedAnswers.length;

  @override

  void initState() {

    super.initState();

    _loadTest();

  }

  @override

  void dispose() {

    _timer?.cancel();

    super.dispose();

  }

  Future<void> _loadTest() async {

    try {

      final questions = await ref.read(

        testQuestionsProvider(widget.testId).future,

      );

      final test = await ref.read(

        testProvider(widget.testId).future,

      );

      if (!mounted) {

        return;

      }

      if (questions.isEmpty) {

        setState(() {

          _isLoading = false;

          _errorMessage = 'No questions are available for this test.';

        });

        return;

      }

      setState(() {

        _questions = questions;

        _remainingSeconds = test.durationMinutes * 60;

        _isLoading = false;

      });

      _startTimer();

    } catch (error) {

      if (!mounted) {

        return;

      }

      setState(() {

        _isLoading = false;

        _errorMessage = error

            .toString()

            .replaceFirst('Exception: ', '');

      });

    }

  }

  void _startTimer() {

    _timer?.cancel();

    _timer = Timer.periodic(

      const Duration(seconds: 1),

      (_) {

        if (!mounted || _isSubmitting) {

          return;

        }

        if (_remainingSeconds <= 1) {

          _timer?.cancel();

          setState(() {

            _remainingSeconds = 0;

          });

          _submitAutomatically();

          return;

        }

        setState(() {

          _remainingSeconds--;

        });

      },

    );

  }

  void _selectOption(String optionId) {

    if (_isSubmitting) {

      return;

    }

    setState(() {

      _selectedAnswers[_currentQuestion.questionId] = optionId;

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

  }

  Future<void> _showSubmitConfirmation() async {

    if (_isSubmitting) {

      return;

    }

    final unansweredCount =

        _questions.length - _answeredCount;

    final shouldSubmit = await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text('Submit test?'),

          content: Text(

            unansweredCount == 0

                ? 'You have answered all '

                    '${_questions.length} questions.'

                : 'You have $unansweredCount unanswered '

                    '${unansweredCount == 1 ? 'question' : 'questions'}. '

                    'Do you want to submit anyway?',

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.of(context).pop(false);

              },

              child: const Text('Continue'),

            ),

            FilledButton(

              onPressed: () {

                Navigator.of(context).pop(true);

              },

              child: const Text('Submit'),

            ),

          ],

        );

      },

    );

    if (shouldSubmit == true && mounted) {

      await _submitAttempt();

    }

  }

  Future<void> _submitAutomatically() async {

    if (!mounted || _isSubmitting) {

      return;

    }

    ScaffoldMessenger.of(context)

      ..hideCurrentSnackBar()

      ..showSnackBar(

        const SnackBar(

          content: Text(

            'Time is up. Submitting your test...',

          ),

        ),

      );

    await _submitAttempt();

  }

  Future<void> _submitAttempt() async {

    if (_isSubmitting) {

      return;

    }

    setState(() {

      _isSubmitting = true;

    });

    _timer?.cancel();

    try {

      final answers = _questions.map(

        (question) {

          return TestAnswerSubmission(

            questionId: question.questionId,

            selectedOptionId:

                _selectedAnswers[question.questionId],

          );

        },

      ).toList();

      final result = await ref

          .read(testRepositoryProvider)

          .submitAttempt(

            attemptId: widget.attemptId,

            answers: answers,

          );

      if (!mounted) {

        return;

      }

      await _openResultScreen(result);

    } catch (error) {

      if (!mounted) {

        return;

      }

      setState(() {

        _isSubmitting = false;

      });

      _startTimer();

      ScaffoldMessenger.of(context)

        ..hideCurrentSnackBar()

        ..showSnackBar(

          SnackBar(

            content: Text(

              error.toString().replaceFirst(

                    'Exception: ',

                    '',

                  ),

            ),

          ),

        );

    }

  }

  Future<void> _openResultScreen(
    AttemptResultModel result,
  ) async {
    if (!mounted) {
      return;
    }

    context.pushReplacement(
      AppRoutes.testResultFor(
        testId: widget.testId,
        attemptId: widget.attemptId,
      ),
      extra: result,
    );
  }

  @override

  Widget build(BuildContext context) {

    if (_isLoading) {

      return const Scaffold(

        backgroundColor: AppColors.background,

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }

    if (_errorMessage != null) {

      return Scaffold(

        backgroundColor: AppColors.background,

        appBar: AppBar(

          title: Text(widget.title),

        ),

        body: _ErrorState(

          message: _errorMessage!,

          onRetry: () {

            setState(() {

              _isLoading = true;

              _errorMessage = null;

            });

            _loadTest();

          },

        ),

      );

    }

    if (_questions.isEmpty) {

      return const Scaffold(

        backgroundColor: AppColors.background,

        body: Center(

          child: Text(

            'No questions available for this test.',

          ),

        ),

      );

    }

    final selectedOptionId =

        _selectedAnswers[_currentQuestion.questionId];

    return PopScope(

      canPop: false,

      onPopInvokedWithResult: (didPop, result) {

        if (didPop || _isSubmitting) {

          return;

        }

        _showExitConfirmation();

      },

      child: Scaffold(

        backgroundColor: AppColors.background,

        appBar: AppBar(

          automaticallyImplyLeading: false,

          title: Text(widget.title),

          actions: [

            _TimerBadge(

              remainingSeconds: _remainingSeconds,

            ),

            const SizedBox(

              width: AppSpacing.md,

            ),

          ],

        ),

        body: SafeArea(

          child: Column(

            children: [

              _ProgressHeader(

                currentIndex: _currentIndex,

                totalQuestions: _questions.length,

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

                    crossAxisAlignment:

                        CrossAxisAlignment.start,

                    children: [

                      _QuestionHeader(

                        question: _currentQuestion,

                        questionNumber:

                            _currentIndex + 1,

                        totalQuestions:

                            _questions.length,

                      ),

                      const SizedBox(

                        height: AppSpacing.md,

                      ),

                      _QuestionCard(

                        question: _currentQuestion,

                      ),

                      const SizedBox(

                        height: AppSpacing.md,

                      ),

                      _OptionsSection(

                        question: _currentQuestion,

                        selectedOptionId:

                            selectedOptionId,

                        onOptionSelected:

                            _selectOption,

                      ),

                      const SizedBox(

                        height: AppSpacing.lg,

                      ),

                      _QuestionNavigator(

                        questions: _questions,

                        currentIndex: _currentIndex,

                        selectedAnswers:

                            _selectedAnswers,

                        onQuestionSelected:

                            _goToQuestion,

                      ),

                    ],

                  ),

                ),

              ),

              _BottomNavigation(

                isFirstQuestion: _isFirstQuestion,

                isLastQuestion: _isLastQuestion,

                hasSelectedAnswer:

                    selectedOptionId != null,

                isSubmitting: _isSubmitting,

                onPrevious: _goToPrevious,

                onNext: _goToNext,

                onSubmit:

                    _showSubmitConfirmation,

              ),

            ],

          ),

        ),

      ),

    );

  }

  Future<void> _showExitConfirmation() async {

    final shouldExit = await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text('Leave test?'),

          content: const Text(

            'Your current answers will remain in this '

            'screen, but the attempt will not be submitted.',

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.of(context).pop(false);

              },

              child: const Text('Stay'),

            ),

            FilledButton(

              onPressed: () {

                Navigator.of(context).pop(true);

              },

              child: const Text('Leave'),

            ),

          ],

        );

      },

    );

    if (shouldExit == true && mounted) {

      Navigator.of(context).pop();

    }

  }

}

class _TimerBadge extends StatelessWidget {

  const _TimerBadge({

    required this.remainingSeconds,

  });

  final int remainingSeconds;

  @override

  Widget build(BuildContext context) {

    final minutes = remainingSeconds  ~/ 60;

    final seconds = remainingSeconds % 60;

    final text =

        '${minutes.toString().padLeft(2, '0')}:'

        '${seconds.toString().padLeft(2, '0')}';

    final isLow = remainingSeconds <= 60;

    return Container(

      padding: const EdgeInsets.symmetric(

        horizontal: AppSpacing.md,

        vertical: AppSpacing.sm,

      ),

      decoration: BoxDecoration(

        color: isLow

            ? AppColors.error.withValues(alpha: 0.10)

            : AppColors.primaryLight,

        borderRadius: BorderRadius.circular(

          AppRadius.pill,

        ),

      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(

            Icons.timer_outlined,

            size: 18,

            color: isLow

                ? AppColors.error

                : AppColors.primary,

          ),

          const SizedBox(width: 6),

          Text(

            text,

            style: Theme.of(context)

                .textTheme

                .labelLarge

                ?.copyWith(

                  color: isLow

                      ? AppColors.error

                      : AppColors.primary,

                  fontWeight: FontWeight.w700,

                ),

          ),

        ],

      ),

    );

  }

}

class _ProgressHeader extends StatelessWidget {

  const _ProgressHeader({

    required this.currentIndex,

    required this.totalQuestions,

    required this.answeredCount,

  });

  final int currentIndex;

  final int totalQuestions;

  final int answeredCount;

  @override

  Widget build(BuildContext context) {

    final progress = totalQuestions == 0

        ? 0.0

        : (currentIndex + 1) / totalQuestions;

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(

        AppSpacing.md,

        AppSpacing.sm,

        AppSpacing.md,

        AppSpacing.md,

      ),

      color: Colors.white,

      child: Column(

        children: [

          Row(

            children: [

              Text(

                'Question ${currentIndex + 1} '

                'of $totalQuestions',

                style: Theme.of(context)

                    .textTheme

                    .bodySmall

                    ?.copyWith(

                      color: AppColors.textSecondary,

                      fontWeight: FontWeight.w600,

                    ),

              ),

              const Spacer(),

              Text(

                '$answeredCount answered',

                style: Theme.of(context)

                    .textTheme

                    .bodySmall

                    ?.copyWith(

                      color: AppColors.primary,

                      fontWeight: FontWeight.w600,

                    ),

              ),

            ],

          ),

          const SizedBox(

            height: AppSpacing.sm,

          ),

          ClipRRect(

            borderRadius: BorderRadius.circular(100),

            child: LinearProgressIndicator(

              value: progress,

              minHeight: 6,

              backgroundColor: AppColors.border,

            ),

          ),

        ],

      ),

    );

  }

}

class _QuestionHeader extends StatelessWidget {

  const _QuestionHeader({

    required this.question,

    required this.questionNumber,

    required this.totalQuestions,

  });

  final TestQuestionModel question;

  final int questionNumber;

  final int totalQuestions;

  @override

  Widget build(BuildContext context) {

    return Row(

      children: [

        Container(

          padding: const EdgeInsets.symmetric(

            horizontal: AppSpacing.sm,

            vertical: AppSpacing.xs,

          ),

          decoration: BoxDecoration(

            color: AppColors.primary.withValues(

              alpha: 0.08,

            ),

            borderRadius: BorderRadius.circular(

              AppRadius.sm,

            ),

          ),

          child: Text(

            'Q$questionNumber',

            style: Theme.of(context)

                .textTheme

                .labelLarge

                ?.copyWith(

                  color: AppColors.primary,

                  fontWeight: FontWeight.w700,

                ),

          ),

        ),

        const SizedBox(

          width: AppSpacing.sm,

        ),

        _DifficultyBadge(

          difficulty: question.difficulty,

        ),

        const Spacer(),

        Text(

          '+${question.marks} / '

          '-${question.negativeMarks}',

          style: Theme.of(context)

              .textTheme

              .labelMedium

              ?.copyWith(

                color: AppColors.textSecondary,

                fontWeight: FontWeight.w600,

              ),

        ),

      ],

    );

  }

}

class _QuestionCard extends StatelessWidget {

  const _QuestionCard({

    required this.question,

  });

  final TestQuestionModel question;

  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(

        AppSpacing.lg,

      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(

          AppRadius.lg,

        ),

        border: Border.all(

          color: AppColors.border,

        ),

      ),

      child: Column(

        crossAxisAlignment:

            CrossAxisAlignment.start,

        children: [

          Wrap(

            spacing: AppSpacing.xs,

            runSpacing: AppSpacing.xs,

            children: [

              _MetadataChip(

                icon: Icons.menu_book_rounded,

                label: question.subjectName,

              ),

              _MetadataChip(

                icon: Icons.layers_outlined,

                label: question.chapterName,

              ),

              _MetadataChip(

                icon: Icons.topic_outlined,

                label: question.topicName,

              ),

            ],

          ),

          const SizedBox(

            height: AppSpacing.lg,

          ),

          Text(

            question.questionText,

            style: Theme.of(context)

                .textTheme

                .headlineSmall

                ?.copyWith(

                  color: AppColors.textPrimary,

                  fontWeight: FontWeight.w700,

                  height: 1.45,

                ),

          ),

          if (question.imageUrl != null &&

              question.imageUrl!.trim().isNotEmpty) ...[

            const SizedBox(

              height: AppSpacing.md,

            ),

            ClipRRect(

              borderRadius: BorderRadius.circular(

                AppRadius.md,

              ),

              child: Image.network(

                question.imageUrl!,

                width: double.infinity,

                fit: BoxFit.contain,

                errorBuilder:

                    (_, __, ___) {

                  return Container(

                    height: 120,

                    alignment: Alignment.center,

                    decoration: BoxDecoration(

                      color: AppColors.surface,

                      borderRadius:

                          BorderRadius.circular(

                        AppRadius.md,

                      ),

                    ),

                    child: const Text(

                      'Unable to load question image',

                    ),

                  );

                },

              ),

            ),

          ],

        ],

      ),

    );

  }

}

class _OptionsSection extends StatelessWidget {

  const _OptionsSection({

    required this.question,

    required this.selectedOptionId,

    required this.onOptionSelected,

  });

  final TestQuestionModel question;

  final String? selectedOptionId;

  final ValueChanged<String> onOptionSelected;

  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment:

          CrossAxisAlignment.start,

      children: [

        Text(

          'Choose your answer',

          style: Theme.of(context)

              .textTheme

              .titleMedium

              ?.copyWith(

                color: AppColors.textPrimary,

                fontWeight: FontWeight.w700,

              ),

        ),

        const SizedBox(

          height: AppSpacing.sm,

        ),

        ...question.options.map(

          (option) {

            final isSelected =

                option.id == selectedOptionId;

            return Padding(

              padding: const EdgeInsets.only(

                bottom: AppSpacing.sm,

              ),

              child: _OptionCard(

                option: option,

                isSelected: isSelected,

                onTap: () {

                  onOptionSelected(option.id);

                },

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

    required this.onTap,

  });

  final TestQuestionOption option;

  final bool isSelected;

  final VoidCallback onTap;

  @override

  Widget build(BuildContext context) {

    final label = String.fromCharCode(

      64 + option.optionOrder,

    );

    return Material(

      color: Colors.transparent,

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(

          AppRadius.md,

        ),

        child: AnimatedContainer(

          duration: const Duration(

            milliseconds: 150,

          ),

          width: double.infinity,

          padding: const EdgeInsets.all(

            AppSpacing.md,

          ),

          decoration: BoxDecoration(

            color: isSelected

                ? AppColors.primary.withValues(

                    alpha: 0.06,

                  )

                : Colors.white,

            borderRadius: BorderRadius.circular(

              AppRadius.md,

            ),

            border: Border.all(

              color: isSelected

                  ? AppColors.primary

                  : AppColors.border,

              width: isSelected ? 1.5 : 1,

            ),

          ),

          child: Row(

            crossAxisAlignment:

                CrossAxisAlignment.start,

            children: [

              AnimatedContainer(

                duration: const Duration(

                  milliseconds: 150,

                ),

                width: 36,

                height: 36,

                alignment: Alignment.center,

                decoration: BoxDecoration(

                  color: isSelected

                      ? AppColors.primary

                      : AppColors.surface,

                  shape: BoxShape.circle,

                  border: Border.all(

                    color: isSelected

                        ? AppColors.primary

                        : AppColors.border,

                  ),

                ),

                child: Text(

                  label,

                  style: Theme.of(context)

                      .textTheme

                      .titleSmall

                      ?.copyWith(

                        color: isSelected

                            ? Colors.white

                            : AppColors.primary,

                        fontWeight: FontWeight.w700,

                      ),

                ),

              ),

              const SizedBox(

                width: AppSpacing.md,

              ),

              Expanded(

                child: Padding(

                  padding: const EdgeInsets.only(

                    top: 6,

                  ),

                  child: Text(

                    option.optionText,

                    style: Theme.of(context)

                        .textTheme

                        .bodyLarge

                        ?.copyWith(

                          color:

                              AppColors.textPrimary,

                          fontWeight: isSelected

                              ? FontWeight.w600

                              : FontWeight.w400,

                          height: 1.4,

                        ),

                  ),

                ),

              ),

              if (isSelected)

                const Padding(

                  padding: EdgeInsets.only(top: 5),

                  child: Icon(

                    Icons.check_circle_rounded,

                    color: AppColors.primary,

                    size: 22,

                  ),

                ),

            ],

          ),

        ),

      ),

    );

  }

}

class _QuestionNavigator extends StatelessWidget {

  const _QuestionNavigator({

    required this.questions,

    required this.currentIndex,

    required this.selectedAnswers,

    required this.onQuestionSelected,

  });

  final List<TestQuestionModel> questions;

  final int currentIndex;

  final Map<String, String> selectedAnswers;

  final ValueChanged<int> onQuestionSelected;

  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(

        AppSpacing.md,

      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(

          AppRadius.lg,

        ),

        border: Border.all(

          color: AppColors.border,

        ),

      ),

      child: Column(

        crossAxisAlignment:

            CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Text(

                'Question Navigator',

                style: Theme.of(context)

                    .textTheme

                    .titleSmall

                    ?.copyWith(

                      color:

                          AppColors.textPrimary,

                      fontWeight:

                          FontWeight.w700,

                    ),

              ),

              const Spacer(),

              const _NavigatorLegend(

                color: AppColors.primary,

                label: 'Answered',

              ),

              const SizedBox(

                width: AppSpacing.sm,

              ),

              const _NavigatorLegend(

                color: AppColors.border,

                label: 'Unanswered',

              ),

            ],

          ),

          const SizedBox(

            height: AppSpacing.md,

          ),

          Wrap(

            spacing: AppSpacing.sm,

            runSpacing: AppSpacing.sm,

            children: List.generate(

              questions.length,

              (index) {

                final question =

                    questions[index];

                final isCurrent =

                    index == currentIndex;

                final isAnswered =

                    selectedAnswers.containsKey(

                  question.questionId,

                );

                return _QuestionNumberButton(

                  number: index + 1,

                  isCurrent: isCurrent,

                  isAnswered: isAnswered,

                  onTap: () {

                    onQuestionSelected(

                      index,

                    );

                  },

                );

              },

            ),

          ),

        ],

      ),

    );

  }

}

class _QuestionNumberButton

    extends StatelessWidget {

  const _QuestionNumberButton({

    required this.number,

    required this.isCurrent,

    required this.isAnswered,

    required this.onTap,

  });

  final int number;

  final bool isCurrent;

  final bool isAnswered;

  final VoidCallback onTap;

  @override

  Widget build(BuildContext context) {

    Color backgroundColor;

    if (isCurrent) {

      backgroundColor = AppColors.primary;

    } else if (isAnswered) {

      backgroundColor =

          AppColors.primary.withValues(

        alpha: 0.12,

      );

    } else {

      backgroundColor = AppColors.surface;

    }

    Color textColor;

    if (isCurrent) {

      textColor = Colors.white;

    } else if (isAnswered) {

      textColor = AppColors.primary;

    } else {

      textColor = AppColors.textSecondary;

    }

    return Material(

      color: Colors.transparent,

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(

          AppRadius.sm,

        ),

        child: Container(

          width: 42,

          height: 42,

          alignment: Alignment.center,

          decoration: BoxDecoration(

            color: backgroundColor,

            borderRadius: BorderRadius.circular(

              AppRadius.sm,

            ),

            border: Border.all(

              color: isCurrent

                  ? AppColors.primary

                  : isAnswered

                      ? AppColors.primary

                          .withValues(

                          alpha: 0.2,

                        )

                      : AppColors.border,

            ),

          ),

          child: Text(

            '$number',

            style: Theme.of(context)

                .textTheme

                .labelLarge

                ?.copyWith(

                  color: textColor,

                  fontWeight: FontWeight.w700,

                ),

          ),

        ),

      ),

    );

  }

}

class _NavigatorLegend

    extends StatelessWidget {

  const _NavigatorLegend({

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

          width: 8,

          height: 8,

          decoration: BoxDecoration(

            color: color,

            shape: BoxShape.circle,

          ),

        ),

        const SizedBox(width: 4),

        Text(

          label,

          style: Theme.of(context)

              .textTheme

              .labelSmall

              ?.copyWith(

                color:

                    AppColors.textSecondary,

              ),

        ),

      ],

    );

  }

}

class _BottomNavigation

    extends StatelessWidget {

  const _BottomNavigation({

    required this.isFirstQuestion,

    required this.isLastQuestion,

    required this.hasSelectedAnswer,

    required this.isSubmitting,

    required this.onPrevious,

    required this.onNext,

    required this.onSubmit,

  });

  final bool isFirstQuestion;

  final bool isLastQuestion;

  final bool hasSelectedAnswer;

  final bool isSubmitting;

  final VoidCallback onPrevious;

  final VoidCallback onNext;

  final VoidCallback onSubmit;

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.fromLTRB(

        AppSpacing.md,

        AppSpacing.sm,

        AppSpacing.md,

        AppSpacing.md,

      ),

      decoration: const BoxDecoration(

        color: Colors.white,

        border: Border(

          top: BorderSide(

            color: AppColors.border,

          ),

        ),

      ),

      child: Row(

        children: [

          Expanded(

            child: OutlinedButton.icon(

              onPressed: isFirstQuestion ||

                      isSubmitting

                  ? null

                  : onPrevious,

              icon: const Icon(

                Icons.arrow_back_rounded,

              ),

              label: const Text('Previous'),

            ),

          ),

          const SizedBox(

            width: AppSpacing.sm,

          ),

          Expanded(

            child: FilledButton.icon(

              onPressed: isSubmitting

                  ? null

                  : isLastQuestion

                      ? onSubmit

                      : onNext,

              icon: isSubmitting

                  ? const SizedBox(

                      width: 18,

                      height: 18,

                      child:

                          CircularProgressIndicator(

                        strokeWidth: 2,

                      ),

                    )

                  : Icon(

                      isLastQuestion

                          ? Icons.check_rounded

                          : Icons

                              .arrow_forward_rounded,

                    ),

              label: Text(

                isSubmitting

                    ? 'Submitting...'

                    : isLastQuestion

                        ? 'Submit'

                        : 'Next',

              ),

            ),

          ),

        ],

      ),

    );

  }

}

class _MetadataChip

    extends StatelessWidget {

  const _MetadataChip({

    required this.icon,

    required this.label,

  });

  final IconData icon;

  final String label;

  @override

  Widget build(BuildContext context) {

    return Container(

      constraints: const BoxConstraints(

        maxWidth: 180,

      ),

      padding: const EdgeInsets.symmetric(

        horizontal: AppSpacing.sm,

        vertical: AppSpacing.xs,

      ),

      decoration: BoxDecoration(

        color: AppColors.surface,

        borderRadius: BorderRadius.circular(

          AppRadius.sm,

        ),

      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(

            icon,

            size: 14,

            color: AppColors.textSecondary,

          ),

          const SizedBox(

            width: AppSpacing.xs,

          ),

          Flexible(

            child: Text(

              label,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: Theme.of(context)

                  .textTheme

                  .labelMedium

                  ?.copyWith(

                    color:

                        AppColors.textSecondary,

                  ),

            ),

          ),

        ],

      ),

    );

  }

}

class _DifficultyBadge

    extends StatelessWidget {

  const _DifficultyBadge({

    required this.difficulty,

  });

  final String difficulty;

  @override

  Widget build(BuildContext context) {

    final normalized =

        difficulty.toLowerCase();

    return Container(

      padding: const EdgeInsets.symmetric(

        horizontal: AppSpacing.sm,

        vertical: AppSpacing.xs,

      ),

      decoration: BoxDecoration(

        color: _backgroundColor(normalized),

        borderRadius: BorderRadius.circular(

          AppRadius.sm,

        ),

      ),

      child: Text(

        difficulty.toUpperCase(),

        style: Theme.of(context)

            .textTheme

            .labelSmall

            ?.copyWith(

              color: _textColor(normalized),

              fontWeight: FontWeight.w700,

              letterSpacing: 0.4,

            ),

      ),

    );

  }

  Color _backgroundColor(

    String difficulty,

  ) {

    switch (difficulty) {

      case 'easy':

        return Colors.green.withValues(

          alpha: 0.10,

        );

      case 'hard':

        return Colors.red.withValues(

          alpha: 0.10,

        );

      default:

        return Colors.orange.withValues(

          alpha: 0.10,

        );

    }

  }

  Color _textColor(

    String difficulty,

  ) {

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

class _ErrorState extends StatelessWidget {

  const _ErrorState({

    required this.message,

    required this.onRetry,

  });

  final String message;

  final VoidCallback onRetry;

  @override

  Widget build(BuildContext context) {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(

          AppSpacing.xxl,

        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            const Icon(

              Icons.error_outline_rounded,

              size: 48,

              color: AppColors.error,

            ),

            const SizedBox(

              height: AppSpacing.md,

            ),

            Text(

              message,

              textAlign: TextAlign.center,

            ),

            const SizedBox(

              height: AppSpacing.lg,

            ),

            FilledButton.icon(

              onPressed: onRetry,

              icon: const Icon(

                Icons.refresh_rounded,

              ),

              label: const Text('Retry'),

            ),

          ],

        ),

      ),

    );

  }

}
