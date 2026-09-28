import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../routing/app_router.dart';
import '../../data/models/dashboard_model.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => const _DashboardLoading(),
      error: (error, stackTrace) => _DashboardError(
        message: error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        onRetry: () {
          ref.invalidate(dashboardProvider);
        },
      ),
      data: (dashboard) {
        return _DashboardContent(
          dashboard: dashboard,
        );
      },
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    required this.dashboard,
  });

  final DashboardSummary dashboard;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final examId = dashboard.exam?.id;

    void showComingSoon(String feature) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$feature is coming next.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    void openSubjects() {
      if (examId == null || examId.isEmpty) {
        showComingSoon('Exam selection');
        return;
      }

      context.push(
        AppRoutes.subjectsForExam(examId),
      );
    }

    void openPractice() {
      if (examId == null || examId.isEmpty) {
        showComingSoon('Exam selection');
        return;
      }

      context.push(
        AppRoutes.questionsForExam(examId),
      );
    }

    void openCreateTest() {
      if (examId == null || examId.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Please select an exam before creating a test.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
      }

      context.push(
        AppRoutes.createTestForExam(examId),
      );
    }

    void openRecentTest(DashboardRecentTest test) {
      context.push(
        AppRoutes.testResultFor(
          testId: test.testId,
          attemptId: test.attemptId,
        ),
      );
    }

    void openArea(DashboardArea area) {
      if (examId == null || examId.isEmpty) {
        showComingSoon('Exam selection');
        return;
      }

      context.push(
        AppRoutes.topicsForChapter(
          examId: examId,
          chapterId: area.chapterId,
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);

            await ref.read(
              dashboardProvider.future,
            );
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ------------------------------------------------------------
              // Header
              // ------------------------------------------------------------

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning 👋',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              dashboard.student.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      _HeaderIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {
                          showComingSoon('Notifications');
                        },
                      ),
                      const SizedBox(
                        width: AppSpacing.sm,
                      ),
                      _HeaderIconButton(
                        icon: Icons.person_outline_rounded,
                        onTap: () {
                          showComingSoon('Profile');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // Exam
              // ------------------------------------------------------------

              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                sliver: SliverToBoxAdapter(
                  child: AppCard(
                    padding: const EdgeInsets.all(
                      AppSpacing.lg,
                    ),
                    onTap: () {
                      showComingSoon('Exam switching');
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(
                              AppRadius.md,
                            ),
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            color: AppColors.primary,
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
                                'Preparing for',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                dashboard.exam?.name ??
                                    'Select an exam',
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // Performance overview
              // ------------------------------------------------------------

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _PerformanceCard(
                    overall: dashboard.overall,
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // Quick Practice
              // ------------------------------------------------------------

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Practice',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: AppSpacing.md,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.auto_awesome_rounded,
                              title: 'AI Test',
                              subtitle: 'Personalized',
                              color: AppColors.aiPurple,
                              backgroundColor:
                                  AppColors.aiPurpleLight,
                              onTap: openCreateTest,
                            ),
                          ),
                          const SizedBox(
                            width: AppSpacing.md,
                          ),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.quiz_outlined,
                              title: 'Practice',
                              subtitle: 'By subject',
                              color: AppColors.primary,
                              backgroundColor:
                                  AppColors.primaryLight,
                              onTap: openPractice,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // Subjects
              // ------------------------------------------------------------

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _SubjectsSection(
                    subjects: dashboard.subjects,
                    onViewAll: openSubjects,
                    onSubjectTap: openSubjects,
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // Weak areas
              // ------------------------------------------------------------

              if (dashboard.weakAreas.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _AreasSection(
                      title: 'Needs Attention',
                      subtitle:
                          'Topics where your accuracy is below 60%.',
                      areas: dashboard.weakAreas,
                      isWeak: true,
                      onAreaTap: openArea,
                    ),
                  ),
                ),

              // ------------------------------------------------------------
              // Strong areas
              // ------------------------------------------------------------

              if (dashboard.strongAreas.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _AreasSection(
                      title: 'Your Strengths',
                      subtitle:
                          'Topics where your accuracy is 80% or higher.',
                      areas: dashboard.strongAreas,
                      isWeak: false,
                      onAreaTap: openArea,
                    ),
                  ),
                ),

              // ------------------------------------------------------------
              // Performance insight
              // ------------------------------------------------------------

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _PerformanceInsightCard(
                    dashboard: dashboard,
                  ),
                ),
              ),

              // ------------------------------------------------------------
              // Recent tests
              // ------------------------------------------------------------

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                sliver: SliverToBoxAdapter(
                  child: _RecentTestsSection(
                    tests: dashboard.recentTests,
                    onTestTap: openRecentTest,
                    onViewAll: () {
                      showComingSoon('Test history');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // --------------------------------------------------------------
      // Bottom navigation
      // --------------------------------------------------------------

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break;

            case 1:
              openPractice();
              break;

            case 2:
              showComingSoon('Analytics');
              break;

            case 3:
              showComingSoon('Profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.menu_book_outlined,
            ),
            selectedIcon: Icon(
              Icons.menu_book_rounded,
            ),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.analytics_outlined,
            ),
            selectedIcon: Icon(
              Icons.analytics_rounded,
            ),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// Performance Card
// ======================================================================

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.overall,
  });

  final DashboardOverall overall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final progress = (overall.accuracy / 100).clamp(
      0.0,
      1.0,
    );

    return AppCard(
      padding: const EdgeInsets.all(
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Performance Overview',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                '${overall.accuracy.toStringAsFixed(0)}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppRadius.pill,
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor:
                  AppColors.surfaceSecondary,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          Row(
            children: [
              _StatItem(
                value: '${overall.completedTests}',
                label: 'Tests',
              ),
              const _VerticalDivider(),
              _StatItem(
                value: '${overall.attemptedQuestions}',
                label: 'Questions',
              ),
              const _VerticalDivider(),
              _StatItem(
                value: '${overall.correctAnswers}',
                label: 'Correct',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge,
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.border,
    );
  }
}

// ======================================================================
// Subjects
// ======================================================================

class _SubjectsSection extends StatelessWidget {
  const _SubjectsSection({
    required this.subjects,
    required this.onViewAll,
    required this.onSubjectTap,
  });

  final List<DashboardSubjectPerformance> subjects;
  final VoidCallback onViewAll;
  final VoidCallback onSubjectTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your Subjects',
                style: theme.textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: subjects.isEmpty
                  ? null
                  : onViewAll,
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        if (subjects.isEmpty)
          const _EmptyCard(
            icon: Icons.menu_book_outlined,
            title: 'No subject performance yet',
            message:
                'Complete a test to start tracking subject accuracy.',
          )
        else
          ...subjects.map(
            (subject) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.md,
                ),
                child: _SubjectProgress(
                  subject: subject,
                  onTap: onSubjectTap,
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SubjectProgress extends StatelessWidget {
  const _SubjectProgress({
    required this.subject,
    required this.onTap,
  });

  final DashboardSubjectPerformance subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final progress = (subject.accuracy / 100).clamp(
      0.0,
      1.0,
    );

    final color = _subjectColor(
      subject.subjectName,
    );

    return AppCard(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                '${subject.accuracy.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppRadius.pill,
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor:
                  AppColors.surfaceSecondary,
              color: color,
            ),
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${subject.correctAnswers} correct '
              'of ${subject.attemptedQuestions} attempted',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// Areas
// ======================================================================

class _AreasSection extends StatelessWidget {
  const _AreasSection({
    required this.title,
    required this.subtitle,
    required this.areas,
    required this.isWeak,
    required this.onAreaTap,
  });

  final String title;
  final String subtitle;
  final List<DashboardArea> areas;
  final bool isWeak;
  final ValueChanged<DashboardArea> onAreaTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(
          height: AppSpacing.xs,
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(
          height: AppSpacing.md,
        ),
        ...areas.map(
          (area) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: _AreaTile(
                area: area,
                isWeak: isWeak,
                onTap: () => onAreaTap(area),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AreaTile extends StatelessWidget {
  const _AreaTile({
    required this.area,
    required this.isWeak,
    required this.onTap,
  });

  final DashboardArea area;
  final bool isWeak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final percentage =
        '${area.accuracy.toStringAsFixed(0)}%';

    return AppCard(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isWeak
                  ? AppColors.errorLight
                  : AppColors.successLight,
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: Icon(
              isWeak
                  ? Icons.trending_down_rounded
                  : Icons.trending_up_rounded,
              color: isWeak
                  ? AppColors.error
                  : AppColors.success,
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
                  area.topicName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  '${area.subjectName} • '
                  '${area.chapterName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                percentage,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isWeak
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                '${area.attemptedQuestions} answered',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(
            width: AppSpacing.xs,
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// Performance Insight
// ======================================================================

class _PerformanceInsightCard extends StatelessWidget {
  const _PerformanceInsightCard({
    required this.dashboard,
  });

  final DashboardSummary dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final overall = dashboard.overall;

    String title;
    String message;

    if (overall.completedTests == 0) {
      title =
          'Start building your performance history';

      message =
          'Complete your first test and PrepMate will '
          'start identifying your strengths and areas '
          'that need attention.';
    } else if (dashboard.weakAreas.isNotEmpty) {
      final weak = dashboard.weakAreas.first;

      title =
          '${weak.topicName} needs more practice';

      message =
          'Your current accuracy in ${weak.topicName} '
          'is ${weak.accuracy.toStringAsFixed(0)}%. '
          'Practice this topic to strengthen your fundamentals.';
    } else if (dashboard.strongAreas.isNotEmpty) {
      final strong = dashboard.strongAreas.first;

      title =
          '${strong.topicName} is a strength';

      message =
          'You are performing at '
          '${strong.accuracy.toStringAsFixed(0)}% accuracy '
          'in this topic. Keep the momentum going.';
    } else {
      title = 'Keep building your data';

      message =
          'Complete more questions across different '
          'topics so PrepMate can identify meaningful '
          'performance patterns.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.aiPurpleLight,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.aiPurple,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(
                width: AppSpacing.md,
              ),
              Expanded(
                child: Text(
                  'Performance Insight',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          Text(
            title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// Recent Tests
// ======================================================================

class _RecentTestsSection extends StatelessWidget {
  const _RecentTestsSection({
    required this.tests,
    required this.onTestTap,
    required this.onViewAll,
  });

  final List<DashboardRecentTest> tests;
  final ValueChanged<DashboardRecentTest> onTestTap;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Tests',
                style: theme.textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: tests.isEmpty
                  ? null
                  : onViewAll,
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        if (tests.isEmpty)
          const _EmptyCard(
            icon: Icons.history_rounded,
            title: 'No completed tests yet',
            message:
                'Your completed tests will appear here.',
          )
        else
          ...tests.map(
            (test) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.sm,
                ),
                child: _RecentTestTile(
                  test: test,
                  onTap: () => onTestTap(test),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _RecentTestTile extends StatelessWidget {
  const _RecentTestTile({
    required this.test,
    required this.onTap,
  });

  final DashboardRecentTest test;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: const Icon(
              Icons.quiz_outlined,
              color: AppColors.primary,
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
                  test.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  _formatDate(test.submittedAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '${test.correctAnswers}/'
                '${test.totalQuestions}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                '${test.accuracy.toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(
            width: AppSpacing.xs,
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// Quick Action
// ======================================================================

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(
        AppRadius.lg,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// Empty
// ======================================================================

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(
        AppSpacing.xl,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.textSecondary,
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
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  message,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// Loading
// ======================================================================

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ======================================================================
// Error
// ======================================================================

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(
              AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(
                      AppRadius.lg,
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.error,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.lg,
                ),
                Text(
                  'Unable to load dashboard',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
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
        ),
      ),
    );
  }
}

// ======================================================================
// Header Button
// ======================================================================

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(
        AppRadius.md,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppRadius.md,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 21,
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// Helpers
// ======================================================================

Color _subjectColor(
  String subjectName,
) {
  final normalized = subjectName.toLowerCase();

  if (normalized.contains('physics')) {
    return AppColors.physics;
  }

  if (normalized.contains('chemistry')) {
    return AppColors.chemistry;
  }

  if (normalized.contains('biology')) {
    return AppColors.biology;
  }

  return AppColors.primary;
}

String _formatDate(
  DateTime date,
) {
  final localDate = date.toLocal();
  final now = DateTime.now();

  final today = DateTime(
    now.year,
    now.month,
    now.day,
  );

  final target = DateTime(
    localDate.year,
    localDate.month,
    localDate.day,
  );

  final difference = today.difference(target).inDays;

  if (difference == 0) {
    return 'Today';
  }

  if (difference == 1) {
    return 'Yesterday';
  }

  if (difference > 1 && difference < 7) {
    return '$difference days ago';
  }

  return '${localDate.day.toString().padLeft(2, '0')}/'
      '${localDate.month.toString().padLeft(2, '0')}/'
      '${localDate.year}';
}