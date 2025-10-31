import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/user_management/user_management_screen.dart';
import '../screens/user_management/user_detail_screen.dart';
import '../screens/user_management/new_employee_screen.dart';
import '../screens/unit_management/unit_management_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
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
              final userId = state.pathParameters['userId']!;
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
