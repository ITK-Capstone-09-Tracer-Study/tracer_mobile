import 'package:flutter/material.dart';
import '../models/survey_report_model.dart';
import '../models/faculty_model.dart';
import '../models/major_model.dart';

class SurveyReportProvider extends ChangeNotifier {
  // State management
  bool _isLoading = false;
  String? _errorMessage;
  
  // Survey list data
  List<SurveyReportModel> _surveys = [];
  List<SurveyReportModel> _filteredSurveys = [];
  
  // Pagination
  int _currentPage = 1;
  int _perPage = 10;
  int _totalPages = 1;
  int _totalItems = 0;
  
  // Search
  String _searchQuery = '';
  
  // Survey detail data
  SurveyReportModel? _selectedSurvey;
  SurveyStatisticsModel? _statistics;
  List<AlumniResponseModel> _responses = [];
  List<AlumniResponseModel> _filteredResponses = [];
  
  // Filter data
  List<FacultyModel> _faculties = [];
  List<MajorModel> _majors = [];
  List<MajorModel> _filteredMajors = [];
  
  int? _selectedFacultyId;
  int? _selectedMajorId;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SurveyReportModel> get surveys => _filteredSurveys;
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  String get searchQuery => _searchQuery;
  
  SurveyReportModel? get selectedSurvey => _selectedSurvey;
  SurveyStatisticsModel? get statistics => _statistics;
  List<AlumniResponseModel> get responses => _filteredResponses;
  
  List<FacultyModel> get faculties => _faculties;
  List<MajorModel> get majors => _filteredMajors;
  int? get selectedFacultyId => _selectedFacultyId;
  int? get selectedMajorId => _selectedMajorId;
  
  // ===== SURVEY LIST METHODS =====
  
  /// Fetch surveys with pagination
  Future<void> fetchSurveys({int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // TODO: Implement API call
      // final response = await apiService.getSurveys(page: page, perPage: _perPage);
      
      // Dummy data untuk sementara
      await Future.delayed(const Duration(milliseconds: 500));
      
      _surveys = _generateDummySurveys();
      _filteredSurveys = List.from(_surveys);
      _currentPage = page;
      _totalItems = _surveys.length;
      _totalPages = (_totalItems / _perPage).ceil();
      
      _applySearchFilter();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch surveys: $e';
      notifyListeners();
    }
  }
  
