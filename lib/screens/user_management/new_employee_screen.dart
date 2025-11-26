import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/major_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../models/user_model.dart';
import '../../models/major_model.dart';
import '../../models/faculty_model.dart';
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
  FacultyModel? _selectedFaculty;
  MajorModel? _selectedMajor;
  final TextEditingController _roleSearchController = TextEditingController();
  final TextEditingController _unitTypeSearchController = TextEditingController();
  final TextEditingController _facultySearchController = TextEditingController();
  final TextEditingController _majorSearchController = TextEditingController();
  
  final List<Map<String, String>> _roles = [
    {'value': 'admin', 'label': 'Admin'},
    {'value': 'tracer_team', 'label': 'Tracer Team'},
    {'value': 'major_team', 'label': 'Major Team'},
    {'value': 'head_of_unit', 'label': 'Head of Unit'},
  ];
  
  final List<Map<String, String>> _unitTypes = [
    {'value': 'institutional', 'label': 'Institutional'},
    {'value': 'faculty', 'label': 'Faculty'},
    {'value': 'major', 'label': 'Major'},
  ];
  
  List<Map<String, String>> _filteredRoles = [];
  List<Map<String, String>> _filteredUnitTypes = [];
  List<FacultyModel> _filteredFaculties = [];
  List<MajorModel> _filteredMajors = [];
  
  bool _isRoleDropdownOpen = false;
  bool _isUnitTypeDropdownOpen = false;
  bool _isFacultyDropdownOpen = false;
  bool _isMajorDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredRoles = _roles;
    _filteredUnitTypes = _unitTypes;
    
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MajorProvider>().initialize();
      context.read<FacultyProvider>().initialize();
    });
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
            .where((role) => role['label']!.toLowerCase().contains(query.toLowerCase()))
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
            .where((type) => type['label']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterFaculties(String query) {
    final facultyProvider = context.read<FacultyProvider>();
    
    setState(() {
      if (query.isEmpty) {
        _filteredFaculties = facultyProvider.faculties;
      } else {
        _filteredFaculties = facultyProvider.searchFaculties(query);
      }
    });
  }

  void _filterMajors(String query) {
    final majorProvider = context.read<MajorProvider>();
    
    setState(() {
      if (query.isEmpty) {
        _filteredMajors = majorProvider.majors;
      } else {
        _filteredMajors = majorProvider.searchMajors(query);
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
      int? unitId;
      String? unitName;
      
      if (_selectedRole == 'head_of_unit') {
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
        
        if (_selectedUnitType == 'faculty') {
          if (_selectedFaculty == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a faculty'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          unitName = _selectedFaculty?.name;
          // Get faculty ID from selected FacultyModel
          unitId = _selectedFaculty?.id;
        } else if (_selectedUnitType == 'major') {
          if (_selectedMajor == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a major'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          unitName = _selectedMajor?.name;
          // Get major ID from selected MajorModel
          unitId = _selectedMajor?.id;
        } else {
          // Institutional
          unitType = 'institutional';
          unitName = 'Institutional';
        }
      } else if (_selectedRole == 'major_team') {
        if (_selectedMajor == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a major'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        unitType = 'major';
        unitName = _selectedMajor?.name;
        // Get major ID from selected MajorModel
        unitId = _selectedMajor?.id;
      } else {
        // Admin and TracerTeam
        unitType = 'institutional';
      }

      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole!,
        unitType: unitType ?? 'institutional',
        unitId: unitId,
        unitName: unitName,
        nikNip: _nikNipController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
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
    // Get display label for selected role
    String? roleLabel = _selectedRole != null 
        ? _roles.firstWhere((r) => r['value'] == _selectedRole, 
            orElse: () => {'label': _selectedRole!})['label']
        : null;
    
    // Get display label for selected unit type
    String? unitTypeLabel = _selectedUnitType != null 
        ? _unitTypes.firstWhere((u) => u['value'] == _selectedUnitType, 
            orElse: () => {'label': _selectedUnitType!})['label']
        : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role Field with Searchable Dropdown
        _buildLabel('Role', required: true),
        const SizedBox(height: 8),
        _buildRoleDropdown(
          hint: 'Select a role',
          value: roleLabel,
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
        if (_selectedRole == 'major_team') ...[
          _buildLabel('Major', required: true),
          const SizedBox(height: 8),
          _buildMajorDropdown(
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
                  // Load majors from MajorProvider
                  final majorProvider = context.read<MajorProvider>();
                  _filteredMajors = majorProvider.majors;
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
        if (_selectedRole == 'head_of_unit') ...[
          _buildLabel('Unit', required: true),
          const SizedBox(height: 8),
          _buildUnitTypeDropdown(
            hint: 'Select a unit type',
            value: unitTypeLabel,
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
          if (_selectedUnitType == 'faculty') ...[
            _buildLabel('Faculty', required: true),
            const SizedBox(height: 8),
            _buildFacultyDropdown(
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
                    // Load faculties from FacultyProvider
                    final facultyProvider = context.read<FacultyProvider>();
                    _filteredFaculties = facultyProvider.faculties;
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
          if (_selectedUnitType == 'major') ...[
            _buildLabel('Major', required: true),
            const SizedBox(height: 8),
            _buildMajorDropdown(
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
                    // Load majors from MajorProvider
                    final majorProvider = context.read<MajorProvider>();
                    _filteredMajors = majorProvider.majors;
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

  // Major dropdown with MajorModel support
  Widget _buildMajorDropdown({
    required String hint,
    required MajorModel? value,
    required List<MajorModel> items,
    required TextEditingController searchController,
    required bool isOpen,
    required VoidCallback onToggle,
    required Function(String) onSearch,
    required Function(MajorModel) onSelect,
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
                    value?.name ?? hint,
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
                            item.name,
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

  // Faculty dropdown with FacultyModel support
  Widget _buildFacultyDropdown({
    required String hint,
    required FacultyModel? value,
    required List<FacultyModel> items,
    required TextEditingController searchController,
    required bool isOpen,
    required VoidCallback onToggle,
    required Function(String) onSearch,
    required Function(FacultyModel) onSelect,
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
                    value?.name ?? hint,
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
                            item.name,
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

  // Role dropdown with Map<String, String> support
  Widget _buildRoleDropdown({
    required String hint,
    required String? value,
    required List<Map<String, String>> items,
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
                        onTap: () => onSelect(item['value']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Text(
                            item['label']!,
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

  // Unit Type dropdown with Map<String, String> support
  Widget _buildUnitTypeDropdown({
    required String hint,
    required String? value,
    required List<Map<String, String>> items,
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
                        onTap: () => onSelect(item['value']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Text(
                            item['label']!,
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
