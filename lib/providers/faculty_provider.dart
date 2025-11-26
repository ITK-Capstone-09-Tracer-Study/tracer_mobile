import 'package:flutter/foundation.dart';
import '../models/faculty_model.dart';
import '../services/faculty_service.dart';

/// Provider for Faculty (Fakultas) management
/// Digunakan untuk dropdown pemilihan faculty di New Employee screen
class FacultyProvider extends ChangeNotifier {
  final FacultyService _facultyService = FacultyService();

  List<FacultyModel> _faculties = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  List<FacultyModel> get faculties => _faculties;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  /// Initialize - fetch all faculties from API
  Future<void> initialize() async {
    if (_isInitialized && _faculties.isNotEmpty) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _facultyService.getAllFaculties();
    
    if (response.success && response.data != null) {
      _faculties = response.data!;
      // Sort by name
      _faculties.sort((a, b) => a.name.compareTo(b.name));
      _errorMessage = null;
      _isInitialized = true;
    } else {
      _errorMessage = response.message;
      // Use dummy data for development if API fails
      _faculties = _generateDummyFaculties();
      _isInitialized = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Force refresh faculties from API
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }

  /// Get faculty by ID
  FacultyModel? getFacultyById(int id) {
    try {
      return _faculties.firstWhere((faculty) => faculty.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get faculty by name
  FacultyModel? getFacultyByName(String name) {
    try {
      return _faculties.firstWhere((faculty) => faculty.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Search faculties by name
  List<FacultyModel> searchFaculties(String query) {
    if (query.isEmpty) return _faculties;
    
    return _faculties.where((faculty) {
      return faculty.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Generate dummy data for development/fallback
  List<FacultyModel> _generateDummyFaculties() {
    return [
      FacultyModel(
        id: 1,
        name: 'Fakultas Teknologi Industri',
      ),
      FacultyModel(
        id: 2,
        name: 'Fakultas Teknik Sipil dan Perencanaan',
      ),
      FacultyModel(
        id: 3,
        name: 'Fakultas MIPA',
      ),
      FacultyModel(
        id: 4,
        name: 'Fakultas Teknologi Kelautan',
      ),
      FacultyModel(
        id: 5,
        name: 'Fakultas Vokasi',
      ),
    ];
  }
}
