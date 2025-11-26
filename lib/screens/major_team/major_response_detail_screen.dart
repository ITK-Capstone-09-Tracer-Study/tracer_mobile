import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../models/survey_response_model.dart';

/// Simple model for respondent dropdown
class SimpleRespondent {
  final int id;
  final String name;

  SimpleRespondent({required this.id, required this.name});
}

class MajorResponseDetailScreen extends StatefulWidget {
  final int surveyId;
  final int respondentId;
  final String? surveyTitle;
  final String? respondentName;

  const MajorResponseDetailScreen({
    super.key,
    required this.surveyId,
    required this.respondentId,
    this.surveyTitle,
    this.respondentName,
  });

  @override
  State<MajorResponseDetailScreen> createState() => _MajorResponseDetailScreenState();
}

class _MajorResponseDetailScreenState extends State<MajorResponseDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // Respondents list for dropdown
  List<SimpleRespondent> _respondents = [];
  int? _selectedRespondentId;
  
  // Current response data
  SurveyResponseDetailModel? _currentResponse;
  int _currentSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedRespondentId = widget.respondentId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Dummy respondents list
      _respondents = [
        SimpleRespondent(id: 1, name: 'Dr. Porter Stroman DVM'),
        SimpleRespondent(id: 2, name: 'Stefanie Schneider Sr.'),
        SimpleRespondent(id: 3, name: 'Prof. Henri Mitchell'),
        SimpleRespondent(id: 4, name: 'Janis Orn DDS'),
        SimpleRespondent(id: 5, name: 'Miss Jayda Howell MD'),
        SimpleRespondent(id: 6, name: 'Jerome Pouros'),
        SimpleRespondent(id: 7, name: 'Myrtice Braun MD'),
        SimpleRespondent(id: 8, name: 'Tina Wolff'),
      ];

      // Dummy response data
      _currentResponse = _generateDummyResponse(_selectedRespondentId ?? widget.respondentId);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
    }
  }

  SurveyResponseDetailModel _generateDummyResponse(int respondentId) {
    final respondent = _respondents.firstWhere(
      (r) => r.id == respondentId,
      orElse: () => SimpleRespondent(id: respondentId, name: 'Alumni'),
    );

    return SurveyResponseDetailModel(
      id: respondentId,
      surveyId: widget.surveyId,
      alumniId: respondentId,
      alumniName: respondent.name,
      alumniEmail: '${respondent.name.toLowerCase().replaceAll(' ', '.')}@email.com',
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      sections: [
        SectionResponseModel(
          sectionId: 1,
          title: 'Data Diri',
          description: 'Informasi dasar tentang alumni',
          order: 1,
          questions: [
            QuestionResponseModel(
              questionId: 1,
              question: 'quisquam ut dolor',
              type: 'linear_scale',
              answer: -4,
              fromValue: -4,
              toValue: 1,
              fromLabel: 'Sangat Tidak Setuju',
              toLabel: 'Sangat Setuju',
            ),
            QuestionResponseModel(
              questionId: 2,
              question: 'Ipsus modi reprehenderit in quas omnis et qui',
              type: 'multiple_choice',
              answer: 'nihil',
              options: ['nihil', 'et', 'sit'],
            ),
            QuestionResponseModel(
              questionId: 3,
              question: 'est temporibus dolores repellendus',
              type: 'paragraph',
              answer: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),
          ],
        ),
        SectionResponseModel(
          sectionId: 2,
          title: 'Status Pekerjaan',
          description: 'Informasi tentang pekerjaan saat ini',
          order: 2,
          questions: [
            QuestionResponseModel(
              questionId: 4,
              question: 'Status pekerjaan saat ini',
              type: 'multiple_choice',
              answer: 'Bekerja',
              options: ['Bekerja', 'Wiraswasta', 'Melanjutkan Studi', 'Belum Bekerja'],
            ),
            QuestionResponseModel(
              questionId: 5,
              question: 'Bidang pekerjaan yang digeluti',
              type: 'checkboxes',
              answer: ['IT/Software', 'Engineering'],
              options: ['IT/Software', 'Engineering', 'Kesehatan', 'Pendidikan', 'Lainnya'],
            ),
          ],
        ),
      ],
    );
  }

  SectionResponseModel? get _currentSection {
    if (_currentResponse == null || _currentResponse!.sections.isEmpty) {
      return null;
    }
    if (_currentSectionIndex >= _currentResponse!.sections.length) {
      return _currentResponse!.sections.last;
    }
    return _currentResponse!.sections[_currentSectionIndex];
  }

  int get _totalSections => _currentResponse?.sections.length ?? 0;
  bool get _canGoToPrevious => _currentSectionIndex > 0;
  bool get _canGoToNext => _currentSectionIndex < _totalSections - 1;

  void _goToPreviousSection() {
    if (_canGoToPrevious) {
      setState(() {
        _currentSectionIndex--;
      });
    }
  }

  void _goToNextSection() {
    if (_canGoToNext) {
      setState(() {
        _currentSectionIndex++;
      });
    }
  }

  void _selectRespondent(int respondentId) {
    setState(() {
      _selectedRespondentId = respondentId;
      _currentSectionIndex = 0;
      _currentResponse = _generateDummyResponse(respondentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Respon Alumni'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_respondents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'Tidak ada respon yang tersedia',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Text(
            'Survey Management > ${widget.surveyTitle ?? 'Survey'} > Detail Respon Alumni',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Detail Respon Alumni',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          
          const SizedBox(height: 24),
          
          // Controls section
          _buildControlsSection(),
          
          const SizedBox(height: 24),
          
          // Response content
          if (_currentResponse != null && _currentSection != null)
            _buildResponseContent(),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Respondent Dropdown
          _buildRespondentDropdown(),
          
          const SizedBox(height: 12),
          
          // Section Navigation
          _buildSectionNavigation(),
          
          const SizedBox(height: 12),
          
          // Action Buttons Row
          Row(
            children: [
              // Delete Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showDeleteConfirmation,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Export Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleExport,
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRespondentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<int>(
        value: _selectedRespondentId,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text('Pilih Alumni'),
        items: _respondents.map((respondent) {
          return DropdownMenuItem<int>(
            value: respondent.id,
            child: Text(
              respondent.name,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _selectRespondent(value);
          }
        },
      ),
    );
  }

  Widget _buildSectionNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          IconButton(
            onPressed: _canGoToPrevious ? _goToPreviousSection : null,
            icon: Icon(
              Icons.chevron_left,
              color: _canGoToPrevious ? AppColors.textPrimary : Colors.grey[300],
            ),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          
          const SizedBox(width: 16),
          
          // Section indicator
          Text(
            '${_currentSectionIndex + 1} dari $_totalSections',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Next Button
          IconButton(
            onPressed: _canGoToNext ? _goToNextSection : null,
            icon: Icon(
              Icons.chevron_right,
              color: _canGoToNext ? AppColors.textPrimary : Colors.grey[300],
            ),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseContent() {
    final section = _currentSection!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title and description
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          if (section.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              section.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // Questions and answers
          ...section.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < section.questions.length - 1 ? 32 : 0,
              ),
              child: _buildQuestionAnswer(question),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionAnswer(QuestionResponseModel question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text
        Text(
          question.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Answer based on question type
        _buildAnswerWidget(question),
      ],
    );
  }

  Widget _buildAnswerWidget(QuestionResponseModel question) {
    switch (question.type) {
      case 'short_answer':
      case 'paragraph':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            question.formattedAnswer,
            style: const TextStyle(fontSize: 14),
          ),
        );
        
      case 'multiple_choice':
        return _buildMultipleChoiceAnswer(question);
        
      case 'checkboxes':
        return _buildCheckboxesAnswer(question);
        
      case 'linear_scale':
        return _buildLinearScaleAnswer(question);
        
      default:
        return Text(
          question.formattedAnswer,
          style: const TextStyle(fontSize: 14),
        );
    }
  }

  Widget _buildMultipleChoiceAnswer(QuestionResponseModel question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: question.options?.map((option) {
        final isSelected = question.answer == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 20,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                option,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList() ?? [],
    );
  }

  Widget _buildCheckboxesAnswer(QuestionResponseModel question) {
    final selectedOptions = question.answer is List 
        ? List<String>.from(question.answer as List)
        : <String>[];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: question.options?.map((option) {
        final isSelected = selectedOptions.contains(option);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                option,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList() ?? [],
    );
  }

  Widget _buildLinearScaleAnswer(QuestionResponseModel question) {
    final selectedValue = question.answer as int;
    final fromValue = question.fromValue ?? 1;
    final toValue = question.toValue ?? 5;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scale options
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              toValue - fromValue + 1,
              (index) {
                final value = fromValue + index;
                final isSelected = value == selectedValue;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (question.fromLabel != null)
              Expanded(
                child: Text(
                  question.fromLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            if (question.toLabel != null)
              Expanded(
                child: Text(
                  question.toLabel!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Respon'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus respon alumni ini? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // TODO: Call API to delete
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Respon berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Go back after delete
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _handleExport() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export akan segera tersedia'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
