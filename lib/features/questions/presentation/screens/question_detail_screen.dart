import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/question_model.dart';
import '../../data/models/question_option_model.dart';
import '../providers/question_provider.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  const QuestionDetailScreen({
    super.key,
    required this.question,
    required this.examId,
  });

  final Question question;
  final String examId;

  @override
  ConsumerState<QuestionDetailScreen> createState() =>
      _QuestionDetailScreenState();
}

class _QuestionDetailScreenState
    extends ConsumerState<QuestionDetailScreen> {
  String? _selectedOptionId;

  bool _isChecking = false;
  bool _isChecked = false;

  String? _correctOptionId;
  bool? _isCorrect;
  int? _marksAwarded;
  String? _explanation;

  Question get _question => widget.question;

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

    if (_isChecked || _isChecking) {
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final result = await ref
          .read(questionRepositoryProvider)
          .checkAnswer(
            questionId: _question.id,
            selectedOptionId: selectedOptionId,
              examId: widget.examId,

          );

      if (!mounted) {
        return;
      }

      setState(() {
        _isChecking = false;
        _isChecked = true;
        _correctOptionId = result.correctOptionId;
        _isCorrect = result.isCorrect;
        _marksAwarded = result.marksAwarded;
        _explanation = result.explanation;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isChecking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
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

  void _selectOption(String optionId) {
    if (_isChecked || _isChecking) {
      return;
    }

    setState(() {
      _selectedOptionId = optionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuestionHeader(
              question: _question,
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            _QuestionCard(
              question: _question,
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            _OptionsSection(
              question: _question,
              selectedOptionId: _selectedOptionId,
              correctOptionId: _correctOptionId,
              checked: _isChecked,
              onOptionSelected: _selectOption,
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            if (!_isChecked)
              _CheckAnswerButton(
                isChecking: _isChecking,
                enabled: _selectedOptionId != null,
                onPressed: _checkAnswer,
              ),

            if (_isChecked) ...[
              _AnswerResultCard(
                isCorrect: _isCorrect ?? false,
                marksAwarded: _marksAwarded ?? 0,
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              _ExplanationCard(
                explanation: _explanation,
              ),
            ],

            const SizedBox(
              height: AppSpacing.lg,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({
    required this.question,
  });

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _InfoChip(
          icon: Icons.menu_book_rounded,
          label: question.subjectName,
        ),
        _InfoChip(
          icon: Icons.layers_outlined,
          label: question.chapterName,
        ),
        _InfoChip(
          icon: Icons.topic_outlined,
          label: question.topicName,
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
  });

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Question',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              _DifficultyBadge(
                difficulty: question.difficulty,
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
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
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
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

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Row(
            children: [
              Expanded(
                child: _MarksItem(
                  label: 'Correct',
                  value: '+${question.marks}',
                  icon: Icons.add_circle_outline_rounded,
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              Expanded(
                child: _MarksItem(
                  label: 'Incorrect',
                  value: '-${question.negativeMarks}',
                  icon: Icons.remove_circle_outline_rounded,
                ),
              ),
            ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            checked
                ? 'Answer'
                : 'Choose your answer',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          ...question.options.map(
            (option) {
              final isSelected =
                  option.id == selectedOptionId;

              final isCorrect =
                  checked &&
                  option.id == correctOptionId;

              final isIncorrect =
                  checked &&
                  option.id == selectedOptionId &&
                  option.id != correctOptionId;

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.sm,
                ),
                child: _OptionCard(
                  option: option,
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  isIncorrect: isIncorrect,
                  enabled: !checked,
                  onTap: () {
                    onOptionSelected(option.id);
                  },
                ),
              );
            },
          ),
        ],
      ),
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
    final label = String.fromCharCode(
      64 + option.optionOrder,
    );

    Color backgroundColor = Colors.white;
    Color borderColor = AppColors.border;

    Color labelBackground =
        AppColors.primary.withValues(
      alpha: 0.08,
    );

    Color labelColor = AppColors.primary;

    IconData? trailingIcon;
    Color? trailingColor;

    if (isCorrect) {
      backgroundColor =
          Colors.green.withValues(alpha: 0.08);

      borderColor = Colors.green.shade600;

      labelBackground = Colors.green.shade600;
      labelColor = Colors.white;

      trailingIcon = Icons.check_circle_rounded;
      trailingColor = Colors.green.shade700;
    } else if (isIncorrect) {
      backgroundColor =
          Colors.red.withValues(alpha: 0.08);

      borderColor = Colors.red.shade600;

      labelBackground = Colors.red.shade600;
      labelColor = Colors.white;

      trailingIcon = Icons.cancel_rounded;
      trailingColor = Colors.red.shade700;
    } else if (isSelected) {
      backgroundColor =
          AppColors.primary.withValues(alpha: 0.06);

      borderColor = AppColors.primary;

      labelBackground = AppColors.primary;
      labelColor = Colors.white;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
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
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
              AppRadius.md,
            ),
            border: Border.all(
              color: borderColor,
              width: isSelected ||
                      isCorrect ||
                      isIncorrect
                  ? 1.5
                  : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w800,
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
                          fontWeight: isSelected ||
                                  isCorrect ||
                                  isIncorrect
                              ? FontWeight.w600
                              : FontWeight.w400,
                          height: 1.4,
                        ),
                  ),
                ),
              ),

              if (trailingIcon != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                  ),
                  child: Icon(
                    trailingIcon,
                    color: trailingColor,
                    size: 22,
                  ),
                )
              else
                Icon(
                  isSelected
                      ? Icons
                          .radio_button_checked_rounded
                      : Icons
                          .radio_button_unchecked_rounded,
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

class _CheckAnswerButton extends StatelessWidget {
  const _CheckAnswerButton({
    required this.isChecking,
    required this.enabled,
    required this.onPressed,
  });

  final bool isChecking;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed:
            enabled && !isChecking
                ? onPressed
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
            : const Icon(
                Icons.check_rounded,
              ),
        label: Text(
          isChecking
              ? 'Checking...'
              : 'Check Answer',
        ),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(
            54,
          ),
        ),
      ),
    );
  }
}

class _AnswerResultCard extends StatelessWidget {
  const _AnswerResultCard({
    required this.isCorrect,
    required this.marksAwarded,
  });

  final bool isCorrect;
  final int marksAwarded;

  @override
  Widget build(BuildContext context) {
    final resultColor = isCorrect
        ? Colors.green.shade700
        : Colors.red.shade700;

    final backgroundColor = isCorrect
        ? Colors.green.withValues(alpha: 0.08)
        : Colors.red.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: resultColor.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: resultColor,
            size: 32,
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect
                      ? 'Correct answer'
                      : 'Incorrect answer',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: resultColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  isCorrect
                      ? 'You earned +$marksAwarded marks.'
                      : 'You received $marksAwarded marks.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w600,
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
        explanation != null &&
        explanation!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.05,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Text(
                'Explanation',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      color:
                          AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            hasExplanation
                ? explanation!
                : 'No explanation is available for this question yet.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }
}

class _MarksItem extends StatelessWidget {
  const _MarksItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),

          const SizedBox(
            width: AppSpacing.xs,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
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
                Text(
                  value,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 240,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppRadius.sm,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.primary,
          ),

          const SizedBox(
            width: AppSpacing.xs,
          ),

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                    color:
                        AppColors.textSecondary,
                    fontWeight:
                        FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
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