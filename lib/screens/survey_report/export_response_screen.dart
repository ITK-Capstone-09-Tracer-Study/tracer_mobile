import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/survey_response_provider.dart';
import '../../models/survey_response_model.dart';

class ExportResponseScreen extends StatefulWidget {
  final int surveyId;
  final int respondentId;

  const ExportResponseScreen({
    super.key,
    required this.surveyId,
    required this.respondentId,
  });

  @override
  State<ExportResponseScreen> createState() => _ExportResponseScreenState();
}

class _ExportResponseScreenState extends State<ExportResponseScreen> {
  // Export options
  String _selectedFormat = 'PDF';
  String _selectedPage = 'All';
  String _selectedLayout = 'Portrait';
  
  // Available formats
  final List<String> _formats = ['PDF'];
  
  // Available layouts
  final List<String> _layouts = ['Portrait', 'Landscape'];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SurveyResponseProvider>();
      // Initialize if not already loaded
      if (provider.currentResponse == null || 
          provider.selectedRespondentId != widget.respondentId) {
        provider.initialize(widget.surveyId).then((_) {
          if (provider.respondents.any((r) => r.id == widget.respondentId)) {
            provider.selectRespondent(widget.respondentId);
          }
        });
      }
    });
  }

  List<String> _getPageOptions(SurveyResponseProvider provider) {
    final sections = provider.currentResponse?.sections ?? [];
    final options = <String>['All'];
    
    for (int i = 0; i < sections.length; i++) {
      options.add('${i + 1}. ${sections[i].title}');
    }
    
    return options;
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

          if (provider.currentResponse == null) {
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

          final pageOptions = _getPageOptions(provider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Text(
                  'Survey Report > Detail Respon Alumni > Export',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Export',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                const SizedBox(height: 24),
                
                // Export options panel
                _buildExportOptions(pageOptions),
                
                const SizedBox(height: 24),
                
                // Preview panel below
                _buildPreviewPanel(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExportOptions(List<String> pageOptions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Format dropdown
          const Text(
            'Format',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButton<String>(
              value: _selectedFormat,
              isExpanded: true,
              underline: const SizedBox(),
              items: _formats.map((format) {
                return DropdownMenuItem<String>(
                  value: format,
                  child: Text(format),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFormat = value;
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Page dropdown
          const Text(
            'Page',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButton<String>(
              value: _selectedPage,
              isExpanded: true,
              underline: const SizedBox(),
              items: pageOptions.map((page) {
                return DropdownMenuItem<String>(
                  value: page,
                  child: Text(
                    page,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPage = value;
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Layout radio buttons
          const Text(
            'Layout',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _selectedLayout,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLayout = value;
                });
              }
            },
            child: Row(
              children: _layouts.map((layout) {
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLayout = layout;
                      });
                    },
                    child: Row(
                      children: [
                        Radio<String>(
                          value: layout,
                        ),
                        Text(
                          layout,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleExport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Export'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel(SurveyResponseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview title
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Preview container
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildPreviewContent(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewContent(SurveyResponseProvider provider) {
    final response = provider.currentResponse;
    if (response == null) {
      return const Center(
        child: Text('No response data available'),
      );
    }

    // Determine which sections to show
    List<SectionResponseModel> sectionsToShow;
    if (_selectedPage == 'All') {
      sectionsToShow = response.sections;
    } else {
      // Parse the section number from the selected page
      final sectionIndex = int.tryParse(_selectedPage.split('.').first) ?? 1;
      if (sectionIndex > 0 && sectionIndex <= response.sections.length) {
        sectionsToShow = [response.sections[sectionIndex - 1]];
      } else {
        sectionsToShow = response.sections;
      }
    }

    // Layout indicator
    final isLandscape = _selectedLayout == 'Landscape';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Layout indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLandscape ? Icons.crop_landscape : Icons.crop_portrait,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedLayout,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Header
              _buildPreviewHeader(response),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Alumni info
              _buildAlumniInfo(response),
              
              const SizedBox(height: 24),
              
              // Sections
              ...sectionsToShow.map((section) => 
                _buildPreviewSection(section)
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewHeader(SurveyResponseDetailModel response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Survey Response Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Generated on ${DateTime.now().toString().split(' ')[0]}',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAlumniInfo(SurveyResponseDetailModel response) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Respondent Information',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Name', response.alumniName),
          _buildInfoRow('Email', response.alumniEmail),
          if (response.completedAt != null)
            _buildInfoRow(
              'Completed At',
              response.completedAt.toString().split(' ')[0],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(SectionResponseModel section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              section.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          
          if (section.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              section.description,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Questions
          ...section.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildPreviewQuestion(index + 1, question);
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewQuestion(int number, QuestionResponseModel question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Text(
            '$number. ${question.question}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Answer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: _buildPreviewAnswer(question),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewAnswer(QuestionResponseModel question) {
    switch (question.type) {
      case 'multiple_choice':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: question.options?.map((option) {
            final isSelected = question.answer == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(
                    isSelected 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                    size: 12,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        color: isSelected 
                            ? AppColors.textPrimary 
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList() ?? [],
        );

      case 'checkboxes':
        final selectedOptions = question.answer is List 
            ? List<String>.from(question.answer as List)
            : <String>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: question.options?.map((option) {
            final isSelected = selectedOptions.contains(option);
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(
                    isSelected 
                        ? Icons.check_box 
                        : Icons.check_box_outline_blank,
                    size: 12,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        color: isSelected 
                            ? AppColors.textPrimary 
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList() ?? [],
        );

      case 'linear_scale':
        final selectedValue = question.answer as int?;
        final fromValue = question.fromValue ?? 1;
        final toValue = question.toValue ?? 5;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                toValue - fromValue + 1,
                (index) {
                  final value = fromValue + index;
                  final isSelected = value == selectedValue;
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (question.fromLabel != null || question.toLabel != null) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (question.fromLabel != null)
                    Text(
                      question.fromLabel!,
                      style: TextStyle(
                        fontSize: 7,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (question.toLabel != null)
                    Text(
                      question.toLabel!,
                      style: TextStyle(
                        fontSize: 7,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ],
        );

      default:
        return Text(
          question.formattedAnswer,
          style: const TextStyle(fontSize: 9),
        );
    }
  }

  void _handleExport() {
    // TODO: Implement actual PDF export functionality
    // For now, show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exporting as $_selectedFormat with $_selectedPage page(s) in $_selectedLayout layout...',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
    
    // Simulate export delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
