import 'package:flutter/material.dart';
import '../models/survey_model.dart';

class SurveyProvider extends ChangeNotifier {
  // Template surveys (fixed)
  final List<SurveyModel> _templateSurveys = [
    SurveyModel(
      id: 'template_exit',
      title: 'Exit Survey IF',
      type: 'exit_survey',
      lastEdited: DateTime(2025, 9, 1),
      isTemplate: true,
    ),
    SurveyModel(
      id: 'template_tracer1',
      title: 'Tracer Study I IF',
      type: 'tracer_study_1',
      lastEdited: DateTime(2025, 9, 1),
      isTemplate: true,
    ),
    SurveyModel(
      id: 'template_skp',
      title: 'SKP IF',
      type: 'skp',
      lastEdited: DateTime(2025, 9, 1),
      isTemplate: true,
    ),
    SurveyModel(
      id: 'template_tracer2',
      title: 'Tracer Study I SI',
      type: 'tracer_study_2',
      lastEdited: DateTime(2025, 9, 1),
      isTemplate: true,
    ),
  ];

  // Periode list
  final List<PeriodeModel> _periodes = [
    PeriodeModel(
      id: 'p1',
      name: 'Periode 2022',
      year: 2022,
      createdAt: DateTime(2022, 1, 1),
    ),
  ];

  // Periode surveys
  final List<SurveyModel> _periodeSurveys = [
    // Periode 2022 surveys
    SurveyModel(
      id: 'p2022_exit',
      title: 'Exit Survey',
      type: 'exit_survey',
      periode: '2022',
      lastEdited: DateTime(2025, 9, 1),
    ),
    SurveyModel(
      id: 'p2022_tracer1',
      title: 'Exit Survey',
      type: 'tracer_study_1',
      periode: '2022',
      lastEdited: DateTime(2025, 9, 1),
    ),
    SurveyModel(
      id: 'p2022_skp',
      title: 'Exit Survey',
      type: 'skp',
      periode: '2022',
      lastEdited: DateTime(2025, 9, 1),
    ),
    SurveyModel(
      id: 'p2022_tracer2',
      title: 'Exit Survey',
      type: 'tracer_study_2',
      periode: '2022',
      lastEdited: DateTime(2025, 9, 1),
    ),
  ];

  List<SurveyModel> get templateSurveys => _templateSurveys;
  List<PeriodeModel> get periodes => _periodes;
  List<SurveyModel> get periodeSurveys => _periodeSurveys;

  // Get surveys by periode
  List<SurveyModel> getSurveysByPeriode(String periode) {
    return _periodeSurveys
        .where((survey) => survey.periode == periode)
        .toList();
  }

  // Add new periode
  void addPeriode(PeriodeModel periode) {
    _periodes.add(periode);
    
    // Create 4 surveys for this periode
    final surveysToAdd = [
      SurveyModel(
        id: 'p${periode.year}_exit',
        title: 'Exit Survey',
        type: 'exit_survey',
        periode: periode.year.toString(),
        lastEdited: DateTime.now(),
      ),
      SurveyModel(
        id: 'p${periode.year}_tracer1',
        title: 'Exit Survey',
        type: 'tracer_study_1',
        periode: periode.year.toString(),
        lastEdited: DateTime.now(),
      ),
      SurveyModel(
        id: 'p${periode.year}_skp',
        title: 'Exit Survey',
        type: 'skp',
        periode: periode.year.toString(),
        lastEdited: DateTime.now(),
      ),
      SurveyModel(
        id: 'p${periode.year}_tracer2',
        title: 'Exit Survey',
        type: 'tracer_study_2',
        periode: periode.year.toString(),
        lastEdited: DateTime.now(),
      ),
    ];
    
    _periodeSurveys.addAll(surveysToAdd);
    notifyListeners();
  }

  // Update periode name
  void updatePeriode(String id, PeriodeModel updatedPeriode) {
    final index = _periodes.indexWhere((p) => p.id == id);
    if (index != -1) {
      _periodes[index] = updatedPeriode;
      notifyListeners();
    }
  }

  // Delete periode and its surveys
  void deletePeriode(String id) {
    final periode = _periodes.firstWhere((p) => p.id == id);
    _periodes.removeWhere((p) => p.id == id);
    _periodeSurveys.removeWhere((s) => s.periode == periode.year.toString());
    notifyListeners();
  }

  // Update survey
  void updateSurvey(String id, SurveyModel updatedSurvey) {
    final index = _periodeSurveys.indexWhere((s) => s.id == id);
    if (index != -1) {
      _periodeSurveys[index] = updatedSurvey.copyWith(
        lastEdited: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
