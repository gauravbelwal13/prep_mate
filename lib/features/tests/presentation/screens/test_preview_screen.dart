import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:prep_mate/features/tests/data/models/test_question_model.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../routing/app_router.dart';
import '../providers/test_provider.dart';

class TestPreviewScreen extends ConsumerWidget {
  const TestPreviewScreen({
    required this.testId,
    super.key,
  });

  final String testId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final testAsync =
        ref.watch(testProvider(testId));

    final questionsAsync =
        ref.watch(testQuestionsProvider(testId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Preview'),
      ),
      body: testAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          message: error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              ),
          onRetry: () {
            ref.invalidate(
              testProvider(testId),
            );

            ref.invalidate(
              testQuestionsProvider(testId),
            );
          },
        ),
        data: (test) {
          return questionsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => _ErrorState(
              message: error
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
              onRetry: () {
                ref.invalidate(
                  testProvider(testId),
                );

                ref.invalidate(
                  testQuestionsProvider(testId),
                );
              },
            ),
            data: (questions) {
              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                  ),
                  children: [
                    _buildHeroCard(
                      context,
                      test.title,
                      test.examName,
                      test.description,
                    ),
                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                    _buildStatsCard(
                      context,
                      totalQuestions:
                          test.totalQuestions,
                      durationMinutes:
                          test.durationMinutes,
                    ),
                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                    _buildQuestionsCard(
                      context,
                      questions,
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: questions.isEmpty
                            ? null
                            : () {
                                _showStartDialog(
                                  context,
                                  ref,
                                  test.title,
                                );
                              },
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                        ),
                        label: const Text(
                          'Start Test',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    String title,
    String examName,
    String? description,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(
              alpha: 0.82,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.16,
              ),
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          Text(
            examName,
            style:
                theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(
                alpha: 0.82,
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style:
                theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (description != null &&
              description.trim().isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(
                color: Colors.white.withValues(
                  alpha: 0.86,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required int totalQuestions,
    required int durationMinutes,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.quiz_outlined,
              value: '$totalQuestions',
              label: 'Questions',
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.timer_outlined,
              value: '$durationMinutes min',
              label: 'Duration',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsCard(
    BuildContext context,
    List<TestQuestionModel> questions,
  ) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Questions',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${questions.length}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          ...questions.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final question = entry.value;

              return Container(
                margin: const EdgeInsets.only(
                  bottom: AppSpacing.sm,
                ),
                padding: const EdgeInsets.all(
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors.surfaceSecondary,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.sm,
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: theme
                            .textTheme.labelLarge
                            ?.copyWith(
                          color:
                              AppColors.primary,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
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
                            question.questionText,
                            maxLines: 3,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme.textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            '${question.subjectName} • '
                            '${question.chapterName}',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme
                                .textTheme.bodySmall,
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              _DifficultyBadge(
                                difficulty:
                                    question
                                        .difficulty,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                '+${question.marks} / '
                                '-${question.negativeMarks}',
                                style: theme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showStartDialog(
    BuildContext context,
    WidgetRef ref,
    String testTitle,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Start test?',
          ),
          content: Text(
            'You are about to start "$testTitle". '
            'Your attempt will begin when you continue.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(
                  dialogContext,
                ).pop();

                try {
                  final attempt = await ref
                      .read(
                        testRepositoryProvider,
                      )
                      .startAttempt(testId);

                  if (!context.mounted) {
                    return;
                  }

                  context.push(
                    AppRoutes.testForAttempt(
                      testId: testId,
                      attemptId: attempt.id,
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          error
                              .toString()
                              .replaceFirst(
                                'Exception: ',
                                '',
                              ),
                        ),
                      ),
                    );
                }
              },
              child: const Text(
                'Start',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 22,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _VerticalDivider
    extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 55,
      color: AppColors.border,
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.pill,
        ),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: theme.textTheme.labelSmall
            ?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}