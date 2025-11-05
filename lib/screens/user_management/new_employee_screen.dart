import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/unit_provider.dart';
import '../../models/user_model.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';

class NewEmployeeScreen extends StatefulWidget {
  const NewEmployeeScreen({super.key});

  @override
  State<NewEmployeeScreen> createState() => _NewEmployeeScreenState();
}

class _NewEmployeeScreenState extends State<NewEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentTabIndex = 0;
  
  // Personal Information Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nikNipController = TextEditingController();
  
  // Module Permissions
  String? _selectedRole;
  String? _selectedUnitType;
  String? _selectedFaculty;
  String? _selectedMajor;
  final TextEditingController _roleSearchController = TextEditingController();
  final TextEditingController _unitTypeSearchController = TextEditingController();
  final TextEditingController _facultySearchController = TextEditingController();
  final TextEditingController _majorSearchController = TextEditingController();
  
  final List<String> _roles = [
    'Admin',
    'TracerTeam',
    'MajorTeam',
    'HeadOfUnit',
  ];
  
  final List<String> _unitTypes = [
    'Institutional',
    'Faculty',
    'Major',
  ];
  
  List<String> _filteredRoles = [];
  List<String> _filteredUnitTypes = [];
  List<String> _filteredFaculties = [];
  List<String> _filteredMajors = [];
  
  bool _isRoleDropdownOpen = false;
  bool _isUnitTypeDropdownOpen = false;
  bool _isFacultyDropdownOpen = false;
  bool _isMajorDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredRoles = _roles;
    _filteredUnitTypes = _unitTypes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _nikNipController.dispose();
    _roleSearchController.dispose();
    _unitTypeSearchController.dispose();
    _facultySearchController.dispose();
    _majorSearchController.dispose();
    super.dispose();
  }

  void _filterRoles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRoles = _roles;
      } else {
        _filteredRoles = _roles
            .where((role) => role.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterUnitTypes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUnitTypes = _unitTypes;
      } else {
        _filteredUnitTypes = _unitTypes
            .where((type) => type.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterFaculties(String query) {
    final unitProvider = context.read<UnitProvider>();
    final faculties = unitProvider.getFakultasList()
        .map((unit) => unit.name)
        .toList();
    
    setState(() {
      if (query.isEmpty) {
        _filteredFaculties = faculties;
      } else {
        _filteredFaculties = faculties
            .where((name) => name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterMajors(String query) {
    final unitProvider = context.read<UnitProvider>();
    final majors = unitProvider.getUnitsByType('program_studi')
        .map((unit) => unit.name)
        .toList();
    
    setState(() {
      if (query.isEmpty) {
        _filteredMajors = majors;
      } else {
        _filteredMajors = majors
            .where((name) => name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _createEmployee() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a role'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      // Validation based on role
      String? unitType;
      String? unitId;
      String? unitName;
      
      if (_selectedRole == 'HeadOfUnit') {
        if (_selectedUnitType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a unit type'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        
        unitType = _selectedUnitType;
        
        if (_selectedUnitType == 'Faculty') {
          if (_selectedFaculty == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a faculty'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          unitName = _selectedFaculty;
          // Get faculty ID from UnitProvider
          final unitProvider = context.read<UnitProvider>();
          final faculty = unitProvider.getFakultasList()
              .firstWhere((unit) => unit.name == _selectedFaculty);
          unitId = faculty.id;
        } else if (_selectedUnitType == 'Major') {
          if (_selectedMajor == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a major'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          unitName = _selectedMajor;
          // Get major ID from UnitProvider
          final unitProvider = context.read<UnitProvider>();
          final major = unitProvider.getUnitsByType('program_studi')
              .firstWhere((unit) => unit.name == _selectedMajor);
          unitId = major.id;
        } else {
          // Institutional
          unitName = 'Institutional';
        }
      } else if (_selectedRole == 'MajorTeam') {
        if (_selectedMajor == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a major'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        unitType = 'Major';
        unitName = _selectedMajor;
        // Get major ID from UnitProvider
        final unitProvider = context.read<UnitProvider>();
        final major = unitProvider.getUnitsByType('program_studi')
            .firstWhere((unit) => unit.name == _selectedMajor);
        unitId = major.id;
      } else {
        // Admin and TracerTeam
        unitType = 'Institutional';
      }

      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole!,
        unitType: unitType,
        unitId: unitId,
        unitName: unitName,
        nikNip: _nikNipController.text.isEmpty ? null : _nikNipController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        createdAt: DateTime.now(),
      );

      context.read<UserProvider>().addUser(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee created successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go('/user-management');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Text(
              'New Employee',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
            ),
            child: Row(
              children: [
                _buildTab('Personal', 0),
                const SizedBox(width: AppConstants.paddingLarge),
                _buildTab('Module Permissions', 1),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: _currentTabIndex == 0
                    ? _buildPersonalTab()
                    : _buildModulePermissionsTab(),
              ),
            ),
          ),
          
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createEmployee,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Create'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/user-management'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _currentTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Field
        _buildLabel('Name', required: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Full Name',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppConstants.paddingLarge),
        
        // Email Field
        _buildLabel('Email', required: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'youremail@example.org',
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
        ),
        
        const SizedBox(height: AppConstants.paddingLarge),
        
        // NIK/NIP Field
        _buildLabel('NIK/NIP'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nikNipController,
          decoration: const InputDecoration(
            hintText: 'NIK/NIP',
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingLarge),
        
        // Password Field
        _buildLabel('Password', required: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            hintText: 'Password',
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppConstants.paddingLarge),
        
        // Phone Number Field
        _buildLabel('Phone Number'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            hintText: 'Phone Number',
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildModulePermissionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role Field with Searchable Dropdown
        _buildLabel('Role', required: true),
        const SizedBox(height: 8),
        _buildSearchableDropdown(
          hint: 'Select a role',
          value: _selectedRole,
          items: _filteredRoles,
          searchController: _roleSearchController,
          isOpen: _isRoleDropdownOpen,
          onToggle: () {
            setState(() {
              _isRoleDropdownOpen = !_isRoleDropdownOpen;
              if (_isRoleDropdownOpen) {
                _isUnitTypeDropdownOpen = false;
                _isFacultyDropdownOpen = false;
                _isMajorDropdownOpen = false;
                _roleSearchController.clear();
                _filteredRoles = _roles;
              }
            });
          },
          onSearch: _filterRoles,
          onSelect: (value) {
            setState(() {
              _selectedRole = value;
              _isRoleDropdownOpen = false;
              // Reset unit selections when role changes
              _selectedUnitType = null;
              _selectedFaculty = null;
              _selectedMajor = null;
            });
          },
        ),
        
        const SizedBox(height: AppConstants.paddingLarge),
        
        // Conditional fields based on role
        // MajorTeam: Show Major selector
        if (_selectedRole == 'MajorTeam') ...[
          _buildLabel('Major', required: true),
          const SizedBox(height: 8),
          _buildSearchableDropdown(
            hint: 'Select a major',
            value: _selectedMajor,
            items: _filteredMajors,
            searchController: _majorSearchController,
            isOpen: _isMajorDropdownOpen,
            onToggle: () {
              setState(() {
                _isMajorDropdownOpen = !_isMajorDropdownOpen;
                if (_isMajorDropdownOpen) {
                  _isRoleDropdownOpen = false;
                  _isUnitTypeDropdownOpen = false;
                  _isFacultyDropdownOpen = false;
                  _majorSearchController.clear();
                  // Load majors from UnitProvider
                  final unitProvider = context.read<UnitProvider>();
                  _filteredMajors = unitProvider.getUnitsByType('program_studi')
                      .map((unit) => unit.name)
                      .toList();
                }
              });
            },
            onSearch: _filterMajors,
            onSelect: (value) {
              setState(() {
                _selectedMajor = value;
                _isMajorDropdownOpen = false;
              });
            },
          ),
        ],
        
        // HeadOfUnit: Show Unit Type, then Faculty or Major based on selection
        if (_selectedRole == 'HeadOfUnit') ...[
          _buildLabel('Unit', required: true),
          const SizedBox(height: 8),
          _buildSearchableDropdown(
            hint: 'Select a unit type',
            value: _selectedUnitType,
            items: _filteredUnitTypes,
            searchController: _unitTypeSearchController,
            isOpen: _isUnitTypeDropdownOpen,
            onToggle: () {
              setState(() {
                _isUnitTypeDropdownOpen = !_isUnitTypeDropdownOpen;
                if (_isUnitTypeDropdownOpen) {
                  _isRoleDropdownOpen = false;
                  _isFacultyDropdownOpen = false;
                  _isMajorDropdownOpen = false;
                  _unitTypeSearchController.clear();
                  _filteredUnitTypes = _unitTypes;
                }
              });
            },
            onSearch: _filterUnitTypes,
            onSelect: (value) {
              setState(() {
                _selectedUnitType = value;
                _isUnitTypeDropdownOpen = false;
                // Reset faculty and major when unit type changes
                _selectedFaculty = null;
                _selectedMajor = null;
              });
            },
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Show Faculty selector if Faculty is selected
          if (_selectedUnitType == 'Faculty') ...[
            _buildLabel('Faculty', required: true),
            const SizedBox(height: 8),
            _buildSearchableDropdown(
              hint: 'Select a faculty',
              value: _selectedFaculty,
              items: _filteredFaculties,
              searchController: _facultySearchController,
              isOpen: _isFacultyDropdownOpen,
              onToggle: () {
                setState(() {
                  _isFacultyDropdownOpen = !_isFacultyDropdownOpen;
                  if (_isFacultyDropdownOpen) {
                    _isRoleDropdownOpen = false;
                    _isUnitTypeDropdownOpen = false;
                    _isMajorDropdownOpen = false;
                    _facultySearchController.clear();
                    // Load faculties from UnitProvider
                    final unitProvider = context.read<UnitProvider>();
                    _filteredFaculties = unitProvider.getFakultasList()
                        .map((unit) => unit.name)
                        .toList();
                  }
                });
              },
              onSearch: _filterFaculties,
              onSelect: (value) {
                setState(() {
                  _selectedFaculty = value;
                  _isFacultyDropdownOpen = false;
                });
              },
            ),
          ],
          
          // Show Major selector if Major is selected
          if (_selectedUnitType == 'Major') ...[
            _buildLabel('Major', required: true),
            const SizedBox(height: 8),
            _buildSearchableDropdown(
              hint: 'Select a major',
              value: _selectedMajor,
              items: _filteredMajors,
              searchController: _majorSearchController,
              isOpen: _isMajorDropdownOpen,
              onToggle: () {
                setState(() {
                  _isMajorDropdownOpen = !_isMajorDropdownOpen;
                  if (_isMajorDropdownOpen) {
                    _isRoleDropdownOpen = false;
                    _isUnitTypeDropdownOpen = false;
                    _isFacultyDropdownOpen = false;
                    _majorSearchController.clear();
                    // Load majors from UnitProvider
                    final unitProvider = context.read<UnitProvider>();
                    _filteredMajors = unitProvider.getUnitsByType('program_studi')
                        .map((unit) => unit.name)
                        .toList();
                  }
                });
              },
              onSearch: _filterMajors,
              onSelect: (value) {
                setState(() {
                  _selectedMajor = value;
                  _isMajorDropdownOpen = false;
                });
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required TextEditingController searchController,
    required bool isOpen,
    required VoidCallback onToggle,
    required Function(String) onSearch,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dropdown Button
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: isOpen ? AppColors.primary : AppColors.border,
                width: isOpen ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value == null 
                          ? AppColors.textHint 
                          : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        
        // Dropdown Menu
        if (isOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: onSearch,
                ),
                
                const SizedBox(height: 8),
                
                // Items List
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return InkWell(
                        onTap: () => onSelect(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
