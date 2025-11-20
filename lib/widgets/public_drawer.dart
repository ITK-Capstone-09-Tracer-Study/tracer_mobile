import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';
import '../constants/colors.dart';

/// Public Drawer untuk user yang belum login (alumni/public)
/// Menu: Beranda, Isi Kuesioner, FAQ, Login (Admin)
class PublicDrawer extends StatelessWidget {
  const PublicDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                ),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.home_outlined,
                    title: 'Beranda',
                    route: '/',
                  ),
                  
                  _buildMenuItem(
                    context,
                    icon: Icons.assignment_outlined,
                    title: 'Isi Kuesioner',
                    route: '/isi-kuesioner',
                  ),
                  
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'FAQ',
                    route: '/faq',
                  ),
                  
                  const Divider(height: 32),
                  
                  _buildMenuItem(
                    context,
                    icon: Icons.login,
                    title: 'Login (Admin)',
                    route: '/login',
                    isHighlighted: true,
                  ),
                ],
              ),
            ),
            
            // Footer Version
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    bool isHighlighted = false,
  }) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isSelected = currentRoute == route;
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 4,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isHighlighted 
              ? AppColors.primary 
              : (isSelected ? AppColors.primary : AppColors.textSecondary),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isHighlighted 
                ? AppColors.primary 
                : (isSelected ? AppColors.primary : AppColors.textPrimary),
            fontWeight: isSelected || isHighlighted ? FontWeight.w600 : FontWeight.normal,
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
      ),
    );
  }
}
