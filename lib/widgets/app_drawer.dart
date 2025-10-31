import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../constants/colors.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isUserDirectoryExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header dengan Logo dan Info Institusi
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppConstants.logoPath,
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tracer Study',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Institut Teknologi Kalimantan',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // User Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Row(
                  children: [
                    // Profile Photo
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'DU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Name',
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '12345',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            const Divider(height: 1),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                ),
                children: [
                  // User Directory dengan dropdown
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      leading: const Icon(Icons.people_outline),
                      title: const Text('User Directory'),
                      trailing: Icon(
                        _isUserDirectoryExpanded 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                      ),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isUserDirectoryExpanded = expanded;
                        });
                      },
                      children: [
                        _buildSubMenuItem(
                          context,
                          icon: Icons.grid_view,
                          title: 'Unit Directory',
                          route: '/unit-management',
                        ),
                        _buildSubMenuItem(
                          context,
                          icon: Icons.person_outline,
                          title: 'Employee Directory',
                          route: '/user-management',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Text(
                'Version ${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isSelected = currentRoute.startsWith(route);
    
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 72,
        right: AppConstants.paddingMedium,
      ),
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      onTap: () {
        context.go(route);
        Navigator.pop(context); // Close drawer after navigation
      },
    );
  }
}