  /// Search surveys
  void searchSurveys(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }
  
  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredSurveys = List.from(_surveys);
    } else {
      _filteredSurveys = _surveys.where((survey) {
        return survey.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               survey.graduationNumber.toString().contains(_searchQuery);
      }).toList();
    }
  }
  
  /// Change items per page
  void changePerPage(int newPerPage) {
    _perPage = newPerPage;
    _currentPage = 1;
    fetchSurveys(page: 1);
  }
  
  /// Go to next page
  void nextPage() {
    if (_currentPage < _totalPages) {
      fetchSurveys(page: _currentPage + 1);
    }
  }
  
  /// Go to previous page
  void previousPage() {
    if (_currentPage > 1) {
      fetchSurveys(page: _currentPage - 1);
    }
  }
  
  // ===== SURVEY DETAIL METHODS =====
  
  /// Fetch survey detail with statistics and responses
  Future<void> fetchSurveyDetail(int surveyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // TODO: Implement API calls
      // final surveyResponse = await apiService.getSurveyById(surveyId);
      // final statsResponse = await apiService.getSurveyStatistics(surveyId);
      // final responsesData = await apiService.getSurveyResponses(surveyId);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Dummy data
      _selectedSurvey = _surveys.firstWhere((s) => s.id == surveyId);
      _statistics = SurveyStatisticsModel(
        surveyId: surveyId,
        totalTarget: 31,
        completed: 8,
        notCompleted: 23,
      );
      _responses = _generateDummyResponses();
      _filteredResponses = List.from(_responses);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch survey detail: $e';
      notifyListeners();
    }
  }
  
  /// Fetch faculties for filter
  Future<void> fetchFaculties() async {
    try {
      // TODO: Implement API call
      // final response = await apiService.getFaculties();
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Dummy data
      _faculties = [
        FacultyModel(id: 1, name: 'Fakultas Consequuntur Magnam Libero'),
        FacultyModel(id: 2, name: 'Fakultas Iure Quo Dolores'),
        FacultyModel(id: 3, name: 'Fakultas Qui Deleniti Pariatur'),
        FacultyModel(id: 4, name: 'Fakultas Cupiditate Quos Commodi'),
      ];
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch faculties: $e';
      notifyListeners();
    }
  }
  
  /// Fetch all majors
  Future<void> fetchMajors() async {
    try {
      // TODO: Implement API call
      // final response = await apiService.getMajors();
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Dummy data
      _majors = [
        MajorModel(id: 1, departmentId: 1, code: 'SUR', name: 'Surveyor', facultyName: 'Fakultas Consequuntur Magnam Libero'),
        MajorModel(id: 2, departmentId: 2, code: 'ENV', name: 'Environmental Compliance Inspector', facultyName: 'Fakultas Iure Quo Dolores'),
        MajorModel(id: 3, departmentId: 3, code: 'OIL', name: 'Oil Service Unit Operator', facultyName: 'Fakultas Iure Quo Dolores'),
        MajorModel(id: 4, departmentId: 4, code: 'PRD', name: 'Production Worker', facultyName: 'Fakultas Qui Deleniti Pariatur'),
        MajorModel(id: 5, departmentId: 5, code: 'SET', name: 'Set Designer', facultyName: 'Fakultas Consequuntur Magnam Libero'),
        MajorModel(id: 6, departmentId: 6, code: 'EED', name: 'Electrical and Electronics Drafter', facultyName: 'Fakultas Iure Quo Dolores'),
        MajorModel(id: 7, departmentId: 7, code: 'CRI', name: 'Criminal Investigator', facultyName: 'Fakultas Cupiditate Quos Commodi'),
        MajorModel(id: 8, departmentId: 8, code: 'HAN', name: 'Hand Presser', facultyName: 'Fakultas Qui Deleniti Pariatur'),
      ];
      _filteredMajors = List.from(_majors);
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch majors: $e';
      notifyListeners();
    }
  }
  
  /// Set faculty filter
  void setFacultyFilter(int? facultyId) {
    _selectedFacultyId = facultyId;
    _selectedMajorId = null; // Reset major filter when faculty changes
    
    // Filter majors berdasarkan fakultas
    if (facultyId == null) {
      _filteredMajors = List.from(_majors);
    } else {
      final facultyName = _faculties.firstWhere((f) => f.id == facultyId).name;
      _filteredMajors = _majors.where((m) => m.facultyName == facultyName).toList();
    }
    
    _applyResponseFilter();
    notifyListeners();
  }
  
  /// Set major filter
  void setMajorFilter(int? majorId) {
    _selectedMajorId = majorId;
    _applyResponseFilter();
    notifyListeners();
  }
  
  /// Apply filter to responses
  void _applyResponseFilter() {
    _filteredResponses = _responses.where((response) {
      bool matchFaculty = _selectedFacultyId == null || response.facultyId == _selectedFacultyId;
      bool matchMajor = _selectedMajorId == null || response.majorId == _selectedMajorId;
      return matchFaculty && matchMajor;
    }).toList();
  }
  
  /// Reset filters
  void resetFilters() {
    _selectedFacultyId = null;
    _selectedMajorId = null;
    _filteredMajors = List.from(_majors);
    _filteredResponses = List.from(_responses);
    notifyListeners();
  }
  
  // ===== DUMMY DATA GENERATORS =====
  
  List<SurveyReportModel> _generateDummySurveys() {
    return [
      SurveyReportModel(
        id: 1,
        kindId: 1,
        graduationNumber: 6653,
        title: 'nostrum sequi adipisci',
        startedAt: DateTime(2011, 1, 9),
        endedAt: DateTime(2026, 1, 16),
      ),
      SurveyReportModel(
        id: 2,
        kindId: 1,
        graduationNumber: 6653,
        title: 'neque in et voluptatum',
        startedAt: DateTime(1981, 12, 28),
        endedAt: DateTime(1982, 3, 21),
      ),
      SurveyReportModel(
        id: 3,
        kindId: 2,
        graduationNumber: 37070,
        title: 'enim',
        startedAt: DateTime(1973, 8, 24),
        endedAt: DateTime(1973, 9, 4),
      ),
      SurveyReportModel(
        id: 4,
        kindId: 2,
        graduationNumber: 37070,
        title: 'voluptas beatae minus doloremque veniam',
        startedAt: DateTime(1991, 9, 8),
        endedAt: DateTime(1991, 12, 5),
      ),
      SurveyReportModel(
        id: 5,
        kindId: 3,
        graduationNumber: 4,
        title: 'incidunt eos',
        startedAt: DateTime(1988, 4, 28),
        endedAt: DateTime(1988, 7, 24),
      ),
      SurveyReportModel(
        id: 6,
        kindId: 3,
        graduationNumber: 4,
        title: 'facilis architecto eaque officia',
        startedAt: DateTime(2012, 6, 9),
        endedAt: DateTime(2012, 6, 13),
      ),
      SurveyReportModel(
        id: 7,
        kindId: 1,
        graduationNumber: 6653,
        title: 'adipisci sint animi autem explicabo',
        startedAt: DateTime(2010, 6, 20),
        endedAt: DateTime(2010, 7, 16),
      ),
      SurveyReportModel(
        id: 8,
        kindId: 1,
        graduationNumber: 6653,
        title: 'quis recusandae velit eum',
        startedAt: DateTime(1974, 2, 15),
        endedAt: DateTime(1974, 2, 18),
      ),
      SurveyReportModel(
        id: 9,
        kindId: 2,
        graduationNumber: 37070,
        title: 'voluptatem',
        startedAt: DateTime(1988, 9, 5),
        endedAt: DateTime(1988, 10, 18),
      ),
      SurveyReportModel(
        id: 10,
        kindId: 2,
        graduationNumber: 37070,
        title: 'laborum nesciunt similique',
        startedAt: DateTime(2005, 10, 12),
        endedAt: DateTime(2005, 11, 26),
      ),
    ];
  }
  
  List<AlumniResponseModel> _generateDummyResponses() {
    return [
      AlumniResponseModel(
        id: 1,
        name: 'Dr. Porter Stroman DVM',
        email: 'bill92@mccullough.info',
        nim: '77724655',
        facultyId: 1,
        facultyName: 'Fakultas Consequuntur Magnam Libero',
        majorId: 1,
        majorName: 'Surveyor',
        completedAt: DateTime(2025, 11, 17, 17, 49, 22),
      ),
      AlumniResponseModel(
        id: 2,
        name: 'Stefanie Schneider Sr.',
        email: 'krystal.predovic@predovic.com',
        nim: '81339854',
        facultyId: 2,
        facultyName: 'Fakultas Iure Quo Dolores',
        majorId: 2,
        majorName: 'Environmental Compliance Inspector',
        completedAt: DateTime(2025, 11, 22, 7, 41, 14),
      ),
      AlumniResponseModel(
        id: 3,
        name: 'Prof. Henri Mitchell',
        email: 'celestine73@hotmail.com',
        nim: '82810714',
        facultyId: 2,
        facultyName: 'Fakultas Iure Quo Dolores',
        majorId: 3,
        majorName: 'Oil Service Unit Operator',
        completedAt: DateTime(1983, 1, 7, 1, 54, 7),
      ),
      AlumniResponseModel(
        id: 4,
        name: 'Janis Orn DDS',
        email: 'norval00@schuppe.info',
        nim: '12426901',
        facultyId: 3,
        facultyName: 'Fakultas Qui Deleniti Pariatur',
        majorId: 4,
        majorName: 'Production Worker',
        completedAt: null,
      ),
      AlumniResponseModel(
        id: 5,
        name: 'Miss Jayda Howell MD',
        email: 'cole.sedrick@gmail.com',
        nim: '85610187',
        facultyId: 1,
        facultyName: 'Fakultas Consequuntur Magnam Libero',
        majorId: 5,
        majorName: 'Set Designer',
        completedAt: DateTime(1996, 5, 29, 10, 18, 0),
      ),
      AlumniResponseModel(
        id: 6,
        name: 'Jerome Pouros',
        email: 'aschmitt@durgan.net',
        nim: '23370281',
        facultyId: 2,
        facultyName: 'Fakultas Iure Quo Dolores',
        majorId: 6,
        majorName: 'Electrical and Electronics Drafter',
        completedAt: DateTime(1998, 11, 23, 22, 31, 4),
      ),
      AlumniResponseModel(
        id: 7,
        name: 'Myrtice Braun MD',
        email: 'lbotsford@yahoo.com',
        nim: '12056221',
        facultyId: 4,
        facultyName: 'Fakultas Cupiditate Quos Commodi',
        majorId: 7,
        majorName: 'Criminal Investigator',
        completedAt: DateTime(2002, 4, 30, 3, 51, 48),
      ),
      AlumniResponseModel(
        id: 8,
        name: 'Tina Wolff',
        email: 'zelda.moore@brown.biz',
        nim: '15523372',
        facultyId: 3,
        facultyName: 'Fakultas Qui Deleniti Pariatur',
        majorId: 8,
        majorName: 'Hand Presser',
        completedAt: null,
      ),
    ];
  }
}
