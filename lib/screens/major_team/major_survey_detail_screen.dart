import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/app_drawer.dart';
import '../../models/section_model.dart';

/// Model untuk responden survey (untuk daftar tabel)
class _SurveyRespondent {
  final int id;
  final String name;
  final String email;
  final String nim;
  final DateTime? completedAt;

  _SurveyRespondent({
    required this.id,
    required this.name,
    required this.email,
    required this.nim,
    this.completedAt,
  });
}

class MajorSurveyDetailScreen extends StatefulWidget {
  final int surveyId;
  final String surveyTitle;

  const MajorSurveyDetailScreen({
    super.key,
    required this.surveyId,
    required this.surveyTitle,
  });

  @override
  State<MajorSurveyDetailScreen> createState() => _MajorSurveyDetailScreenState();
}

class _MajorSurveyDetailScreenState extends State<MajorSurveyDetailScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  bool _isLoading = false;
  bool _hasChanges = false;
  
  // Expansion state
  bool _isTracerQuestionsExpanded = false;
  bool _isAdditionalQuestionsExpanded = true;
  
  // Tracer Team Questions (read-only)
  List<SectionModel> _tracerSections = [];
  
  // Major Team Additional Questions (editable) - flat list, no sections
  List<QuestionModel> _additionalQuestions = [];
  int _nextQuestionTempId = -1;

  // Responses tab state
  List<_SurveyRespondent> _respondents = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _perPage = 10;
  int _totalRespondents = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadSurveyData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _respondents.isEmpty) {
      _loadRespondents();
    }
  }

  void _loadSurveyData() {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load from API
    // Dummy data for tracer team questions
    _tracerSections = [
      SectionModel(
        id: 1,
        title: 'Data Diri',
        description: 'Informasi dasar tentang alumni',
        order: 1,
        questions: [
          QuestionModel(
            id: 1,
            type: QuestionType.shortAnswer,
            question: 'Nama Lengkap',
            required: true,
          ),
          QuestionModel(
            id: 2,
            type: QuestionType.shortAnswer,
            question: 'NIM',
            required: true,
          ),
          QuestionModel(
            id: 3,
            type: QuestionType.multipleChoice,
            question: 'Jenis Kelamin',
            required: true,
            options: [
              QuestionOption(label: 'Laki-laki', value: 'L'),
              QuestionOption(label: 'Perempuan', value: 'P'),
            ],
          ),
        ],
      ),
      SectionModel(
        id: 2,
        title: 'Status Pekerjaan',
        description: 'Informasi tentang pekerjaan saat ini',
        order: 2,
        questions: [
          QuestionModel(
            id: 4,
            type: QuestionType.multipleChoice,
            question: 'Status Pekerjaan Saat Ini',
            required: true,
            options: [
              QuestionOption(label: 'Bekerja', value: 'bekerja'),
              QuestionOption(label: 'Wiraswasta', value: 'wiraswasta'),
              QuestionOption(label: 'Melanjutkan Studi', value: 'studi'),
              QuestionOption(label: 'Belum Bekerja', value: 'belum'),
            ],
          ),
          QuestionModel(
            id: 5,
            type: QuestionType.paragraph,
            question: 'Deskripsi Pekerjaan',
            required: false,
          ),
        ],
      ),
    ];

    // Dummy data for additional questions from major team
    _additionalQuestions = [];

    setState(() {
      _isLoading = false;
    });
  }

  void _loadRespondents() {
    // TODO: Load from API - GET /{panel}/surveys/{id}/responses or similar
    // For now, using dummy data
    setState(() {
      _totalRespondents = 8;
      _respondents = [
        _SurveyRespondent(
          id: 1,
          name: 'Dr. Porter Stroman DVM',
          email: 'bill92@mccullough.info',
          nim: '77724655',
          completedAt: DateTime(2024, 3, 15, 10, 30),
        ),
        _SurveyRespondent(
          id: 2,
          name: 'Stefanie Schneider Sr.',
          email: 'krystal.predovic@predovic.com',
          nim: '81339854',
          completedAt: DateTime(2024, 3, 14, 14, 45),
        ),
        _SurveyRespondent(
          id: 3,
          name: 'Prof. Henri Mitchell',
          email: 'celestine73@hotmail.com',
          nim: '82810714',
          completedAt: DateTime(2024, 3, 13, 9, 15),
        ),
        _SurveyRespondent(
          id: 4,
          name: 'Janis Orn DDS',
          email: 'norval00@schuppe.info',
          nim: '12426901',
          completedAt: DateTime(2024, 3, 12, 16, 20),
        ),
        _SurveyRespondent(
          id: 5,
          name: 'Miss Jayda Howell MD',
          email: 'cole.sedrick@gmail.com',
          nim: '85610187',
          completedAt: DateTime(2024, 3, 11, 11, 0),
        ),
        _SurveyRespondent(
          id: 6,
          name: 'Jerome Pouros',
          email: 'aschmitt@durgan.net',
          nim: '23370281',
          completedAt: DateTime(2024, 3, 10, 13, 30),
        ),
        _SurveyRespondent(
          id: 7,
          name: 'Myrtice Braun MD',
          email: 'lbotsford@yahoo.com',
          nim: '12056221',
          completedAt: DateTime(2024, 3, 9, 8, 45),
        ),
        _SurveyRespondent(
          id: 8,
          name: 'Tina Wolff',
          email: 'zelda.moore@brown.biz',
          nim: '15523372',
          completedAt: DateTime(2024, 3, 8, 15, 10),
        ),
      ];
    });
  }

  List<_SurveyRespondent> get _filteredRespondents {
    if (_searchQuery.isEmpty) {
      return _respondents;
    }
    return _respondents.where((r) {
      final query = _searchQuery.toLowerCase();
      return r.name.toLowerCase().contains(query) ||
          r.email.toLowerCase().contains(query) ||
          r.nim.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _saveChanges() async {
    // Validate questions before saving
    final validationError = _validateQuestions();
    if (validationError != null) {
      _showValidationError(validationError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Call API to save changes
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pertanyaan tambahan berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _hasChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBack() async {
    if (_hasChanges) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Perubahan Belum Disimpan'),
          content: const Text('Ada perubahan yang belum disimpan. Yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Keluar'),
            ),
          ],
        ),
      );
      
      if (shouldLeave == true && mounted) {
        context.go('/major-survey-management');
      }
    } else {
      context.go('/major-survey-management');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Perubahan Belum Disimpan'),
            content: const Text('Ada perubahan yang belum disimpan. Yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Keluar'),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          context.go('/major-survey-management');
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Survey Management'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBack(),
          ),
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            // Breadcrumb & Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
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
              GestureDetector(
                onTap: () => context.go('/major-survey-management'),
                child: Text(
                  'Survey Management',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
              ),
              Flexible(
                child: Text(
                  widget.surveyTitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
              ),
              Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Title and Actions Row
          Row(
            children: [
              Expanded(
                child: Text(
                  'Edit ${widget.surveyTitle}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Action buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _hasChanges ? _saveChanges : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Questions'),
                Tab(text: 'Responses'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildQuestionsTab(),
        _buildResponsesTab(),
      ],
    );
  }

  Widget _buildQuestionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Pertanyaan Tim Tracer (Read-only)
          _buildCollapsibleSection(
            title: 'Pertanyaan Tim Tracer',
            subtitle: 'Klik untuk melihat/menyembunyikan',
            isExpanded: _isTracerQuestionsExpanded,
            onToggle: () {
              setState(() {
                _isTracerQuestionsExpanded = !_isTracerQuestionsExpanded;
              });
            },
            child: _buildTracerQuestions(),
          ),
          
          const SizedBox(height: 16),
          
          // Pertanyaan Tambahan (Editable) - Direct questions, no sections
          _buildCollapsibleSection(
            title: 'Pertanyaan Tambahan',
            subtitle: 'Buat pertanyaan tambahan untuk prodi',
            isExpanded: _isAdditionalQuestionsExpanded,
            onToggle: () {
              setState(() {
                _isAdditionalQuestionsExpanded = !_isAdditionalQuestionsExpanded;
              });
            },
            child: _buildAdditionalQuestionsBuilder(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  // ========== TRACER QUESTIONS (READ-ONLY) ==========
  
  Widget _buildTracerQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pertanyaan ini dibuat oleh Tim Tracer dan tidak dapat diubah.',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Sections
        ..._tracerSections.map((section) => _buildTracerSectionCard(section)),
      ],
    );
  }

  Widget _buildTracerSectionCard(SectionModel section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Section ${section.order}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (section.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              section.description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          
          // Questions
          ...section.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildTracerQuestionItem(question, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildTracerQuestionItem(QuestionModel question, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            question.question,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (question.required)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Required',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        question.type.displayName,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    
                    // Show options if applicable
                    if (question.options.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: question.options.map((opt) {
                          return Chip(
                            label: Text(opt.label, style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                          );
                        }).toList(),
                      ),
                    ],
                    
                    // Show linear scale info
                    if (question.type == QuestionType.linearScale) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${question.fromValue} (${question.fromLabel}) - ${question.toValue} (${question.toLabel})',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== ADDITIONAL QUESTIONS BUILDER (EDITABLE) ==========
  // Direct questions list without sections

  Widget _buildAdditionalQuestionsBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Question button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Question'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Questions List
        if (_additionalQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.quiz_outlined, 
                    size: 48, 
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada pertanyaan tambahan',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klik "Add Question" untuk menambah pertanyaan',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _additionalQuestions.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _additionalQuestions.removeAt(oldIndex);
                _additionalQuestions.insert(newIndex, item);
                _hasChanges = true;
              });
            },
            itemBuilder: (context, qIndex) {
              final question = _additionalQuestions[qIndex];
              return Container(
                key: ObjectKey(question),
                child: _buildQuestionCard(question, qIndex),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionModel question, int qIndex) {
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
              ReorderableDragStartListener(
                index: qIndex,
                child: const Icon(Icons.drag_handle, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
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
                onPressed: () => _deleteQuestion(qIndex),
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
                    question.hasCondition = false;
                  }
                  if (value != QuestionType.linearScale) {
                    question.fromLabel = null;
                    question.fromValue = null;
                    question.toLabel = null;
                    question.toValue = null;
                  } else {
                    // Initialize linear scale defaults
                    question.fromValue ??= 1;
                    question.toValue ??= 5;
                    question.fromLabel ??= '';
                    question.toLabel ??= '';
                  }
                  _hasChanges = true;
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
              hintText: 'Masukkan pertanyaan',
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
              _hasChanges = true;
            },
          ),
          const SizedBox(height: 12),

          // Required and Has Condition Checkboxes
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: question.required,
                    onChanged: (value) {
                      setState(() {
                        question.required = value ?? false;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const Text('Required'),
                ],
              ),
              // Show Has Condition only for Multiple Choice and Checkboxes
              if (question.type == QuestionType.multipleChoice || 
                  question.type == QuestionType.checkboxes)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: question.hasCondition,
                      onChanged: (value) {
                        setState(() {
                          question.hasCondition = value ?? false;
                          // If enabling hasCondition and options don't have values yet, initialize them
                          if (question.hasCondition) {
                            for (var opt in question.options) {
                              if (opt.value.isEmpty) {
                                opt.value = opt.label;
                              }
                            }
                          }
                          _hasChanges = true;
                        });
                      },
                    ),
                    const Text('Has Condition'),
                  ],
                ),
            ],
          ),

          // Type-specific fields
          _buildTypeSpecificFields(question, qIndex),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificFields(QuestionModel question, int qIndex) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.checkboxes:
        return _buildOptionsField(question, qIndex);
      case QuestionType.linearScale:
        return _buildLinearScaleFields(question);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOptionsField(QuestionModel question, int qIndex) {
    // If hasCondition is false, show simple list
    if (!question.hasCondition) {
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
                onPressed: () => _addOption(qIndex),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Option'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Simple Options List
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
                          option.value = value;
                          _hasChanges = true;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _deleteOption(qIndex, optIndex),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
    
    // If hasCondition is true, show advanced layout with Label, Value columns
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
              onPressed: () => _addOption(qIndex),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add to options'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Options table
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 28), // For drag handle
                    Expanded(
                      flex: 2,
                      child: Text('Label', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Text('Value', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                    ),
                    const SizedBox(width: 40), // For delete button
                  ],
                ),
              ),
              
              // Options List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: question.options.length,
                itemBuilder: (context, optIndex) {
                  final option = question.options[optIndex];
                  return _buildOptionRow(
                    option: option,
                    optIndex: optIndex,
                    qIndex: qIndex,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionRow({
    required QuestionOption option,
    required int optIndex,
    required int qIndex,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // Drag Handle
          const Icon(Icons.drag_indicator, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 8),
            
          // Label Field
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: option.label,
              decoration: InputDecoration(
                hintText: 'Label',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: (value) {
                option.label = value;
                _hasChanges = true;
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // Value Field
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: option.value,
              decoration: InputDecoration(
                hintText: 'Value',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: (value) {
                option.value = value;
                _hasChanges = true;
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _deleteOption(qIndex, optIndex),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
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
                  _hasChanges = true;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: question.fromLabel ?? '',
                decoration: InputDecoration(
                  labelText: 'From Label',
                  hintText: 'e.g., Sangat Tidak Setuju',
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
                  _hasChanges = true;
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
                  _hasChanges = true;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: question.toLabel ?? '',
                decoration: InputDecoration(
                  labelText: 'To Label',
                  hintText: 'e.g., Sangat Setuju',
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
                  _hasChanges = true;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== QUESTION OPERATIONS ==========

  void _addQuestion() {
    setState(() {
      _additionalQuestions.add(QuestionModel(
        id: _nextQuestionTempId--,
        type: QuestionType.shortAnswer,
        question: '',
        required: false,
        hasCondition: false,
        options: [],
      ));
      _hasChanges = true;
    });
  }

  void _deleteQuestion(int qIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _additionalQuestions.removeAt(qIndex);
                _hasChanges = true;
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addOption(int qIndex) {
    setState(() {
      _additionalQuestions[qIndex].options.add(
        QuestionOption(
          label: '',
          value: '',
        ),
      );
      _hasChanges = true;
    });
  }

  void _deleteOption(int qIndex, int optIndex) {
    setState(() {
      _additionalQuestions[qIndex].options.removeAt(optIndex);
      _hasChanges = true;
    });
  }

  // ========== VALIDATION ==========

  String? _validateQuestions() {
    if (_additionalQuestions.isEmpty) {
      return null; // OK to have no additional questions
    }

    for (int i = 0; i < _additionalQuestions.length; i++) {
      final question = _additionalQuestions[i];
      final questionNum = i + 1;

      // Validate question text
      if (question.question.trim().isEmpty) {
        return 'Question $questionNum: Question text is required';
      }

      // Validate type-specific fields
      if (question.type == QuestionType.multipleChoice || 
          question.type == QuestionType.checkboxes) {
        
        // Validate has options
        if (question.options.isEmpty) {
          return 'Question $questionNum: Please add at least 2 options';
        }

        // Validate minimum 2 options
        if (question.options.length < 2) {
          return 'Question $questionNum: ${question.type.displayName} requires at least 2 options';
        }

        // Validate each option has label
        for (int k = 0; k < question.options.length; k++) {
          final option = question.options[k];
          if (option.label.trim().isEmpty) {
            return 'Question $questionNum, Option ${k + 1}: Option text is required';
          }
        }
      }

      if (question.type == QuestionType.linearScale) {
        // Validate from value
        if (question.fromValue == null) {
          return 'Question $questionNum: From Value is required';
        }

        // Validate to value
        if (question.toValue == null) {
          return 'Question $questionNum: To Value is required';
        }

        // Validate from != to
        if (question.fromValue == question.toValue) {
          return 'Question $questionNum: From Value and To Value must be different';
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

  // ========== RESPONSES TAB ==========

  Widget _buildResponsesTab() {
    if (_respondents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Belum ada responden',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada alumni yang mengisi survey ini',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Table
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Table Header
                _buildResponsesTableHeader(),
                
                const Divider(height: 1),
                
                // Table Body
                Expanded(
                  child: _filteredRespondents.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada hasil pencarian',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredRespondents.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final respondent = _filteredRespondents[index];
                            return _buildRespondentRow(respondent);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        // Pagination Controls
        _buildResponsesPaginationControls(),
      ],
    );
  }

  Widget _buildResponsesTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Nama',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Email',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'NIM',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          // Action column for View button
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildRespondentRow(_SurveyRespondent respondent) {
    return InkWell(
      onTap: () => _viewRespondentDetail(respondent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                respondent.name,
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      respondent.email,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                respondent.nim,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            // View Button
            SizedBox(
              width: 60,
              child: TextButton(
                onPressed: () => _viewRespondentDetail(respondent),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    const Text('View', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesPaginationControls() {
    final totalPages = (_totalRespondents / _perPage).ceil();
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Per Page Selector
          Row(
            children: [
              const Text('Per page', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<int>(
                  value: _perPage,
                  underline: const SizedBox(),
                  items: [10, 20, 50].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _perPage = value;
                        _currentPage = 1;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          // Next Button
          ElevatedButton(
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    // TODO: fetch next page
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _viewRespondentDetail(_SurveyRespondent respondent) {
    context.push(
      '/major-response-detail/${widget.surveyId}/${respondent.id}',
      extra: {
        'surveyTitle': widget.surveyTitle,
        'respondentName': respondent.name,
      },
    );
  }
}
