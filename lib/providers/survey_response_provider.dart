import 'package:flutter/material.dart';
import '../models/survey_response_model.dart';
import '../models/survey_report_model.dart';

class SurveyResponseProvider extends ChangeNotifier {
  // State management
  bool _isLoading = false;
  String? _errorMessage;
  
  // Response data
  List<AlumniResponseModel> _respondents = [];
  int? _selectedRespondentId;
  SurveyResponseDetailModel? _currentResponse;
  
  // Section navigation
  int _currentSectionIndex = 0;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AlumniResponseModel> get respondents => _respondents;
  int? get selectedRespondentId => _selectedRespondentId;
  SurveyResponseDetailModel? get currentResponse => _currentResponse;
  int get currentSectionIndex => _currentSectionIndex;
  
  int get totalSections => _currentResponse?.sections.length ?? 0;
  SectionResponseModel? get currentSection {
    if (_currentResponse == null || _currentSectionIndex >= totalSections) {
      return null;
    }
    return _currentResponse!.sections[_currentSectionIndex];
  }
  
  bool get canGoToPrevious => _currentSectionIndex > 0;
  bool get canGoToNext => _currentSectionIndex < totalSections - 1;
  
  /// Initialize with survey ID and fetch respondents list
  Future<void> initialize(int surveyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // TODO: Implement API call
      // final response = await apiService.getSurveyRespondents(surveyId);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Dummy data - hanya alumni yang sudah mengisi survey
      _respondents = _generateDummyRespondents();
      
      // Auto-select first respondent if available
      if (_respondents.isNotEmpty) {
        await selectRespondent(_respondents.first.id);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load respondents: $e';
      notifyListeners();
    }
  }
  
  /// Select a respondent and load their response
  Future<void> selectRespondent(int respondentId) async {
    _selectedRespondentId = respondentId;
    _currentSectionIndex = 0; // Reset to first section
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // TODO: Implement API call
      // final response = await apiService.getSurveyResponse(surveyId, respondentId);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Dummy data
      _currentResponse = _generateDummyResponse(respondentId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load response: $e';
      notifyListeners();
    }
  }
  
  /// Navigate to next section
  void goToNextSection() {
    if (canGoToNext) {
      _currentSectionIndex++;
      notifyListeners();
    }
  }
  
  /// Navigate to previous section
  void goToPreviousSection() {
    if (canGoToPrevious) {
      _currentSectionIndex--;
      notifyListeners();
    }
  }
  
