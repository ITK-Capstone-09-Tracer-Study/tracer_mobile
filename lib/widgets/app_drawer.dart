import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../constants/colors.dart';
import '../constants/roles.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userRole = currentUser?.role ?? '';
    
    // Get user initials for avatar
    final userName = currentUser?.name ?? 'User';
    final userInitials = _getInitials(userName);
    
    // Get role display name
    final roleDisplay = RolePermissions.getRoleDisplayName(userRole);
    
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header dengan Logo
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppConstants.logoPath,
                  height: 40,
                ),
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
                      child: Center(
                        child: Text(
                          userInitials,
                          style: const TextStyle(
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
                            userName,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            roleDisplay,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
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
                children: _buildMenuItems(context, userRole),
              ),
            ),
            
            // Footer
            const Divider(height: 1),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ),
            
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

  /// Get user initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  /// Build menu items based on user role
  List<Widget> _buildMenuItems(BuildContext context, String userRole) {
    final menus = <Widget>[];
    
    // Admin menus
    if (RolePermissions.hasMenuAccess(userRole, 'user_management') ||
        RolePermissions.hasMenuAccess(userRole, 'unit_management')) {
      menus.add(
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('User Directory'),
            children: [
              if (RolePermissions.hasMenuAccess(userRole, 'unit_management'))
                _buildSubMenuItem(
                  context,
                  icon: Icons.grid_view,
                  title: 'Unit Directory',
                  route: '/unit-management',
                ),
              if (RolePermissions.hasMenuAccess(userRole, 'user_management'))
                _buildSubMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Employee Directory',
                  route: '/user-management',
                ),
            ],
          ),
        ),
      );
    }
    
    // Tracer Team menus
    if (RolePermissions.hasMenuAccess(userRole, 'survey_management')) {
      menus.add(
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Questionnaire'),
            children: [
              _buildSubMenuItem(
                context,
                icon: Icons.description_outlined,
                title: 'Survey Management',
                route: '/survey-management',
              ),
            ],
          ),
        ),
      );
    }
    
    // Major Team menus
    if (RolePermissions.hasMenuAccess(userRole, 'major_survey_sections')) {
      menus.add(
        ListTile(
          leading: const Icon(Icons.assignment_outlined),
          title: const Text('Survey Pertanyaan Tambahan'),
          onTap: () {
            context.go('/major-survey-sections');
            Navigator.pop(context);
          },
        ),
      );
    }
    
    // If no menus available, show a message
    if (menus.isEmpty) {
      menus.add(
        const Padding(
          padding: EdgeInsets.all(AppConstants.paddingLarge),
          child: Center(
            child: Text(
              'No menu available for your role',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }
    
    return menus;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              debugPrint('🔴 Logout button pressed');
              
              // Get AuthProvider BEFORE any async operations
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              
              // Close dialog first
              Navigator.pop(dialogContext);
              debugPrint('✅ Dialog closed');
              
              try {
                // Show loading
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (loadingContext) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  debugPrint('✅ Loading indicator shown');
                }
                
                // Call logout from AuthProvider
                await authProvider.logout();
                debugPrint('✅ Logout completed');
                
                // Close loading and navigate
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  debugPrint('✅ Loading indicator closed');
                  
                  // Navigate to public home
                  context.go('/');
                  debugPrint('✅ Navigated to public home');
                }
              } catch (e) {
                debugPrint('❌ Logout error: $e');
                // Try to close loading if it's open
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
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
