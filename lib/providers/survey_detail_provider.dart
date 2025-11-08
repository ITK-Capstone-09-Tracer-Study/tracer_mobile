import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/survey_model.dart';

class SurveyDetailProvider extends ChangeNotifier {
  SurveyModel? _currentSurvey;
  String _surveyTitle = 'Untitled Survey';
  String _surveyDescription = '';
  final List<QuestionModel> _questions = [];
  final List<Map<String, dynamic>> _undoStack = [];
  final List<Map<String, dynamic>> _redoStack = [];
  bool _showPreview = false;

  SurveyModel? get currentSurvey => _currentSurvey;
  String get surveyTitle => _surveyTitle;
  String get surveyDescription => _surveyDescription;
  List<QuestionModel> get questions => _questions;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get showPreview => _showPreview;

  void loadSurvey(SurveyModel survey) {
    _currentSurvey = survey;
    _surveyTitle = survey.title;
    _surveyDescription = survey.description ?? '';
    
    // Load questions (dummy for now)
    _questions.clear();
    _questions.add(
      QuestionModel(
        id: 'q1',
        title: 'Question 1',
        questionType: 'multiple_choice',
        options: ['Option 1'],
        order: 0,
      ),
    );
    notifyListeners();
  }

  void updateTitle(String title) {
    _saveState();
    _surveyTitle = title;
    notifyListeners();
  }

  void updateDescription(String description) {
    _saveState();
    _surveyDescription = description;
    notifyListeners();
  }

  void addQuestion({int? afterIndex}) {
    _saveState();
    final order = afterIndex != null ? afterIndex + 1 : _questions.length;
    
    // Shift orders of questions after insertion point
    for (var i = 0; i < _questions.length; i++) {
      if (_questions[i].order >= order) {
        _questions[i] = _questions[i].copyWith(order: _questions[i].order + 1);
      }
    }

    final newQuestion = QuestionModel(
      id: 'q${DateTime.now().millisecondsSinceEpoch}',
      title: 'Untitled question',
      questionType: 'multiple_choice',
      options: ['Option 1'],
      order: order,
    );

    if (afterIndex != null) {
      _questions.insert(afterIndex + 1, newQuestion);
    } else {
      _questions.add(newQuestion);
    }
    
    notifyListeners();
  }

  void updateQuestion(String id, QuestionModel updatedQuestion) {
    _saveState();
    final index = _questions.indexWhere((q) => q.id == id);
    if (index != -1) {
      _questions[index] = updatedQuestion;
      notifyListeners();
    }
  }

  void duplicateQuestion(String id) {
    _saveState();
    final index = _questions.indexWhere((q) => q.id == id);
    if (index != -1) {
      final original = _questions[index];
      final duplicate = QuestionModel(
        id: 'q${DateTime.now().millisecondsSinceEpoch}',
        title: '${original.title} (Copy)',
        questionType: original.questionType,
        options: List.from(original.options),
        isRequired: original.isRequired,
        linearScaleMin: original.linearScaleMin,
        linearScaleMax: original.linearScaleMax,
        linearScaleLabelMin: original.linearScaleLabelMin,
        linearScaleLabelMax: original.linearScaleLabelMax,
        order: original.order + 1,
      );

      // Shift orders of questions after this
      for (var i = index + 1; i < _questions.length; i++) {
        _questions[i] = _questions[i].copyWith(order: _questions[i].order + 1);
      }

      _questions.insert(index + 1, duplicate);
      notifyListeners();
    }
  }

  void deleteQuestion(String id) {
    _saveState();
    final index = _questions.indexWhere((q) => q.id == id);
    if (index != -1) {
      final deletedOrder = _questions[index].order;
      _questions.removeAt(index);

      // Shift orders of questions after deletion
      for (var i = 0; i < _questions.length; i++) {
        if (_questions[i].order > deletedOrder) {
          _questions[i] = _questions[i].copyWith(order: _questions[i].order - 1);
        }
      }

      notifyListeners();
    }
  }

  void togglePreview() {
    _showPreview = !_showPreview;
    notifyListeners();
  }

  void reorderQuestions(int oldIndex, int newIndex) {
    _saveState();
    
    // Adjust newIndex if moving down
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Remove from old position
    final question = _questions.removeAt(oldIndex);

    // Insert at new position
    _questions.insert(newIndex, question);

    // Update all orders
    for (var i = 0; i < _questions.length; i++) {
      _questions[i] = _questions[i].copyWith(order: i);
    }

    notifyListeners();
  }

  void _saveState() {
    _undoStack.add({
      'title': _surveyTitle,
      'description': _surveyDescription,
      'questions': _questions.map((q) => q.toJson()).toList(),
    });
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add({
        'title': _surveyTitle,
        'description': _surveyDescription,
        'questions': _questions.map((q) => q.toJson()).toList(),
      });

      final state = _undoStack.removeLast();
      _surveyTitle = state['title'];
      _surveyDescription = state['description'];
      _questions.clear();
      _questions.addAll(
        (state['questions'] as List).map((q) => QuestionModel.fromJson(q)),
      );
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add({
        'title': _surveyTitle,
        'description': _surveyDescription,
        'questions': _questions.map((q) => q.toJson()).toList(),
      });

      final state = _redoStack.removeLast();
      _surveyTitle = state['title'];
      _surveyDescription = state['description'];
      _questions.clear();
      _questions.addAll(
        (state['questions'] as List).map((q) => QuestionModel.fromJson(q)),
      );
      notifyListeners();
    }
  }
}
