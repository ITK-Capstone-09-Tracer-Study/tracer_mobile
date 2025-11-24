/// Model untuk Section dalam Survey
/// Section adalah "halaman" terpisah dalam survey (seperti Google Forms)
class SectionModel {
  final int? id;
  final int? surveyId;
  String title;
  String description;
  final String? condition; // Condition untuk routing
  int order;
  List<QuestionModel> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SectionModel({
    this.id,
    this.surveyId,
    required this.title,
    required this.description,
    this.condition,
    required this.order,
    this.questions = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as int?,
      surveyId: json['survey_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      condition: json['next_condition'] as String?,
      order: json['order'] as int,
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => QuestionModel.fromJson(q))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
    };

    if (id != null) map['id'] = id;
    if (surveyId != null) map['survey_id'] = surveyId;
    if (condition != null) map['condition'] = condition;
    
    return map;
  }

  SectionModel copyWith({
    int? id,
    int? surveyId,
    String? title,
    String? description,
    String? condition,
    int? order,
    List<QuestionModel>? questions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SectionModel(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      title: title ?? this.title,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      order: order ?? this.order,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Import dari question_model.dart yang akan diupdate
class QuestionModel {
  final int? id;
  QuestionType type; // short_answer, paragraph, multiple_choice, checkboxes, linear_scale
  String question;
  bool required;
  final bool hasCondition;
  final String? condition;
  List<QuestionOption> options; // For multiple_choice & checkboxes
  String? fromLabel; // For linear_scale
  int? fromValue; // For linear_scale
  String? toLabel; // For linear_scale
  int? toValue; // For linear_scale

  QuestionModel({
    this.id,
    required this.type,
    required this.question,
    this.required = false,
    this.hasCondition = false,
    this.condition,
    this.options = const [],
    this.fromLabel,
    this.fromValue,
    this.toLabel,
    this.toValue,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int?,
      type: QuestionType.fromString(json['type'] as String),
      question: json['question'] as String,
      required: json['required'] as bool? ?? false,
      hasCondition: json['has_condition'] as bool? ?? false,
      condition: json['next_condition'] as String?,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((o) => QuestionOption.fromJson(o))
              .toList()
          : [],
      fromLabel: json['from_label'] as String?,
      fromValue: json['from_value'] as int?,
      toLabel: json['to_label'] as String?,
      toValue: json['to_value'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type.value,
      'question': question,
      'required': required,
      'has_condition': hasCondition,
      // Always include options (empty array if not applicable)
      'options': options.map((o) => o.toJson()).toList(),
      // Always include linear scale fields (null if not applicable)
      'from_label': fromLabel,
      'from_value': fromValue,
      'to_label': toLabel,
      'to_value': toValue,
    };

    if (id != null) map['id'] = id;
    if (condition != null) map['next_condition'] = condition;

    return map;
  }

  QuestionModel copyWith({
    int? id,
    QuestionType? type,
    String? question,
    bool? required,
    bool? hasCondition,
    String? condition,
    List<QuestionOption>? options,
    String? fromLabel,
    int? fromValue,
    String? toLabel,
    int? toValue,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      question: question ?? this.question,
      required: required ?? this.required,
      hasCondition: hasCondition ?? this.hasCondition,
      condition: condition ?? this.condition,
      options: options ?? this.options,
      fromLabel: fromLabel ?? this.fromLabel,
      fromValue: fromValue ?? this.fromValue,
      toLabel: toLabel ?? this.toLabel,
      toValue: toValue ?? this.toValue,
    );
  }
}

/// Model untuk Option dalam Question (multiple_choice & checkboxes)
class QuestionOption {
  String label;
  String value;
  final String? condition;

  QuestionOption({
    required this.label,
    required this.value,
    this.condition,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      label: json['label'] as String,
      value: json['value'] as String,
      condition: json['condition'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'label': label,
      'value': value,
    };
    if (condition != null && condition!.isNotEmpty) {
      map['condition'] = condition;
    }
    return map;
  }

  QuestionOption copyWith({
    String? label,
    String? value,
    String? condition,
  }) {
    return QuestionOption(
      label: label ?? this.label,
      value: value ?? this.value,
      condition: condition ?? this.condition,
    );
  }
}

/// Question Types enum
enum QuestionType {
  shortAnswer('short_answer', 'Short Answer'),
  paragraph('paragraph', 'Paragraph'),
  multipleChoice('multiple_choice', 'Multiple Choice'),
  checkboxes('checkboxes', 'Checkboxes'),
  linearScale('linear_scale', 'Linear Scale');

  final String value;
  final String displayName;

  const QuestionType(this.value, this.displayName);

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => QuestionType.shortAnswer,
    );
  }

  String toJson() => value;
}
