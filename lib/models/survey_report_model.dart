/// Model untuk Survey Report (untuk role head_of_unit)
/// Berisi informasi survey yang akan ditampilkan di tabel Survey Report
class SurveyReportModel {
  final int id;
  final int kindId;
  final int graduationNumber;
  final String title;
  final String? description;
  final DateTime startedAt;
  final DateTime endedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relasi dengan SurveyKind
  final String? kindName;

  SurveyReportModel({
    required this.id,
    required this.kindId,
    required this.graduationNumber,
    required this.title,
    this.description,
    required this.startedAt,
    required this.endedAt,
    this.createdAt,
    this.updatedAt,
    this.kindName,
  });

  /// From JSON (untuk API integration)
  /// Sesuai dengan SurveyTransformer dari API
  factory SurveyReportModel.fromJson(Map<String, dynamic> json) {
    return SurveyReportModel(
      id: json['id'] as int,
      kindId: json['kind_id'] as int,
      graduationNumber: json['graduation_number'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: DateTime.parse(json['ended_at'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      kindName: json['kind']?['name'] as String?,
    );
  }

  /// Copy with method
  SurveyReportModel copyWith({
    int? id,
    int? kindId,
    int? graduationNumber,
    String? title,
    String? description,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? kindName,
  }) {
    return SurveyReportModel(
      id: id ?? this.id,
      kindId: kindId ?? this.kindId,
      graduationNumber: graduationNumber ?? this.graduationNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kindName: kindName ?? this.kindName,
    );
  }
}

/// Model untuk response statistik survey
class SurveyStatisticsModel {
  final int surveyId;
  final int totalTarget;
  final int completed;
  final int notCompleted;
  
  SurveyStatisticsModel({
    required this.surveyId,
    required this.totalTarget,
    required this.completed,
    required this.notCompleted,
  });
  
  /// Progress percentage
  double get progressPercentage {
    if (totalTarget == 0) return 0.0;
    return (completed / totalTarget) * 100;
  }
  
  factory SurveyStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SurveyStatisticsModel(
      surveyId: json['survey_id'] as int,
      totalTarget: json['total_target'] as int,
      completed: json['completed'] as int,
      notCompleted: json['not_completed'] as int,
    );
  }
}

/// Model untuk Alumni Response (user yang mengisi survey)
class AlumniResponseModel {
  final int id;
  final String name;
  final String email;
  final String nim;
  final int facultyId;
  final String facultyName;
  final int majorId;
  final String majorName;
  final DateTime? completedAt;
  
  AlumniResponseModel({
    required this.id,
    required this.name,
    required this.email,
    required this.nim,
    required this.facultyId,
    required this.facultyName,
    required this.majorId,
    required this.majorName,
    this.completedAt,
  });
  
  /// Status apakah alumni sudah mengisi
  bool get hasCompleted => completedAt != null;
  
  factory AlumniResponseModel.fromJson(Map<String, dynamic> json) {
    return AlumniResponseModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      nim: json['nim'] as String,
      facultyId: json['faculty_id'] as int,
      facultyName: json['faculty_name'] as String,
      majorId: json['major_id'] as int,
      majorName: json['major_name'] as String,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
  
  AlumniResponseModel copyWith({
    int? id,
    String? name,
    String? email,
    String? nim,
    int? facultyId,
    String? facultyName,
    int? majorId,
    String? majorName,
    DateTime? completedAt,
  }) {
    return AlumniResponseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      nim: nim ?? this.nim,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      majorId: majorId ?? this.majorId,
      majorName: majorName ?? this.majorName,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
