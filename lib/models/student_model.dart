class StudentModel {
  final String id; // Student ID
  final String name;
  final int? lastResult; // majorId for latest quiz result
  final String? updatedAt; // ISO timestamp

  StudentModel({
    required this.id,
    required this.name,
    this.lastResult,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': id,
      'name': name,
      'lastResult': lastResult,
      'updatedAt': updatedAt,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['studentId'] as String,
      name: map['name'] as String,
      lastResult: map['lastResult'] as int?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  StudentModel copyWith({
    String? id,
    String? name,
    int? lastResult,
    String? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastResult: lastResult ?? this.lastResult,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


