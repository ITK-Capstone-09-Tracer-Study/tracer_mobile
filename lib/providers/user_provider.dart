import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  // Dummy data untuk development
  final List<UserModel> _users = [
    UserModel(
      id: 1,
      name: 'Dr. Budi Santoso, S.T., M.T.',
      email: 'budi.santoso@itk.ac.id',
      role: 'head_of_unit',
      unitType: 'faculty',
      unitId: 1,
      unitName: 'Fakultas Teknologi Industri',
      nikNip: '198501012010121001',
      phoneNumber: '+62 812-3456-7890',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    UserModel(
      id: 2,
      name: 'Siti Rahmawati, S.Kom., M.Kom.',
      email: 'siti.rahmawati@itk.ac.id',
      role: 'major_team',
      unitType: 'major',
      unitId: 1,
      unitName: 'Teknik Informatika',
      nikNip: '199002152015042002',
      phoneNumber: '+62 813-4567-8901',
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ),
    UserModel(
      id: 3,
      name: 'Ahmad Fauzi',
      email: 'ahmad.fauzi@itk.ac.id',
      role: 'tracer_team',
      unitType: 'institutional',
      nikNip: '199203202018031003',
      phoneNumber: '+62 814-5678-9012',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    UserModel(
      id: 4,
      name: 'Dewi Lestari',
      email: 'dewi.lestari@itk.ac.id',
      role: 'admin',
      unitType: 'institutional',
      nikNip: '199305102019032004',
      phoneNumber: '+62 815-6789-0123',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    UserModel(
      id: 5,
      name: 'Muhammad Rizki',
      email: 'muhammad.rizki@itk.ac.id',
      role: 'head_of_unit',
      unitType: 'major',
      unitId: 2,
      unitName: 'Teknik Elektro',
      nikNip: '11190001',
      phoneNumber: '+62 816-7890-1234',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    ),
    UserModel(
      id: 6,
      name: 'Putri Amelia',
      email: 'putri.amelia@itk.ac.id',
      role: 'major_team',
      unitType: 'major',
      unitId: 3,
      unitName: 'Teknik Mesin',
      nikNip: '11210001',
      phoneNumber: '+62 817-8901-2345',
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
    UserModel(
      id: 7,
      name: 'Dr. Ir. Bambang Supriyanto, M.Eng.',
      email: 'bambang.supriyanto@itk.ac.id',
      role: 'tracer_team',
      unitType: 'institutional',
      nikNip: '197801051999031001',
      phoneNumber: '+62 818-9012-3456',
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
    ),
  ];

  List<UserModel> get users => _users;
  
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  
  String _groupBy = '';
  String get groupBy => _groupBy;

  // Get filtered users based on search
  List<UserModel> get filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    
    return _users.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.name.toLowerCase().contains(query) ||
             user.email.toLowerCase().contains(query) ||
             user.role.toLowerCase().contains(query) ||
             (user.unitName?.toLowerCase().contains(query) ?? false) ||
             user.unitType.toLowerCase().contains(query) ||
             user.nikNip.toLowerCase().contains(query);
    }).toList();
  }

  // Search users
  void searchUsers(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set group by
  void setGroupBy(String value) {
    _groupBy = value;
    notifyListeners();
  }

  // Get user by ID
  UserModel? getUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new user
  void addUser(UserModel user) {
    _users.add(user);
    notifyListeners();
  }

  // Update user
  void updateUser(int id, UserModel updatedUser) {
    final index = _users.indexWhere((user) => user.id == id);
    if (index != -1) {
      _users[index] = updatedUser.copyWith(
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Delete user
  void deleteUser(int id) {
    _users.removeWhere((user) => user.id == id);
    notifyListeners();
  }

  // Get users grouped by unit
  Map<String, List<UserModel>> getUsersByUnit() {
    final Map<String, List<UserModel>> grouped = {};
    for (var user in filteredUsers) {
      final unitKey = user.unitName ?? user.unitType;
      if (!grouped.containsKey(unitKey)) {
        grouped[unitKey] = [];
      }
      grouped[unitKey]!.add(user);
    }
    return grouped;
  }

  // Get users grouped by role
  Map<String, List<UserModel>> getUsersByRole() {
    final Map<String, List<UserModel>> grouped = {};
    for (var user in filteredUsers) {
      if (!grouped.containsKey(user.role)) {
        grouped[user.role] = [];
      }
      grouped[user.role]!.add(user);
    }
    return grouped;
  }
}
