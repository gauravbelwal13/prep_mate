import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routing/app_router.dart';
import '../../data/models/question_model.dart';
import '../providers/question_provider.dart';

class QuestionsScreen extends ConsumerStatefulWidget {
  const QuestionsScreen({
    super.key,
    required this.examId,
    this.subjectId,
    this.chapterId,
    this.topicId,
    this.title,
  });

  final String examId;
  final String? subjectId;
  final String? chapterId;
  final String? topicId;
  final String? title;

  @override
  ConsumerState<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends ConsumerState<QuestionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _subjectFilter = 'All';
  final Set<String> _bookmarkedQuestionIds = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  QuestionFilter get _filter {
    return QuestionFilter(
      examId: widget.examId,
      subjectId: widget.subjectId,
      chapterId: widget.chapterId,
      topicId: widget.topicId,
      limit: 20,
    );
  }

  List<Question> _filteredQuestions(List<Question> questions) {
    final query = _searchQuery.trim().toLowerCase();

    return questions.where((question) {
      final matchesSubject =
          _subjectFilter == 'All' || question.subjectName == _subjectFilter;

      if (!matchesSubject) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return question.questionText.toLowerCase().contains(query) ||
          question.subjectName.toLowerCase().contains(query) ||
          question.chapterName.toLowerCase().contains(query) ||
          question.topicName.toLowerCase().contains(query);
    }).toList();
  }

  List<String> _subjectFilters(List<Question> questions) {
    final subjects = questions
        .map((question) => question.subjectName)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['All', ...subjects];
  }

void _openQuestion(Question question) {
  context.push(
    AppRoutes.questionDetailFor(
      questionId: question.id,
      examId: widget.examId,
    ),
    extra: question,
  );
}

  void _startPractice(List<Question> questions) {
    if (questions.isEmpty) {
      return;
    }

    context.push(
      AppRoutes.practiceFor(
        examId: widget.examId,
        questions: questions,
      ),
      extra: questions,
    );
  }

  Future<void> _refresh(QuestionFilter filter) async {
    ref.invalidate(questionsProvider(filter));
    await ref.read(questionsProvider(filter).future);
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider(_filter));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title ?? 'Question Bank'),
        actions: [
          IconButton(
            tooltip: 'Bookmarks',
            onPressed: () {
              setState(() {
                _subjectFilter = 'All';
                _searchQuery = '';
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
        ],
      ),
      body: questionsAsync.when(
        loading: () => const _QuestionsLoading(),
        error: (error, stackTrace) => _QuestionsError(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () {
            ref.invalidate(questionsProvider(_filter));
          },
        ),
        data: (questions) {
          final visibleQuestions = _filteredQuestions(questions);
          final subjectFilters = _subjectFilters(questions);

          return RefreshIndicator(
            onRefresh: () => _refresh(_filter),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _QuestionBankHeader(
                      questionCount: questions.length,
                      visibleCount: visibleQuestions.length,
                      searchController: _searchController,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onFilterPressed: () => _showFilterSheet(
                        context,
                        subjectFilters,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 58,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: subjectFilters.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final subject = subjectFilters[index];

                        return _SubjectChip(
                          label: subject,
                          selected: _subjectFilter == subject,
                          onTap: () {
                            setState(() {
                              _subjectFilter = subject;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _PracticeBanner(
                      questionCount: visibleQuestions.length,
                      onTap: () => _startPractice(visibleQuestions),
                    ),
                  ),
                ),
                if (visibleQuestions.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyQuestions(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: visibleQuestions.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final question = visibleQuestions[index];

                        return _QuestionCard(
                          question: question,
                          questionNumber: index + 1,
                          bookmarked: _bookmarkedQuestionIds.contains(
                            question.id,
                          ),
                          onBookmark: () {
                            setState(() {
                              if (_bookmarkedQuestionIds.contains(
                                question.id,
                              )) {
                                _bookmarkedQuestionIds.remove(question.id);
                              } else {
                                _bookmarkedQuestionIds.add(question.id);
                              }
                            });
                          },
                          onTap: () => _openQuestion(question),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showFilterSheet(
    BuildContext context,
    List<String> subjects,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              Text(
                'Filter questions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...subjects.map(
                (subject) => RadioListTile<String>(
                  value: subject,
                  groupValue: _subjectFilter,
                  title: Text(subject),
                  onChanged: (value) {
                    Navigator.of(context).pop(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _subjectFilter = selected;
      });
    }
  }
}

class _QuestionBankHeader extends StatelessWidget {
  const _QuestionBankHeader({
    required this.questionCount,
    required this.visibleCount,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterPressed,
  });

  final int questionCount;
  final int visibleCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    final countText = visibleCount == questionCount
        ? '$questionCount questions loaded'
        : '$visibleCount of $questionCount questions';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Bank',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Practice questions by subject, chapter and topic.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search questions, topics, keywords...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              height: 52,
              width: 52,
              child: OutlinedButton(
                onPressed: onFilterPressed,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Icon(Icons.tune_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          countText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _PracticeBanner extends StatelessWidget {
  const _PracticeBanner({
    required this.questionCount,
    required this.onTap,
  });

  final int questionCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice loaded questions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$questionCount ${questionCount == 1 ? 'question' : 'questions'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: questionCount == 0 ? null : onTap,
            child: const Text('Practice'),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.bookmarked,
    required this.onBookmark,
    required this.onTap,
  });

  final Question question;
  final int questionNumber;
  final bool bookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
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
                children: [
                  _QuestionNumberBadge(number: questionNumber),
                  const SizedBox(width: AppSpacing.sm),
                  _DifficultyBadge(difficulty: question.difficulty),
                  const Spacer(),
                  Text(
                    '+${question.marks} / -${question.negativeMarks}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  IconButton(
                    tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
                    onPressed: onBookmark,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: bookmarked
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                question.questionText,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(
                    '${question.options.length} options',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Open question',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionNumberBadge extends StatelessWidget {
  const _QuestionNumberBadge({
    required this.number,
  });

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        'Q$number',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
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

class _QuestionsLoading extends StatelessWidget {
  const _QuestionsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _QuestionsError extends StatelessWidget {
  const _QuestionsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Unable to load questions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
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

class _EmptyQuestions extends StatelessWidget {
  const _EmptyQuestions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No questions found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'There are no questions available for this selection yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
