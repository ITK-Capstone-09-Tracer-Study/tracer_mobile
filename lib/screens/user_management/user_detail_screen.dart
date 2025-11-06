import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  
  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _nikNipController;
  late TextEditingController _phoneController;
  late String _selectedRole;
  late String? _selectedUnitType;
  late String? _selectedUnitName;
  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _nikNipController = TextEditingController();
    _phoneController = TextEditingController();
    _selectedRole = '';
    _selectedUnitType = null;
    _selectedUnitName = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nikNipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData(UserModel user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _nikNipController.text = user.nikNip ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    // Ensure role is valid, default to 'admin' if not in the list
    _selectedRole = AppConstants.userRoles.contains(user.role) 
        ? user.role 
        : 'admin';
    _selectedUnitType = user.unitType;
    _selectedUnitName = user.unitName;
  }

  void _markAsModified() {
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    }
  }

  void _saveChanges(BuildContext context, UserModel originalUser) {
    if (_formKey.currentState!.validate()) {
      final updatedUser = originalUser.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        nikNip: _nikNipController.text.isEmpty ? null : _nikNipController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        role: _selectedRole,
        unitType: _selectedUnitType,
        unitName: _selectedUnitName,
        // Keep the original unitId, as it's managed through role/unit selection
        // In the future with API, this will be properly updated through unit selector
      );

      context.read<UserProvider>().updateUser(widget.userId, updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      setState(() {
        _isModified = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.getUserById(widget.userId);

        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('User Detail'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/user-management'),
                    child: const Text('Back to User Management'),
                  ),
                ],
              ),
            ),
          );
        }

        // Load user data when first built
        if (_nameController.text.isEmpty) {
          _loadUserData(user);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('User Detail'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_isModified) {
                  _showDiscardDialog(context);
                } else {
                  context.go('/user-management');
                }
              },
            ),
            actions: [
              if (_isModified)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton.icon(
                    onPressed: () => _saveChanges(context, user),
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              children: [
                // Profile Photo Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty 
                                ? user.name.substring(0, 2).toUpperCase() 
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'User ID: ${user.id}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Personal Information Section
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                  onChanged: (_) => _markAsModified(),
                ),
                
                const SizedBox(height: AppConstants.paddingMedium),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (_) => _markAsModified(),
                ),
                
                const SizedBox(height: AppConstants.paddingMedium),
                
                // NIK/NIP Field
                TextFormField(
                  controller: _nikNipController,
                  decoration: const InputDecoration(
                    labelText: 'NIK/NIP',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  onChanged: (_) => _markAsModified(),
                ),
                
                const SizedBox(height: AppConstants.paddingMedium),
                
                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => _markAsModified(),
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Module Permissions Section
                Text(
                  'Module Permissions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                
                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: AppConstants.userRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(AppConstants.userRoleLabels[role] ?? role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                    _markAsModified();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppConstants.paddingMedium),
                
                // Unit Type (readonly - for display only)
                if (_selectedUnitType != null) ...[
                  TextFormField(
                    initialValue: AppConstants.unitTypeLabels[_selectedUnitType] ?? _selectedUnitType,
                    decoration: const InputDecoration(
                      labelText: 'Unit Type',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                ],
                
                // Unit Name (readonly - for display only)
                if (_selectedUnitName != null) ...[
                  TextFormField(
                    initialValue: _selectedUnitName,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                ],
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Metadata Section
                if (user.createdAt != null || user.updatedAt != null) ...[
                  Text(
                    'Metadata',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  if (user.createdAt != null)
                    _buildInfoRow(
                      context,
                      'Created At',
                      _formatDateTime(user.createdAt!),
                    ),
                  
                  if (user.updatedAt != null)
                    _buildInfoRow(
                      context,
                      'Last Updated',
                      _formatDateTime(user.updatedAt!),
                    ),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                ],
                
                // Save Button (large)
                if (_isModified)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                    child: ElevatedButton(
                      onPressed: () => _saveChanges(context, user),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/user-management');
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
