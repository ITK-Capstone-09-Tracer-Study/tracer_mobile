import 'survey_kind_model.dart';

class SurveyModel {
  final String id; // Kept as String for compatibility, but API uses int
  final int? dbId; // Actual database ID
  final String title;
  final String type; // 'exit_survey', 'tracer_study_1', 'skp', 'tracer_study_2'
  final String? periode; // null untuk template, 'YYYY' untuk periode
  final DateTime lastEdited;
  final String? description;
  final bool isTemplate;
  final bool isActive;
  final int? surveyKindId;
  final SurveyKindModel? kind;

  SurveyModel({
    required this.id,
    this.dbId,
    required this.title,
    required this.type,
    this.periode,
    required this.lastEdited,
    this.description,
    this.isTemplate = false,
    this.isActive = true,
    this.surveyKindId,
    this.kind,
  });

  SurveyModel copyWith({
    String? id,
    int? dbId,
    String? title,
    String? type,
    String? periode,
    DateTime? lastEdited,
    String? description,
    bool? isTemplate,
    bool? isActive,
    int? surveyKindId,
    SurveyKindModel? kind,
  }) {
    return SurveyModel(
      id: id ?? this.id,
      dbId: dbId ?? this.dbId,
      title: title ?? this.title,
      type: type ?? this.type,
      periode: periode ?? this.periode,
      lastEdited: lastEdited ?? this.lastEdited,
      description: description ?? this.description,
      isTemplate: isTemplate ?? this.isTemplate,
      isActive: isActive ?? this.isActive,
      surveyKindId: surveyKindId ?? this.surveyKindId,
      kind: kind ?? this.kind,
    );
  }

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    // Handle SurveyKind as Template
    if (json.containsKey('order') && !json.containsKey('year')) {
      return SurveyModel(
        id: 'kind_${json['id']}',
        dbId: json['id'] as int,
        title: json['name'] as String,
        type: json['name'] as String, // Use name as type for now
        periode: null,
        lastEdited: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        description: json['description'] as String?,
        isTemplate: true,
        isActive: json['is_active'] is bool 
            ? json['is_active'] as bool 
            : (json['is_active'] == 1),
        surveyKindId: json['id'] as int,
      );
    }

    // Handle Regular Survey
    final kind = json['kind'] != null ? SurveyKindModel.fromJson(json['kind']) : null;
    
    return SurveyModel(
      id: json['id'].toString(),
      dbId: json['id'] as int,
      title: json['name'] as String,
      type: kind?.name ?? json['survey_kind_id'].toString(),
      periode: json['year']?.toString(),
      lastEdited: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      description: json['description'] as String?,
      isTemplate: false,
      isActive: json['is_active'] is bool 
          ? json['is_active'] as bool 
          : (json['is_active'] == 1),
      surveyKindId: json['survey_kind_id'] as int?,
      kind: kind,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': dbId ?? id,
      'name': title,
      'survey_kind_id': surveyKindId,
      'year': periode != null ? int.tryParse(periode!) : null,
      'description': description,
      'is_active': isActive,
      'updated_at': lastEdited.toIso8601String(),
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
