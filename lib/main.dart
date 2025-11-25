import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import 'providers/user_provider.dart';
import 'providers/unit_provider.dart';
import 'providers/survey_provider.dart';
import 'providers/survey_kind_provider.dart';
import 'providers/survey_report_provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_client.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API client
  await ApiClient().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
        ChangeNotifierProvider(create: (_) => SurveyProvider()),
        ChangeNotifierProvider(create: (_) => SurveyKindProvider()),
        ChangeNotifierProvider(create: (_) => SurveyReportProvider()),
      ],
      child: Builder(
        builder: (context) {
          // Get AuthProvider from context to pass to router
          final authProvider = context.read<AuthProvider>();
          
          return MaterialApp.router(
            title: 'Tracer Study ITK',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: AppRouter.createRouter(authProvider),
          );
        },
      ),
    );
  }
}
