import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/survey_provider.dart';
import '../../models/survey_model.dart';
import '../../constants/app_constants.dart';
import '../../constants/colors.dart';
import 'survey_detail_screen.dart';

class SurveyManagementScreen extends StatefulWidget {
  const SurveyManagementScreen({super.key});

  @override
  State<SurveyManagementScreen> createState() => _SurveyManagementScreenState();
}

class _SurveyManagementScreenState extends State<SurveyManagementScreen> {
  bool _isEditMode = false;
  String? _expandedPeriodeId;

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _showAddPeriodeDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddPeriodeDialog(),
    );
  }

  void _showEditPeriodeDialog(PeriodeModel periode) {
    showDialog(
      context: context,
      builder: (context) => _EditPeriodeDialog(periode: periode),
    );
  }

  void _showDeletePeriodeConfirmation(PeriodeModel periode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Periode?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${periode.name}? '
          'Semua survey dalam periode ini akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SurveyProvider>().deletePeriode(periode.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${periode.name} berhasil dihapus'),
                  backgroundColor: AppColors.success,
                ),
              );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title & Actions
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Questionnaire',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Survey Management',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit/Done Button
                if (_isEditMode)
                  TextButton.icon(
                    onPressed: _toggleEditMode,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Done'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: _toggleEditMode,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Consumer<SurveyProvider>(
              builder: (context, surveyProvider, child) {
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  children: [
                    // Template Section
                    _buildTemplateSection(surveyProvider),
                    
                    const SizedBox(height: AppConstants.paddingXLarge),
                    
                    // Periodes Section
                    ...surveyProvider.periodes.map((periode) {
                      return _buildPeriodeSection(
                        periode,
                        surveyProvider.getSurveysByPeriode(periode.year.toString()),
                      );
                    }),

                    // Add Periode Button (in edit mode)
                    if (_isEditMode) ...[
                      const SizedBox(height: AppConstants.paddingLarge),
                      OutlinedButton.icon(
                        onPressed: _showAddPeriodeDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Periode Baru'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppConstants.paddingXLarge),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection(SurveyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Template',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        
        // Template Survey Cards (2x2 Grid on mobile)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: provider.templateSurveys.length,
          itemBuilder: (context, index) {
            final survey = provider.templateSurveys[index];
            return _buildSurveyCard(survey, isTemplate: true);
          },
        ),
      ],
    );
  }

  Widget _buildPeriodeSection(PeriodeModel periode, List<SurveyModel> surveys) {
    final isExpanded = _expandedPeriodeId == periode.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Periode Header
        InkWell(
          onTap: () {
            setState(() {
              _expandedPeriodeId = isExpanded ? null : periode.id;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    periode.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Edit Mode Actions
                if (_isEditMode) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _showEditPeriodeDialog(periode),
                    tooltip: 'Edit Periode',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => _showDeletePeriodeConfirmation(periode),
                    color: AppColors.error,
                    tooltip: 'Hapus Periode',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                
                Icon(
                  isExpanded 
                      ? Icons.keyboard_arrow_up 
                      : Icons.keyboard_arrow_down,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        // Periode Surveys (Collapsible)
        if (isExpanded) ...[
          const SizedBox(height: AppConstants.paddingMedium),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: surveys.length,
            itemBuilder: (context, index) {
              final survey = surveys[index];
              return _buildSurveyCard(survey);
            },
          ),
        ],
        
        const SizedBox(height: AppConstants.paddingLarge),
      ],
    );
  }

  Widget _buildSurveyCard(SurveyModel survey, {bool isTemplate = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to survey detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurveyDetailScreen(survey: survey),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card content area (placeholder for survey preview)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Survey Title
                Text(
                  survey.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Last Edited Date
                Text(
                  'Last Edited ${_formatDate(survey.lastEdited)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                // More Options Button
                if (!isTemplate)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onPressed: () {
                        _showSurveyOptions(survey);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _showSurveyOptions(SurveyModel survey) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Survey'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit survey
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit survey - Coming Soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate Survey'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Duplicate survey - Coming Soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Survey', 
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                // Show delete confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Add Periode Dialog
class _AddPeriodeDialog extends StatefulWidget {
  @override
  State<_AddPeriodeDialog> createState() => _AddPeriodeDialogState();
}

class _AddPeriodeDialogState extends State<_AddPeriodeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _savePeriode() {
    if (_formKey.currentState!.validate()) {
      final year = int.parse(_yearController.text);
      final periode = PeriodeModel(
        id: 'p$year',
        name: 'Periode $year',
        year: year,
        createdAt: DateTime.now(),
      );

      context.read<SurveyProvider>().addPeriode(periode);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Periode $year berhasil ditambahkan'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Periode Baru'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Tahun',
                hintText: 'Contoh: 2023',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tahun tidak boleh kosong';
                }
                final year = int.tryParse(value);
                if (year == null) {
                  return 'Masukkan tahun yang valid';
                }
                if (year < 2000 || year > 2100) {
                  return 'Tahun harus antara 2000-2100';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Format: Periode [Tahun]',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _savePeriode,
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}

// Edit Periode Dialog
class _EditPeriodeDialog extends StatefulWidget {
  final PeriodeModel periode;

  const _EditPeriodeDialog({required this.periode});

  @override
  State<_EditPeriodeDialog> createState() => _EditPeriodeDialogState();
}

class _EditPeriodeDialogState extends State<_EditPeriodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.periode.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _savePeriode() {
    if (_formKey.currentState!.validate()) {
      final updatedPeriode = widget.periode.copyWith(
        name: _nameController.text.trim(),
      );

      context.read<SurveyProvider>().updatePeriode(
        widget.periode.id,
        updatedPeriode,
      );
      
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periode berhasil diupdate'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Nama Periode'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Periode',
                hintText: 'Contoh: Periode 2023',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama periode tidak boleh kosong';
                }
                if (value.trim().length < 3) {
                  return 'Nama periode minimal 3 karakter';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _savePeriode,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
