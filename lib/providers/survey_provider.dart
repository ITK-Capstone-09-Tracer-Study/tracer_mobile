import 'package:flutter/material.dart';
import '../models/survey_model.dart';
import '../services/survey_service.dart';

class SurveyProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();
  
  List<SurveyModel> _templateSurveys = [];
  List<PeriodeModel> _periodes = [];
  List<SurveyModel> _periodeSurveys = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  List<SurveyModel> get templateSurveys => _templateSurveys;
  List<PeriodeModel> get periodes => _periodes;
  List<SurveyModel> get periodeSurveys => _periodeSurveys;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize and fetch data
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch Survey Kinds (Templates)
      final kindsResponse = await _surveyService.getSurveyKinds();
      if (kindsResponse.success && kindsResponse.data != null) {
        // Convert SurveyKindModel to SurveyModel (as templates)
        _templateSurveys = kindsResponse.data!.map((kind) => SurveyModel(
          id: 'kind_${kind.id}',
          dbId: kind.id,
          title: kind.name,
          type: kind.name,
          lastEdited: kind.updatedAt ?? DateTime.now(),
          description: kind.description,
          isTemplate: true,
          isActive: kind.isActive,
          surveyKindId: kind.id,
        )).toList();
      }

      // Fetch Surveys
      final surveysResponse = await _surveyService.getSurveys();
      if (surveysResponse.success && surveysResponse.data != null) {
        _periodeSurveys = surveysResponse.data!;
        
        // Extract unique years to create Periodes
        final years = _periodeSurveys
            .map((s) => s.periode)
            .where((p) => p != null)
            .map((p) => int.tryParse(p!))
            .where((y) => y != null)
            .toSet()
            .toList();
            
        years.sort((a, b) => b!.compareTo(a!)); // Sort descending
        
        _periodes = years.map((year) => PeriodeModel(
          id: year.toString(),
          name: 'Periode $year',
          year: year!,
          createdAt: DateTime.now(), // We don't have this info from API grouping
        )).toList();
      }
    } catch (e) {
      _errorMessage = 'Failed to load surveys: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get surveys by periode
  List<SurveyModel> getSurveysByPeriode(String periode) {
    return _periodeSurveys
        .where((survey) => survey.periode == periode)
        .toList();
  }

  // Add new periode (Create surveys for a year)
  Future<void> addPeriode(PeriodeModel periode) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // For each template (SurveyKind), create a new Survey for this year
      for (var template in _templateSurveys) {
        if (template.surveyKindId != null) {
          await _surveyService.createSurvey({
            'name': template.title,
            'survey_kind_id': template.surveyKindId,
            'year': periode.year,
            'description': template.description,
            'is_active': true,
            'sections': [], // Empty sections initially
          });
        }
      }
      
      // Refresh data
      await initialize();
      
    } catch (e) {
      _errorMessage = 'Failed to create surveys for periode: $e';
      // Fallback: add locally so UI updates even if API fails (for demo/testing)
      _periodes.add(periode);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update periode name
  void updatePeriode(String id, PeriodeModel updatedPeriode) {
    final index = _periodes.indexWhere((p) => p.id == id);
    if (index != -1) {
      _periodes[index] = updatedPeriode;
      notifyListeners();
    }
  }

  // Delete periode
  Future<void> deletePeriode(String periodeId) async {
    // Delete all surveys in this periode
    final surveysToDelete = _periodeSurveys.where((s) => s.periode == periodeId).toList();
    
    for (var survey in surveysToDelete) {
      if (survey.dbId != null) {
        await _surveyService.deleteSurvey(survey.dbId!);
      }
    }
    
    _periodes.removeWhere((p) => p.id == periodeId);
    _periodeSurveys.removeWhere((s) => s.periode == periodeId);
    notifyListeners();
  }
}
