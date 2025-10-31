import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../constants/app_constants.dart';

class UnitManagementScreen extends StatelessWidget {
  const UnitManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Text(
              'Unit Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Unit Management - Coming Soon'),
            ),
          ),
        ],
      ),
    );
  }
}
