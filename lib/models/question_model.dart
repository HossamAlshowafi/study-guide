class QuestionModel {
  final int? id;
  final String questionText;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final int majorId;

  QuestionModel({
    this.id,
    required this.questionText,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.majorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'majorId': majorId,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int?,
      questionText: map['questionText'] as String,
      option1: map['option1'] as String,
      option2: map['option2'] as String,
      option3: map['option3'] as String,
      option4: map['option4'] as String,
      majorId: map['majorId'] as int,
    );
  }

  QuestionModel copyWith({
    int? id,
    String? questionText,
    String? option1,
    String? option2,
    String? option3,
    String? option4,
    int? majorId,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      option1: option1 ?? this.option1,
      option2: option2 ?? this.option2,
      option3: option3 ?? this.option3,
      option4: option4 ?? this.option4,
      majorId: majorId ?? this.majorId,
    );
  }
}






