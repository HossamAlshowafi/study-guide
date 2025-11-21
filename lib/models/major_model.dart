class MajorModel {
  final int? id;
  final String name;
  final String description;
  final String requirements;
  final String careers;
  final String imagePath;
  final String planLink;
  final int displayOrder;

  MajorModel({
    this.id,
    required this.name,
    required this.description,
    required this.requirements,
    required this.careers,
    required this.imagePath,
    required this.planLink,
    this.displayOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'requirements': requirements,
      'careers': careers,
      'imagePath': imagePath,
      'planLink': planLink,
      'displayOrder': displayOrder,
    };
  }

  factory MajorModel.fromMap(Map<String, dynamic> map) {
    return MajorModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      requirements: map['requirements'] as String,
      careers: map['careers'] as String,
      imagePath: map['imagePath'] as String,
      planLink: map['planLink'] as String,
      displayOrder: map['displayOrder'] as int? ?? 0,
    );
  }

  MajorModel copyWith({
    int? id,
    String? name,
    String? description,
    String? requirements,
    String? careers,
    String? imagePath,
    String? planLink,
    int? displayOrder,
  }) {
    return MajorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      careers: careers ?? this.careers,
      imagePath: imagePath ?? this.imagePath,
      planLink: planLink ?? this.planLink,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}


