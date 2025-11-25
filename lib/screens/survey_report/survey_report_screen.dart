import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/survey_report_provider.dart';
import '../../models/survey_report_model.dart';
import 'survey_statistics_screen.dart';

class SurveyReportScreen extends StatefulWidget {
  const SurveyReportScreen({super.key});

  @override
  State<SurveyReportScreen> createState() => _SurveyReportScreenState();
}

class _SurveyReportScreenState extends State<SurveyReportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurveyReportProvider>().fetchSurveys();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Survey Report > List',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Survey Report',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
            ),
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
              onChanged: (value) {
                context.read<SurveyReportProvider>().searchSurveys(value);
              },
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Table
          Expanded(
            child: Consumer<SurveyReportProvider>(
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

                if (provider.surveys.isEmpty) {
                  return const Center(
                    child: Text('No surveys found'),
                  );
                }

                return Column(
                  children: [
                    // Table Container
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
                            width: 900,
                            child: Column(
                              children: [
                                // Table Header
                                _buildTableHeader(),
                                
                                const Divider(height: 1),
                                
                                // Table Body
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: provider.surveys.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final survey = provider.surveys[index];
                                      return _buildTableRow(context, survey);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Pagination Controls
                    _buildPaginationControls(provider),
                  ],
                );
              },
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
          _buildHeaderCell('Judul Survey', flex: 3),
          _buildHeaderCell('Tahun Lulus', flex: 2),
          _buildHeaderCell('Mulai', flex: 2),
          _buildHeaderCell('Selesai', flex: 2),
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

  Widget _buildTableRow(BuildContext context, SurveyReportModel survey) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurveyStatisticsScreen(surveyId: survey.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                survey.title,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                survey.graduationNumber.toString(),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                dateFormat.format(survey.startedAt),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                dateFormat.format(survey.endedAt),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
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
                  value: provider.perPage,
                  underline: const SizedBox(),
                  items: [10, 20, 50].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.changePerPage(value);
                    }
                  },
                ),
              ),
            ],
          ),

          // Next Button
          ElevatedButton(
            onPressed: provider.currentPage < provider.totalPages
                ? provider.nextPage
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
}
