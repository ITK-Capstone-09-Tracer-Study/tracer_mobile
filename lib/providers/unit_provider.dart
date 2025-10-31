import 'package:flutter/material.dart';
import '../models/unit_model.dart';

class UnitProvider extends ChangeNotifier {
  // Dummy data untuk development
  final List<UnitModel> _units = [
    // Fakultas
    UnitModel(
      id: 'f1',
      name: 'Fakultas Teknologi Industri',
      type: 'fakultas',
      description: 'Fakultas Teknologi Industri ITK',
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
    ),
    UnitModel(
      id: 'f2',
      name: 'Fakultas Matematika dan Ilmu Pengetahuan Alam',
      type: 'fakultas',
      description: 'Fakultas MIPA ITK',
      createdAt: DateTime.now().subtract(const Duration(days: 480)),
    ),
    
    // Jurusan
    UnitModel(
      id: 'j1',
      name: 'Jurusan Teknologi Informasi',
      type: 'jurusan',
      parentId: 'f1',
      parentName: 'Fakultas Teknologi Industri',
      description: 'Jurusan Teknologi Informasi',
      createdAt: DateTime.now().subtract(const Duration(days: 450)),
    ),
    UnitModel(
      id: 'j2',
      name: 'Jurusan Teknik Elektro',
      type: 'jurusan',
      parentId: 'f1',
      parentName: 'Fakultas Teknologi Industri',
      description: 'Jurusan Teknik Elektro',
      createdAt: DateTime.now().subtract(const Duration(days: 440)),
    ),
    UnitModel(
      id: 'j3',
      name: 'Jurusan Matematika',
      type: 'jurusan',
      parentId: 'f2',
      parentName: 'Fakultas Matematika dan Ilmu Pengetahuan Alam',
      description: 'Jurusan Matematika',
      createdAt: DateTime.now().subtract(const Duration(days: 430)),
    ),
    
    // Program Studi
    UnitModel(
      id: 'ps1',
      name: 'Teknik Informatika',
      type: 'program_studi',
      parentId: 'j1',
      parentName: 'Jurusan Teknologi Informasi',
      description: 'Program Studi Teknik Informatika',
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
    ),
    UnitModel(
      id: 'ps2',
      name: 'Sistem Informasi',
      type: 'program_studi',
      parentId: 'j1',
      parentName: 'Jurusan Teknologi Informasi',
      description: 'Program Studi Sistem Informasi',
      createdAt: DateTime.now().subtract(const Duration(days: 390)),
    ),
    UnitModel(
      id: 'ps3',
      name: 'Teknik Elektro',
      type: 'program_studi',
      parentId: 'j2',
      parentName: 'Jurusan Teknik Elektro',
      description: 'Program Studi Teknik Elektro',
      createdAt: DateTime.now().subtract(const Duration(days: 380)),
    ),
    UnitModel(
      id: 'ps4',
      name: 'Matematika',
      type: 'program_studi',
      parentId: 'j3',
      parentName: 'Jurusan Matematika',
      description: 'Program Studi Matematika',
      createdAt: DateTime.now().subtract(const Duration(days: 370)),
    ),
    UnitModel(
      id: 'ps5',
      name: 'Statistika',
      type: 'program_studi',
      parentId: 'j3',
      parentName: 'Jurusan Matematika',
      description: 'Program Studi Statistika',
      createdAt: DateTime.now().subtract(const Duration(days: 360)),
    ),
  ];

  List<UnitModel> get units => _units;
  
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Get units by type
  List<UnitModel> getUnitsByType(String type) {
    return _units.where((unit) => unit.type == type).toList();
  }

  // Get filtered units by type and search
  List<UnitModel> getFilteredUnitsByType(String type) {
    var filtered = getUnitsByType(type);
    
    if (_searchQuery.isEmpty) {
      return filtered;
    }
    
    return filtered.where((unit) {
      final query = _searchQuery.toLowerCase();
      return unit.name.toLowerCase().contains(query) ||
             (unit.parentName?.toLowerCase().contains(query) ?? false) ||
             (unit.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Search units
  void searchUnits(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Get unit by ID
  UnitModel? getUnitById(String id) {
    try {
      return _units.firstWhere((unit) => unit.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new unit
  void addUnit(UnitModel unit) {
    _units.add(unit);
    notifyListeners();
  }

  // Update unit
  void updateUnit(String id, UnitModel updatedUnit) {
    final index = _units.indexWhere((unit) => unit.id == id);
    if (index != -1) {
      _units[index] = updatedUnit.copyWith(
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Delete unit
  void deleteUnit(String id) {
    _units.removeWhere((unit) => unit.id == id);
    notifyListeners();
  }

  // Get fakultas list for dropdown
  List<UnitModel> getFakultasList() {
    return getUnitsByType('fakultas');
  }

  // Get jurusan list by fakultas
  List<UnitModel> getJurusanByFakultas(String fakultasId) {
    return _units
        .where((unit) => unit.type == 'jurusan' && unit.parentId == fakultasId)
        .toList();
  }

  // Get program studi list by jurusan
  List<UnitModel> getProgramStudiByJurusan(String jurusanId) {
    return _units
        .where((unit) => unit.type == 'program_studi' && unit.parentId == jurusanId)
        .toList();
  }
}
