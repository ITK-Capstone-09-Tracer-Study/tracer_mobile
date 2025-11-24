import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/survey_provider.dart';
import '../../providers/survey_kind_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../models/section_model.dart';

class SurveyFormScreen extends StatefulWidget {
  final int? surveyId; // null untuk create, ada value untuk edit

  const SurveyFormScreen({
    super.key,
    this.surveyId,
  });

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _graduationNumberController = TextEditingController();
  
  int? _selectedKindId;
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _isLoading = false;

  // Sections state
  List<SectionModel> _sections = [];
  int _nextSectionTempId = -1; // Temporary IDs for new sections (negative numbers)

  bool get isEditing => widget.surveyId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load survey kinds
      Provider.of<SurveyKindProvider>(context, listen: false).initialize();
      
      // Load survey data if editing
      if (isEditing) {
        _loadSurveyData();
      }
    });
  }

  void _loadSurveyData() {
    final provider = Provider.of<SurveyProvider>(context, listen: false);
    final survey = provider.getSurveyById(widget.surveyId!);
    
    if (survey != null) {
      _titleController.text = survey.title;
      _descriptionController.text = survey.description;
      _graduationNumberController.text = survey.graduationNumber.toString();
      _selectedKindId = survey.kindId;
      _startedAt = survey.startedAt;
      _endedAt = survey.endedAt;
      _sections = List.from(survey.sections);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _graduationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.go('/survey-management'),
                      child: Text(
                        'Survey Management',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    Text(
                      isEditing ? 'Edit' : 'Create',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isEditing ? 'Edit Survey' : 'Create Survey',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildLabel('Title', isRequired: true),
                      TextFormField(
                        controller: _titleController,
                        decoration: _buildInputDecoration('Survey title'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Description
                      _buildLabel('Description', isRequired: true),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _buildInputDecoration('Survey description'),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Kind
                      _buildLabel('Kind', isRequired: true),
                      Consumer<SurveyKindProvider>(
                        builder: (context, kindProvider, child) {
                          if (kindProvider.isLoading) {
                            return const CircularProgressIndicator();
                          }

                          return DropdownButtonFormField<int>(
                            initialValue: _selectedKindId,
                            decoration: _buildInputDecoration('Select survey kind'),
                            items: kindProvider.surveyKinds.map((kind) {
                              return DropdownMenuItem(
                                value: kind.id,
                                child: Text(kind.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedKindId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Kind is required';
                              }
                              return null;
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Graduation Number
                      _buildLabel('Graduation Number', isRequired: true),
                      TextFormField(
                        controller: _graduationNumberController,
                        decoration: _buildInputDecoration('e.g. 2025'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Graduation number is required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Must be a valid number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Started At
                      _buildLabel('Started At', isRequired: true),
                      InkWell(
                        onTap: () => _selectDateTime(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _startedAt != null
                                      ? _formatDateTime(_startedAt!)
                                      : 'Select date & time',
                                  style: TextStyle(
                                    color: _startedAt != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_startedAt == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            'Started date is required',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Ended At
                      _buildLabel('Ended At', isRequired: true),
                      InkWell(
                        onTap: () => _selectDateTime(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _endedAt != null
                                      ? _formatDateTime(_endedAt!)
                                      : 'Select date & time',
                                  style: TextStyle(
                                    color: _endedAt != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_endedAt == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            'End date is required',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Sections Builder
                      _buildSectionsBuilder(),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(isEditing ? 'Update' : 'Create'),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.go('/survey-management'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          children: isRequired
              ? [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    // Store context before async gap
    final navigator = Navigator.of(context);
    
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: navigator.context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted || time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStartDate) {
        _startedAt = dateTime;
      } else {
        _endedAt = dateTime;
      }
    });
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
           '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSubmit() async {
    // 1. Validate basic form fields
    if (!_formKey.currentState!.validate()) {
      _showValidationError('Please fill in all required fields correctly');
      return;
    }

    // 2. Validate dates
    if (_startedAt == null || _endedAt == null) {
      _showValidationError('Please select both start and end dates');
      return;
    }

    if (_endedAt!.isBefore(_startedAt!)) {
      _showValidationError('End date must be after start date');
      return;
    }

    // 3. Validate sections
    final validationError = _validateSections();
    if (validationError != null) {
      _showValidationError(validationError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<SurveyProvider>(context, listen: false);
    
    final data = {
      'kind_id': _selectedKindId!,
      'graduation_number': int.parse(_graduationNumberController.text),
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'started_at': _startedAt!.toIso8601String(),
      'ended_at': _endedAt!.toIso8601String(),
      'sections': _sections.map((section) => section.toJson()).toList(),
    };

    bool success;
    if (isEditing) {
      success = await provider.updateSurvey(widget.surveyId!, data);
    } else {
      success = await provider.createSurvey(data);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Survey updated successfully'
                  : 'Survey created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/survey-management');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ??
                  (isEditing
                      ? 'Failed to update survey'
                      : 'Failed to create survey'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ========== SECTIONS BUILDER ==========

  Widget _buildSectionsBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Section button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sections',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _addSection,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Section'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sections List
        if (_sections.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.description_outlined, 
                    size: 48, 
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No sections yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add sections to build your survey',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sections.length,
            onReorder: _onReorderSection,
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final section = _sections[index];
              return ReorderableDragStartListener(
                key: ValueKey(section.id),
                index: index,
                child: _buildSectionCard(section, index),
              );
            },
          ),
          
          // Bottom Add Section Button
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: _addSection,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Another Section'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard(SectionModel section, int index) {
    return Card(
      key: ValueKey(section.id),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(Icons.drag_handle, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Section ${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteSection(index),
                  tooltip: 'Delete section',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section Title
            TextFormField(
              initialValue: section.title,
              decoration: InputDecoration(
                labelText: 'Section Title *',
                hintText: 'e.g., Personal Information',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                section.title = value;
              },
            ),
            const SizedBox(height: 16),

            // Section Description
            TextFormField(
              initialValue: section.description,
              decoration: InputDecoration(
                labelText: 'Section Description',
                hintText: 'Optional description for this section',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
              onChanged: (value) {
                section.description = value;
              },
            ),
            const SizedBox(height: 16),

            // Questions Builder
            _buildQuestionsBuilder(section, index),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsBuilder(SectionModel section, int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Questions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _addQuestion(sectionIndex),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Question'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Questions List
        if (section.questions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No questions yet. Click "Add Question" to start.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: section.questions.length,
            itemBuilder: (context, qIndex) {
              final question = section.questions[qIndex];
              return _buildQuestionCard(question, sectionIndex, qIndex);
            },
          ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionModel question, int sectionIndex, int qIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question ${qIndex + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _deleteQuestion(sectionIndex, qIndex),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Type Selector
          DropdownButtonFormField<QuestionType>(
            initialValue: question.type,
            decoration: InputDecoration(
              labelText: 'Question Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: QuestionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  question.type = value;
                  // Reset type-specific fields
                  if (value != QuestionType.multipleChoice && 
                      value != QuestionType.checkboxes) {
                    question.options = [];
                  }
                  if (value != QuestionType.linearScale) {
                    question.fromLabel = null;
                    question.fromValue = null;
                    question.toLabel = null;
                    question.toValue = null;
                  }
                });
              }
            },
          ),
          const SizedBox(height: 12),

          // Question Text
          TextFormField(
            initialValue: question.question,
            decoration: InputDecoration(
              labelText: 'Question Text *',
              hintText: 'Enter your question',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 2,
            onChanged: (value) {
              question.question = value;
            },
          ),
          const SizedBox(height: 12),

          // Required Checkbox
          Row(
            children: [
              Checkbox(
                value: question.required,
                onChanged: (value) {
                  setState(() {
                    question.required = value ?? false;
                  });
                },
              ),
              const Text('Required'),
            ],
          ),

          // Type-specific fields
          _buildTypeSpecificFields(question, sectionIndex, qIndex),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificFields(QuestionModel question, int sectionIndex, int qIndex) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.checkboxes:
        return _buildOptionsField(question, sectionIndex, qIndex);
      case QuestionType.linearScale:
        return _buildLinearScaleFields(question);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOptionsField(QuestionModel question, int sectionIndex, int qIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Options',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _addOption(sectionIndex, qIndex),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Option'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Options List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: question.options.length,
          itemBuilder: (context, optIndex) {
            final option = question.options[optIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: option.label,
                      decoration: InputDecoration(
                        labelText: 'Option ${optIndex + 1}',
                        hintText: 'Enter option text',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        option.label = value;
                        option.value = value; // Use label as value
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _deleteOption(sectionIndex, qIndex, optIndex),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLinearScaleFields(QuestionModel question) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: question.fromValue?.toString() ?? '1',
                decoration: InputDecoration(
                  labelText: 'From Value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  question.fromValue = int.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: question.fromLabel ?? '',
                decoration: InputDecoration(
                  labelText: 'From Label',
                  hintText: 'e.g., Poor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  question.fromLabel = value;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: question.toValue?.toString() ?? '5',
                decoration: InputDecoration(
                  labelText: 'To Value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  question.toValue = int.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: question.toLabel ?? '',
                decoration: InputDecoration(
                  labelText: 'To Label',
                  hintText: 'e.g., Excellent',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  question.toLabel = value;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== SECTION OPERATIONS ==========

  void _addSection() {
    setState(() {
      _sections.add(SectionModel(
        id: _nextSectionTempId--,
        surveyId: widget.surveyId ?? 0,
        title: '',
        description: '',
        condition: null,
        order: _sections.length,
        questions: [],
      ));
    });
  }

  void _deleteSection(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Section'),
        content: const Text('Are you sure you want to delete this section?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _sections.removeAt(index);
                // Update order
                for (int i = 0; i < _sections.length; i++) {
                  _sections[i].order = i;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onReorderSection(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final section = _sections.removeAt(oldIndex);
      _sections.insert(newIndex, section);
      
      // Update order
      for (int i = 0; i < _sections.length; i++) {
        _sections[i].order = i;
      }
    });
  }

  // ========== QUESTION OPERATIONS ==========

  void _addQuestion(int sectionIndex) {
    setState(() {
      _sections[sectionIndex].questions.add(QuestionModel(
        type: QuestionType.shortAnswer,
        question: '',
        required: false,
        hasCondition: false,
        condition: null,
        options: [],
        fromLabel: 'Poor',
        fromValue: 1,
        toLabel: 'Excellent',
        toValue: 5,
      ));
    });
  }

  void _deleteQuestion(int sectionIndex, int qIndex) {
    setState(() {
      _sections[sectionIndex].questions.removeAt(qIndex);
    });
  }

  void _addOption(int sectionIndex, int qIndex) {
    setState(() {
      _sections[sectionIndex].questions[qIndex].options.add(
        QuestionOption(
          label: '',
          value: '',
          condition: null,
        ),
      );
    });
  }

  void _deleteOption(int sectionIndex, int qIndex, int optIndex) {
    setState(() {
      _sections[sectionIndex].questions[qIndex].options.removeAt(optIndex);
    });
  }

  // ========== VALIDATION ==========

  String? _validateSections() {
    if (_sections.isEmpty) {
      return 'Please add at least one section to the survey';
    }

    for (int i = 0; i < _sections.length; i++) {
      final section = _sections[i];
      final sectionNum = i + 1;

      // Validate section title
      if (section.title.trim().isEmpty) {
        return 'Section $sectionNum: Title is required';
      }

      // Validate section has questions
      if (section.questions.isEmpty) {
        return 'Section $sectionNum: Please add at least one question';
      }

      // Validate each question
      for (int j = 0; j < section.questions.length; j++) {
        final question = section.questions[j];
        final questionNum = j + 1;

        // Validate question text
        if (question.question.trim().isEmpty) {
          return 'Section $sectionNum, Question $questionNum: Question text is required';
        }

        // Validate type-specific fields
        if (question.type == QuestionType.multipleChoice || 
            question.type == QuestionType.checkboxes) {
          
          // Validate has options
          if (question.options.isEmpty) {
            return 'Section $sectionNum, Question $questionNum: Please add at least 2 options for ${question.type.displayName}';
          }

          // Validate minimum 2 options
          if (question.options.length < 2) {
            return 'Section $sectionNum, Question $questionNum: ${question.type.displayName} requires at least 2 options';
          }

          // Validate each option has label
          for (int k = 0; k < question.options.length; k++) {
            final option = question.options[k];
            if (option.label.trim().isEmpty) {
              return 'Section $sectionNum, Question $questionNum, Option ${k + 1}: Option text is required';
            }
          }
        }

        if (question.type == QuestionType.linearScale) {
          // Validate from value
          if (question.fromValue == null) {
            return 'Section $sectionNum, Question $questionNum: From Value is required for Linear Scale';
          }

          // Validate to value
          if (question.toValue == null) {
            return 'Section $sectionNum, Question $questionNum: To Value is required for Linear Scale';
          }

          // Validate from != to (must be different values)
          if (question.fromValue == question.toValue) {
            return 'Section $sectionNum, Question $questionNum: From Value and To Value must be different';
          }

          // Note: Backend accepts any integer values (ascending or descending scale)
          // Examples: 1 to 5, 5 to 1, -10 to 10, 100 to 0, etc.
        }
      }
    }

    return null; // All validations passed
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
