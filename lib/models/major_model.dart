/// Model untuk Major (Program Studi) sesuai dengan API
/// Endpoint: /{panel}/majors
class MajorModel {
  final int id;
  final int departmentId;
  final String code;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Optional: untuk menampung data department dan faculty jika di-include dari API
  final String? departmentName;
  final String? facultyName;

  MajorModel({
    required this.id,
    required this.departmentId,
    required this.code,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.departmentName,
    this.facultyName,
  });

  /// Copy with method untuk update data
  MajorModel copyWith({
    int? id,
    int? departmentId,
    String? code,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? departmentName,
    String? facultyName,
  }) {
    return MajorModel(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      code: code ?? this.code,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      departmentName: departmentName ?? this.departmentName,
      facultyName: facultyName ?? this.facultyName,
    );
  }

  /// From JSON (untuk API integration)
  /// Sesuai dengan MajorTransformer dari API
  factory MajorModel.fromJson(Map<String, dynamic> json) {
    return MajorModel(
      id: json['id'] as int,
      departmentId: json['department_id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      // Jika API mengirim data department yang di-include
      departmentName: json['department'] != null
          ? json['department']['name'] as String?
          : null,
      // Jika API mengirim data faculty yang di-include (nested)
      facultyName: json['department'] != null && json['department']['faculty'] != null
          ? json['department']['faculty']['name'] as String?
          : null,
    );
  }

  /// To JSON (untuk API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'department_id': departmentId,
      'code': code,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// To JSON untuk create/update request (hanya field yang diperlukan)
  /// Sesuai dengan CreateMajorRequest dan UpdateMajorRequest
  Map<String, dynamic> toRequestJson() {
    return {
      'department_id': departmentId,
      'code': code,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'MajorModel(id: $id, code: $code, name: $name, departmentId: $departmentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MajorModel &&
        other.id == id &&
        other.code == code &&
        other.name == name &&
        other.departmentId == departmentId;
  }

  @override
  int get hashCode =>
      id.hashCode ^ code.hashCode ^ name.hashCode ^ departmentId.hashCode;
}
