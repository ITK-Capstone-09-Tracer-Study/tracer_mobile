import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/survey_response_provider.dart';
import '../../models/survey_response_model.dart';

class AlumniResponseDetailScreen extends StatefulWidget {
  final int surveyId;
  final int? initialRespondentId;

  const AlumniResponseDetailScreen({
    super.key,
    required this.surveyId,
    this.initialRespondentId,
  });

  @override
  State<AlumniResponseDetailScreen> createState() => _AlumniResponseDetailScreenState();
}

class _AlumniResponseDetailScreenState extends State<AlumniResponseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SurveyResponseProvider>();
      provider.initialize(widget.surveyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      drawer: const AppDrawer(),
      body: Consumer<SurveyResponseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (provider.respondents.isEmpty) {
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
                  'Survey Report > Detail Respon Alumni',
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
                _buildControlsSection(provider),
                
                const SizedBox(height: 24),
                
                // Response content
                if (provider.currentResponse != null && provider.currentSection != null)
                  _buildResponseContent(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlsSection(SurveyResponseProvider provider) {
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
          _buildRespondentDropdown(provider),
          
          const SizedBox(height: 12),
          
          // Section Navigation
          _buildSectionNavigation(provider),
          
          const SizedBox(height: 12),
          
          // Action Buttons Row
          Row(
            children: [
              // Delete Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmation(provider),
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
                  onPressed: () => _handleExport(provider),
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

  Widget _buildRespondentDropdown(SurveyResponseProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<int>(
        value: provider.selectedRespondentId,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text('Pilih Alumni'),
        items: provider.respondents.map((respondent) {
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
            provider.selectRespondent(value);
          }
        },
      ),
    );
  }

  Widget _buildSectionNavigation(SurveyResponseProvider provider) {
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
            onPressed: provider.canGoToPrevious
                ? provider.goToPreviousSection
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: provider.canGoToPrevious ? AppColors.textPrimary : Colors.grey[300],
            ),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          
          const SizedBox(width: 16),
          
          // Section indicator
          Text(
            '${provider.currentSectionIndex + 1} dari ${provider.totalSections}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Next Button
          IconButton(
            onPressed: provider.canGoToNext
                ? provider.goToNextSection
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: provider.canGoToNext ? AppColors.textPrimary : Colors.grey[300],
            ),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseContent(SurveyResponseProvider provider) {
    final section = provider.currentSection!;
    
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            toValue - fromValue + 1,
            (index) {
              final value = fromValue + index;
              final isSelected = value == selectedValue;
              
              return Container(
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
              );
            },
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

  void _showDeleteConfirmation(SurveyResponseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Respon'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus respon alumni ini? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              final success = await provider.deleteResponse();
              if (success && mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Respon berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
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

  void _handleExport(SurveyResponseProvider provider) {
    if (provider.selectedRespondentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih alumni terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    context.push(
      '/export-response',
      extra: {
        'surveyId': widget.surveyId,
        'respondentId': provider.selectedRespondentId,
      },
    );
  }
}