  /// Delete current response
  Future<bool> deleteResponse() async {
    if (_selectedRespondentId == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // TODO: Implement API call
      // await apiService.deleteSurveyResponse(surveyId, _selectedRespondentId!);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Remove from respondents list
      _respondents.removeWhere((r) => r.id == _selectedRespondentId);
      
      // Select next respondent or clear
      if (_respondents.isNotEmpty) {
        await selectRespondent(_respondents.first.id);
      } else {
        _currentResponse = null;
        _selectedRespondentId = null;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete response: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Export response (placeholder for future implementation)
  Future<void> exportResponse() async {
    // TODO: Implement export functionality
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  // ===== DUMMY DATA GENERATORS =====
  
  List<AlumniResponseModel> _generateDummyRespondents() {
    return [
      AlumniResponseModel(
        id: 1,
        name: 'Dr. Porter Stroman DVM',
        email: 'bill92@mccullough.com',
        nim: '10121001',
        facultyId: 1,
        facultyName: 'Fakultas Teknologi Industri',
        majorId: 1,
        majorName: 'Teknik Informatika',
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AlumniResponseModel(
        id: 2,
        name: 'Stefanie Schneider Sr.',
        email: 'krystal.predovic@gmail.com',
        nim: '10121002',
        facultyId: 1,
        facultyName: 'Fakultas Teknologi Industri',
        majorId: 1,
        majorName: 'Teknik Informatika',
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      AlumniResponseModel(
        id: 3,
        name: 'Prof. Henri Mitchell',
        email: 'celestine73@hotmail.com',
        nim: '10121003',
        facultyId: 1,
        facultyName: 'Fakultas Teknologi Industri',
        majorId: 1,
        majorName: 'Teknik Informatika',
        completedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      AlumniResponseModel(
        id: 4,
        name: 'Janis Orn DDS',
        email: 'norval00@schuppe.com',
        nim: '10121004',
        facultyId: 1,
        facultyName: 'Fakultas Teknologi Industri',
        majorId: 2,
        majorName: 'Sistem Informasi',
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      AlumniResponseModel(
        id: 5,
        name: 'Miss Jayda Howell MD',
        email: 'cole.sedrick@gmail.com',
        nim: '10121005',
        facultyId: 1,
        facultyName: 'Fakultas Teknologi Industri',
        majorId: 2,
        majorName: 'Sistem Informasi',
        completedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      AlumniResponseModel(
        id: 6,
        name: 'Jerome Bayer',
        email: 'cashmill@durgan.org',
        nim: '10121006',
        facultyId: 2,
        facultyName: 'Fakultas MIPA',
        majorId: 3,
        majorName: 'Matematika',
        completedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      AlumniResponseModel(
        id: 7,
        name: 'Alva Tremblay',
        email: 'janelle.schmeler@yahoo.com',
        nim: '10121007',
        facultyId: 2,
        facultyName: 'Fakultas MIPA',
        majorId: 3,
        majorName: 'Matematika',
        completedAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      AlumniResponseModel(
        id: 8,
        name: 'Lavern Johns',
        email: 'caden.mann@example.org',
        nim: '10121008',
        facultyId: 2,
        facultyName: 'Fakultas MIPA',
        majorId: 4,
        majorName: 'Statistika',
        completedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }
  
  SurveyResponseDetailModel _generateDummyResponse(int respondentId) {
    final respondent = _respondents.firstWhere((r) => r.id == respondentId);
    
    return SurveyResponseDetailModel(
      id: respondentId,
      surveyId: 1,
      alumniId: respondentId,
      alumniName: respondent.name,
      alumniEmail: respondent.email,
      completedAt: respondent.completedAt,
      sections: [
        SectionResponseModel(
          sectionId: 1,
          title: 'Data Diri',
          description: 'Informasi dasar tentang alumni',
          order: 1,
          questions: [
            QuestionResponseModel(
              questionId: 1,
              question: 'quisquam ut dolor',
              type: 'linear_scale',
              answer: -4,
              fromValue: -4,
              toValue: 1,
              fromLabel: 'Sangat Tidak Setuju',
              toLabel: 'Sangat Setuju',
            ),
            QuestionResponseModel(
              questionId: 2,
              question: 'Ipsus modi reprehenderit in quas omnis et qui',
              type: 'multiple_choice',
              answer: 'nihil',
              options: ['nihil', 'et', 'sit'],
            ),
            QuestionResponseModel(
              questionId: 3,
              question: 'est temporibus dolores repellendus ductius cumque accusamus saepe et',
              type: 'linear_scale',
              answer: -5,
              fromValue: -5,
              toValue: -2,
              fromLabel: 'Sangat Buruk',
              toLabel: 'Sangat Baik',
            ),
          ],
        ),
        SectionResponseModel(
          sectionId: 2,
          title: 'Pekerjaan',
          description: 'Informasi tentang status pekerjaan',
          order: 2,
          questions: [
            QuestionResponseModel(
              questionId: 4,
              question: 'tincidunt elus quam illum',
              type: 'paragraph',
              answer: 'fugit',
            ),
            QuestionResponseModel(
              questionId: 5,
              question: 'et soluta omnis rerum voluptatius et tempora qui quis quia',
              type: 'short_answer',
              answer: 'veya',
            ),
            QuestionResponseModel(
              questionId: 6,
              question: 'Ipsus aut ut cumque aliqua tasto ductimus',
              type: 'linear_scale',
              answer: 4,
              fromValue: 4,
              toValue: 5,
              fromLabel: 'Tidak Puas',
              toLabel: 'Sangat Puas',
            ),
          ],
        ),
        SectionResponseModel(
          sectionId: 3,
          title: 'Kompetensi',
          description: 'Penilaian kompetensi yang dimiliki',
          order: 3,
          questions: [
            QuestionResponseModel(
              questionId: 7,
              question: 'repetit error qui deserunt nihil',
              type: 'linear_scale',
              answer: 1,
              fromValue: 1,
              toValue: 5,
              fromLabel: 'Sangat Rendah',
              toLabel: 'Sangat Tinggi',
            ),
            QuestionResponseModel(
              questionId: 8,
              question: 'sequi cupiditate quis repudiandae rerum labore',
              type: 'checkboxes',
              answer: ['fugiat', 'praesentium', 'ut', 'cumque', 'dolores'],
              options: ['fugiat', 'praesentium', 'ut', 'cumque', 'dolores'],
            ),
          ],
        ),
      ],
    );
  }
}
