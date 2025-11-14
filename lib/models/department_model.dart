/// Model untuk Department (Jurusan) sesuai dengan API
/// Endpoint: /{panel}/departments
class DepartmentModel {
  final int id;
  final int facultyId;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Optional: untuk menampung data faculty jika di-include dari API
  final String? facultyName;

  DepartmentModel({
    required this.id,
    required this.facultyId,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.facultyName,
  });

  /// Copy with method untuk update data
  DepartmentModel copyWith({
    int? id,
    int? facultyId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? facultyName,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      facultyName: facultyName ?? this.facultyName,
    );
  }

  /// From JSON (untuk API integration)
  /// Sesuai dengan DepartmentTransformer dari API
  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as int,
      facultyId: json['faculty_id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      // Jika API mengirim data faculty yang di-include
      facultyName: json['faculty'] != null 
          ? json['faculty']['name'] as String?
          : null,
    );
  }

  /// To JSON (untuk API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'faculty_id': facultyId,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// To JSON untuk create/update request (hanya field yang diperlukan)
  /// Sesuai dengan CreateDepartmentRequest dan UpdateDepartmentRequest
  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      'faculty_id': facultyId,
    };
  }

  @override
  String toString() {
    return 'DepartmentModel(id: $id, name: $name, facultyId: $facultyId, facultyName: $facultyName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DepartmentModel &&
        other.id == id &&
        other.name == name &&
        other.facultyId == facultyId;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ facultyId.hashCode;
}
