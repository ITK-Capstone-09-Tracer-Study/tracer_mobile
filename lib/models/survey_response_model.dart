/// Model untuk Survey Response Detail
/// Berisi jawaban lengkap dari alumni terhadap survey
class SurveyResponseDetailModel {
  final int id;
  final int surveyId;
  final int alumniId;
  final String alumniName;
  final String alumniEmail;
  final DateTime? completedAt;
  final List<SectionResponseModel> sections;

  SurveyResponseDetailModel({
    required this.id,
    required this.surveyId,
    required this.alumniId,
    required this.alumniName,
    required this.alumniEmail,
    this.completedAt,
    required this.sections,
  });

  factory SurveyResponseDetailModel.fromJson(Map<String, dynamic> json) {
    return SurveyResponseDetailModel(
      id: json['id'] as int,
      surveyId: json['survey_id'] as int,
      alumniId: json['alumni_id'] as int,
      alumniName: json['alumni_name'] as String,
      alumniEmail: json['alumni_email'] as String,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      sections: (json['sections'] as List<dynamic>)
          .map((s) => SectionResponseModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'alumni_id': alumniId,
      'alumni_name': alumniName,
      'alumni_email': alumniEmail,
      'completed_at': completedAt?.toIso8601String(),
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }
}

/// Model untuk Section Response
class SectionResponseModel {
  final int sectionId;
  final String title;
  final String description;
  final int order;
  final List<QuestionResponseModel> questions;

  SectionResponseModel({
    required this.sectionId,
    required this.title,
    required this.description,
    required this.order,
    required this.questions,
  });

  factory SectionResponseModel.fromJson(Map<String, dynamic> json) {
    return SectionResponseModel(
      sectionId: json['section_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => QuestionResponseModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section_id': sectionId,
      'title': title,
      'description': description,
      'order': order,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

/// Model untuk Question Response
class QuestionResponseModel {
  final int questionId;
  final String question;
  final String type; // 'short_answer', 'paragraph', 'multiple_choice', 'checkboxes', 'linear_scale'
  final dynamic answer; // Dapat berupa String, int, atau List<String>
  final List<String>? options; // Untuk multiple_choice dan checkboxes
  final int? fromValue; // Untuk linear_scale
  final int? toValue; // Untuk linear_scale
  final String? fromLabel; // Untuk linear_scale
  final String? toLabel; // Untuk linear_scale

  QuestionResponseModel({
    required this.questionId,
    required this.question,
    required this.type,
    required this.answer,
    this.options,
    this.fromValue,
    this.toValue,
    this.fromLabel,
    this.toLabel,
  });

  /// Get formatted answer for display
  String get formattedAnswer {
    if (answer == null) return '-';
    
    switch (type) {
      case 'short_answer':
      case 'paragraph':
        return answer.toString();
      case 'multiple_choice':
        return answer.toString();
      case 'checkboxes':
        if (answer is List) {
          return (answer as List).join(', ');
        }
        return answer.toString();
      case 'linear_scale':
        return answer.toString();
      default:
        return answer.toString();
    }
  }

  factory QuestionResponseModel.fromJson(Map<String, dynamic> json) {
    return QuestionResponseModel(
      questionId: json['question_id'] as int,
      question: json['question'] as String,
      type: json['type'] as String,
      answer: json['answer'],
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      fromValue: json['from_value'] as int?,
      toValue: json['to_value'] as int?,
      fromLabel: json['from_label'] as String?,
      toLabel: json['to_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question': question,
      'type': type,
      'answer': answer,
      'options': options,
      'from_value': fromValue,
      'to_value': toValue,
      'from_label': fromLabel,
      'to_label': toLabel,
    };
  }
}
