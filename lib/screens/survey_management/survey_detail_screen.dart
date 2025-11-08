import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/survey_detail_provider.dart';
import '../../models/survey_model.dart';
import '../../models/question_model.dart';
import '../../constants/colors.dart';

class SurveyDetailScreen extends StatefulWidget {
  final SurveyModel survey;

  const SurveyDetailScreen({
    super.key,
    required this.survey,
  });

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SurveyDetailProvider _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _provider = SurveyDetailProvider();
    _provider.loadSurvey(widget.survey);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.survey.title),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          actions: [
            // Undo
            Consumer<SurveyDetailProvider>(
              builder: (context, provider, _) {
                return IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: provider.canUndo ? provider.undo : null,
                  tooltip: 'Undo',
                );
              },
            ),
            // Redo
            Consumer<SurveyDetailProvider>(
              builder: (context, provider, _) {
                return IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: provider.canRedo ? provider.redo : null,
                  tooltip: 'Redo',
                );
              },
            ),
            // Preview Toggle
            Consumer<SurveyDetailProvider>(
              builder: (context, provider, _) {
                return IconButton(
                  icon: Icon(
                    provider.showPreview 
                        ? Icons.visibility_off 
                        : Icons.visibility,
                  ),
                  onPressed: provider.togglePreview,
                  tooltip: provider.showPreview ? 'Hide Preview' : 'Show Preview',
                );
              },
            ),
            // Share (Coming Soon)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share - Coming Soon')),
                );
              },
              tooltip: 'Share',
            ),
            // Publish
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showPublishDialog();
                },
                icon: const Icon(Icons.publish, size: 18),
                label: const Text('Publish'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Questions'),
              Tab(text: 'Responses'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildQuestionsTab(),
            _buildResponsesTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsTab() {
    return Consumer<SurveyDetailProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Survey Title & Description Card
            _SurveyHeaderCard(
              title: provider.surveyTitle,
              description: provider.surveyDescription,
              onTitleChanged: provider.updateTitle,
              onDescriptionChanged: provider.updateDescription,
            ),

            const SizedBox(height: 12),

            // Questions with ReorderableListView
            if (!provider.showPreview && provider.questions.isNotEmpty)
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.questions.length,
                onReorder: (oldIndex, newIndex) {
                  provider.reorderQuestions(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final question = provider.questions[index];
                  return Column(
                    key: ValueKey(question.id),
                    children: [
                      _QuestionCard(
                        question: question,
                        questionNumber: index + 1,
                        showPreview: false,
                        onUpdate: (updated) => provider.updateQuestion(question.id, updated),
                        onDuplicate: () => provider.duplicateQuestion(question.id),
                        onDelete: () => provider.deleteQuestion(question.id),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              )
            else if (provider.showPreview)
              // Preview mode (no reordering)
              ...provider.questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return Column(
                  children: [
                    _QuestionCard(
                      question: question,
                      questionNumber: index + 1,
                      showPreview: true,
                      onUpdate: (updated) => provider.updateQuestion(question.id, updated),
                      onDuplicate: () => provider.duplicateQuestion(question.id),
                      onDelete: () => provider.deleteQuestion(question.id),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }),

            // Add Question Button
            _AddQuestionButton(
              onTap: () => provider.addQuestion(),
            ),

            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  Widget _buildResponsesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.poll_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No responses yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Responses will appear here once\nthe survey is published',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Collect email addresses'),
                value: false,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Limit to 1 response'),
                value: false,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Edit after submit'),
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPublishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Survey'),
        content: const Text(
          'Are you sure you want to publish this survey? '
          'It will be available to respondents.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Survey published successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }
}

// Survey Header Card (Title & Description)
class _SurveyHeaderCard extends StatefulWidget {
  final String title;
  final String description;
  final Function(String) onTitleChanged;
  final Function(String) onDescriptionChanged;

  const _SurveyHeaderCard({
    required this.title,
    required this.description,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
  });

  @override
  State<_SurveyHeaderCard> createState() => _SurveyHeaderCardState();
}

class _SurveyHeaderCardState extends State<_SurveyHeaderCard> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.primary, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Survey Title',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onTitleChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Survey description',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onDescriptionChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// Question Card
class _QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final int questionNumber;
  final bool showPreview;
  final Function(QuestionModel) onUpdate;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.showPreview,
    required this.onUpdate,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _titleController;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.question.title);
    _initializeOptionControllers();
  }

  void _initializeOptionControllers() {
    _optionControllers.clear();
    for (var option in widget.question.options) {
      _optionControllers.add(TextEditingController(text: option));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag Handle (Left side)
        if (!widget.showPreview)
          Container(
            margin: const EdgeInsets.only(top: 24, right: 8),
            child: ReorderableDragStartListener(
              index: widget.questionNumber - 1,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.drag_indicator,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

        // Main Question Card
        Expanded(
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Title
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Question ${widget.questionNumber}',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      widget.onUpdate(widget.question.copyWith(title: value));
                    },
                  ),

                  const SizedBox(height: 16),

                  // Question Type Selector
                  if (!widget.showPreview) ...[
                    _QuestionTypeSelector(
                      currentType: widget.question.questionType,
                      onChanged: (type) {
                        widget.onUpdate(widget.question.copyWith(questionType: type));
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Question Options based on type
                  _buildQuestionOptions(),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Action Buttons
                  if (!widget.showPreview)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.content_copy, size: 20),
                          onPressed: widget.onDuplicate,
                          tooltip: 'Duplicate',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: widget.onDelete,
                          color: AppColors.error,
                          tooltip: 'Delete',
                        ),
                        const SizedBox(width: 8),
                        const Text('Required'),
                        Switch(
                          value: widget.question.isRequired,
                          onChanged: (value) {
                            widget.onUpdate(widget.question.copyWith(isRequired: value));
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),

        // Add Question Button (Right side)
        if (!widget.showPreview) ...[
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(top: 24),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                onTap: () {
                  context.read<SurveyDetailProvider>().addQuestion(
                    afterIndex: widget.questionNumber - 1,
                  );
                },
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.add, size: 24),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionOptions() {
    switch (widget.question.questionType) {
      case 'multiple_choice':
        return _buildMultipleChoiceOptions();
      case 'checkbox':
        return _buildCheckboxOptions();
      case 'short_answer':
        return _buildShortAnswerPreview();
      case 'paragraph':
        return _buildParagraphPreview();
      case 'linear_scale':
        return _buildLinearScaleOptions();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMultipleChoiceOptions() {
    return Column(
      children: [
        ..._optionControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue: -1,
                  onChanged: widget.showPreview ? null : (_) {}, // ignore: deprecated_member_use
                ),
                Expanded(
                  child: widget.showPreview
                      ? Text(controller.text)
                      : TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Option ${index + 1}',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) => _updateOptions(),
                        ),
                ),
                if (!widget.showPreview)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _removeOption(index),
                  ),
              ],
            ),
          );
        }),
        if (!widget.showPreview)
          Row(
            children: [
              Radio<int>(value: -1, groupValue: -1, onChanged: null), // ignore: deprecated_member_use
              TextButton(
                onPressed: _addOption,
                child: const Text('Add option'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCheckboxOptions() {
    return Column(
      children: [
        ..._optionControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: widget.showPreview ? null : (_) {}, // ignore: deprecated_member_use
                ),
                Expanded(
                  child: widget.showPreview
                      ? Text(controller.text)
                      : TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Option ${index + 1}',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) => _updateOptions(),
                        ),
                ),
                if (!widget.showPreview)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _removeOption(index),
                  ),
              ],
            ),
          );
        }),
        if (!widget.showPreview)
          Row(
            children: [
              Checkbox(value: false, onChanged: null), // ignore: deprecated_member_use
              TextButton(
                onPressed: _addOption,
                child: const Text('Add option'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildShortAnswerPreview() {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Short answer text',
        border: UnderlineInputBorder(),
      ),
      enabled: widget.showPreview,
    );
  }

  Widget _buildParagraphPreview() {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Long answer text',
        border: UnderlineInputBorder(),
      ),
      maxLines: 3,
      enabled: widget.showPreview,
    );
  }

  Widget _buildLinearScaleOptions() {
    final min = widget.question.linearScaleMin ?? 1;
    final max = widget.question.linearScaleMax ?? 5;

    return Column(
      children: [
        Row(
          children: [
            Text('$min'),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(max - min + 1, (index) {
                  return Radio<int>(
                    value: min + index,
                    groupValue: -1,
                    onChanged: widget.showPreview ? null : (_) {}, // ignore: deprecated_member_use
                  );
                }),
              ),
            ),
            Text('$max'),
          ],
        ),
        if (!widget.showPreview) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Label (optional)',
                    labelText: '$min',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Label (optional)',
                    labelText: '$max',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _addOption() {
    final newOptions = List<String>.from(widget.question.options);
    newOptions.add('Option ${newOptions.length + 1}');
    _optionControllers.add(TextEditingController(text: newOptions.last));
    widget.onUpdate(widget.question.copyWith(options: newOptions));
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 1) {
      final newOptions = List<String>.from(widget.question.options);
      newOptions.removeAt(index);
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      widget.onUpdate(widget.question.copyWith(options: newOptions));
    }
  }

  void _updateOptions() {
    final newOptions = _optionControllers.map((c) => c.text).toList();
    widget.onUpdate(widget.question.copyWith(options: newOptions));
  }
}

// Question Type Selector
class _QuestionTypeSelector extends StatelessWidget {
  final String currentType;
  final Function(String) onChanged;

  const _QuestionTypeSelector({
    required this.currentType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: currentType,
        isExpanded: true,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: 'multiple_choice',
            child: Row(
              children: [
                Icon(Icons.radio_button_checked, size: 20),
                SizedBox(width: 8),
                Text('Multiple Choice'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'checkbox',
            child: Row(
              children: [
                Icon(Icons.check_box, size: 20),
                SizedBox(width: 8),
                Text('Checkboxes'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'short_answer',
            child: Row(
              children: [
                Icon(Icons.short_text, size: 20),
                SizedBox(width: 8),
                Text('Short Answer'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'paragraph',
            child: Row(
              children: [
                Icon(Icons.subject, size: 20),
                SizedBox(width: 8),
                Text('Paragraph'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'linear_scale',
            child: Row(
              children: [
                Icon(Icons.linear_scale, size: 20),
                SizedBox(width: 8),
                Text('Linear Scale'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

// Add Question Button
class _AddQuestionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddQuestionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
