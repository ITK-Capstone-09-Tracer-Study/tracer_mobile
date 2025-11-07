class SurveyModel {
  final String id;
  final String title;
  final String type; // 'exit_survey', 'tracer_study_1', 'skp', 'tracer_study_2'
  final String? periode; // null untuk template, 'YYYY' untuk periode
  final DateTime lastEdited;
  final String? description;
  final bool isTemplate;

  SurveyModel({
    required this.id,
    required this.title,
    required this.type,
    this.periode,
    required this.lastEdited,
    this.description,
    this.isTemplate = false,
  });

  SurveyModel copyWith({
    String? id,
    String? title,
    String? type,
    String? periode,
    DateTime? lastEdited,
    String? description,
    bool? isTemplate,
  }) {
    return SurveyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      periode: periode ?? this.periode,
      lastEdited: lastEdited ?? this.lastEdited,
      description: description ?? this.description,
      isTemplate: isTemplate ?? this.isTemplate,
    );
  }

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      type: json['type'] as String,
      periode: json['periode'] as String?,
      lastEdited: json['last_edited'] != null
          ? DateTime.parse(json['last_edited'] as String)
          : DateTime.now(),
      description: json['description'] as String?,
      isTemplate: json['is_template'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'periode': periode,
      'last_edited': lastEdited.toIso8601String(),
      'description': description,
      'is_template': isTemplate,
    };
  }
}

class PeriodeModel {
  final String id;
  final String name; // e.g., "Periode 2022"
  final int year;
  final DateTime createdAt;

  PeriodeModel({
    required this.id,
    required this.name,
    required this.year,
    required this.createdAt,
  });

  PeriodeModel copyWith({
    String? id,
    String? name,
    int? year,
    DateTime? createdAt,
  }) {
    return PeriodeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
