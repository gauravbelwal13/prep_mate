import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prep_mate/features/tests/presentation/providers/test_provider.dart';
import 'package:prep_mate/routing/app_router.dart';

import '../../../academic/data/models/chapter_model.dart';
import '../../../academic/data/models/subject_model.dart';
import '../../../academic/data/models/topic_model.dart';
import '../../../academic/presentation/providers/academic_provider.dart';
import '../../../questions/data/models/question_model.dart';
import '../../../questions/presentation/providers/question_provider.dart';

class CreateTestScreen extends ConsumerStatefulWidget {
  const CreateTestScreen({
    required this.examId,
    this.examName,
    super.key,
  });

  final String examId;
  final String? examName;

  @override
  ConsumerState<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends ConsumerState<CreateTestScreen> {
  String? _selectedSubjectId;
  String? _selectedChapterId;
  String? _selectedTopicId;
  String? _selectedDifficulty;

  int _questionCount = 10;
  int _durationMinutes = 15;

  List<Question> _loadedQuestions = [];
  final Set<String> _selectedQuestionIds = {};

  bool _isLoadingQuestions = false;
  bool _isCreatingTest = false;

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(
      subjectsProvider(widget.examId),
    );

    final chaptersAsync = _selectedSubjectId == null
        ? null
        : ref.watch(
            chaptersProvider(_selectedSubjectId!),
          );

    final topicsAsync = _selectedChapterId == null
        ? null
        : ref.watch(
            topicsProvider(_selectedChapterId!),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            32,
          ),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildTestDetailsCard(context),
            const SizedBox(height: 16),
            _buildScopeCard(
              context,
              subjectsAsync,
              chaptersAsync,
              topicsAsync,
            ),
            const SizedBox(height: 16),
            _buildDifficultyCard(context),
            const SizedBox(height: 16),
            _buildQuestionCountCard(context),
            const SizedBox(height: 16),
            _buildDurationCard(context),
            const SizedBox(height: 24),
            _buildLoadQuestionsButton(context),
            const SizedBox(height: 24),
            if (_loadedQuestions.isNotEmpty)
              _buildQuestionSelectionCard(context),
            if (_loadedQuestions.isNotEmpty)
              const SizedBox(height: 24),
            if (_loadedQuestions.isNotEmpty)
              _buildCreateTestButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build your test',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.examName == null
              ? 'Choose your preparation scope and questions.'
              : 'Create a ${widget.examName} practice test.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTestDetailsCard(BuildContext context) {
    return _SectionCard(
      title: 'Test details',
      icon: Icons.edit_note_rounded,
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Test title',
              hintText: 'e.g. Physics Revision Test',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Optional test description',
              prefixIcon: Icon(Icons.notes_rounded),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeCard(
    BuildContext context,
    AsyncValue<List<Subject>> subjectsAsync,
    AsyncValue<List<Chapter>>? chaptersAsync,
    AsyncValue<List<Topic>>? topicsAsync,
  ) {
    return _SectionCard(
      title: 'Question scope',
      icon: Icons.account_tree_rounded,
      child: Column(
        children: [
          subjectsAsync.when(
            loading: () => const _LoadingField(
              label: 'Subject',
            ),
            error: (error, stackTrace) => _ErrorField(
              label: 'Subject',
              message: 'Unable to load subjects.',
            ),
            data: (subjects) {
              return DropdownButtonFormField<String?>(
                initialValue: _selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(Icons.menu_book_rounded),
                ),
                hint: const Text('All subjects'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All subjects'),
                  ),
                  ...subjects.map(
                    (subject) => DropdownMenuItem<String?>(
                      value: subject.id,
                      child: Text(subject.name),
                    ),
                  ),
                ],
                onChanged: _onSubjectChanged,
              );
            },
          ),
          const SizedBox(height: 14),
          if (_selectedSubjectId != null)
            chaptersAsync!.when(
              loading: () => const _LoadingField(
                label: 'Chapter',
              ),
              error: (error, stackTrace) => _ErrorField(
                label: 'Chapter',
                message: 'Unable to load chapters.',
              ),
              data: (chapters) {
                return DropdownButtonFormField<String?>(
                  initialValue: _selectedChapterId,
                  decoration: const InputDecoration(
                    labelText: 'Chapter',
                    prefixIcon: Icon(Icons.layers_rounded),
                  ),
                  hint: const Text('All chapters'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All chapters'),
                    ),
                    ...chapters.map(
                      (chapter) => DropdownMenuItem<String?>(
                        value: chapter.id,
                        child: Text(chapter.name),
                      ),
                    ),
                  ],
                  onChanged: _onChapterChanged,
                );
              },
            ),
          if (_selectedSubjectId != null)
            const SizedBox(height: 14),
          if (_selectedChapterId != null)
            topicsAsync!.when(
              loading: () => const _LoadingField(
                label: 'Topic',
              ),
              error: (error, stackTrace) => _ErrorField(
                label: 'Topic',
                message: 'Unable to load topics.',
              ),
              data: (topics) {
                return DropdownButtonFormField<String?>(
                  initialValue: _selectedTopicId,
                  decoration: const InputDecoration(
                    labelText: 'Topic',
                    prefixIcon: Icon(Icons.topic_rounded),
                  ),
                  hint: const Text('All topics'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All topics'),
                    ),
                    ...topics.map(
                      (topic) => DropdownMenuItem<String?>(
                        value: topic.id,
                        child: Text(topic.name),
                      ),
                    ),
                  ],
                  onChanged: _onTopicChanged,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(BuildContext context) {
    return _SectionCard(
      title: 'Difficulty',
      icon: Icons.speed_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ChoiceChip(
            label: 'All',
            selected: _selectedDifficulty == null,
            onSelected: () {
              setState(() {
                _selectedDifficulty = null;
              });
            },
          ),
          _ChoiceChip(
            label: 'Easy',
            selected: _selectedDifficulty == 'easy',
            onSelected: () {
              setState(() {
                _selectedDifficulty = 'easy';
              });
            },
          ),
          _ChoiceChip(
            label: 'Medium',
            selected: _selectedDifficulty == 'medium',
            onSelected: () {
              setState(() {
                _selectedDifficulty = 'medium';
              });
            },
          ),
          _ChoiceChip(
            label: 'Hard',
            selected: _selectedDifficulty == 'hard',
            onSelected: () {
              setState(() {
                _selectedDifficulty = 'hard';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCountCard(BuildContext context) {
    return _SectionCard(
      title: 'Number of questions',
      icon: Icons.format_list_numbered_rounded,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_questionCount questions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '5 - 50',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Slider(
            min: 5,
            max: 50,
            divisions: 9,
            value: _questionCount.toDouble(),
            label: '$_questionCount',
            onChanged: (value) {
              setState(() {
                _questionCount = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard(BuildContext context) {
    return _SectionCard(
      title: 'Test duration',
      icon: Icons.timer_outlined,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_durationMinutes minutes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '5 - 180 min',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Slider(
            min: 5,
            max: 180,
            divisions: 35,
            value: _durationMinutes.toDouble(),
            label: '$_durationMinutes min',
            onChanged: (value) {
              setState(() {
                _durationMinutes = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadQuestionsButton(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: _isLoadingQuestions ? null : _loadQuestions,
        icon: _isLoadingQuestions
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.search_rounded),
        label: Text(
          _isLoadingQuestions
              ? 'Loading questions...'
              : 'Load questions',
        ),
      ),
    );
  }

  Widget _buildQuestionSelectionCard(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'Select questions',
      icon: Icons.checklist_rounded,
      trailing: Text(
        '${_selectedQuestionIds.length}/${_loadedQuestions.length}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
      child: Column(
        children: [
          if (_loadedQuestions.length < _questionCount)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Only ${_loadedQuestions.length} matching questions '
                'were found.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          Row(
            children: [
              TextButton(
                onPressed: _selectAllQuestions,
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: _clearQuestionSelection,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ..._loadedQuestions.asMap().entries.map(
                (entry) => _buildQuestionTile(
                  context,
                  entry.key,
                  entry.value,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildQuestionTile(
    BuildContext context,
    int index,
    Question question,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedQuestionIds.contains(question.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(14),
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : null,
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) {
          _toggleQuestion(question.id);
        },
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          '${index + 1}. ${question.questionText}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${question.subjectName} • '
            '${question.chapterName} • '
            '${question.topicName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTestButton(BuildContext context) {
    final selectedCount = _selectedQuestionIds.length;

    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed: _isCreatingTest || selectedCount == 0
            ? null
            : _createTest,
        icon: _isCreatingTest
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.auto_awesome_rounded),
        label: Text(
          _isCreatingTest
              ? 'Creating test...'
              : 'Create test ($selectedCount questions)',
        ),
      ),
    );
  }

  void _onSubjectChanged(String? value) {
    setState(() {
      _selectedSubjectId = value;
      _selectedChapterId = null;
      _selectedTopicId = null;
      _clearLoadedQuestions();
    });
  }

  void _onChapterChanged(String? value) {
    setState(() {
      _selectedChapterId = value;
      _selectedTopicId = null;
      _clearLoadedQuestions();
    });
  }

  void _onTopicChanged(String? value) {
    setState(() {
      _selectedTopicId = value;
      _clearLoadedQuestions();
    });
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
      _selectedQuestionIds.clear();
    });

    try {
      final filter = QuestionFilter(
        examId: widget.examId,
        subjectId: _selectedSubjectId,
        chapterId: _selectedChapterId,
        topicId: _selectedTopicId,
        difficulty: _selectedDifficulty,
        limit: _questionCount,
      );

      final questions = await ref.read(
        questionsProvider(filter).future,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loadedQuestions = questions;
        _isLoadingQuestions = false;
      });

      if (questions.isEmpty) {
        _showMessage(
          'No questions matched the selected filters.',
        );
        return;
      }

      _selectFirstAvailableQuestions();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingQuestions = false;
      });

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _createTest() async {
  if (_selectedQuestionIds.isEmpty) {
    _showMessage('Select at least one question.');
    return;
  }

  final title = _titleController.text.trim();

  if (title.isEmpty) {
    _showMessage('Enter a title for the test.');
    return;
  }

  setState(() {
    _isCreatingTest = true;
  });

  try {
    final repository = ref.read(testRepositoryProvider);

    final test = await repository.createTest(
      examId: widget.examId,
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      questionIds: _selectedQuestionIds.toList(),
      durationMinutes: _durationMinutes,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isCreatingTest = false;
    });

    context.push(
      AppRoutes.testPreviewFor(test.id),
    );
  } catch (error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isCreatingTest = false;
    });

    _showMessage(
      error.toString().replaceFirst('Exception: ', ''),
    );
  }
}

  void _selectFirstAvailableQuestions() {
    final count = _questionCount.clamp(
      0,
      _loadedQuestions.length,
    );

    setState(() {
      _selectedQuestionIds
        ..clear()
        ..addAll(
          _loadedQuestions
              .take(count)
              .map((question) => question.id),
        );
    });
  }

  void _selectAllQuestions() {
    setState(() {
      _selectedQuestionIds
        ..clear()
        ..addAll(
          _loadedQuestions.map((question) => question.id),
        );
    });
  }

  void _clearQuestionSelection() {
    setState(() {
      _selectedQuestionIds.clear();
    });
  }

  void _toggleQuestion(String questionId) {
    setState(() {
      if (_selectedQuestionIds.contains(questionId)) {
        _selectedQuestionIds.remove(questionId);
      } else {
        _selectedQuestionIds.add(questionId);
      }
    });
  }

  void _clearLoadedQuestions() {
    _loadedQuestions = [];
    _selectedQuestionIds.clear();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _LoadingField extends StatelessWidget {
  const _LoadingField({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.hourglass_top_rounded),
      ),
      child: const SizedBox(
        height: 20,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorField extends StatelessWidget {
  const _ErrorField({
    required this.label,
    required this.message,
  });

  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.error_outline_rounded),
      ),
      child: Text(message),
    );
  }
}