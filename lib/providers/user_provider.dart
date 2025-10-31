import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  // Dummy data untuk development
  List<UserModel> _users = [
    UserModel(
      id: '1',
      name: 'Dr. Budi Santoso, S.T., M.T.',
      email: 'budi.santoso@itk.ac.id',
      role: 'Dosen',
      unit: 'Teknik Informatika',
      nikNip: '198501012010121001',
      phone: '+62 812-3456-7890',
      position: 'Kepala Program Studi',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    UserModel(
      id: '2',
      name: 'Siti Rahmawati, S.Kom., M.Kom.',
      email: 'siti.rahmawati@itk.ac.id',
      role: 'Dosen',
      unit: 'Teknik Informatika',
      nikNip: '199002152015042002',
      phone: '+62 813-4567-8901',
      position: 'Dosen',
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ),
    UserModel(
      id: '3',
      name: 'Ahmad Fauzi',
      email: 'ahmad.fauzi@itk.ac.id',
      role: 'Staff',
      unit: 'Administrasi',
      nikNip: '199203202018031003',
      phone: '+62 814-5678-9012',
      position: 'Staff Administrasi',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    UserModel(
      id: '4',
      name: 'Dewi Lestari',
      email: 'dewi.lestari@itk.ac.id',
      role: 'Admin',
      unit: 'Teknik Informatika',
      nikNip: '199305102019032004',
      phone: '+62 815-6789-0123',
      position: 'Administrator Sistem',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    UserModel(
      id: '5',
      name: 'Muhammad Rizki',
      email: 'muhammad.rizki@student.itk.ac.id',
      role: 'Alumni',
      unit: 'Teknik Informatika',
      nikNip: '11190001',
      phone: '+62 816-7890-1234',
      position: 'Alumni',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    ),
    UserModel(
      id: '6',
      name: 'Putri Amelia',
      email: 'putri.amelia@student.itk.ac.id',
      role: 'Mahasiswa',
      unit: 'Teknik Informatika',
      nikNip: '11210001',
      phone: '+62 817-8901-2345',
      position: 'Mahasiswa Aktif',
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
    UserModel(
      id: '7',
      name: 'Dr. Ir. Bambang Supriyanto, M.Eng.',
      email: 'bambang.supriyanto@itk.ac.id',
      role: 'Dosen',
      unit: 'Teknik Elektro',
      nikNip: '197801051999031001',
      phone: '+62 818-9012-3456',
      position: 'Profesor',
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
             user.unit.toLowerCase().contains(query) ||
             (user.nikNip?.toLowerCase().contains(query) ?? false);
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
  UserModel? getUserById(String id) {
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
  void updateUser(String id, UserModel updatedUser) {
    final index = _users.indexWhere((user) => user.id == id);
    if (index != -1) {
      _users[index] = updatedUser.copyWith(
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Delete user
  void deleteUser(String id) {
    _users.removeWhere((user) => user.id == id);
    notifyListeners();
  }

  // Get users grouped by unit
  Map<String, List<UserModel>> getUsersByUnit() {
    final Map<String, List<UserModel>> grouped = {};
    for (var user in filteredUsers) {
      if (!grouped.containsKey(user.unit)) {
        grouped[user.unit] = [];
      }
      grouped[user.unit]!.add(user);
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
