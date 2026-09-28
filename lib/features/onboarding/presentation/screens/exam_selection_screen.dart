import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../routing/app_router.dart';
import '../../data/models/exam_model.dart';
import '../providers/onboarding_provider.dart';

class ExamSelectionScreen extends ConsumerStatefulWidget {
  const ExamSelectionScreen({super.key});

  @override
  ConsumerState<ExamSelectionScreen> createState() =>
      _ExamSelectionScreenState();
}

class _ExamSelectionScreenState
    extends ConsumerState<ExamSelectionScreen> {
  String? _selectedExamId;
  bool _isSaving = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  Future<void> _continue() async {
    if (_selectedExamId == null) {
      _showMessage('Please select an exam to continue.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(onboardingRepositoryProvider).updateExam(
            examId: _selectedExamId!,
          );

      ref.invalidate(studentProfileProvider);

      if (!mounted) {
        return;
      }

      context.go(AppRoutes.dashboard);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        ref
            .read(onboardingRepositoryProvider)
            .extractErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  List<Exam> _filterExams(List<Exam> exams) {
    final query = _searchQuery.trim().toLowerCase();

    return exams.where((exam) {
      final name = exam.name.toLowerCase();
      final description =
          (exam.description ?? '').toLowerCase();
      final code = exam.code.toLowerCase();

      final matchesSearch = query.isEmpty ||
          name.contains(query) ||
          description.contains(query) ||
          code.contains(query);

      final matchesCategory =
          _selectedCategory == 'All' ||
              _matchesCategory(exam, _selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  bool _matchesCategory(Exam exam, String category) {
    final code = exam.code.toUpperCase();
    final name = exam.name.toLowerCase();

    switch (category) {
      case 'Exams':
        return code.contains('JEE') ||
            code.contains('NEET') ||
            name.contains('exam');

      case 'Programming':
        return name.contains('flutter') ||
            name.contains('java') ||
            name.contains('program') ||
            name.contains('development') ||
            name.contains('coding');

      case 'School':
        return name.contains('school') ||
            name.contains('class');

      case 'Competitive':
        return code.contains('JEE') ||
            code.contains('NEET') ||
            name.contains('competitive');

      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(examsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _OnboardingHeader(),
            Expanded(
              child: examsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) {
                  return _ExamErrorState(
                    onRetry: () {
                      ref.invalidate(examsProvider);
                    },
                  );
                },
                data: (exams) {
                  if (exams.isEmpty) {
                    return const _EmptyExamState();
                  }

                  final filteredExams = _filterExams(exams);

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xxl,
                            AppSpacing.lg,
                            AppSpacing.xxl,
                            AppSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _HeroHeading(),
                              const SizedBox(
                                height: AppSpacing.lg,
                              ),
                              _SearchField(
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: AppSpacing.md,
                              ),
                              _CategoryFilters(
                                selectedCategory:
                                    _selectedCategory,
                                onCategoryChanged: (category) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: AppSpacing.lg,
                              ),
                              if (filteredExams.isEmpty)
                                const _NoMatchingExams()
                              else
                                ...filteredExams.map(
                                  (exam) => Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: _ExamCard(
                                      exam: exam,
                                      selected:
                                          _selectedExamId ==
                                              exam.id,
                                      onTap: _isSaving
                                          ? null
                                          : () {
                                              setState(() {
                                                _selectedExamId =
                                                    exam.id;
                                              });
                                            },
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                height: AppSpacing.sm,
                              ),
                              const _AiPersonalizationCard(),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.sm,
                          AppSpacing.xxl,
                          AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.04,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, -6),
                            ),
                          ],
                        ),
                        child: AppButton(
                          text: _isSaving
                              ? 'Saving...'
                              : 'Continue to UpForm',
                          onPressed: _isSaving ||
                                  _selectedExamId == null
                              ? null
                              : _continue,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Center(
                  child: AppLogo(
                    width: 245,
                    height: 76,
                  ),
                ),
              ),
              Text(
                '3 of 3',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppRadius.pill,
            ),
            child: const LinearProgressIndicator(
              value: 1,
              minHeight: 6,
              backgroundColor: AppColors.surfaceSecondary,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeading extends StatelessWidget {
  const _HeroHeading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 135,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'What are you\npreparing for?',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                Text(
                  'Choose your target exam or course. '
                  'We will personalize your subjects, '
                  'content and practice experience.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: -2,
            child: Image.asset(
              'assets/images/prep_mate_goals_support_badge.png',
              width: 118,
              height: 118,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by exam, course, skill...',
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
          size: 29,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  static const categories = [
    'All',
    'Exams',
    'Programming',
    'School',
    'Competitive',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected =
              category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.sm,
            ),
            child: GestureDetector(
              onTap: () => onCategoryChanged(category),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    AppRadius.pill,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.exam,
    required this.selected,
    required this.onTap,
  });

  final Exam exam;
  final bool selected;
  final VoidCallback? onTap;

  IconData _getExamIcon() {
    switch (exam.code.toUpperCase()) {
      case 'NEET':
        return Icons.biotech_rounded;

      case 'JEE':
      case 'JEE_MAIN':
      case 'JEE-MAIN':
        return Icons.functions_rounded;

      case 'JEE_ADVANCED':
      case 'JEE-ADVANCED':
        return Icons.school_rounded;

      default:
        return Icons.auto_stories_rounded;
    }
  }

  Color _getIconBackground() {
    switch (exam.code.toUpperCase()) {
      case 'NEET':
        return const Color(0xFFEAF9F4);

      case 'JEE':
      case 'JEE_MAIN':
      case 'JEE-MAIN':
      case 'JEE_ADVANCED':
      case 'JEE-ADVANCED':
        return AppColors.primaryLight;

      default:
        return AppColors.surfaceSecondary;
    }
  }

  String _getSubjectsText() {
    switch (exam.code.toUpperCase()) {
      case 'NEET':
        return 'Physics  •  Chemistry  •  Biology';

      case 'JEE':
      case 'JEE_MAIN':
      case 'JEE-MAIN':
      case 'JEE_ADVANCED':
      case 'JEE-ADVANCED':
        return 'Physics  •  Chemistry  •  Mathematics';

      default:
        return 'Personalized preparation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(
        AppRadius.lg,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppRadius.lg,
            ),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _getIconBackground(),
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Icon(
                  _getExamIcon(),
                  size: 29,
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
                      exam.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (exam.description != null &&
                        exam.description!.isNotEmpty) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        exam.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: 7,
                    ),
                    _SubjectChips(
                      text: _getSubjectsText(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 160,
                ),
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    width: selected ? 7 : 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectChips extends StatelessWidget {
  const _SubjectChips({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final subjects = text
        .split('•')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: subjects.map((subject) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(
              AppRadius.sm,
            ),
          ),
          child: Text(
            subject,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AiPersonalizationCard extends StatelessWidget {
  const _AiPersonalizationCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.aiPurpleLight,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.aiPurple,
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 23,
              color: Colors.white,
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
                  'Personalized for you',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Your choice helps us recommend '
                  'the right subjects, projects and '
                  'practice content using UpForm AI.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
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

class _NoMatchingExams extends StatelessWidget {
  const _NoMatchingExams();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxxl,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 46,
              color: AppColors.textTertiary,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              'No matching exams',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            const Text(
              'Try another search or category.',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamErrorState extends StatelessWidget {
  const _ExamErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: AppColors.textTertiary,
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              'Unable to load exams',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'Please check your connection and try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppSpacing.xl,
            ),
            AppButton(
              text: 'Try Again',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExamState extends StatelessWidget {
  const _EmptyExamState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 52,
              color: AppColors.textTertiary,
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              'No exams available',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'There are currently no exams available '
              'for selection.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}