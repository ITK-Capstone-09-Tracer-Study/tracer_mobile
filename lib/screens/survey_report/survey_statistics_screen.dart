import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/survey_report_provider.dart';
import '../../models/survey_report_model.dart';

class SurveyStatisticsScreen extends StatefulWidget {
  final int surveyId;

  const SurveyStatisticsScreen({
    super.key,
    required this.surveyId,
  });

  @override
  State<SurveyStatisticsScreen> createState() => _SurveyStatisticsScreenState();
}

class _SurveyStatisticsScreenState extends State<SurveyStatisticsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SurveyReportProvider>();
      provider.fetchSurveyDetail(widget.surveyId);
      provider.fetchFaculties();
      provider.fetchMajors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      drawer: const AppDrawer(),
      body: Consumer<SurveyReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Survey Report > Statistik Survey',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Statistik Survey',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              // Statistics Cards
              if (provider.statistics != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Progress',
                          value: '${provider.statistics!.progressPercentage.toStringAsFixed(0)}%',
                          subtitle: 'Total Target: ${provider.statistics!.totalTarget}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Sudah Mengisi',
                          value: '${provider.statistics!.completed}',
                          subtitle: 'Alumni',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Belum Mengisi',
                          value: '${provider.statistics!.notCompleted}',
                          subtitle: 'Alumni',
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Search and Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () {
                              setState(() {
                                _showFilters = !_showFilters;
                              });
                            },
                          ),
                          if (provider.selectedFacultyId != null ||
                              provider.selectedMajorId != null)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.view_list),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Filter Panel
              if (_showFilters)
                Container(
                  margin: const EdgeInsets.all(AppConstants.paddingLarge),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.resetFilters();
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Faculty Dropdown
                      const Text(
                        'Fakultas',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: provider.selectedFacultyId,
                        decoration: const InputDecoration(
                          hintText: 'Select an option',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('All Faculties'),
                          ),
                          ...provider.faculties.map((faculty) {
                            return DropdownMenuItem<int>(
                              value: faculty.id,
                              child: Text(faculty.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          provider.setFacultyFilter(value);
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Major Dropdown
                      const Text(
                        'Program Studi',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: provider.selectedMajorId,
                        decoration: const InputDecoration(
                          hintText: 'Select an option',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('All Programs'),
                          ),
                          ...provider.majors.map((major) {
                            return DropdownMenuItem<int>(
                              value: major.id,
                              child: Text(major.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          provider.setMajorFilter(value);
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showFilters = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Apply filters'),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Alumni Table
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalScrollController,
                    child: SizedBox(
                      width: 1200,
                      child: Column(
                        children: [
                          // Table Header
                          _buildTableHeader(),
                          
                          const Divider(height: 1),
                          
                          // Table Body
                          Expanded(
                            child: provider.responses.isEmpty
                                ? const Center(child: Text('No data available'))
                                : ListView.separated(
                                    itemCount: provider.responses.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final response = provider.responses[index];
                                      return _buildTableRow(response);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Pagination
              _buildPaginationControls(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
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
          _buildHeaderCell('Nama', flex: 3),
          _buildHeaderCell('Email', flex: 3),
          _buildHeaderCell('NIM', flex: 2),
          _buildHeaderCell('Fakultas', flex: 3),
          _buildHeaderCell('Program Studi', flex: 3),
          _buildHeaderCell('Selesai Pada', flex: 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTableRow(AlumniResponseModel response) {
    final dateFormat = DateFormat('MMM d, yyyy HH:mm:ss');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              response.name,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    response.email,
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
              response.nim,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              response.facultyName,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              response.majorName,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: response.completedAt != null
                ? Text(
                    dateFormat.format(response.completedAt!),
                    style: const TextStyle(fontSize: 13),
                  )
                : const Icon(
                    Icons.remove_circle_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(SurveyReportProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
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
                  value: 10,
                  underline: const SizedBox(),
                  items: [10, 20, 50].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
              ),
            ],
          ),

          // Next Button
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
