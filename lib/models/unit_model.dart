class UnitModel {
  final String id;
  final String name;
  final String type; // 'fakultas', 'jurusan', 'program_studi'
  final String? parentId; // untuk jurusan (parent: fakultas), program_studi (parent: jurusan)
  final String? parentName;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UnitModel({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.parentName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  UnitModel copyWith({
    String? id,
    String? name,
    String? type,
    String? parentId,
    String? parentName,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      parentId: json['parentId'] as String?,
      parentName: json['parentName'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'parentId': parentId,
      'parentName': parentName,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
