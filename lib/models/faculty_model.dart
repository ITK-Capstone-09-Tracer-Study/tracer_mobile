/// Model untuk Faculty (Fakultas) sesuai dengan API
/// Endpoint: /{panel}/faculties
class FacultyModel {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FacultyModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  /// Copy with method untuk update data
  FacultyModel copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FacultyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// From JSON (untuk API integration)
  /// Sesuai dengan FacultyTransformer dari API
  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// To JSON (untuk API integration)
  /// Untuk CreateFacultyRequest dan UpdateFacultyRequest
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// To JSON untuk create/update request (hanya field yang diperlukan)
  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
    };
  }

  @override
  String toString() {
    return 'FacultyModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FacultyModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
