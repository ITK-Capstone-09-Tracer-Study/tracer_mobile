import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/add_unit_dialog.dart';
import '../../widgets/edit_unit_dialog.dart';
import '../../providers/unit_provider.dart';
import '../../models/unit_model.dart';
import '../../constants/app_constants.dart';
import '../../constants/colors.dart';

class UnitManagementScreen extends StatefulWidget {
  const UnitManagementScreen({super.key});

  @override
  State<UnitManagementScreen> createState() => _UnitManagementScreenState();
}

class _UnitManagementScreenState extends State<UnitManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'fakultas'; // 'fakultas', 'jurusan', 'program_studi'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getAddButtonLabel() {
    switch (_selectedTab) {
      case 'fakultas':
        return 'Fakultas';
      case 'jurusan':
        return 'Jurusan';
      case 'program_studi':
        return 'Program Studi';
      default:
        return 'Unit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title & Subtitle
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit Directory',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unit Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Tabs (Fakultas, Jurusan, Program Studi)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
            ),
            child: Row(
              children: [
                _buildTabButton('Fakultas', 'fakultas'),
                const SizedBox(width: 8),
                _buildTabButton('Jurusan', 'jurusan'),
                const SizedBox(width: 8),
                _buildTabButton('Program Studi', 'program_studi'),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Add Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddUnitDialog(unitType: _selectedTab),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text(_getAddButtonLabel()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Search and Filter
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
                    onChanged: (value) {
                      context.read<UnitProvider>().searchUnits(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Unit List/Table
          Expanded(
            child: Consumer<UnitProvider>(
              builder: (context, unitProvider, child) {
                final units = unitProvider.getFilteredUnitsByType(_selectedTab);

                if (units.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_getAddButtonLabel()} found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildUnitList(context, units);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = _selectedTab == value;

    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTab = value;
            _searchController.clear();
          });
          context.read<UnitProvider>().searchUnits('');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : Colors.white,
          foregroundColor: isSelected ? Colors.white : AppColors.primary,
          elevation: 0,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildUnitList(BuildContext context, List<UnitModel> units) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header with dropdown
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _getAddButtonLabel(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: ListView.builder(
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                return _buildUnitItem(context, unit);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitItem(BuildContext context, UnitModel unit) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (unit.parentName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    unit.parentName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditUnitDialog(unit: unit),
              );
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

