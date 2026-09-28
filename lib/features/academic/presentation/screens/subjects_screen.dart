import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../routing/app_router.dart';
import '../../data/models/subject_model.dart';
import '../providers/academic_provider.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({
    required this.examId,
    super.key,
  });

  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider(examId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      body: subjectsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () {
            ref.invalidate(subjectsProvider(examId));
          },
        ),
        data: (subjects) {
          if (subjects.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(subjectsProvider(examId));
              await ref.read(subjectsProvider(examId).future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              itemCount: subjects.length,
              separatorBuilder: (_, _) => const SizedBox(
                height: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];

                return _SubjectCard(
                  subject: subject,
                  onTap: () {
                    context.push(
                      AppRoutes.chaptersForSubject(
                        examId: examId,
                        subjectId: subject.id,
                      )
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.onTap,
  });

  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _backgroundColor(subject.name),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _icon(subject.name),
              color: _foregroundColor(subject.name),
              size: 25,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: theme.textTheme.titleMedium,
                ),
                if (subject.description != null &&
                    subject.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subject.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'View chapters',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  IconData _icon(String name) {
    final value = name.toLowerCase();

    if (value.contains('physics')) {
      return Icons.functions_rounded;
    }

    if (value.contains('chemistry')) {
      return Icons.science_outlined;
    }

    if (value.contains('biology')) {
      return Icons.biotech_outlined;
    }

    if (value.contains('mathematics') || value.contains('math')) {
      return Icons.calculate_outlined;
    }

    return Icons.menu_book_outlined;
  }

  Color _backgroundColor(String name) {
    final value = name.toLowerCase();

    if (value.contains('physics')) {
      return AppColors.physics.withValues(alpha: 0.12);
    }

    if (value.contains('chemistry')) {
      return AppColors.chemistry.withValues(alpha: 0.12);
    }

    if (value.contains('biology')) {
      return AppColors.biology.withValues(alpha: 0.12);
    }

    return AppColors.primaryLight;
  }

  Color _foregroundColor(String name) {
    final value = name.toLowerCase();

    if (value.contains('physics')) {
      return AppColors.physics;
    }

    if (value.contains('chemistry')) {
      return AppColors.chemistry;
    }

    if (value.contains('biology')) {
      return AppColors.biology;
    }

    return AppColors.primary;
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
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Unable to load subjects',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No subjects available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Subjects for this exam have not been added yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}