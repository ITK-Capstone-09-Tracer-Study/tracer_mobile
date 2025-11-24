import 'survey_kind_model.dart';
import 'section_model.dart';

/// Model Survey sesuai dengan API structure baru
/// Menggunakan structure dari SurveyTransformer di api.json
class SurveyModel {
  final int id;
  final int kindId;
  final int graduationNumber; // Tahun angkatan
  final String title;
  final String description;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<SectionModel> sections;
  final SurveyKindModel? kind; // Relationship
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SurveyModel({
    required this.id,
    required this.kindId,
    required this.graduationNumber,
    required this.title,
    required this.description,
    required this.startedAt,
    required this.endedAt,
    this.sections = const [],
    this.kind,
    this.createdAt,
    this.updatedAt,
  });

  SurveyModel copyWith({
    int? id,
    int? kindId,
    int? graduationNumber,
    String? title,
    String? description,
    DateTime? startedAt,
    DateTime? endedAt,
    List<SectionModel>? sections,
    SurveyKindModel? kind,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SurveyModel(
      id: id ?? this.id,
      kindId: kindId ?? this.kindId,
      graduationNumber: graduationNumber ?? this.graduationNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      sections: sections ?? this.sections,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] as int,
      kindId: json['kind_id'] as int,
      graduationNumber: json['graduation_number'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: DateTime.parse(json['ended_at'] as String),
      sections: json['sections'] != null
          ? (json['sections'] as List)
              .map((s) => SectionModel.fromJson(s))
              .toList()
          : [],
      kind: json['kind'] != null 
          ? SurveyKindModel.fromJson(json['kind'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind_id': kindId,
      'graduation_number': graduationNumber,
      'title': title,
      'description': description,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }

  /// Helper untuk mendapatkan nama kind
  String get kindName => kind?.name ?? 'Unknown';
  
  /// Helper untuk format tanggal
  String get formattedStartDate {
    return '${startedAt.day}/${startedAt.month}/${startedAt.year}';
  }
  
  String get formattedEndDate {
    return '${endedAt.day}/${endedAt.month}/${endedAt.year}';
  }
}