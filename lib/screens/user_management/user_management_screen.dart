import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGroupBy = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Text(
              'User Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Toolbar dengan Search, New Employee, dan Group By
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Search Field
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
                          context.read<UserProvider>().searchUsers(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // New Employee Button
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/user-management/new');
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('New Employee'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Group By Dropdown
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGroupBy.isEmpty ? null : _selectedGroupBy,
                        decoration: const InputDecoration(
                          labelText: 'Group by',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '',
                            child: Text('None'),
                          ),
                          DropdownMenuItem(
                            value: 'unit',
                            child: Text('Unit'),
                          ),
                          DropdownMenuItem(
                            value: 'role',
                            child: Text('Role'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGroupBy = value ?? '';
                          });
                          context.read<UserProvider>().setGroupBy(value ?? '');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // User Table
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final users = userProvider.filteredUsers;
                
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return _buildUserTable(context, users);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(BuildContext context, List<UserModel> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table Header
            Container(
              color: AppColors.surfaceVariant,
              child: Row(
                children: [
                  _buildHeaderCell('', width: 60, isCheckbox: true),
                  _buildHeaderCell('Name', width: 200),
                  _buildHeaderCell('Email', width: 250),
                  _buildHeaderCell('Role', width: 150),
                  _buildHeaderCell('Unit', width: 200),
                ],
              ),
            ),
            
            // Table Rows
            ...users.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              return _buildUserRow(context, user, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String title, {double width = 150, bool isCheckbox = false}) {
    return Container(
      width: width,
      height: AppConstants.tableHeaderHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      alignment: Alignment.centerLeft,
      child: isCheckbox
          ? Checkbox(
              value: false,
              onChanged: (value) {
                
              },
            )
          : Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.unfold_more,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
    );
  }

  Widget _buildUserRow(BuildContext context, UserModel user, int index) {
    final isEven = index % 2 == 0;
    
    return InkWell(
      onTap: () {
        context.go('/user-management/detail/${user.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isEven ? AppColors.surface : AppColors.surfaceVariant.withValues(alpha: 0.3),
          border: const Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            _buildCheckboxCell(user.id),
            _buildDataCell(user.name, width: 200),
            _buildDataCell(user.email, width: 250),
            _buildDataCell(user.role, width: 150),
            _buildDataCell(user.unitName ?? user.unitType ?? '-', width: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxCell(String userId) {
    return Container(
      width: 60,
      height: AppConstants.tableRowHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      alignment: Alignment.centerLeft,
      child: Checkbox(
        value: false,
        onChanged: (value) {
          
        },
      ),
    );
  }

  Widget _buildDataCell(String text, {double width = 150}) {
    return Container(
      width: width,
      height: AppConstants.tableRowHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
