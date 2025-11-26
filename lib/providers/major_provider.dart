import 'package:flutter/foundation.dart';
import '../models/major_model.dart';
import '../services/major_service.dart';

/// Provider for Major (Program Studi) management
/// Digunakan untuk dropdown pemilihan major di New Employee screen
class MajorProvider extends ChangeNotifier {
  final MajorService _majorService = MajorService();

  List<MajorModel> _majors = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  List<MajorModel> get majors => _majors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  /// Initialize - fetch all majors from API
  Future<void> initialize() async {
    if (_isInitialized && _majors.isNotEmpty) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _majorService.getAllMajors(
      include: 'department,department.faculty', // Include department and faculty for display
    );
    
    if (response.success && response.data != null) {
      _majors = response.data!;
      // Sort by name
      _majors.sort((a, b) => a.name.compareTo(b.name));
      _errorMessage = null;
      _isInitialized = true;
    } else {
      _errorMessage = response.message;
      // Use dummy data for development if API fails
      _majors = _generateDummyMajors();
      _isInitialized = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Force refresh majors from API
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }

  /// Get major by ID
  MajorModel? getMajorById(int id) {
    try {
      return _majors.firstWhere((major) => major.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get major by name
  MajorModel? getMajorByName(String name) {
    try {
      return _majors.firstWhere((major) => major.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Search majors by name
  List<MajorModel> searchMajors(String query) {
    if (query.isEmpty) return _majors;
    
    return _majors.where((major) {
      return major.name.toLowerCase().contains(query.toLowerCase()) ||
             major.code.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Generate dummy data for development/fallback
  List<MajorModel> _generateDummyMajors() {
    return [
      MajorModel(
        id: 1,
        departmentId: 1,
        code: 'TI',
        name: 'Teknik Informatika',
        departmentName: 'Teknik Informatika',
        facultyName: 'Fakultas Teknologi Industri',
      ),
      MajorModel(
        id: 2,
        departmentId: 1,
        code: 'SI',
        name: 'Sistem Informasi',
        departmentName: 'Teknik Informatika',
        facultyName: 'Fakultas Teknologi Industri',
      ),
      MajorModel(
        id: 3,
        departmentId: 2,
        code: 'TE',
        name: 'Teknik Elektro',
        departmentName: 'Teknik Elektro',
        facultyName: 'Fakultas Teknologi Industri',
      ),
      MajorModel(
        id: 4,
        departmentId: 3,
        code: 'TM',
        name: 'Teknik Mesin',
        departmentName: 'Teknik Mesin',
        facultyName: 'Fakultas Teknologi Industri',
      ),
      MajorModel(
        id: 5,
        departmentId: 4,
        code: 'TS',
        name: 'Teknik Sipil',
        departmentName: 'Teknik Sipil',
        facultyName: 'Fakultas Teknik Sipil dan Perencanaan',
      ),
      MajorModel(
        id: 6,
        departmentId: 5,
        code: 'TK',
        name: 'Teknik Kimia',
        departmentName: 'Teknik Kimia',
        facultyName: 'Fakultas Teknologi Industri',
      ),
      MajorModel(
        id: 7,
        departmentId: 6,
        code: 'MT',
        name: 'Matematika',
        departmentName: 'Matematika',
        facultyName: 'Fakultas MIPA',
      ),
      MajorModel(
        id: 8,
        departmentId: 7,
        code: 'FS',
        name: 'Fisika',
        departmentName: 'Fisika',
        facultyName: 'Fakultas MIPA',
      ),
    ];
  }
}
