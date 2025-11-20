import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/user_management/user_management_screen.dart';
import '../screens/user_management/user_detail_screen.dart';
import '../screens/user_management/new_employee_screen.dart';
import '../screens/unit_management/unit_management_screen.dart';
import '../screens/survey_management/survey_management_screen.dart';
import '../screens/public/public_home_screen.dart';
import '../screens/public/faq_screen.dart';
import '../screens/public/alumni_verification_screen.dart';
import '../screens/public/alumni_employment_screen.dart';
import '../screens/public/available_surveys_screen.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: authProvider, // Listen to auth changes
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.uri.path == '/login';
        final isPublicRoute = state.uri.path == '/' || 
                              state.uri.path.startsWith('/isi-kuesioner') ||
                              state.uri.path.startsWith('/alumni-employment') ||
                              state.uri.path.startsWith('/available-surveys') ||
                              state.uri.path.startsWith('/faq');
        
        // If not authenticated and trying to access protected route
        if (!isAuthenticated && !isLoggingIn && !isPublicRoute) {
          return '/';
        }
        
        // No redirect needed
        return null;
      },
      routes: [
      // Public routes (not authenticated)
      GoRoute(
        path: '/',
        name: 'public-home',
        builder: (context, state) => const PublicHomeScreen(),
      ),
      
      GoRoute(
        path: '/isi-kuesioner',
        name: 'isi-kuesioner',
        builder: (context, state) => const AlumniVerificationScreen(),
      ),
      
      GoRoute(
        path: '/alumni-employment',
        name: 'alumni-employment',
        builder: (context, state) => const AlumniEmploymentScreen(),
      ),
      
      GoRoute(
        path: '/available-surveys',
        name: 'available-surveys',
        builder: (context, state) => const AvailableSurveysScreen(),
      ),
      
      GoRoute(
        path: '/faq',
        name: 'faq',
        builder: (context, state) => const FAQScreen(),
      ),
      
      // Admin Login route
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Authenticated routes (admin/staff)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // User Directory routes dengan nested routes
      GoRoute(
        path: '/user-management',
        name: 'user-management',
        builder: (context, state) => const UserManagementScreen(),
        routes: [
          // Nested route untuk detail user
          GoRoute(
            path: 'detail/:userId',
            name: 'user-detail',
            builder: (context, state) {
              final userIdStr = state.pathParameters['userId']!;
              final userId = int.parse(userIdStr);
              return UserDetailScreen(userId: userId);
            },
          ),
          // Nested route untuk new employee
          GoRoute(
            path: 'new',
            name: 'new-employee',
            builder: (context, state) => const NewEmployeeScreen(),
          ),
        ],
      ),
      
      GoRoute(
        path: '/unit-management',
        name: 'unit-management',
        builder: (context, state) => const UnitManagementScreen(),
      ),

      GoRoute(
        path: '/survey-management',
        name: 'survey-management',
        builder: (context, state) => const SurveyManagementScreen(),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
