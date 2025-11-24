import 'package:flutter/foundation.dart';
import '../models/survey_kind_model.dart';
import '../services/survey_service.dart';

/// Provider for Survey Kinds management
class SurveyKindProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();

  List<SurveyKindModel> _surveyKinds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SurveyKindModel> get surveyKinds => _surveyKinds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize - fetch survey kinds from API
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _surveyService.getSurveyKinds();
    
    if (response.success && response.data != null) {
      _surveyKinds = response.data!;
      // Sort by order
      _surveyKinds.sort((a, b) => a.order.compareTo(b.order));
      _errorMessage = null;
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create new survey kind
  Future<bool> createSurveyKind({
    required String name,
    required String respondentRole,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Calculate next order
    final nextOrder = _surveyKinds.isEmpty 
        ? 1 
        : _surveyKinds.map((sk) => sk.order).reduce((a, b) => a > b ? a : b) + 1;

    final data = {
      'name': name,
      'respondent_role': respondentRole,
      'order': nextOrder,
    };

    final response = await _surveyService.createSurveyKind(data);
    
    if (response.success && response.data != null) {
      _surveyKinds.add(response.data!);
      _surveyKinds.sort((a, b) => a.order.compareTo(b.order));
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
  }

  /// Update survey kind
  Future<bool> updateSurveyKind({
    required int id,
    required String name,
    required String respondentRole,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final existingKind = _surveyKinds.firstWhere((sk) => sk.id == id);
    
    final data = {
      'name': name,
      'respondent_role': respondentRole,
      'order': existingKind.order, // Keep existing order
    };

    final response = await _surveyService.updateSurveyKind(id, data);
    
    if (response.success && response.data != null) {
      final index = _surveyKinds.indexWhere((sk) => sk.id == id);
      if (index != -1) {
        _surveyKinds[index] = response.data!;
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
  }

  /// Delete survey kind
  Future<bool> deleteSurveyKind(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _surveyService.deleteSurveyKind(id);
    
    if (response.success) {
      _surveyKinds.removeWhere((sk) => sk.id == id);
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
  }

  /// Reorder survey kinds
  Future<bool> reorderSurveyKinds(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return true;

    // Adjust newIndex if moving down
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Move item in list
    final item = _surveyKinds.removeAt(oldIndex);
    _surveyKinds.insert(newIndex, item);

    // Update order values
    final updatedKinds = <SurveyKindModel>[];
    for (int i = 0; i < _surveyKinds.length; i++) {
      final kind = _surveyKinds[i];
      if (kind.order != i + 1) {
        updatedKinds.add(SurveyKindModel(
          id: kind.id,
          name: kind.name,
          respondentRole: kind.respondentRole,
          order: i + 1,
          isActive: kind.isActive,
          createdAt: kind.createdAt,
          updatedAt: kind.updatedAt,
        ));
      } else {
        updatedKinds.add(kind);
      }
    }
    _surveyKinds = updatedKinds;
    
    notifyListeners();

    // Update order in API for each changed item
    bool allSuccess = true;
    for (final kind in _surveyKinds) {
      final data = {
        'name': kind.name,
        'respondent_role': kind.respondentRole,
        'order': kind.order,
      };
      
      final response = await _surveyService.updateSurveyKind(kind.id, data);
      if (!response.success) {
        allSuccess = false;
        _errorMessage = 'Failed to update order: ${response.message}';
      }
    }

    if (!allSuccess) {
      // Refresh from server if any update failed
      await initialize();
    }

    return allSuccess;
  }
}
