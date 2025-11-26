import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class MajorSurveyManagementScreen extends StatefulWidget {
  const MajorSurveyManagementScreen({super.key});

  @override
  State<MajorSurveyManagementScreen> createState() => _MajorSurveyManagementScreenState();
}

class _MajorSurveyManagementScreenState extends State<MajorSurveyManagementScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Dummy data for surveys - akan diganti dengan data dari API
  final List<Map<String, dynamic>> _surveys = [
    {
      'id': 1,
      'name': 'Tracer Study 2024',
      'description': 'Survey untuk alumni tahun 2024',
      'status': 'active',
      'respondents': 150,
      'additionalQuestions': 5,
      'createdAt': '2024-01-15',
    },
    {
      'id': 2,
      'name': 'Exit Survey 2024',
      'description': 'Survey kepuasan lulusan',
      'status': 'active',
      'respondents': 75,
      'additionalQuestions': 3,
      'createdAt': '2024-02-01',
    },
    {
      'id': 3,
      'name': 'SKP Survey',
      'description': 'Survey Kinerja Pegawai',
      'status': 'draft',
      'respondents': 0,
      'additionalQuestions': 0,
      'createdAt': '2024-03-10',
    },
  ];

  List<Map<String, dynamic>> get _filteredSurveys {
    if (_searchQuery.isEmpty) {
      return _surveys;
    }
    return _surveys.where((survey) {
      return survey['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          survey['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final majorName = currentUser?.unitName ?? 'Program Studi';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Management'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with major info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  majorName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola pertanyaan tambahan untuk survey program studi Anda',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari survey...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Survey list
          Expanded(
            child: _filteredSurveys.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    itemCount: _filteredSurveys.length,
                    itemBuilder: (context, index) {
                      final survey = _filteredSurveys[index];
                      return _buildSurveyCard(context, survey);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada survey ditemukan',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyCard(BuildContext context, Map<String, dynamic> survey) {
    final isActive = survey['status'] == 'active';
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to survey detail screen
          context.go('/major-survey-sections/${survey['id']}', extra: {
            'surveyTitle': survey['name'],
          });
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      survey['name'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? 'Aktif' : 'Draft',
                      style: TextStyle(
                        color: isActive ? AppColors.success : AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                survey['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.people_outline,
                    label: '${survey['respondents']} Responden',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoChip(
                    icon: Icons.quiz_outlined,
                    label: '${survey['additionalQuestions']} Pertanyaan Tambahan',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Dibuat: ${survey['createdAt']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
