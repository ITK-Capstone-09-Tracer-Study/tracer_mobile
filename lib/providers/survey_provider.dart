import 'package:flutter/material.dart';
import '../models/survey_model.dart';
import '../services/survey_service.dart';

/// Provider untuk Survey Management (New Structure)
class SurveyProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();
  
  List<SurveyModel> _surveys = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SurveyModel> get surveys => _surveys;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize - Fetch surveys from API
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _surveyService.getSurveys(
        perPage: 100,
      );
      
      if (response.success && response.data != null) {
        _surveys = response.data!;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load surveys: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new survey
  Future<bool> createSurvey(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _surveyService.createSurvey(data);
      
      if (response.success && response.data != null) {
        _surveys.add(response.data!);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to create survey: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing survey
  Future<bool> updateSurvey(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _surveyService.updateSurvey(id, data);
      
      if (response.success && response.data != null) {
        final index = _surveys.indexWhere((s) => s.id == id);
        if (index != -1) {
          _surveys[index] = response.data!;
        }
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update survey: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete survey
  Future<bool> deleteSurvey(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _surveyService.deleteSurvey(id);
      
      if (response.success) {
        _surveys.removeWhere((s) => s.id == id);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete survey: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get survey by ID
  SurveyModel? getSurveyById(int id) {
    try {
      return _surveys.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filter surveys (for search functionality)
  List<SurveyModel> filterSurveys(String query) {
    if (query.isEmpty) return _surveys;
    
    final lowerQuery = query.toLowerCase();
    return _surveys.where((survey) {
      return survey.title.toLowerCase().contains(lowerQuery) ||
             survey.kindName.toLowerCase().contains(lowerQuery) ||
             survey.graduationNumber.toString().contains(lowerQuery);
    }).toList();
  }
}
